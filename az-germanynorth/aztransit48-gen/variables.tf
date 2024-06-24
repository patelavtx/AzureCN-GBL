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

variable "gateway_name" {
    type = string
    description = "Name of the Aviatrix Gateway"
}

