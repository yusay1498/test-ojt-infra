output "ssm_bastion_instance_id" {
  description = "SSM 踏み台 EC2 インスタンスの ID。"
  value       = module.ssm_bastion.instance_id
}

output "ssm_bastion_iam_role_arn" {
  description = "SSM 踏み台 EC2 の IAM ロール ARN。create_iam_role が false の場合は null。"
  value       = module.ssm_bastion.iam_role_arn
}
