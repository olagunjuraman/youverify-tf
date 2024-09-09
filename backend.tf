terraform {
  backend "s3" {
    bucket         = "TERRAFORM_STATE_BUCKET_NAME"
    key            = "TERRAFORM_STATE_KEY"
    region         = "AWS_REGION"
    encrypt        = true
    dynamodb_table = "TERRAFORM_LOCK_TABLE_NAME"
  }
}