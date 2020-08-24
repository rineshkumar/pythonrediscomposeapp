#!/bin/bash
LOCATION='westus'
RESOURCE_GROUP='mrrkrg'
AKS_CLUSTER_NAME='mrrkakscluster'
ACR_NAME='mrrkacr'
SQL_SERVER_NAME='mrrksqlserver'


version=$(az aks get-versions -l $LOCATION --query 'orchestrators[-1].orchestratorVersion' -o tsv)
echo "Using AKS Version as $version"

echo "Creating resource group $RESOURCE_GROUP at location $LOCATION"
az group create --name $RESOURCE_GROUP --location $LOCATION

echo "Creating aks cluster in resource group $RESOURCE_GROUP at location $LOCATION with name $AKS_CLUSTER_NAME"

az aks create --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --enable-addons monitoring --kubernetes-version $version --generate-ssh-keys --location $LOCATION
echo "Creating acr in resource group $RESOURCE_GROUP with name $ACR_NAME"
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Standard --location $LOCATION
 # Get the id of the service principal configured for AKS
CLIENT_ID=$(az aks show --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --query "servicePrincipalProfile.clientId" --output tsv)
echo "id of the aks service principle is $CLIENT_ID"
# Get the ACR registry resource id
ACR_ID=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "id" --output tsv)
echo "acr id is $ACR_ID"
# Create role assignment
echo "giving pull role to aks principal id in acr"
az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID
echo "creating sql server with name $SQL_SERVER_NAME"
 az sql server create -l $LOCATION -g $RESOURCE_GROUP -n $SQL_SERVER_NAME -u sqladmin -p P2ssw0rd1234
 echo "Creating database with name mhcdb in server $SQL_SERVER_NAME"
  az sql db create -g $RESOURCE_GROUP -s $SQL_SERVER_NAME -n mhcdb --service-objective S0
