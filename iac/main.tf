# Definition of terraform settings.
terraform {
  # Definition of the remote state management in Object storage.
  backend "s3" {
    bucket                      = "fvilarin-devops"
    key                         = "akamai-lke-egress-gateway.tfstate"
    region                      = "us-east-1"
    endpoint                    = "us-east-1.linodeobjects.com"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
  }

  # Required providers.
  required_providers {
    linode = {
      source = "linode/linode"
    }

    null = {
      source = "hashicorp/null"
    }
  }
}

# Definition of the token for the resources provisioning.
provider "linode" {
  token = var.settings.general.token
}