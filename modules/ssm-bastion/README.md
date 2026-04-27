# ssm-bastion

Session Manager 経由でプライベートサブネット内のリソースにアクセスするための EC2 踏み台インスタンスモジュールです。

## 概要

- **EC2 インスタンス**: Amazon Linux 2023、プライベートサブネット配置、パブリック IP なし・キーペアなし
- **接続方式**: AWS Systems Manager Session Manager（インバウンド不要）
- **IAM**: `AmazonSSMManagedInstanceCore` マネージドポリシー付き IAM ロール（新規作成 or 既存利用を選択可能）
- **セキュリティグループ**: インバウンドなし。アウトバウンドは HTTPS（SSM VPC エンドポイント向け）と任意のバックエンドリソース（RDS 等）のみ
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
module "ssm_bastion" {
  source = "./modules/ssm-bastion"

  name                  = "myapp-dev"
  vpc_id                = "vpc-xxxxxxxxxxxxxxxxx"
  subnet_pri_ids        = ["subnet-xxxxxxxxxxxxxxxxx"]
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
  source_security_group_id = module.ssm_bastion.security_group_id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description              = "Allow PostgreSQL from SSM bastion EC2"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.amazon_linux_2023](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | リソース名のプレフィックス。各リソース名の先頭に付与されます。 | `string` | n/a | yes |
| <a name="input_subnet_pri_ids"></a> [subnet\_pri\_ids](#input\_subnet\_pri\_ids) | EC2 インスタンスを配置するプライベートサブネットの ID。少なくとも 1 つのサブネット ID を指定してください。 | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | VPC の CIDR ブロック。Session Manager 用 VPC エンドポイントへの HTTPS アウトバウンド許可に使用されます。ssm\_egress\_cidr\_blocks を指定した場合はその値が優先されます。 | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | EC2 インスタンスおよびセキュリティグループを配置する VPC の ID。 | `string` | n/a | yes |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | IAM ロールおよびインスタンスプロファイルを新規作成するかどうか。false の場合は iam\_instance\_profile\_name を指定してください。 | `bool` | `true` | no |
| <a name="input_enable_detailed_monitoring"></a> [enable\_detailed\_monitoring](#input\_enable\_detailed\_monitoring) | EC2 の詳細モニタリングを有効にするかどうか。有効にすると追加料金が発生します。 | `bool` | `false` | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | 既存の IAM インスタンスプロファイル名。create\_iam\_role が false の場合に必須です。 | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 インスタンスタイプ。DDL 用途のため無料利用枠の t3.micro を推奨します。 | `string` | `"t3.micro"` | no |
| <a name="input_rds_port"></a> [rds\_port](#input\_rds\_port) | RDS への接続ポート番号。PostgreSQL のデフォルトは 5432 です。 | `number` | `5432` | no |
| <a name="input_rds_security_group_id"></a> [rds\_security\_group\_id](#input\_rds\_security\_group\_id) | 接続先 RDS のセキュリティグループ ID。指定した場合、EC2 SG から当該 RDS SG への PostgreSQL アウトバウンドルールが追加されます。 | `string` | `null` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | ルートブロックデバイスのサイズ（GiB）。 | `number` | `30` | no |
| <a name="input_ssm_egress_cidr_blocks"></a> [ssm\_egress\_cidr\_blocks](#input\_ssm\_egress\_cidr\_blocks) | SSM 接続用 HTTPS アウトバウンドを許可する CIDR リスト。VPC Interface Endpoint 利用時は null（vpc\_cidr\_block を使用）、NAT Gateway 利用時は ["0.0.0.0/0"] を指定してください。 | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | 各リソースに付与するタグのマップ。 | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#output\_iam\_instance\_profile\_name) | EC2 インスタンスにアタッチされた IAM インスタンスプロファイル名。 |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | EC2 インスタンスにアタッチされた IAM ロールの ARN。create\_iam\_role が false の場合は null。 |
| <a name="output_instance_arn"></a> [instance\_arn](#output\_instance\_arn) | SSM 踏み台 EC2 インスタンスの ARN。 |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | SSM 踏み台 EC2 インスタンスの ID。 |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | EC2 インスタンスにアタッチされたセキュリティグループの ID。RDS のインバウンドルール設定に使用してください。 |
<!-- END_TF_DOCS -->
