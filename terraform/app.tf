# S3 Bucket for Static Website Hosting
resource "aws_s3_bucket" "app_static_site" {
  bucket = "beer-app-static-site"
}

# Disable Block Public Access for the Bucket
resource "aws_s3_bucket_public_access_block" "app_static_site_public_access" {
  bucket                  = aws_s3_bucket.app_static_site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "app_static_site_ownership" {
  bucket = aws_s3_bucket.app_static_site.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.app_static_site_public_access]
}

# S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "app_static_site_config" {
  bucket = aws_s3_bucket.app_static_site.id

  index_document {
    suffix = "index.html" # Default page
  }

  error_document {
    key = "index.html" # For single-page apps, fallback to index.html
  }
}

resource "aws_s3_bucket_acl" "app_static_site_acl" {
  bucket     = aws_s3_bucket.app_static_site.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.app_static_site_ownership]
}

# Bucket Policy to Allow Public Access for Static Website
resource "aws_s3_bucket_policy" "app_static_site_policy" {
  bucket = aws_s3_bucket.app_static_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.app_static_site.arn}/*"
      }
    ]
  })
}