# Configure Aviatrix provider


provider azurerm {
    tenant_id = "e600d6cb-71a8-4438-b9c7-fd6bc197f582"
    subscription_id = "56f0b5cd-c879-4bca-ad95-e1d244dcb3b0"
    environment = "china"
    skip_provider_registration = "true"

    features {}
}

provider azurerm {
    alias = "gateways"
    tenant_id = "e600d6cb-71a8-4438-b9c7-fd6bc197f582"
    subscription_id = "56f0b5cd-c879-4bca-ad95-e1d244dcb3b0"
    environment = "china"
    skip_provider_registration = "true"
    features {}
}

provider azurerm {
    alias = "controller"
    tenant_id = "e600d6cb-71a8-4438-b9c7-fd6bc197f582"
    subscription_id = "56f0b5cd-c879-4bca-ad95-e1d244dcb3b0"
    environment = "china"
    skip_provider_registration = "true"
    features {}
}


provider "aviatrix" {
  controller_ip           = var.controller_ip
  username                = "admin"
  password                = var.ctrl_password

}


