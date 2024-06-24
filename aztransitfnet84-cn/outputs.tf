output "vpc" {
  description = "The created VPC as an object with all of it's attributes. This was created using the aviatrix_vpc resource."
  value       = module.mc-transit.vpc
}

output "transit_gateway" {
  description = "The created Aviatrix Transit Gateway as an object with all of it's attributes."
  value       = module.mc-transit.transit_gateway
  sensitive   = true
}

output "transitgw_name" {
  description = "The created Aviatrix Transit Gateway as an object with all of it's attributes."
  value       = module.mc-transit.transit_gateway.gw_name
  sensitive   = true
}

output "transitgw_haname" {
  description = "The created Aviatrix Transit Gateway as an object with all of it's attributes."
  value       = module.mc-transit.transit_gateway.ha_gw_name
  sensitive   = true
}

output "transitgw_asn" {
  description = "The created Aviatrix Transit Gateway as an object with all of it's attributes."
  value       = module.mc-transit.transit_gateway.local_as_number
  sensitive   = true
}

output "transitgw_eip" {
  description = "The created Aviatrix Transit Gateway as an object with all of it's attributes."
  value       = module.mc-transit.transit_gateway.public_ip
  sensitive   = true
}

output "transitgw_haeip" {
  description = "The created Aviatrix Transit Gateway as an object with all of it's attributes."
  value       = module.mc-transit.transit_gateway.ha_public_ip
  sensitive   = true
}

output "transitgw_vpcid" {
  description = "The created Aviatrix Transit Gateway as an object with all of it's attributes."
  value       = module.mc-transit.vpc.vpc_id
  sensitive   = true
}

output "mc_firenet_details" {
  description = "The created Aviatrix Transit Gateway as an object with all of it's attributes."
  value       = module.mc-transit.mc_firenet_details
}

/*
output "aviatrix_firenet" {
  description = "Firenet obj. and attributes."
  value       = module.firenet_1.aviatrix_firenet
}

output "aviatrix_firewall_instance" {
  description = "Firewall isntance and attributes."
  value       = module.firenet_1.aviatrix_firewall_instance
  sensitive = true
}
*/
