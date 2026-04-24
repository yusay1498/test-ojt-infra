locals {
  iam_instance_profile_name = var.create_iam_role ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile_name
}

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

  name               = "${var.name}-rds-bastion"
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

  name = "${var.name}-rds-bastion"
  role = aws_iam_role.this[0].name

  tags = var.tags
}

# ------------------------------------------------------------
# Security Group: インバウンドなし・アウトバウンド最小限
# Session Manager はインバウンド不要
# アウトバウンド:
#   - HTTPS (443) → VPC CIDR (SSM VPC エンドポイント向け)
#   - PostgreSQL (rds_port) → RDS セキュリティグループ (rds_security_group_id 指定時)
# ------------------------------------------------------------
resource "aws_security_group" "this" {
  name        = "${var.name}-rds-bastion"
  description = "Security group for RDS bastion EC2 instance. No inbound rules. Outbound restricted to SSM endpoints and RDS."
  vpc_id      = var.vpc_id

  egress {
    description = "Allow HTTPS to VPC CIDR for SSM VPC endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  dynamic "egress" {
    for_each = var.rds_security_group_id != null ? [var.rds_security_group_id] : []

    content {
      description     = "Allow PostgreSQL traffic to RDS security group"
      from_port       = var.rds_port
      to_port         = var.rds_port
      protocol        = "tcp"
      security_groups = [egress.value]
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------
# EC2: RDS DDL 用踏み台インスタンス
# - パブリック IP なし・キーペアなし（Session Manager 経由のみ）
# - IMDSv2 必須
# - EBS 暗号化有効
# ------------------------------------------------------------
resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  iam_instance_profile        = local.iam_instance_profile_name
  associate_public_ip_address = false
  monitoring                  = var.enable_detailed_monitoring

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
