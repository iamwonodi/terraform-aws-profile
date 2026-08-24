################################################################################
# EC2 ASSUME ROLE POLICY
#
# Allows EC2 to assume the IAM role.
#
# This trust relationship is required because the role is attached to an
# EC2 instance through an IAM instance profile. It is also required when
# the profile is supplied to services such as EC2 Image Builder.
################################################################################

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid    = "AllowEC2ToAssumeRole"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}


################################################################################
# ROUTE 53 WRITE POLICY
#
# Creates the policy document used when Route 53 write access is enabled.
#
# The policy allows:
# - Creating, updating, and deleting records in the specified hosted zone.
# - Reading Route 53 hosted-zone and record information.
# - Checking the status of Route 53 changes.
#
# The policy document is created only when:
#
# enable_route53_write_access = true
#
# The resulting policy is attached to the IAM role by the
# aws_iam_role_policy.route53_write resource in main.tf.
################################################################################

data "aws_iam_policy_document" "route53_write" {
  count = var.enable_route53_write_access ? 1 : 0

  statement {
    sid    = "AllowRoute53RecordChanges"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets"
    ]

    resources = [
      "arn:aws:route53:::hostedzone/${var.hosted_zone_id}"
    ]
  }

  statement {
    sid    = "AllowRoute53ReadAccess"
    effect = "Allow"

    actions = [
      "route53:GetChange",
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ListResourceRecordSets"
    ]

    resources = [
      "*"
    ]
  }
}