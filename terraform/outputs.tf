
output "aws_account_id" {
  description = "AWS account used by Terraform"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "Configured AWS region"
  value       = data.aws_region.current.region
}

output "default_vpc_id" {
  description = "Discovered default VPC"
  value       = data.aws_vpc.default.id
}

output "available_subnets" {
  description = "Discovered default subnets"
  value       = data.aws_subnets.default.ids
}

output "amazon_linux_ami" {
  description = "Latest Amazon Linux 2023 AMI"
  value       = nonsensitive(data.aws_ssm_parameter.amazon_linux.value)
}

