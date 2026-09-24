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

variable "path" {
  type        = string
  description = "IAM path applied to both the role and the instance profile. Useful when an organization scopes permissions boundaries, SCPs, or role-creation policies by IAM path."
  default     = "/"

  validation {
    condition     = can(regex("^/([[:print:]]*/)?$", var.path))
    error_message = "path must start and end with '/', for example \"/\" or \"/platform/\"."
  }
}

variable "max_session_duration" {
  type        = number
  description = "Maximum session duration, in seconds, for the IAM role. AWS allows 3600 (1 hour) through 43200 (12 hours)."
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "max_session_duration must be between 3600 and 43200 seconds."
  }
}

variable "permissions_boundary" {
  type        = string
  description = "Optional IAM permissions boundary policy ARN attached to the role. Caps the role's effective permissions regardless of what's granted via enable_ssm_access, enable_ecr_read_access, enable_route53_write_access, or additional_policy_arns."
  default     = null
}

variable "force_detach_policies" {
  type        = bool
  description = "Whether to force-detach any attached managed and inline policies during role deletion. Without this, Terraform (or a manual delete) fails if policies are still attached; useful in a dev environment where the role is torn down often, less commonly wanted in production."
  default     = false
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
  # A list, not a set: a set of ARNs created in the same apply has no known size
  # or order when the plan is made, so the attachments could not be keyed. A set
  # passed by a caller still converts to a list.
  type        = list(string)
  description = "Additional IAM managed policy ARNs to attach to the role."
  default     = []

  validation {
    condition = alltrue([
      for arn in var.additional_policy_arns :
      trimspace(arn) != ""
    ])

    error_message = "additional_policy_arns must contain only non-empty policy ARNs."
  }

  validation {
    condition     = length(distinct(var.additional_policy_arns)) == length(var.additional_policy_arns)
    error_message = "additional_policy_arns must not list the same policy twice."
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