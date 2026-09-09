
module "aws_profile" {
  source = "../../"

  project_name = var.project_name
  environment  = var.environment
  service_name = var.service_name

  role_description = var.role_description

  # Scopes the role and instance profile under an IAM path -- useful when an
  # org restricts role creation or attaches permissions boundaries by path.
  # "/" (the default) is fine for most setups; shown here just to
  # demonstrate the option.
  path = "/platform/"

  # Caps the role's effective permissions regardless of what's granted
  # below -- recommended whenever the role might end up with broad access.
  permissions_boundary = var.permissions_boundary

  enable_ssm_access           = var.enable_ssm_access
  enable_ecr_read_access      = var.enable_ecr_read_access
  enable_route53_write_access = var.enable_route53_write_access

  hosted_zone_id = var.hosted_zone_id

  additional_policy_arns = var.additional_policy_arns

  tags = var.tags
}

