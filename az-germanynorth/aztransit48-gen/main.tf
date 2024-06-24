
# https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-transit/aviatrix/latest


module "mc-transit" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.5.3"
  cloud = "Azure"        
  cidr = var.cidr
  region = var.region
  account = var.account
  resource_group = var.rg 
  local_as_number = var.localasn
  insane_mode = "true"
  name = var.gateway_name
  enable_advertise_transit_cidr = "true"
  #enable_segmentation    = "true"
  tags  =  var.tags
}


# If testing s2c to AZ-CN directly, opt1 or opt2
# Opt1 - tested Apr27 2024 - s2c between AZ transits works
/*
resource "aviatrix_transit_external_device_conn" "toazcn" {
  #  vpcid and transit gateway variable values can be found via the transit gateway output
  vpc_id                    = module.mc-transit.vpc.vpc_id
  connection_name           = "toazcn"
  gw_name                   =  module.mc-transit.transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "IPsec"
  bgp_local_as_num          = "65048"
  bgp_remote_as_num         = "65084"
  remote_gateway_ip         = "139.219.235.33"
  #phase1_local_identifier    = "public_ip"
  pre_shared_key            = "Aviatrix123#"
  enable_ikev2              = "false"
  local_tunnel_cidr         = "169.254.31.201/30, 169.254.32.201/30"
  remote_tunnel_cidr        = "169.254.31.202/30, 169.254.32.202/30"
  #ha_enabled                = "true"
  #backup_remote_gateway_ip  = "20.31.84.218"
  #backup_bgp_remote_as_num  = "65515"
  #backup_pre_shared_key     = "Aviatrix123#"
  #backup_local_tunnel_cidr  = "169.254.21.205/30, 169.254.22.205/30"
  #backup_remote_tunnel_cidr = "169.254.21.206/30, 169.254.22.206/30"
}
*/

/*
#  Opt2 - Test out with remote gateway config
resource "aviatrix_transit_external_device_conn" "to_alicn" {
  #  vpcid and transit gateway variable values can be found via the transit gateway output
  vpc_id                    = module.mc-transit-ali.vpc.vpc_id
  connection_name           = "2alicn"
  gw_name                   = module.mc-transit-ali.transit_gateway.gw_name
  connection_type           = "bgp"
  tunnel_protocol           = "IPsec"
  bgp_local_as_num          = "65048"
  bgp_remote_as_num         = "65084"
  remote_gateway_ip         = "116.62.245.210, 112.124.61.52"             <<  UPDATE with AzCN transit IPs
  phase1_local_identifier = "public_ip"
  enable_ikev2              = "false"
  pre_shared_key            = "Aviatrix123#"
  local_tunnel_cidr         = "169.254.31.201/30, 169.254.32.201/30"
  remote_tunnel_cidr        = "169.254.31.202/30, 169.254.32.202/30"
  #ha_enabled                = "true"
  #backup_remote_gateway_ip  = "20.31.84.218"
  #backup_bgp_remote_as_num  = "65515"
  #backup_pre_shared_key     = "Aviatrix123#"
  #backup_local_tunnel_cidr  = "169.254.21.205/30, 169.254.22.205/30"
  #backup_remote_tunnel_cidr = "169.254.21.206/30, 169.254.22.206/30"
}
*/



#  gateway peering  az global to ali global
#  Comment out if using az - az lab 

resource "aviatrix_transit_gateway_peering" "gbl_az_ali_peering" {
  transit_gateway_name1                       = module.mc-transit.transit_gateway.gw_name
  transit_gateway_name2                       = "alitransit40-ft"
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
