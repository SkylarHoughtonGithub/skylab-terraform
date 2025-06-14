terraform {
  backend "s3" {
    bucket         = "skylab-platform-artifacts"
    region         = "us-east-2"
    key            = "tfstate/dev/skylab/proxmox/vm/k3s/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "LockID"
  }
  required_version = ">= 1.5.0"
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc01"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://host1.skylarhoughtongithub.local:8006/api2/json"
  pm_api_token_id     = "terraform-prov@pve!mytoken"
  pm_api_token_secret = local.proxmox_token
  pm_tls_insecure     = true
}

provider "aws" {
  region = "us-east-2"
}