# Terraform AWS Boundary Deployment Module

This Terraform module deploys HashiCorp Boundary on AWS, providing a secure and scalable solution for managing access to dynamic infrastructure.

## Features

- Deploys Boundary controllers and workers in an Auto Scaling Group
- Sets up a PostgreSQL RDS instance for Boundary's database
- Configures a Network Load Balancer for high availability
- Implements KMS keys for encryption
- Supports optional Route53 DNS record creation
- Allows for ACM or self-signed TLS certificates

## Prerequisites

- Terraform 1.4.7 or later
- AWS account and credentials
- VPC with public and private subnets

## Usage

```hcl

module "boundary" {
    source = "dc-tec/terraform-aws-boundary-deployment"
    version = "~> 1.0"

    name = "lab-boundary"
    vpc_id = data.aws_vpc.id
    private_subnet_ids = aws_subnet.private.*.id
    public_subnet_ids = aws_subnet.public.*.id
    aws_route53_zone = data.aws_route53_zone.main.zone_id
    boundary_a_record = "boundary.example.com"

    tags = {
        Environment = "dev"
        Project = "boundary"
    }
}
```

## Security Considerations

- The module uses KMS keys for encryption of sensitive data.
- Security groups are configured to restrict access to the necessary ports.
- TLS is enabled for the Boundary API listener.
- SSH access is disabled by default but can be enabled if required.

## Customization

You can customize the deployment by adjusting the input variables. For example, you can change instance types, enable logging, or modify the Auto Scaling Group configurations.

## Testing

This module includes Terraform tests located in the `tests` directory. These tests ensure that the security groups, launch templates, and other resources are correctly configured.

To run the tests:

`terraform test`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This module is released under the MIT License. See the LICENSE file for details.
