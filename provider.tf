terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }

  # backend "s3" {
  #   bucket       = "shopflow-dev-terraform-state-01"
  #   key          = "shopflow/dev/terraform.tfstate"
  #   region       = "ap-southeast-1"
  #   encrypt      = true
  #   use_lockfile = true
  # }

}

provider "aws" {
  region = "ap-southeast-1"
}
