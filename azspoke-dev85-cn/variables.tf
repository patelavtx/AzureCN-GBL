variable "controller_ip" {
  description = "Set controller ip"
  type        = string
}

variable "ctrl_password" {
    type = string
}

variable "account" {
    type = string
}

variable "name" {
    type = string
}

variable "transit_gw" {
    type = string
}

variable "cidr" {  
  description = "Set vpc cidr"
  type        = string
}

variable "region" {
  description = "Set regions"
  type        = string
  default = "China East"
}

variable "spoke_cidrs" {
    description = "spoke vpc range"
    type = list(string)
}

variable "gw1_snat" {
  type        = string
}

variable "gw2_snat" {
  type        = string
}

variable "dnatip" {
  type        = string
}

variable "dnatip2" {
  type        = string
}

variable "dstcidr" {
  type        = string
}

variable "dstcidr2" {
  type        = string
}


variable "nat_attached" {
  default     = "true"
}


variable "attached" {
  default     = "true"
}

variable "ha_gw" {
  description = "Required when spoke is HA pair."
  default     = true
}

variable "tags" {
  type = map(string)
  description = ""
}


#  nsg_management module

variable "gateway_resource_group" {
    type = string
    description = "Name of the resource group where Aviatrix Gateways, Azure Public IP addresses and Azure VNET will be deployed"
}

variable "use_existing_resource_group" {
    type = bool
    description = "Whether to deploy a resource group in the Azure Subscription where the gateways will be deployed or create a new resource group"
    default = false
}

variable "gateway_name" {
    type = string
    description = "Name of the Aviatrix Gateway"
}


variable "controller_nsg_name" {
    type = string
    description = "Name of the Network Security Group attached to the Aviatrix Controller Network Interface"  
}

variable "controller_nsg_resource_group_name" {
    type = string
    description = "Name of the Resource Group where the Network Security Group attached to the Aviatrix Controller Network Interface is deployed"  
}

variable "controller_nsg_rule_priority" {
    type = number
    description = "Priority of the rule that will be created in the existing Network Security Group attached to the Aviatrix Controller Network Interface. This number must be unique. Valid values are 100-4096"
    
    validation {
      condition = var.controller_nsg_rule_priority >= 100 && var.controller_nsg_rule_priority <= 4096
      error_message = "Priority must be a number between 100 and 4096"
    }
}

variable "ha_enabled" {
    type = bool
    description = "Whether HAGW will be deployed. Defaults to true"
    default = false
}
