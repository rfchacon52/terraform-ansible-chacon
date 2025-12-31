terraform {
  required_version = ">= 1.0.0"

  required_providers {
    datadog = {
      source  = "datadog/datadog"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  
  # Default US site is datadoghq.com. Change if using US3 or US5.
  site = "datadoghq.com" 
}

provider "aws" {
  region = "us-east-2" # Ohio
}
