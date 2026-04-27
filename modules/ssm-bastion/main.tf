# ------------------------------------------------------------
# AMI: Amazon Linux 2023 (最新)
# ------------------------------------------------------------
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ------------------------------------------------------------
# IAM: Session Manager 用ロール・インスタンスプロファイル
# create_iam_role = false の場合はスキップ
# ------------------------------------------------------------
data "aws_iam_policy_document" "assume_role" {
  count = var.create_iam_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create_iam_role ? 1 : 0

  name               = "${var.name}-ssm-bastion"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.create_iam_role ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_role ? 1 : 0

  name = "${var.name}-ssm-bastion"
  role = aws_iam_role.this[0].name

  tags = var.tags
}

# ------------------------------------------------------------
# EC2: SSM 経由アクセス用踏み台インスタンス
# - パブリック IP なし・キーペアなし（Session Manager 経由のみ）
# - IMDSv2 必須
# - EBS 暗号化有効
# ------------------------------------------------------------
resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_pri_ids[0]
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.create_iam_role ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile_name
  associate_public_ip_address = false
  monitoring                  = var.enable_detailed_monitoring
  ebs_optimized               = true

  # IMDSv2 を強制（セキュリティベストプラクティス）
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = var.root_volume_size

    tags = var.tags
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.create_iam_role || var.iam_instance_profile_name != null
      error_message = "create_iam_role = false の場合、iam_instance_profile_name に既存のインスタンスプロファイル名を指定してください。"
    }
  }
}
