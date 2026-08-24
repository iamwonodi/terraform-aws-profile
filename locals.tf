################################################################################
# AWS IAM PROFILE LOCALS
################################################################################

locals {
  role_name = "${var.project_name}-${var.environment}-${var.service_name}-role"

  instance_profile_name = "${var.project_name}-${var.environment}-${var.service_name}-profile"

  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}