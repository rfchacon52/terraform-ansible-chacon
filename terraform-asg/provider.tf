provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      hashicorp-learn = "aws-asg"
    }
  }
}


terraform {
  cloud {
    organization = "Chacon_Dev"

    workspaces {
      name = "chacon-ws3"
    }
  }
}
