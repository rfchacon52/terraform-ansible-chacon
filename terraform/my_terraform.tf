# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.75.0"
    }
  }

  required_version = ">= 1.5.0"
}
terraform {
  cloud {
    organization = "Chacon_Dev"

    workspaces {
      name = "chacon-ws2"
    }
  }
}

