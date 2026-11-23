resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for self healing EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  # No inbound rules.
  # We will access EC2 using Systems Manager.

  egress {
    description = "Allow outbound connectivity"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}
