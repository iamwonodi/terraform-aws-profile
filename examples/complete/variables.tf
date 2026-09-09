
variable "project_name" {
  type        = string
  description = "Project identifier used when naming the IAM role and instance profile."
  default     = "blueprints"
}

variable "environment" {
  type        = string
  description = "Deployment environment used when naming the IAM role and instance profile."
  default     = "development"
}

variable "service_name" {
  type        = string
  description = "Service identifier used when naming the IAM role and instance profile."
  default     = "example"
}

variable "role_description" {
  type        = string
  description = "Description assigned to the IAM role."
  default     = "IAM role for an EC2-based workload."
}

variable "enable_ssm_access" {
  type        = bool
  description = "Whether to attach the AWS managed Systems Manager policy."
  default     = true
}

variable "enable_ecr_read_access" {
  type        = bool
  description = "Whether to attach the AWS managed ECR read-only policy."
  default     = false
}

variable "enable_route53_write_access" {
  type        = bool
  description = "Whether to create the scoped Route 53 write policy."
  default     = false
}

variable "hosted_zone_id" {
  type        = string
  description = "Route 53 hosted zone ID that receives record-management permissions."
  default     = ""
}

variable "additional_policy_arns" {
  type        = list(string)
  description = "Additional AWS managed or customer-managed policy ARNs to attach to the IAM role."
  default     = []
}

variable "permissions_boundary" {
  description = "Optional IAM permissions boundary policy ARN."
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to the IAM role and instance profile."

  default = {
    ManagedBy = "Terraform"
    Module    = "terraform-aws-profile"
  }
}
