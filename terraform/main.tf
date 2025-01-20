# S3 Bucket for Lambda Deployment Package
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "beer-app-lambda-deployments"
}

# Upload Lambda Code to S3
resource "aws_s3_object" "query_code" {
  bucket = aws_s3_bucket.lambda_bucket.bucket
  key    = "query.zip"
  source = "../lambdas/build/query.zip" # Ensure this file is in the same directory
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "beer-app-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach Policies to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "query_lambda" {
  function_name = "query"
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = aws_s3_object.query_code.key
  handler       = "query.lambda_handler"
  runtime       = "python3.10" # Match your Lambda's runtime
  role          = aws_iam_role.lambda_execution_role.arn
  timeout       = 10
  memory_size   = 128

  environment {
    variables = {
      DYNAMO_TABLE_NAME = "ispindel"
    }
  }
}

# Lambda Function URL
resource "aws_lambda_function_url" "query_lambda_url" {
  function_name      = aws_lambda_function.query_lambda.function_name
  authorization_type = "NONE" # No auth, since you're the only user
}

# Permission for Lambda URL
resource "aws_lambda_permission" "allow_function_url" {
  statement_id           = "AllowFunctionUrl"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.query_lambda.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}
