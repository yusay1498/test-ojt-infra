# rds-bastion

Session Manager 経由で RDS（PostgreSQL）に DDL を実行するための EC2 踏み台インスタンスモジュールです。

## 概要

- **EC2 インスタンス**: Amazon Linux 2023、プライベートサブネット配置、パブリック IP なし・キーペアなし
- **接続方式**: AWS Systems Manager Session Manager（インバウンド不要）
- **IAM**: `AmazonSSMManagedInstanceCore` マネージドポリシー付き IAM ロール（新規作成 or 既存利用を選択可能）
- **セキュリティグループ**: インバウンドなし。アウトバウンドは HTTPS（SSM VPC エンドポイント向け）と PostgreSQL（RDS 向け）のみ
- **IMDSv2**: 必須設定済み
- **EBS**: 暗号化有効

## 前提条件

Session Manager がプライベートサブネットで動作するには、以下のいずれかが必要です。

| 方式                            | 説明                                                                                                                                   |
| ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **VPC Interface Endpoints（推奨）** | `com.amazonaws.<region>.ssm`、`com.amazonaws.<region>.ssmmessages`、`com.amazonaws.<region>.ec2messages` の 3 エンドポイントを VPC に作成してください。セキュアでコスト最適です。 |
| **NAT Gateway**                 | パブリックサブネットに NAT Gateway を配置することでも動作します。                                                                      |

## 使用例

```hcl
module "rds_bastion" {
  source = "./modules/rds-bastion"

  name                  = "myapp-dev"
  vpc_id                = "vpc-xxxxxxxxxxxxxxxxx"
  subnet_id             = "subnet-xxxxxxxxxxxxxxxxx"
  vpc_cidr_block        = "10.0.0.0/16"
  rds_security_group_id = "sg-xxxxxxxxxxxxxxxxx"

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

## RDS セキュリティグループへの設定

このモジュールが出力する `security_group_id` を RDS のインバウンドルールに設定してください。

```hcl
resource "aws_security_group_rule" "rds_from_bastion" {
  type                     = "ingress"
  security_group_id        = "<rds_security_group_id>"
  source_security_group_id = module.rds_bastion.security_group_id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description              = "Allow PostgreSQL from RDS bastion EC2"
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
