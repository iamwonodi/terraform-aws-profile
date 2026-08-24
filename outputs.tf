################################################################################
# IAM ROLE
################################################################################

output "role_name" {
  description = "Name of the IAM role created by the module."
  value       = aws_iam_role.this.name
}


output "role_arn" {
  description = "ARN of the IAM role created by the module."
  value       = aws_iam_role.this.arn
}


################################################################################
# IAM INSTANCE PROFILE
################################################################################

output "instance_profile_name" {
  description = "Name of the IAM instance profile created by the module."
  value       = aws_iam_instance_profile.this.name
}


output "instance_profile_arn" {
  description = "ARN of the IAM instance profile created by the module."
  value       = aws_iam_instance_profile.this.arn
}