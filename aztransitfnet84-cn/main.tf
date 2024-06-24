module "azure-gateway-nsg" {
  providers = {
    azurerm.gateways = azurerm.gateways
    azurerm.controller = azurerm.controller
  }
  source                                      = "github.com/patelavtx/aviatrix_controller_nsg_management_azure_china"
  gateway_resource_group                      = var.gateway_resource_group        # Required. The name of the resource group where the Aviatrix Gateways will be deployed
  use_existing_resource_group                 = false                        # Optional. Defaults to false. Whether to create a new resource group or use an existing one
  gateway_name                                = var.gateway_name                     # Required. This is used to derive the name for the Public IP addresses that will be used by the Aviatrix Gateway
  gateway_region                              = "China East"                   # Required. Azure China Region where the Aviatrix Gateways will be deployed
  tags                = {                                                         # Optional. These tags are only for the public IP addresses that will be created. In addition to the specified tags here the following tags are added {avx-gw-association = format("%s-gw", var.gateway_name), avx-created-resource = "DO-NOT-DELETE"} 
                          user = "atul",
                          environment = "azcn"
                        }
  ha_enabled                                  = var.ha_enabled                        # Optional. Defaults to true. If set to false only one Public IP address is created and must disable ha_gw when creating Aviatrix spoke or transit gateways              
  controller_nsg_name                         = var.controller_nsg_name                   # Required. Name of the NSG associated with the Aviatrix Controller
  controller_nsg_resource_group_name          = var.controller_nsg_resource_group_name                # Required. Name of the resource group where the NSG associated with the Aviatrix Controller is deployed
  controller_nsg_rule_priority                = var.controller_nsg_rule_priority                                # Required. This number must be unique. Before running this module verify the priority number is available in the NSG associated with the Aviatrix Controller
}




module "mc-transit" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.5.3"
  cloud = "Azure"        
  cidr = var.cidr
  region = var.region
  az_support = false
  account = var.account
  resource_group = module.azure-gateway-nsg.gateway_resource_group                            # created from nsg RG
  name = var.gateway_name
  allocate_new_eip = false
  ha_azure_eip_name_resource_group            = format("%s:%s", module.azure-gateway-nsg.gateway_ha_vip.name, module.azure-gateway-nsg.gateway_ha_vip.resource_group_name)
  azure_eip_name_resource_group               = format("%s:%s", module.azure-gateway-nsg.gateway_vip.name, module.azure-gateway-nsg.gateway_vip.resource_group_name)
  enable_advertise_transit_cidr = "true"
  eip                                         = module.azure-gateway-nsg.gateway_vip.ip_address
  ha_eip                                      = module.azure-gateway-nsg.gateway_ha_vip.ip_address
  #local_as_number = var.localasn
  #insane_mode = "true"
  enable_transit_firenet = "false"       
  #enable_bgp_over_lan    = "true"
  #bgp_lan_interfaces_count = "1"
  enable_segmentation    = "false"
  #instance_size = "Standard_D4_v2"
  tags  =  var.tags
}



# If testing s2c to AZ-GLOBAL directly, opt1 or opt2
# Opt1 - tested Apr27 2024 - s2c between AZ transits works
/*
resource "aviatrix_transit_external_device_conn" "toazcn" {
  #  vpcid and transit gateway variable values can be found via the transit gateway output
  vpc_id                    = module.mc-transit.vpc.vpc_id
  connection_name           = "toazglobal"
  gw_name                   =  module.mc-transit.transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "IPsec"
  bgp_local_as_num          = "65084"
  bgp_remote_as_num         = "65048"
  remote_gateway_ip         = ""                                          # UPDATE with Az Global transit IP
  phase1_local_identifier    = "public_ip"
  pre_shared_key            = "Aviatrix123#"
  enable_ikev2              = "false"
  local_tunnel_cidr         = "169.254.31.202/30, 169.254.32.202/30"
  remote_tunnel_cidr        = "169.254.31.201/30, 169.254.32.201/30"
  #ha_enabled                = "true"
  #backup_remote_gateway_ip  = "20.31.84.218"
  #backup_bgp_remote_as_num  = "65515"
  #backup_pre_shared_key     = "Aviatrix123#"
  #backup_local_tunnel_cidr  = "169.254.21.206/30, 169.254.22.206/30"
  #backup_remote_tunnel_cidr = "169.254.21.205/30, 169.254.22.205/30"
}
*/

/*
#  Opt2 - Test out with remote gateway config
resource "aviatrix_transit_external_device_conn" "to_alicn" {
  #  vpcid and transit gateway variable values can be found via the transit gateway output
  vpc_id                    = module.mc-transit-ali.vpc.vpc_id
  connection_name           = "toazglobal"
  gw_name                   = module.mc-transit-ali.transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "IPsec"
  bgp_local_as_num          = "65084"
  bgp_remote_as_num         = "65048"
  remote_gateway_ip         = "116.62.245.210, 112.124.61.52"             <<  UPDATE with AzGBL transit IPs
  phase1_local_identifier = "public_ip"
  enable_ikev2              = "false"
  pre_shared_key            = "Aviatrix123#"
  local_tunnel_cidr         = "169.254.31.202/30, 169.254.32.202/30"
  remote_tunnel_cidr        = "169.254.31.201/30, 169.254.32.201/30"
  #ha_enabled                = "true"
  #backup_remote_gateway_ip  = "20.31.84.218"
  #backup_bgp_remote_as_num  = "65515"
  #backup_pre_shared_key     = "Aviatrix123#"
  #backup_local_tunnel_cidr  = "169.254.21.206/30, 169.254.22.206/30"
  #backup_remote_tunnel_cidr = "169.254.21.205/30, 169.254.22.205/30"
}
*/



#  gateway peering  to ALI transit if deployed  -  works
resource "aviatrix_transit_gateway_peering" "cn_az_ali_peering" {
  transit_gateway_name1                       = module.mc-transit.transit_gateway.gw_name
  transit_gateway_name2                       = "alitransit4-cn"
  #gateway1_excluded_network_cidrs             = ["10.0.0.48/28"]
  #gateway2_excluded_network_cidrs             = ["10.0.0.48/28"]
  #gateway1_excluded_tgw_connections           = ["vpn_connection_a"]
  #gateway2_excluded_tgw_connections           = ["vpn_connection_b"]
  #prepend_as_path1                            = [
  #  "65001",
  #  "65001",
  #  "65001"
  #]
  #prepend_as_path2                            = [
  #  "65002"
  #]
  enable_peering_over_private_network         = false
  enable_insane_mode_encryption_over_internet = false
}

# No BGPoLAN with ARS , as tested and received error msg to that extent
/*
module "azure_route_server" {
  providers = {
    azurerm.gateways = azurerm.gateways
  }
  source  = "../custom-ars/terraform-aviatrix-azure-route-server"
  #version = "1.0.0"
  
  vnetname            = var.vnetname
  name                = var.ars_name
  transit_vnet_obj    = module.mc-transit.vpc
  transit_gw_obj      = module.mc-transit.transit_gateway
  cidr                = var.ars_cidr
  #local_lan_ip        = "10.184.28.116"   ; not needed in new module?
  #backup_local_lan_ip = "10.184.28.124"
  resource_group_name = "${var.ars_name}-rg"                # added this to overcome error; see below
}
*/



# Used to terminate on spoke for NAT purposes, however, NAT not supported in CN currently
/*  
resource "aviatrix_transit_external_device_conn" "toavtxspk58" {
  #  vpcid and transit gateway variable values can be found via the transit gateway output
  vpc_id                    = module.mc-transit.vpc.vpc_id
  connection_name           = "toavtxspk58"
  gw_name                   = var.gateway_name
  connection_type           = "bgp"
  tunnel_protocol           = "IPsec"
  bgp_local_as_num          = "65084"
  bgp_remote_as_num         = "65058"
  #backup_bgp_remote_as_num  = "65515"
  #ha_enabled                = "true"
  remote_gateway_ip         = "20.79.136.49"
  #backup_remote_gateway_ip  = "20.31.84.218"
  pre_shared_key            = "Aviatrix123#"
  #backup_pre_shared_key     = "Aviatrix123#"
  enable_ikev2              = "false"
  local_tunnel_cidr         = "169.254.21.202/30, 169.254.22.202/30"
  remote_tunnel_cidr        = "169.254.21.201/30, 169.254.22.201/30"
  #backup_local_tunnel_cidr  = "169.254.21.206/30, 169.254.22.206/30"
  #backup_remote_tunnel_cidr = "169.254.21.205/30, 169.254.22.205/30"
}
*/

