terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }

    backend "s3" {
        bucket = "my-terraform-state-bucket-977099016287-eu-west-1-an"
        key = "terraform.tfstate"
        region = "eu-west-1"
    }
}