###################################################
# State file 
###################################################

terraform {

required_version = ">= 1.12.0" # Or your desired minimum Terraform version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }

  }



###################################################
# State file 
###################################################

  backend "s3" {
    bucket         = "chacon-backend3"
    key            = "terraform/state"
    region         = "us-east-1"
    use_lockfile   = true
  }

}


provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

