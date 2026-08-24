# AWS IAM Profile

Terraform module for creating an AWS IAM role and EC2 instance profile for EC2-based workloads and services such as AWS EC2 Image Builder.

The module provides commonly required permissions as optional features while allowing the caller to attach additional managed IAM policies when required.

## Features

* Creates an IAM role with an EC2 trust relationship.
* Creates an EC2 instance profile.
* Optional AWS Systems Manager access.
* Optional Amazon ECR read access.
* Optional Route 53 record-management access.
* Optional caller-supplied managed IAM policies.
* Route 53 permissions can be restricted to a specific hosted zone.
* Consistent resource naming based on project, environment, and service.
* Supports additional tags supplied by the caller.

## Architecture

The module creates the following resources:

```text
IAM Role
   |
   +-- EC2 Assume Role Policy
   |
   +-- Optional SSM Managed Policy
   |
   +-- Optional ECR Read Policy
   |
   +-- Optional Route 53 Inline Policy
   |
   +-- Optional Additional Managed Policies
   |
   v
EC2 Instance Profile
```

The resulting instance profile can be attached to EC2 instances or services that require an EC2 instance profile.

For example, AWS EC2 Image Builder can use the generated profile for its temporary build instance.

## Naming

The module does not require the caller to provide arbitrary role or profile names.

Names are generated consistently from:

```text
project_name-environment-service_name-role
project_name-environment-service_name-profile
```

For example:

```text
blueprints-development-ami-builder-role
blueprints-development-ami-builder-profile
```

This provides predictable naming when the module is consumed by larger infrastructure modules.

## IAM Permissions

### EC2 Trust Relationship

The generated role trusts the EC2 service:

```text
ec2.amazonaws.com
```

This allows the role to be exposed to EC2-based workloads through the instance profile.

### Systems Manager Access

Enable with:

```hcl
enable_ssm_access = true
```

The module attaches the AWS managed policy:

```text
AmazonSSMManagedInstanceCore
```

This is appropriate for workloads that need to register with and communicate through AWS Systems Manager.

### ECR Read Access

Enable with:

```hcl
enable_ecr_read_access = true
```

The module attaches:

```text
AmazonEC2ContainerRegistryReadOnly
```

This allows the workload to authenticate with Amazon ECR and pull container images without granting ECR write permissions.

### Route 53 Write Access

Enable with:

```hcl
enable_route53_write_access = true
```

The caller must also provide:

```hcl
hosted_zone_id = "Z0123456789EXAMPLE"
```

The module creates an inline policy allowing:

```text
route53:ChangeResourceRecordSets
```

against the specified hosted zone.

The policy also allows the Route 53 read operations required to identify hosted zones, record sets, and change status.

The write permission is restricted to:

```text
arn:aws:route53:::hostedzone/<hosted-zone-id>
```

This prevents the role from modifying records in unrelated hosted zones.

### Additional Managed Policies

The caller can supply additional managed policy ARNs through:

```hcl
additional_policy_arns = []
```

Example:

```hcl
additional_policy_arns = [
  "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
]
```

This allows the module to remain reusable without requiring a new module release whenever a workload needs another managed policy.

## Example Usage

```hcl
module "aws_profile" {
  source = "git::https://github.com/iamwonodi/terraform-aws-profile.git?ref=v1.0.0"

  project_name  = "blueprints"
  environment   = "development"
  service_name  = "ami-builder"
  role_description = "IAM profile used by AWS EC2 Image Builder."

  enable_ssm_access         = true
  enable_ecr_read_access    = true
  enable_route53_write_access = false

  hosted_zone_id = ""

  additional_policy_arns = []

  tags = {
    ManagedBy = "Terraform"
    Module    = "terraform-aws-profile"
  }
}
```

## Using the Instance Profile

The module exposes the instance profile name:

```hcl
module.aws_profile.instance_profile_name
```

For AWS EC2 Image Builder:

```hcl
instance_profile_name = module.aws_profile.instance_profile_name
```

The generated profile therefore becomes the bridge between the IAM role and the EC2-based service.

## Route 53 Example

```hcl
module "dns_profile" {
  source = "git::https://github.com/iamwonodi/terraform-aws-profile.git?ref=v1.0.0"

  project_name = "blueprints"
  environment  = "production"
  service_name = "dns-manager"

  enable_route53_write_access = true

  hosted_zone_id = "Z0123456789EXAMPLE"

  tags = {
    ManagedBy = "Terraform"
    Module    = "terraform-aws-profile"
  }
}
```

## Inputs

| Name                          | Type           | Default         | Description                                             |
| ----------------------------- | -------------- | --------------- | ------------------------------------------------------- |
| `project_name`                | `string`       | `"example"`     | Project identifier used in resource naming.             |
| `environment`                 | `string`       | `"development"` | Deployment environment used in resource naming.         |
| `service_name`                | `string`       | required        | Service identifier used in resource naming.             |
| `role_description`            | `string`       | module default  | Description assigned to the IAM role.                   |
| `enable_ssm_access`           | `bool`         | `false`         | Whether to attach `AmazonSSMManagedInstanceCore`.       |
| `enable_ecr_read_access`      | `bool`         | `false`         | Whether to attach `AmazonEC2ContainerRegistryReadOnly`. |
| `enable_route53_write_access` | `bool`         | `false`         | Whether to create the Route 53 write policy.            |
| `hosted_zone_id`              | `string`       | `""`            | Route 53 hosted zone receiving write permissions.       |
| `additional_policy_arns`      | `list(string)` | `[]`            | Additional managed policy ARNs attached to the role.    |
| `tags`                        | `map(string)`  | `{}`            | Additional tags applied to module resources.            |

## Outputs

| Name                    | Description                                 |
| ----------------------- | ------------------------------------------- |
| `role_name`             | Name of the IAM role created by the module. |
| `role_arn`              | ARN of the IAM role.                        |
| `instance_profile_name` | Name of the EC2 instance profile.           |
| `instance_profile_arn`  | ARN of the EC2 instance profile.            |

## Requirements

* Terraform `>= 1.6.0`
* AWS provider `>= 6.0, < 7.0`

## Security Considerations

Enable only the permissions required by the workload.

For example, a workload that only needs Systems Manager should use:

```hcl
enable_ssm_access = true
```

and leave unrelated permissions disabled.

Avoid using broad policies such as:

```text
AdministratorAccess
```

unless the workload genuinely requires administrator-level access.

For Route 53, always provide the specific hosted zone ID rather than granting unrestricted Route 53 write permissions.

## Complete Example

A complete working example is available under:

```text
examples/complete/
```

The example contains:

```text
examples/
└── complete/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```
