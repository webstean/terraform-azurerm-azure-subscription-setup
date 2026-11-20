terraform {
  required_version = ">= 1.9.0, < 2.0"

  required_providers {
    azurerm = {
      ## Azure resource manager
      source  = "hashicorp/azurerm"
      version = "~>5.6, < 5.0"
    }
  }
}

