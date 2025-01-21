output "lambda_function_url" {
  description = "The URL of the Lambda"
  value       = var.create_function_url ? aws_lambda_function_url.lambda_url[0].function_url : "n/a"
}

output "lambda_arn" {
  description = "The ARN of the Lambda"
  value       = aws_lambda_function.lambda.arn
}

output "lambda_name" {
  description = "The name of the Lambda"
  value       = aws_lambda_function.lambda.function_name
}