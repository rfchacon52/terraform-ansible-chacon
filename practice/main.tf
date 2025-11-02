
provider "aws" {
       region = "us-east.1"
}

resource  "aws_vpc" "my_vpc" {
       cidr =  "10.0.0.0/16"
}
