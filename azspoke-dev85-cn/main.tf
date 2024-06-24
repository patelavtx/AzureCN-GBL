
# AZURE spoke - dev 

# https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-overlap-nat-spoke/aviatrix/latest
# https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-spoke/aviatrix/latest

/*
data "azurerm_virtual_network" "vnet185" {
  name                = var.name
  resource_group_name = "atulrg-spoke185"
}

output "virtual_network_id" {
  value = data.azurerm_virtual_network.vnet185.id
}
*/

module "azure-gateway-nsg" {
  providers = {
    azurerm.gateways = azurerm.gateways
    azurerm.controller = azurerm.controller
  }
  source                                      = "github.com/patelavtx/aviatrix_controller_nsg_management_azure_china"
  gateway_resource_group                      = var.gateway_resource_group        # Required. The name of the resource group where the Aviatrix Gateways will be deployed
  use_existing_resource_group                 = false                        # Optional. Defaults to false. Whether to create a new resource group or use an existing one
  gateway_name                                = var.gateway_name                     # Required. This is used to derive the name for the Public IP addresses that will be used by the Aviatrix Gateway
  gateway_region                              = var.region                   # Required. Azure China Region where the Aviatrix Gateways will be deployed
  tags                = {                                                         # Optional. These tags are only for the public IP addresses that will be created. In addition to the specified tags here the following tags are added {avx-gw-association = format("%s-gw", var.gateway_name), avx-created-resource = "DO-NOT-DELETE"} 
                          user = "atul",
                          environment = "azcn"
                        }
  ha_enabled                                  = var.ha_enabled                        # Optional. Defaults to true. If set to false only one Public IP address is created and must disable ha_gw when creating Aviatrix spoke or transit gateways              
  controller_nsg_name                         = var.controller_nsg_name                   # Required. Name of the NSG associated with the Aviatrix Controller
  controller_nsg_resource_group_name          = var.controller_nsg_resource_group_name                # Required. Name of the resource group where the NSG associated with the Aviatrix Controller is deployed
  controller_nsg_rule_priority                = var.controller_nsg_rule_priority                                # Required. This number must be unique. Before running this module verify the priority number is available in the NSG associated with the Aviatrix Controller
}


module "spoke_azure_1" {
  source         = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version        = "1.6.5"
  cloud          = "Azure" # added for new mod
  transit_gw     = var.transit_gw
  az_support = false
  attached       = var.attached
  cidr           = var.cidr
  region         = var.region
  ha_gw          = var.ha_gw
  account        = var.account
  insane_mode    = "false"
  #enable_bgp     = "true"
  #local_as_number = "65085"
  #  name of existing RG - use nsg module created
  resource_group = module.azure-gateway-nsg.gateway_resource_group
  name = var.gateway_name
  subnet_pairs = "2"
  allocate_new_eip                            = false         # remember that NSG module is creating the EIPs; setting this to true causes conflict in NSG rule applied to controller
  #ha_azure_eip_name_resource_group            = format("%s:%s", module.azure-gateway-nsg.gateway_ha_vip.name, module.azure-gateway-nsg.gateway_ha_vip.resource_group_name)
  azure_eip_name_resource_group               = format("%s:%s", module.azure-gateway-nsg.gateway_vip.name, module.azure-gateway-nsg.gateway_vip.resource_group_name)
  eip                                         = module.azure-gateway-nsg.gateway_vip.ip_address
  #ha_eip                                      = module.azure-gateway-nsg.gateway_ha_vip.ip_address
  # Test out updating spoke gw RT to modify
  #included_advertised_spoke_routes = "10.185.1.0/24,10.255.185.1/32,10.255.185.2/32,10.255.185.251/32,10.255.185.252/32"
  #included_advertised_spoke_routes = "0.0.0.0/0, 10.20.0.0/24"  
  #filtered_spoke_vpc_routes = "10.185.1.0/25"
  tags = var.tags 
}


module "azure-linux-vm-spoke85" {
  source = "github.com/patelavtx/azure-linux-passwd.git"
  #public_key_file = var.public_key_file                  # used with different source that supports pubpriv key
  region = var.region
  resource_group_name =  module.spoke_azure_1.vpc.resource_group
  subnet_id =   module.spoke_azure_1.vpc.subnets[1].subnet_id 
  vm_name = "${module.spoke_azure_1.vpc.name}-vm"
}

output "spoke85-vm" {
  value = module.azure-linux-vm-spoke85
}



