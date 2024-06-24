# *** used one under ~/ABI/Sandbox ***
#**************************************

# AZURE spoke - dev  

# https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-overlap-nat-spoke/aviatrix/latest
# https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-spoke/aviatrix/latest



module "spoke_azure_1" {
  source         = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version        = "1.6.5"
  cloud          = "Azure" # added for new mod
  transit_gw     = var.transit_gw
  attached       = var.attached
  cidr           = var.cidr
  region         = var.region
  ha_gw          = var.ha_gw
  account        = var.account
  #insane_mode    = "false"                    # needed for bgp
  enable_bgp     = "true"
  local_as_number = "65058"
  resource_group = "atulrg-spoke58"            # NAME of EXISTING RG
  name = var.name
  subnet_pairs = "2"
  # Test out updating spoke gw RT to modify
  #included_advertised_spoke_routes = "10.185.1.0/24,10.255.185.1/32,10.255.185.2/32,10.255.185.251/32,10.255.185.252/32"
  #included_advertised_spoke_routes = "0.0.0.0/0, 10.20.0.0/24"  
  #filtered_spoke_vpc_routes = "10.185.1.0/25"
  tags = var.tags 
}


module "azure-linux-vm-spoke58" {
  source = "github.com/patelavtx/azure-linux-passwd.git"
  #source = "github.com/patelavtx/terraform-azure-azure-linux-vm-public.git"
  #public_key_file = var.public_key_file
  region = var.region
  resource_group_name =  module.spoke_azure_1.vpc.resource_group
  subnet_id =   module.spoke_azure_1.vpc.subnets[1].subnet_id 
  vm_name = "${module.spoke_azure_1.vpc.name}-vm"
}

output "spoke58-vm" {
  value = module.azure-linux-vm-spoke58
}



/* if terminating for NAT on spoke
resource "aviatrix_spoke_external_device_conn" "toavtxtrgw84" {
  vpc_id                   = module.spoke_azure_1.vpc.vpc_id
  connection_name          = "toavtxtrgw84"
  gw_name                  = var.name
  connection_type          = "bgp"
  bgp_local_as_num          = "65058"
  bgp_remote_as_num         = "65084"
  #remote_subnet          = module.spoke_azure_1.vpc.cidr   # needed for external device though doc specifies optional
  remote_gateway_ip = "143.64.97.117, 143.64.97.183"
  pre_shared_key = "Aviatrix123#"
  local_tunnel_cidr        = "169.254.21.201/30, 169.254.22.201/30"
  remote_tunnel_cidr         = "169.254.21.202/30, 169.254.22.202/30"
  #local_tunnel_cidr = "10.10.1.1/30, 10.10.2.1/30"
  #remote_tunnel_cidr = "10.10.1.2/30, 10.10.2.2/30"
  depends_on = [ module.spoke_azure_1 ]
}
*/