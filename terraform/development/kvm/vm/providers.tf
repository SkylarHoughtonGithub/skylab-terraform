terraform {
  backend "s3" {
    bucket         = "skylab-platform-artifacts"
    region         = "us-east-2"
    key            = "tfstate/dev/skylab/ec2/jenkins_docker/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "LockID"
  }
  required_version = ">= 1.5.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://skylar@100.109.18.70/system?known_hosts_verify=ignore"
}

provider "aws" {
  region = "us-east-2"
}