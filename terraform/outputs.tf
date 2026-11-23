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
  description = "Amazon Linux 2023 AMI"
  value       = nonsensitive(data.aws_ssm_parameter.amazon_linux.value)
}

output "ec2_instance_id" {
  description = "Self healing EC2 instance ID"
  value       = aws_instance.app_server.id
}

output "ec2_public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.app_server.public_ip
}

output "ec2_private_ip" {
  description = "EC2 private IP"
  value       = aws_instance.app_server.private_ip
}

output "ec2_security_group_id" {
  description = "EC2 security group ID"
  value       = aws_security_group.ec2_sg.id
}

output "ec2_iam_role" {
  description = "EC2 IAM role"
  value       = aws_iam_role.ec2_ssm_role.name
}
