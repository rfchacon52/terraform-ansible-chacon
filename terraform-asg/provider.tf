###################################################
# State file 
###################################################

terraform {

required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }

  }



###################################################
# State file 
###################################################

  backend "s3" {
    bucket         = "chacon-backend3"
    key            = "terraform/state"
    region         = "us-east-2"
    use_lockfile   = true
  }

}


provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}


