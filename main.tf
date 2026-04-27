module "ssm_bastion" {
  source = "./modules/ssm-bastion"

  name                       = local.name
  vpc_id                     = var.vpc_id
  subnet_id                  = var.subnet_id
  vpc_cidr_block             = var.vpc_cidr_block
  instance_type              = var.instance_type
  root_volume_size           = var.root_volume_size
  enable_detailed_monitoring = var.enable_detailed_monitoring
  create_iam_role            = var.create_iam_role
  iam_instance_profile_name  = var.iam_instance_profile_name
  rds_security_group_id      = var.rds_security_group_id
  rds_port                   = var.rds_port

  tags = local.tags
}
