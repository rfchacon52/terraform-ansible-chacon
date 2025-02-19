provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      hashicorp-learn = "aws-asg"
    }
  }
}


terraform {
  backend "s3" {
    bucket         = "chacon-backend"
    key            = "terraform/state"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock-table"
  }
}