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

variable "cloud" {
  description = "Cloud type"
  type        = string

  validation {
    condition     = contains(["aws", "azure", "oci", "ali", "gcp"], lower(var.cloud))
    error_message = "Invalid cloud type. Choose AWS, Azure, GCP, ALI or OCI."
  }
}

variable "cidr" {
  description = "Set vpc cidr"
  type        = string
}
/*
variable "instance_size" {
  description = "Set vpc cidr"
  type        = string
}
*/
variable "region" {
  description = "Set regions"
  type        = string
}

variable "rg" {
  description = "Set RG"
  type        = string
}

variable "localasn" {
  description = "Set internal BGP ASN"
  type        = string
}

variable "bgp_advertise_cidrs" {
  description = "Define a list of CIDRs that should be advertised via BGP."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Map of tags to assign to the gateway."
  type        = map(string)
  default     = null
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


/*
variable "tags" {
    type = map
    description = "Tags to be applied to the public IP addresses created for the gateways. Make sure to use the correct format depending on the cloud you are deploying"
    default = {}
}
*/

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
    default = true
}

# ARS

variable "vnetname" {
  description = "Name to be used for Azure Route Server related components."
  type        = string
  default = "ars-vnet-testbgplan"
}

variable "ars_name" {
  description = "ars name"
  type        = string
  default = "ars48"
}


variable "ars_cidr" {
  description = "ars cidr"
  type        = string
  default = "10.48.0.0/24"
}



# vng stuff
variable "vng_pip_az_zones" {
  description = "Provide list of availability zones for VNG Public IP"
  type        = list(any)
  default = [ 1,2,3 ]
}


variable "csr_asn" {
  description = "CSR ASN number, cannot be 65520"
  default = 65032
}

variable "ipsec_psk" {
  description = "Provide IPSec Pre-shared key"
  default = "ICqCqDaQLgf86cCw"
}