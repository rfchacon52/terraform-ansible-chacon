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
    bucket = "tfremotestate-ec2"
    key = "state"
    region = "us-east-1"
    dynamodb_table = "tfremotestate-ec2"
  } 
}
