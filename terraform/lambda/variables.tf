variable "lambda_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "lambda_variables" {
  description = "A map of variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "lambda_policy_arn" {
  description = "The ARN of the IAM policy for the Lambda function"
  type        = string
}

variable "s3_bucket" {
  description = "The S3 bucket where the source code is stored"
  type        = string
}

variable "sns_alarm_topic_arn" {
  description = "The ARN of the SNS topic for alarm notifications"
  type        = string
}

variable "create_function_url" {
  description = "Whether to create a URL for the Lambda function"
  type        = bool
  default     = true
}