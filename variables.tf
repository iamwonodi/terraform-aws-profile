################################################################################
# CORE IDENTIFICATION
################################################################################

variable "project_name" {
  type        = string
  description = "Project name used to identify the IAM role and instance profile."

  validation {
    condition     = trimspace(var.project_name) != ""
    error_message = "project_name must not be empty."
  }
}


variable "environment" {
  type        = string
  description = "Environment associated with the IAM role and instance profile."

  validation {
    condition     = trimspace(var.environment) != ""
    error_message = "environment must not be empty."
  }
}

variable "service_name" {
  type        = string
  description = "Service name used to construct the IAM role and EC2 instance profile names."

  validation {
    condition     = trimspace(var.service_name) != ""
    error_message = "service_name must not be empty."
  }
}


################################################################################
# IAM NAMING
################################################################################


variable "role_description" {
  type        = string
  description = "Description assigned to the IAM role."
  default     = "IAM role for EC2-based workloads."
}


################################################################################
# MANAGED ACCESS OPTIONS
################################################################################

variable "enable_ssm_access" {
  type        = bool
  description = "Whether to attach AmazonSSMManagedInstanceCore to the IAM role."
  default     = false
}


variable "enable_ecr_read_access" {
  type        = bool
  description = "Whether to attach AmazonEC2ContainerRegistryReadOnly to the IAM role."
  default     = false
}


################################################################################
# ROUTE53 ACCESS
################################################################################

variable "enable_route53_write_access" {
  type        = bool
  description = "Whether to grant the IAM role permission to modify Route53 records in the specified hosted zones."
  default     = false
}


variable "hosted_zone_id" {
  type        = string
  description = "Route 53 hosted zone ID to which the instance may write records when Route 53 access is enabled."

  default = null

  validation {
    condition = (
      !var.enable_route53_write_access ||
      (
        var.hosted_zone_id != null &&
        trimspace(var.hosted_zone_id) != ""
      )
    )

    error_message = "hosted_zone_id must be provided when enable_route53_write_access is true."
  }
}


################################################################################
# ADDITIONAL POLICIES
################################################################################

variable "additional_policy_arns" {
  type        = set(string)
  description = "Additional IAM managed policy ARNs to attach to the role."
  default     = []

  validation {
    condition = alltrue([
      for arn in var.additional_policy_arns :
      trimspace(arn) != ""
    ])

    error_message = "additional_policy_arns must contain only non-empty policy ARNs."
  }
}


################################################################################
# TAGGING
################################################################################

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to the IAM role and instance profile."
  default     = {}
}