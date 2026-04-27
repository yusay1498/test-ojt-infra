module "ssm_bastion" {
  source = "./modules/ssm-bastion"

  name                       = local.name
  subnet_pri_ids             = var.subnet_pri_ids
  security_group_ids         = var.security_group_ids
  instance_type              = var.instance_type
  root_volume_size           = var.root_volume_size
  enable_detailed_monitoring = var.enable_detailed_monitoring
  create_iam_role            = var.create_iam_role
  iam_instance_profile_name  = var.iam_instance_profile_name

  tags = local.tags
}
