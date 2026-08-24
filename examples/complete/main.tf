
module "aws_profile" {
  source = "git::https://github.com/iamwonodi/terraform-aws-profile.git?ref=v1.0.0"

  project_name = var.project_name
  environment  = var.environment
  service_name = var.service_name

  role_description = var.role_description

  enable_ssm_access           = var.enable_ssm_access
  enable_ecr_read_access      = var.enable_ecr_read_access
  enable_route53_write_access = var.enable_route53_write_access

  hosted_zone_id = var.hosted_zone_id

  additional_policy_arns = var.additional_policy_arns

  tags = var.tags
}

