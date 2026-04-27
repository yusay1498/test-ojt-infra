output "instance_id" {
  description = "SSM 踏み台 EC2 インスタンスの ID。"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "SSM 踏み台 EC2 インスタンスの ARN。"
  value       = aws_instance.this.arn
}

output "iam_role_arn" {
  description = "EC2 インスタンスにアタッチされた IAM ロールの ARN。create_iam_role が false の場合は null。"
  value       = var.create_iam_role ? aws_iam_role.this[0].arn : null
}

output "iam_instance_profile_name" {
  description = "EC2 インスタンスにアタッチされた IAM インスタンスプロファイル名。"
  value       = var.create_iam_role ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile_name
}
