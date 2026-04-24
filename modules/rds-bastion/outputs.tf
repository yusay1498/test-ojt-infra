output "instance_id" {
  description = "RDS 踏み台 EC2 インスタンスの ID。"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "RDS 踏み台 EC2 インスタンスの ARN。"
  value       = aws_instance.this.arn
}

output "security_group_id" {
  description = "EC2 インスタンスにアタッチされたセキュリティグループの ID。RDS のインバウンドルール設定に使用してください。"
  value       = aws_security_group.this.id
}

output "iam_role_arn" {
  description = "EC2 インスタンスにアタッチされた IAM ロールの ARN。create_iam_role が false の場合は null。"
  value       = var.create_iam_role ? aws_iam_role.this[0].arn : null
}

output "iam_instance_profile_name" {
  description = "EC2 インスタンスにアタッチされた IAM インスタンスプロファイル名。"
  value       = local.iam_instance_profile_name
}
