data "archive_file" "restart_app" {
  type        = "zip"
  source_file = "${path.module}/../lambda/restart_app.py"
  output_path = "${path.module}/restart_app.zip"
}

resource "aws_iam_role" "lambda_restart" {
  name = "self-healing-infra-lambda-restart-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_restart.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_ssm" {
  name = "send-restart-command"
  role = aws_iam_role.lambda_restart.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["ssm:SendCommand"]
      Resource = [
        "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:instance/${aws_instance.app_server.id}",
        "arn:aws:ssm:${data.aws_region.current.region}::document/AWS-RunShellScript"
      ]
    }]
  })
}

resource "aws_lambda_function" "restart_app" {
  function_name    = "self-healing-infra-restart-app"
  role             = aws_iam_role.lambda_restart.arn
  handler          = "restart_app.handler"
  runtime          = "python3.12"
  timeout          = 30
  filename         = data.archive_file.restart_app.output_path
  source_code_hash = data.archive_file.restart_app.output_base64sha256

  environment {
    variables = {
      INSTANCE_ID = aws_instance.app_server.id
    }
  }
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.restart_app.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts.arn
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.restart_app.arn
}