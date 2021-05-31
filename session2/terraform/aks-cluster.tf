resource "random_pet" "prefix" {}

provider "azurerm" {
  features {}
}


terraform {
  backend "azurerm" {
    resource_group_name  = "aks-training"
    storage_account_name = "akstrainingdemotfstate"
    container_name       = "aks-training"
    key                  = "aks/terraform.tfstate"
  }
}



resource "azurerm_kubernetes_cluster" "default" {
  name                = "${random_pet.prefix.id}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${random_pet.prefix.id}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "Demo",
    georgec = "true",
  }
}
