terraform {
  backend "remote" {
    organization = "zambrana"

    workspaces {
      name = "HashiTalk2021"
    }
  }
  required_version = "= 0.14.7"
  required_providers {
    databricks = {
      source  = "databrickslabs/databricks"
      version = "0.3.0"
    }
    azurerm = "=2.47.0"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "genericRG" {
  name     = "${var.suffix}${var.rgName}"
  location = var.location
  tags     = var.tags
}
