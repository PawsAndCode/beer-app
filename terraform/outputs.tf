output "query_lambda_function_url" {
  description = "The URL of the Query Lambda"
  value       = aws_lambda_function_url.query_lambda_url.function_url
}