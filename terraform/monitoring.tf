# SNS Topic for Alarm Notification
resource "aws_sns_topic" "invocation_alarm_topic" {
  name = "lambda-invocation-alarm-topic"
}

# Lambda to disable all Lambda functions when the invocation limit is exceeded
resource "aws_iam_policy" "disable_lambda_policy" {
  name = "disable-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "lambda:PutFunctionConcurrency", # Required to disable Lambda functions
        ],
        Resource = "arn:aws:lambda:*:*:function:*" # Restrict to specific functions if needed
      }
    ]
  })
}

module "disable_lambda" {
  source = "./lambda"

  s3_bucket           = aws_s3_bucket.lambda_bucket.bucket
  sns_alarm_topic_arn = aws_sns_topic.invocation_alarm_topic.arn
  create_function_url = false

  lambda_name       = "disable_all"
  lambda_policy_arn = aws_iam_policy.disable_lambda_policy.arn
  lambda_variables = {
    LAMBDA_FUNCTIONS = "query" # list all external Lambda functions
  }
}

# SNS Subscription for Disable Lambda
resource "aws_sns_topic_subscription" "sns_disable_lambda_subscription" {
  topic_arn = aws_sns_topic.invocation_alarm_topic.arn
  protocol  = "lambda"
  endpoint  = module.disable_lambda.lambda_arn
}

# Allow SNS to Invoke the Disable Lambda
resource "aws_lambda_permission" "sns_invoke_permission" {
  statement_id  = "AllowSNSInvocation"
  action        = "lambda:InvokeFunction"
  function_name = module.disable_lambda.lambda_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.invocation_alarm_topic.arn
}