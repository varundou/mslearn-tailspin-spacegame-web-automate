terraform {
  required_version = "> 0.12.0"
  
  backend "azurerm" {
    resource_group_name  = "cloud-shell-storage-westus"
    storage_account_name = "tfsa2222"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  version = ">=2.0.0"
  features {}
}

variable "resource_group_name" {
  default = "varun-senthilkumar"
  description = "The name of the resource group"
}

variable "resource_group_location" {
  description = "The location of the resource group"
}

variable "app_service_plan_name" {
  default = "tailspin-space-game-asp"
  description = "The name of the app service plan"
}

variable "app_service_name_prefix" {
  default = "tailspin-space-game-web"
  description = "The beginning part of your App Service host name"
}

resource "random_integer" "app_service_name_suffix" {
  min = 1000
  max = 9999
}

resource "azurerm_app_service_plan" "spacegame" {
  name                = var.app_service_plan_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "spacegame_dev" {
  name                = "${var.app_service_name_prefix}-dev-${random_integer.app_service_name_suffix.result}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.spacegame.id

  site_config {
    linux_fx_version = "DOTNETCORE|3.1"
    app_command_line = "dotnet Tailspin.SpaceGame.Web.dll"
  }
}

output "appservice_name_dev" {
  value       = azurerm_app_service.spacegame_dev.name
  description = "The App Service name for the dev environment"
}
output "website_hostname_dev" {
  value       = azurerm_app_service.spacegame_dev.default_site_hostname
  description = "The hostname of the website in the dev environment"
}
