# A fresh environment: the policy is created in the same apply as the role, so
# its ARN is unknown when the plan is made. terraform_data stands in for it.
resource "terraform_data" "policy" {
  input = "policy"
}

module "under_test" {
  source = "../.."

  project_name = "acme"
  environment  = "development"
  service_name = "app"

  additional_policy_arns = [terraform_data.policy.id, "arn:aws:iam::aws:policy/ReadOnlyAccess"]
}
