
# Terraform with Azure Devopspipeline

This lab will guide you through the creation of Azure resources. This is using bash with Azure CLI installed. Azure Cloud bash shell can also be used to complete this lab.

## Pre-requisities

1) [Azure Cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
2) Azure Subscription


## Demo 

Create resource group, storage account and blob container to store the Terraform backend state file. 
Storage account access key will require to retrieve/read the terraform backend file.

```bash

# Set variables
RESOURCE_GROUP_NAME=devop-rsg
STORAGE_ACCOUNT_NAME=devopsstgacc
STORAGE_CONTAINER_NAME=devops-blob
LOCATION=EastUS
SPN_NAME=devops-spn002
KV_NAME=devops-kvlt002

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $STORAGE_CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

## Storage account access key is required to access storage account key/secrets.

# Query the Storage account key
SUBID=$(az account show --query id --output tsv)
devlabstg_key1=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv)
devlabstg_key2=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query "[1].value" --output tsv)

```
Create Azure AD service principal and assign contibutor role to subscription scope. 
You may want to assign more restricted resources like Azure resource group

`
# Create service principal for authentication
SPN=$(az ad sp create-for-rbac -n $SPN_NAME --role Contributor --scopes subscriptions/$SUBID -o json)
`
View the stored environment variable of SPN client id and secret.

`
echo $SPN | jq
echo $SPN | jq -r '.appId'
`





