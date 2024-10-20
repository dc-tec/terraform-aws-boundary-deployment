<!-- BEGIN_TF_DOCS -->
# Terraform AWS Boundary Deployment Module

This Terraform module deploys HashiCorp Boundary on AWS, providing a secure and scalable solution for managing access to dynamic infrastructure.

## Features

- Deploys Boundary controllers and workers in Auto Scaling Groups
- Sets up a PostgreSQL RDS instance for Boundary's database
- Configures Application Load Balancer (ALB) and Network Load Balancer (NLB) for high availability
- Implements KMS keys for encryption
- Supports optional Route53 DNS record creation
- Allows for ACM or self-signed TLS certificates
- Integrates with AWS Systems Manager (SSM) for secure instance management
- Configures CloudWatch logging (optional)

## Prerequisites

- Terraform 1.4.7 or later
- AWS account and credentials
- VPC with public and private subnets

## Usage

Please see the [examples](./examples) directory for examples on how to use this module.

## Security Considerations

- Database credentials are securely managed and not exposed in plain text
- KMS keys are used for encryption of sensitive data
- Security groups are configured to restrict access to necessary ports only
- IAM roles and policies follow the principle of least privilege
- SSM integration allows for secure instance management without exposing SSH ports
- CloudWatch logging can be enabled for audit and troubleshooting purposes

## Customization

The module supports various customization options through variables, including:

- Instance types for controllers and workers
- Database configuration
- Auto Scaling Group settings
- Logging preferences
- SSH access (if required)
- SSM access (if required)

Refer to the [module documentation](./MODULE\_DOCS.md) file for all available options.

## Outputs

The module provides several outputs, including:

- ALB DNS name
- NLB DNS name
- Controller and worker security group IDs
- KMS key ARNs

These outputs can be used for further configuration or to provide access information to users.

## After deployment

After succesfuly deploying Boundary, you will need to "initialize" Boundary. The easiest way to do this is by using the following Terraform module

## Contributing

Contributions to this module are welcome. Please ensure that you update tests and documentation with any changes.

## License

This module is licensed under the MIT License. See the LICENSE

## Module Documentation

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.70.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.acm_boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate.boundary_api_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.acm_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_autoscaling_group.boundary_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_group.boundary_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_log_group.boundary_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.boundary_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_db_instance.boundary_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.boundary_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_eip.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_access_key.boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_group.boundary_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_membership.boundary_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_membership) | resource |
| [aws_iam_group_policy.boundary_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy) | resource |
| [aws_iam_instance_profile.boundary_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_instance_profile.boundary_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.boundary_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.boundary_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.boundary_controller_secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.boundary_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.cloudwatch_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.cloudwatch_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ssm_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ssm_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_user.boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.boundary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_kms_alias.boundary_recovery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.boundary_root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.boundary_worker_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.boundary_recovery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.boundary_root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.boundary_worker_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_launch_template.boundary_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_launch_template.boundary_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb.boundary_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb.boundary_nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.boundary_lb_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.boundary_lb_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.boundary_lb_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.boundary_lb_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_nat_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route53_record.acm_dns_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.www](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_secretsmanager_secret.boundary_api_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.boundary_api_cert_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.boundary_db_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.boundary_api_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.boundary_db_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.boundary_self_signed_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.boundary_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.boundary_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.boundary_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.boundary_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_9201_boundary_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_9201_boundary_workers_direct](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_egress_boundary_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_egress_boundary_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_ssh_boundary_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_ssh_boundary_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.boundary_controller_allow_9200_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.boundary_controller_api_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.boundary_controller_health_allow_9203](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.boundary_controller_lb_allow_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.boundary_controller_to_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.boundary_lb_allow_443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.boundary_lb_allow_9201](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.boundary_worker_allow_9202_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.boundary_worker_allow_9202_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.boundary_worker_allow_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.ec2messages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ssmmessages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [random_password.boundary_db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.boundary_api_cert_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.boundary_api_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_ami.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_user.boundary_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_user) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ssh_inbound_cidr_blocks"></a> [allowed\_ssh\_inbound\_cidr\_blocks](#input\_allowed\_ssh\_inbound\_cidr\_blocks) | CIDR blocks to allow SSH access to the Controllers and Workers | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_aws_route53_zone"></a> [aws\_route53\_zone](#input\_aws\_route53\_zone) | The Route 53 zone to create the A record in | `string` | `"Z12345678901234567890"` | no |
| <a name="input_boundary_a_record"></a> [boundary\_a\_record](#input\_boundary\_a\_record) | The A record to create in Route 53 for the Boundary Controller | `string` | `"boundary.example.com"` | no |
| <a name="input_boundary_admin_users"></a> [boundary\_admin\_users](#input\_boundary\_admin\_users) | The list of Boundary admin users | `list(string)` | <pre>[<br>  "boundary-admin"<br>]</pre> | no |
| <a name="input_boundary_controller_asg"></a> [boundary\_controller\_asg](#input\_boundary\_controller\_asg) | The configuration for the Boundary Controller Auto Scaling Group | <pre>object({<br>    min_size         = number<br>    max_size         = number<br>    desired_capacity = number<br>  })</pre> | <pre>{<br>  "desired_capacity": 3,<br>  "max_size": 6,<br>  "min_size": 3<br>}</pre> | no |
| <a name="input_boundary_worker_asg"></a> [boundary\_worker\_asg](#input\_boundary\_worker\_asg) | The configuration for the Boundary Worker Auto Scaling Group | <pre>object({<br>    min_size         = number<br>    max_size         = number<br>    desired_capacity = number<br>  })</pre> | <pre>{<br>  "desired_capacity": 1,<br>  "max_size": 10,<br>  "min_size": 1<br>}</pre> | no |
| <a name="input_controller_instance_type"></a> [controller\_instance\_type](#input\_controller\_instance\_type) | The instance type to use for the Boundary Controller | `string` | `"t3.micro"` | no |
| <a name="input_controller_instance_volume_size"></a> [controller\_instance\_volume\_size](#input\_controller\_instance\_volume\_size) | The size of the EBS volume to use for the Boundary Controller | `number` | `50` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | Whether to create a new VPC | `bool` | `true` | no |
| <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage) | The amount of storage to allocate for the Boundary Database | `number` | `20` | no |
| <a name="input_db_backup_enabled"></a> [db\_backup\_enabled](#input\_db\_backup\_enabled) | Whether to enable backups for the Boundary Database | `bool` | `true` | no |
| <a name="input_db_backup_retention_period"></a> [db\_backup\_retention\_period](#input\_db\_backup\_retention\_period) | The number of days to retain backups for | `number` | `7` | no |
| <a name="input_db_backup_window"></a> [db\_backup\_window](#input\_db\_backup\_window) | The backup window for the Boundary Database | `string` | `"03:00-06:00"` | no |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | The engine version to use for the Boundary Database (must be version 13.0 or higher) | `string` | `"16.4"` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | The instance class to use for the Boundary Database | `string` | `"db.t3.micro"` | no |
| <a name="input_db_multi_az"></a> [db\_multi\_az](#input\_db\_multi\_az) | Whether to enable Multi-AZ for the Boundary Database | `bool` | `false` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | The username to use for the Boundary Database user | `string` | `"postgres"` | no |
| <a name="input_enable_ssh"></a> [enable\_ssh](#input\_enable\_ssh) | Whether to enable SSH access to the Controllers and Workers | `bool` | `false` | no |
| <a name="input_logging_enabled"></a> [logging\_enabled](#input\_logging\_enabled) | Whether to enable logging for the Boundary Controller | `bool` | `false` | no |
| <a name="input_logging_retention_in_days"></a> [logging\_retention\_in\_days](#input\_logging\_retention\_in\_days) | The number of days to retain logs for | `number` | `30` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the deployment | `string` | `"boundary"` | no |
| <a name="input_private_subnet_cidr_blocks"></a> [private\_subnet\_cidr\_blocks](#input\_private\_subnet\_cidr\_blocks) | List of private subnet CIDR blocks | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24"<br>]</pre> | no |
| <a name="input_private_subnet_count"></a> [private\_subnet\_count](#input\_private\_subnet\_count) | The number of private subnets to create | `number` | `3` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet IDs | `list(string)` | <pre>[<br>  "subnet-0123456789abcdefg",<br>  "subnet-0123456789abcdefg"<br>]</pre> | no |
| <a name="input_public_subnet_count"></a> [public\_subnet\_count](#input\_public\_subnet\_count) | The number of public subnets to create | `number` | `3` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of public subnet IDs | `list(string)` | <pre>[<br>  "subnet-0123456789abcdefg",<br>  "subnet-0123456789abcdefg"<br>]</pre> | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | The public key to use for SSH access | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | <pre>{<br>  "Environment": "Development",<br>  "Project": "Boundary"<br>}</pre> | no |
| <a name="input_use_acm"></a> [use\_acm](#input\_use\_acm) | Whether to use ACM to generate a certificate or generate a self-signed certificate for the Boundary Controller | `bool` | `false` | no |
| <a name="input_use_cloudwatch"></a> [use\_cloudwatch](#input\_use\_cloudwatch) | Whether to use AWS CloudWatch to log the Boundary Controller | `bool` | `false` | no |
| <a name="input_use_route53"></a> [use\_route53](#input\_use\_route53) | Use Route53 to create a DNS record | `bool` | `false` | no |
| <a name="input_use_ssm"></a> [use\_ssm](#input\_use\_ssm) | Whether to use AWS SSM to access the Boundary Controllers and Workers | `bool` | `false` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC | `string` | `"vpc-0123456789abcdefg"` | no |
| <a name="input_worker_instance_type"></a> [worker\_instance\_type](#input\_worker\_instance\_type) | The instance type to use for the Boundary Workers | `string` | `"t3.micro"` | no |
| <a name="input_worker_instance_volume_size"></a> [worker\_instance\_volume\_size](#input\_worker\_instance\_volume\_size) | The size of the EBS volume to use for the Boundary Workers | `number` | `50` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_boundary_aws_plugin_access_key_id"></a> [boundary\_aws\_plugin\_access\_key\_id](#output\_boundary\_aws\_plugin\_access\_key\_id) | Boundary AWS Plugin Access Key ID |
| <a name="output_boundary_aws_plugin_secret_access_key"></a> [boundary\_aws\_plugin\_secret\_access\_key](#output\_boundary\_aws\_plugin\_secret\_access\_key) | Boundary AWS Plugin Secret Access Key |
| <a name="output_boundary_lb_dns"></a> [boundary\_lb\_dns](#output\_boundary\_lb\_dns) | DNS address of the Load Balancer, if chosen to opt out of route53 usage |
| <a name="output_boundary_worker_auth_key"></a> [boundary\_worker\_auth\_key](#output\_boundary\_worker\_auth\_key) | Boundary Worker Authentication Key, used for initializition of Boundary |
| <a name="output_boundary_worker_sg_id"></a> [boundary\_worker\_sg\_id](#output\_boundary\_worker\_sg\_id) | Boundary Worker Security Group ID |
<!-- END_TF_DOCS -->