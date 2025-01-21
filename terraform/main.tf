data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# S3 Bucket for Lambda Deployment Package
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "beer-app-lambda-deployments"
}

resource "aws_iam_policy" "dynamodb_ispindel_read_policy" {
  name        = "DynamoDBReadPolicy"
  description = "IAM policy to read from the ispindel DynamoDB table"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/ispindel"
      }
    ]
  })
}

module "query_lambda" {
  source = "./lambda"

  s3_bucket           = aws_s3_bucket.lambda_bucket.bucket
  sns_alarm_topic_arn = aws_sns_topic.invocation_alarm_topic.arn

  lambda_name       = "query"
  lambda_policy_arn = aws_iam_policy.dynamodb_ispindel_read_policy.arn
  lambda_variables = {
    DYNAMO_TABLE_NAME = "ispindel"
  }
}
