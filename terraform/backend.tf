terraform {
  backend "s3" {
    bucket         = "pawsandcode-beerapp-terraform"          # The name of your S3 bucket
    key            = "terraform/state.tfstate"                # The state file key inside the bucket
    region         = "eu-central-1"                           # The region of the S3 bucket and DynamoDB table
    dynamodb_table = "pawsandcode_beerapp_terraformlocktable" # The DynamoDB table for state locking
    encrypt        = true                                     # Enable encryption for state files in S3
  }
}