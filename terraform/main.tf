resource "aws_s3_bucket" "risk_data" { bucket = "risk-poc-bucket-tf" }

resource "aws_dynamodb_table" "risk_indicators" {
  name         = "RiskIndicatorsTF"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute { name = "id"  type = "S" }
}

resource "aws_sqs_queue" "risk_events" { name = "risk-events-tf" }

resource "aws_iam_role" "lambda_role" {
  name = "risk-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole", Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambdas/process_exposure.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "process_exposure" {
  function_name    = "process-exposure"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "process_exposure.handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_role.arn
  timeout          = 30
  environment { variables = { TABLE_NAME = aws_dynamodb_table.risk_indicators.name } }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_exposure.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.risk_data.arn
}

resource "aws_s3_bucket_notification" "on_upload" {
  bucket = aws_s3_bucket.risk_data.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.process_exposure.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_s3]
}

output "bucket_name" { value = aws_s3_bucket.risk_data.bucket }
output "table_name"  { value = aws_dynamodb_table.risk_indicators.name }
output "queue_url"   { value = aws_sqs_queue.risk_events.url }
output "lambda_name" { value = aws_lambda_function.process_exposure.function_name }
