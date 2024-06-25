# Configure Aviatrix provider


provider azurerm {
    tenant_id = ""
    subscription_id = ""
    environment = "china"
    skip_provider_registration = "true"

    features {}
}

provider azurerm {
    alias = "gateways"
    tenant_id = ""
    subscription_id = ""
    environment = "china"
    skip_provider_registration = "true"
    features {}
}

provider azurerm {
    alias = "controller"
    tenant_id = ""
    subscription_id = ""
    environment = "china"
    skip_provider_registration = "true"
    features {}
}


provider "aviatrix" {
  controller_ip           = var.controller_ip
  username                = "admin"
  password                = var.ctrl_password

}


