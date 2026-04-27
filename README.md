AWS Terraform Module Template
================================================================================

このリポジトリはTerraformの研修で使用するディレクトリのベースとして使います。

使用する際は以下コマンドを使用し、デプロイの対象となるモジュールまで移動させてください。

```bash
git clone https://github.com/yusay1498/aws-terraform-template.git

rm -rf ./aws-terraform-template/.git

rm -rf ./aws-terraform-template/.github

mv ./aws-terraform-template {移動させたいディレクトリパス}
```

以下に、デプロイ手順なども載っているのでご確認ください。

Introduction
--------------------------------------------------------------------------------

Ensure to read follows first.

- (en) https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/structure.html
- (ja) https://docs.aws.amazon.com/ja_jp/prescriptive-guidance/latest/terraform-aws-provider-best-practices/structure.html


Deployment steps
--------------------------------------------------------------------------------

### Step1. Configure tfvars

Edit `envs/${env_name}/terraform.tfvars`

```
container_api_count = 0
```

### Step2. Login using awscli

With MFA. (`AWS_STS_PROFILE` is optional.)

```bash
AWS_STS_PROFILE=${profile} \
AWS_STS_MFA_DEVICE_ARN=${mfa_device_arn} \
source ./helpers/aws_login_mfa.sh
```

With MFA and assume-role. (`AWS_STS_PROFILE` is optional.)

```bash
AWS_STS_PROFILE=${profile} \
AWS_STS_ROLE_ARN=${assume_role_arn} \
AWS_STS_MFA_DEVICE_ARN=${mfa_device_arn} \
source ./helpers/aws_login_mfa_assume.sh
```

### Step3. Deploy resources

```bash
terraform init -reconfigure -backend-config=./envs/${env_name}/config.s3.tfbackend

terraform plan -var-file=./envs/${env_name}/terraform.tfvars

terraform apply -var-file=./envs/${env_name}/terraform.tfvars
```

### Step4. Deploy container image

Upload container image to deployed ECR repositories.

```bash
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${account}.dkr.ecr.ap-northeast-1.amazonaws.com

docker build -t ${image_name} .

docker tag ${image_name}:latest ${account}.dkr.ecr.ap-northeast-1.amazonaws.com/${image_name}:latest

docker push ${account}.dkr.ecr.ap-northeast-1.amazonaws.com/${image_name}:latest
```

### Step5. Re-configure tfvars

Edit `envs/${env_name}/terraform.tfvars`

```
# Set value greater than or equal to 1.
container_api_count = 1
```

### Step6. Re-deploy resources

```bash
terraform plan -var-file=./envs/${env_name}/terraform.tfvars

terraform apply -var-file=./envs/${env_name}/terraform.tfvars
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ssm_bastion"></a> [ssm\_bastion](#module\_ssm\_bastion) | ./modules/ssm-bastion | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_subnet_pri_ids"></a> [subnet\_pri\_ids](#input\_subnet\_pri\_ids) | EC2 インスタンスを配置するプライベートサブネットの ID。 | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | VPC の CIDR ブロック。Session Manager 用 VPC エンドポイントへの HTTPS アウトバウンド許可に使用されます。 | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | EC2 インスタンスおよびセキュリティグループを配置する VPC の ID。 | `string` | n/a | yes |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | IAM ロールおよびインスタンスプロファイルを新規作成するかどうか。false の場合は iam\_instance\_profile\_name を指定してください。 | `bool` | `true` | no |
| <a name="input_enable_detailed_monitoring"></a> [enable\_detailed\_monitoring](#input\_enable\_detailed\_monitoring) | EC2 の詳細モニタリングを有効にするかどうか。 | `bool` | `false` | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | 既存の IAM インスタンスプロファイル名。create\_iam\_role が false の場合に必須です。 | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 インスタンスタイプ。 | `string` | `"t3.micro"` | no |
| <a name="input_rds_port"></a> [rds\_port](#input\_rds\_port) | RDS への接続ポート番号。PostgreSQL のデフォルトは 5432 です。 | `number` | `5432` | no |
| <a name="input_rds_security_group_id"></a> [rds\_security\_group\_id](#input\_rds\_security\_group\_id) | 接続先 RDS のセキュリティグループ ID。指定した場合、EC2 SG から当該 RDS SG への PostgreSQL アウトバウンドルールが追加されます。 | `string` | `null` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | ルートブロックデバイスのサイズ（GiB）。 | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssm_bastion_iam_role_arn"></a> [ssm\_bastion\_iam\_role\_arn](#output\_ssm\_bastion\_iam\_role\_arn) | SSM 踏み台 EC2 の IAM ロール ARN。create\_iam\_role が false の場合は null。 |
| <a name="output_ssm_bastion_instance_id"></a> [ssm\_bastion\_instance\_id](#output\_ssm\_bastion\_instance\_id) | SSM 踏み台 EC2 インスタンスの ID。 |
| <a name="output_ssm_bastion_security_group_id"></a> [ssm\_bastion\_security\_group\_id](#output\_ssm\_bastion\_security\_group\_id) | SSM 踏み台 EC2 のセキュリティグループ ID。接続先リソースのインバウンドルール設定に使用してください。 |
<!-- END_TF_DOCS -->