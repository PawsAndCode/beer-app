output "query_lambda_function_url" {
  description = "The URL of the Query Lambda"
  value       = aws_lambda_function_url.query_lambda_url.function_url
}

output "main_app_static_site_url" {
  description = "The URL of the S3 static website"
  value       = aws_s3_bucket.app_static_site.website_endpoint
}