################################################################################
# AWS IAM PROFILE
#
# Creates an IAM role and instance profile intended for EC2-based workloads.
#
# The profile can optionally provide:
#
# - AWS Systems Manager access
# - Amazon ECR read access
# - Route53 write access
# - Additional caller-supplied managed policies
#
# The resulting instance profile can be attached to EC2 instances and AWS
# services such as EC2 Image Builder that require an EC2 instance profile.
################################################################################



################################################################################
# IAM ROLE
#
# Creates the IAM role that will be associated with the instance profile.
################################################################################

resource "aws_iam_role" "this" {
  name = local.role_name

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  description = var.role_description

  tags = merge(
    local.common_tags,
    {
      Name = local.role_name
      Type = "EC2 IAM Role"
    }
  )
}


################################################################################
# SSM ACCESS
#
# Provides the standard AWS managed policy required for common Systems Manager
# functionality on EC2 instances.
#
# This allows workloads using the profile to participate in Systems Manager
# without requiring the caller to manually attach the policy.
################################################################################

resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.enable_ssm_access ? 1 : 0

  role = aws_iam_role.this.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


################################################################################
# ECR READ ACCESS
#
# Provides read-only access to Amazon Elastic Container Registry.
#
# This is useful for EC2 workloads that need to authenticate to ECR and pull
# private container images.
################################################################################

resource "aws_iam_role_policy_attachment" "ecr_read" {
  count = var.enable_ecr_read_access ? 1 : 0

  role = aws_iam_role.this.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


################################################################################
# ROUTE53 WRITE ACCESS

# The policy intentionally does not grant unrestricted access to unrelated AWS ROUTE53
# services.
################################################################################


resource "aws_iam_role_policy" "route53_write" {
  count = var.enable_route53_write_access ? 1 : 0

  name = "${local.role_name}-route53-write"

  role = aws_iam_role.this.id

  policy = data.aws_iam_policy_document.route53_write[0].json
}


################################################################################
# ADDITIONAL MANAGED POLICIES
#
# Allows the caller to attach additional AWS managed or customer-managed IAM
# policies without requiring changes to this module.
################################################################################

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = toset(var.additional_policy_arns)

  role = aws_iam_role.this.name

  policy_arn = each.value
}


################################################################################
# IAM INSTANCE PROFILE
#
# Creates the EC2 instance profile that exposes the IAM role to EC2 instances.
#
# This is the value that can be supplied to AWS EC2 Image Builder through:
#
# instance_profile_name = module.aws_profile.instance_profile_name
################################################################################

resource "aws_iam_instance_profile" "this" {
  name = local.instance_profile_name

  role = aws_iam_role.this.name

  tags = merge(
    local.common_tags,
    {
      Name = local.instance_profile_name
      Type = "EC2 Instance Profile"
    }
  )
}