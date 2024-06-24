# AzureCN-GBL

##  Aviatrix Auzre Controller in Azure China NSG Management for Aviatrix Gateways Deployed in Azure China

## Description

### Note:

This Terraform module automates the creation of NSG rules in the NSG attached to an Aviatrix Controller deployed in Azure China to allow communication with Aviatrix Gateways. This is needed because Avitrix Controllers deployed in Azure China doesn't support Security Group Management; this makes deploying Aviatrix Gateways through automation using Terraform challenging, requiring users to manually add the public IP addresses of the gateways to the NSG attached to the controller before the gateway creation times out.

This Terraform module:

- Is limited to deployments in Azure China.
- Doesn't create any Aviatrix resources. It is intended to be used in conjunction with [mc-transit](https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-transit/aviatrix/latest), [mc-spoke](https://registry.terraform.io/modules/terraform-aviatrix-modules/mc-spoke/aviatrix/latest) modules, Aviatrix Transit or Spoke gateway resources.
- Supports Azure controller deployment with only 6.7 and above versions.
- Creates one or two Standard Public IP addresses to be associated with the gateways.
- Adds a security rule to the existing NSG associated with an Azure Controller deployed in China




## Examples

###  aztransitfnet84-cn 

Example of deploying Aviatrix Transit in Azure China
Example of *tfvars
```
controller_ip = ""
ctrl_password = "Aviatrix123#"
account       = "AzCN-proj"
cloud         = "Azure"
cidr          = "10.84.28.0/23"
region        = "China East"
rg            = "atulrg-tx84"
localasn      = "65084"
tags = {
  ProjectName        = "CN test"
  BusinessOwnerEmail = "apatel@aviatrix.com"
}

# nsg_management
gateway_resource_group = "atulrg-cntx84"
#gateway_region = "China North 3"
gateway_name = "aztransit84-cn3"
controller_nsg_name = "azCN-ctl-security-group"
controller_nsg_resource_group_name = "AZCN-CTL-RG" 
controller_nsg_rule_priority = "100"
```



###  azspoke-dev85-cn

Example of deploying Aviatrix Spoke in Azure China
Example of *tfvars

```
controller_ip = ""
ctrl_password = "Aviatrix123#"
name          = "azcn3-spoke85"
cidr          = "10.85.1.0/24"
account      = "AzCN-proj"
transit_gw   = "aztransit84-cn3"
attached     = "true"
nat_attached = "false"
ha_gw        = "false"


tags = {
  ProjectName        = "CN test"
  BusinessOwnerEmail = "apatel@aviatrix.com"
}


spoke_cidrs = ["10.85.1.0/24",]
gw1_snat    = "10.255.185.1"
gw2_snat    = "10.255.185.2"
dnatip      = "10.185.1.20"
dnatip2     = "10.185.1.53"
dstcidr     = "10.255.185.251/32"
dstcidr2    = "10.255.185.252/32"


# *** REMEMBER to set controller_nsg ***
# nsg_management
gateway_resource_group = "atulrg-cnspk85"
#gateway_region = "China East"
gateway_name = "azcn3-spoke85"
controller_nsg_name = "azCN-ctl-security-group"
controller_nsg_resource_group_name = "azCN-ctl-rg" 
controller_nsg_rule_priority = "110"
```


###   az-germanynorth 

Example of deploying Aviatrix Transit + Spoke outside China
Added as a comparison.
Example of *tfvars

```
controller_ip = ""
ctrl_password = "Aviatrix123#"
name          = "az-spoke58-gec"
cidr          = "10.58.1.0/24"
region       = "Germany West Central"
account      = "AZ-proj"
transit_gw   = "aztransit48-gec"
attached     = "true"
nat_attached = "false"
ha_gw        = "false"


tags = {
  ProjectName        = "vWAN migration proj"
  BusinessOwnerEmail = "apatel@aviatrix.com"
}


spoke_cidrs = ["10.85.1.0/24",]
gw1_snat    = "10.255.185.1"
gw2_snat    = "10.255.185.2"
dnatip      = "10.185.1.20"
dnatip2     = "10.185.1.53"
dstcidr     = "10.255.185.251/32"
dstcidr2    = "10.255.185.252/32"
```


## Prerequisites

1. [Terraform v0.13+](https://www.terraform.io/downloads.html) - execute terraform files


## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.52 |


## Procedures for Running this Module

### 1. Authenticating to Azure

Set the environment in Azure CLI to Azure China:

```shell
az cloud set -n AzureChinaCloud
```

Login to the Azure CLI using:

```shell
az login --use-device-code
````
*Note: Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs#authenticating-to-azure-active-directory) for different methods of authentication to Azure, incase above command is not applicable.*

Pick the subscription you want and use it in the command below.

```shell
az account set --subscription <subscription_id>
```

Set environment variables ARM_ENDPOINT and ARM_ENVIRONMENT to use Azure China endpoints:

  ``` shell
  export ARM_ENDPOINT=https://management.chinacloudapi.cn
  export ARM_ENVIRONMENT=china
  ```

If executing this code from a CI/CD pipeline, the following environment variables are required. The service principal used to authenticate the CI/CD tool into Azure must either have subscription owner role or a custom role that has `Microsoft.Authorization/roleAssignments/write` to be able to succesfully create the role assignments required

``` shell
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

### 2. Applying Terraform configuration

> Note: The public IP addresses, VNET and Gateways must all reside in the same Resource Group. If you are deploying Spoke Gateways to an existing VNET set parameter "use_existing_resource_group" to true and use the resource group name of the VNET

```hcl

provider azurerm {
    alias = "gateways"
    tenant_id = "12345678-abcd-abcd-abcd-1234567890ab"
    subscription_id = "12345678-abcd-abcd-abcd-1234567890ab"
    environment = "china"
    features {}
}

provider azurerm {
    alias = "controller"
    tenant_id = "12345678-abcd-abcd-abcd-1234567890ab"
    subscription_id = "12345678-abcd-abcd-abcd-1234567890ab"
    environment = "china"
    features {}
}

module "azure-gateway-nsg" {
  providers = {
    azurerm.gateways =azurerm.gateways
    azurerm.controller = azurerm.controller
  }
  source                                      = "github.com/jocortems/aviatrix_controller_nsg_management_azure_china"
  gateway_resource_group                      = var.gateway_resource_group        # Required. The name of the resource group where the Aviatrix Gateways will be deployed
  use_existing_resource_group                 = true/false                        # Optional. Defaults to false. Whether to create a new resource group or use an existing one
  gateway_name                                = "example-gw"                      # Required. This is used to derive the name for the Public IP addresses that will be used by the Aviatrix Gateway
  gateway_region                              = "China North 3"                   # Required. Azure China Region where the Aviatrix Gateways will be deployed
  tags                = {                                                         # Optional. These tags are only for the public IP addresses that will be created. In addition to the specified tags here the following tags are added {avx-gw-association = format("%s-gw", var.gateway_name), avx-created-resource = "DO-NOT-DELETE"} 
                          user = "jorge",
                          environment = "testing"
                        }
  ha_enabled                                  = true/false                         # Optional. Defaults to true. If set to false only one Public IP address is created and must disable ha_gw when creating Aviatrix spoke or transit gateways              
  controller_nsg_name                         = "controller-nsg"                   # Required. Name of the NSG associated with the Aviatrix Controller
  controller_nsg_resource_group_name          = "controller-nsg-rg"                # Required. Name of the resource group where the NSG associated with the Aviatrix Controller is deployed
  controller_nsg_rule_priority                = 300                                # Required. This number must be unique. Before running this module verify the priority number is available in the NSG associated with the Aviatrix Controller
}


module "mc-transit" {
  source                                      = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version                                     = "2.3.2"
  name                                        = "avx-transit-vnet"
  account                                     = "azure-account"
  cloud                                       = "Azure"
  region                                      = "China North 3"
  az_support                                  = false
  gw_name                                     = "example-gw"
  resource_group                              = module.azure-gateway-nsg.gateway_resource_group
  cidr                                        = "172.16.0.0/23"
  allocate_new_eip                            = false
  ha_azure_eip_name_resource_group            = format("%s:%s", module.azure-gateway-nsg.gateway_ha_vip.name, module.azure-gateway-nsg.gateway_ha_vip.resource_group_name)
  azure_eip_name_resource_group               = format("%s:%s", module.azure-gateway-nsg.gateway_vip.name, module.azure-gateway-nsg.gateway_vip.resource_group_name)
  eip                                         = module.azure-gateway-nsg.gateway_vip.ip_address
  ha_eip                                      = module.azure-gateway-nsg.gateway_vip.ip_address
}
```

### Execute

```shell
terraform init
terraform apply --var-file=<terraform.tfvars>
````

## **Disclaimer**:

The material embodied in this software/code is provided to you "as-is" and without warranty of any kind, express, implied or otherwise, including without limitation, any warranty of fitness for a particular purpose. In no event shall the Aviatrix Inc. be liable to you or anyone else for any direct, special, incidental, indirect or consequential damages of any kind, or any damages whatsoever, including without limitation, loss of profit, loss of use, savings or revenue, or the claims of third parties, whether or not Aviatrix Inc. has been advised of the possibility of such loss, however caused and on any theory of liability, arising out of or in connection with the possession, use or performance of this software/code.