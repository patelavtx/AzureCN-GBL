# Configure Aviatrix provider


provider azurerm {
    alias = "gateways"
    tenant_id = "<id>"
    subscription_id = ""
    environment = "china"
    features {}
}

provider azurerm {
    alias = "controller"
    tenant_id = ""
    subscription_id = ""
    environment = "china"
    features {}
}



provider "aviatrix" {
  controller_ip           = var.controller_ip
  username                = "admin"
  password                = var.ctrl_password

}

