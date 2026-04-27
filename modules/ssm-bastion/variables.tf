variable "name" {
  description = "リソース名のプレフィックス。各リソース名の先頭に付与されます。"
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

variable "security_group_ids" {
  description = "EC2 インスタンスにアタッチするセキュリティグループの ID リスト。開発チームが管理する既存のセキュリティグループ（デフォルト SG 等）の ID を指定してください。"
  type        = list(string)
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

variable "tags" {
  description = "各リソースに付与するタグのマップ。"
  type        = map(string)
  default     = {}
}
