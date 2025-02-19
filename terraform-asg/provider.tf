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
    organization = "Chacon_10"

    workspaces {
      name = "Chacon-10-ws5"
    }
  }
}
