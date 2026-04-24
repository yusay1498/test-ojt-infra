output "rds_bastion_instance_id" {
  description = "RDS 踏み台 EC2 インスタンスの ID。"
  value       = module.rds_bastion.instance_id
}

output "rds_bastion_security_group_id" {
  description = "RDS 踏み台 EC2 のセキュリティグループ ID。RDS のインバウンドルール設定に使用してください。"
  value       = module.rds_bastion.security_group_id
}

output "rds_bastion_iam_role_arn" {
  description = "RDS 踏み台 EC2 の IAM ロール ARN。create_iam_role が false の場合は null。"
  value       = module.rds_bastion.iam_role_arn
}
