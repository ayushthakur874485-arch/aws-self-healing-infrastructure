resource "aws_instance" "app_server" {
  ami           = data.aws_ssm_parameter.amazon_linux.value
  instance_type = var.instance_type

  subnet_id = data.aws_subnets.default.ids[0]

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/user-data.sh.tftpl", {
    app_py_b64  = base64encode(file("${path.module}/../app/app.py"))
    service_b64 = base64encode(file("${path.module}/../app/demo-app.service"))
    cw_b64      = base64encode(file("${path.module}/../monitoring/cloudwatch-agent.json"))
  })

  user_data_replace_on_change = true

  tags = {
    Name = "${var.project_name}-server"
    Role = "self-healing-app-server"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm_managed_instance,
    aws_iam_role_policy_attachment.cloudwatch_agent,
  ]
}