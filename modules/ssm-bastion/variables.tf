variable "name" {
  description = "リソース名のプレフィックス。各リソース名の先頭に付与されます。"
  type        = string
}

variable "vpc_id" {
  description = "EC2 インスタンスおよびセキュリティグループを配置する VPC の ID。"
  type        = string
}

variable "subnet_pri_ids" {
  description = "EC2 インスタンスを配置するプライベートサブネットの ID。少なくとも 1 つのサブネット ID を指定してください。"
  type        = list(string)

  validation {
    condition     = length(var.subnet_pri_ids) > 0
    error_message = "subnet_pri_ids には少なくとも 1 つのサブネット ID を指定してください。"
  }
}

variable "vpc_cidr_block" {
  description = "VPC の CIDR ブロック。Session Manager 用 VPC エンドポイントへの HTTPS アウトバウンド許可に使用されます。ssm_egress_cidr_blocks を指定した場合はその値が優先されます。"
  type        = string
}

variable "ssm_egress_cidr_blocks" {
  description = "SSM 接続用 HTTPS アウトバウンドを許可する CIDR リスト。VPC Interface Endpoint 利用時は null（vpc_cidr_block を使用）、NAT Gateway 利用時は [\"0.0.0.0/0\"] を指定してください。"
  type        = list(string)
  default     = null
}

variable "instance_type" {
  description = "EC2 インスタンスタイプ。DDL 用途のため無料利用枠の t3.micro を推奨します。"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "ルートブロックデバイスのサイズ（GiB）。"
  type        = number
  default     = 30
}

variable "enable_detailed_monitoring" {
  description = "EC2 の詳細モニタリングを有効にするかどうか。有効にすると追加料金が発生します。"
  type        = bool
  default     = false
}

variable "create_iam_role" {
  description = "IAM ロールおよびインスタンスプロファイルを新規作成するかどうか。false の場合は iam_instance_profile_name を指定してください。"
  type        = bool
  default     = true
}

variable "iam_instance_profile_name" {
  description = "既存の IAM インスタンスプロファイル名。create_iam_role が false の場合に必須です。"
  type        = string
  default     = null
}

variable "rds_security_group_id" {
  description = "接続先 RDS のセキュリティグループ ID。指定した場合、EC2 SG から当該 RDS SG への PostgreSQL アウトバウンドルールが追加されます。"
  type        = string
  default     = null
}

variable "rds_port" {
  description = "RDS への接続ポート番号。PostgreSQL のデフォルトは 5432 です。"
  type        = number
  default     = 5432
}

variable "tags" {
  description = "各リソースに付与するタグのマップ。"
  type        = map(string)
  default     = {}
}
