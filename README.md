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

Refer to the [module documentation](./MODULE_DOCS.md) file for all available options.

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
