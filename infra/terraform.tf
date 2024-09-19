terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.62.0"      
    }
  }

  backend "s3" {
    bucket = "github-pipe"
    key = "document-db/terraform.tfstate"
    region = "sa-east-1"
  }
}

provider "aws" {
    alias = "us_east"
    region = "us-east-1"
}