#!/bin/bash

# Configuration
BUCKET_NAME="beer-app-static-site"
AWS_REGION="eu-central-1"

# Sync all files in the current directory to the S3 bucket
echo "Deploying files to S3 bucket: $BUCKET_NAME"
aws s3 sync . s3://$BUCKET_NAME --acl public-read --delete --exclude "deploy.sh"

# Set bucket website configuration
echo "Configuring S3 bucket for static website hosting..."
aws s3 website s3://$BUCKET_NAME/ --index-document index.html --error-document index.html

# Output website URL
echo "Deployment complete. Access your site at:"
echo "http://$BUCKET_NAME.s3-website-$AWS_REGION.amazonaws.com"
