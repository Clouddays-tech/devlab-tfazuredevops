
# Terraform with Azure Devops pipeline

This lab will guide you through the creation of Azure resources. Those are required to setup Azure Devops pipeline with terraform. CI/CD pipeline retrieves the required credentials/ keys from the Azure keyvault and terraform backend file is using Azure Storage account backend. This lab will create using bash shell with Azure CLI installed. Feel free to use Azure Cloud bash shell to complete this lab. 

## Pre-requisities

1) [Azure Cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
2) Azure Subscription


## Demo 

Create resource group, storage account and blob container to store the Terraform backend state file. 
Storage account access key will require to retrieve/read the terraform backend file.

First login to Azure Cloud, type `az login`. the browser will prompt to authenticate with your credentials. 
Once authentication is successful, verify by typing `az account show` command. 


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

# Query the Storage account keys
SUBID=$(az account show --query id --output tsv)
devlabstg_key1=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv)
devlabstg_key2=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query "[1].value" --output tsv)

```
Create Azure AD service principal and assign contibutor role to subscription scope. 
You may want to assign more restricted resources like Azure resource group

```
# Create service principal for authentication
SPN=$(az ad sp create-for-rbac -n $SPN_NAME --role Contributor --scopes subscriptions/$SUBID -o json)
```

View the stored environment variable of SPN client id and secret.

```
echo $SPN | jq
echo $SPN | jq -r '.appId'
```

Then, set the variables again for Azure keyvault secret keys. 

```
# Set Variables
SPN_CLIENT_ID=$(az ad sp list --filter "displayName eq '$SPN_NAME'" --query '[0].appId' --output tsv)
SPN_SECRET=$(echo $SPN | jq -r '.password')
TENANTID=$(echo $SPN | jq -r '.tenant')
clientid_name="spn-client-id"
clientsecret="spn-client-secret"
tenantid="spn-tenant-id"
key1name="devlabstg-key1"
key2name="devlabstg-key2"
```

Create Azure key vault and assign get,list permissions to service principal created earlier. 

```bash
#### Create Key Vault
az keyvault create -l $LOCATION --name $KV_NAME --resource-group $RESOURCE_GROUP_NAME --enable-rbac-authorization false

# Set Access Policy
az keyvault set-policy --name $KV_NAME --spn $SPN_CLIENT_ID --secret-permissions get list
```

Set secret key to store in Azure keyvault.

```
# Create KeyVault Secret keys
az keyvault secret set --vault-name $KV_NAME --name $clientid_name --value $SPN_CLIENT_ID
az keyvault secret set --vault-name $KV_NAME --name $clientsecret --value $SPN_SECRET
az keyvault secret set --vault-name $KV_NAME --name $tenantid --value $TENANTID
az keyvault secret set --vault-name $KV_NAME --name $key1name --value $devlabstg_key1
az keyvault secret set --vault-name $KV_NAME --name $key2name --value $devlabstg_key2
az keyvault secret set --vault-name $KV_NAME --name sub-id --value $SUBID
```

There is terraform codes in this repo which just create sample azure resource group, terraform can try authenticate and create using the service principal.
```
# Logout the current session 
az logout

# terraform command 
cd terraform

terraform init -backend-config="access_key=${devlabstg_key1}"

terraform plan -out=tfplan -var="spn-client-id=${SPN_CLIENT_ID}" -var="spn-client-secret=${SPN_SECRET}" -var="spn-tenant-id=${TENANTID}" -var="subscription_id=${SUBID}"

tf apply tfplan
```
Users are typically use email id and password to connect Azure. But system account like Azure Devops pipeline will be more securely connect using service principal and managed identities. 

```
az login --service-principal --username $(echo $SPN | jq -r '.appId') \
                             --password $(echo $SPN | jq -r '.password') \
                             --tenant   $(echo $SPN | jq -r '.tenant')

az group list -o table
```








