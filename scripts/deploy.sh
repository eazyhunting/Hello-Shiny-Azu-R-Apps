#!/bin/bash

# Variables
RESOURCE_GROUP="shiny-$RANDOM-rg"
LOCATION="eastus"
ACR_NAME="shinyacr$RANDOM"  # Ensure ACR name is globally unique
IMAGE_NAME="shiny-app:latest"
WEB_APP_NAME="shiny-webapp-$RANDOM"  # Ensure Web App name is globally unique
PLAN_NAME="shiny-app-plan-$RANDOM"  # Ensure App Service Plan name is globally unique

# Step 1: Create a Resource Group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Step 2: Create an Azure Container Registry (ACR)
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --admin-enabled true

# Step 3: Log in to ACR
az acr login --name $ACR_NAME --resource-group $RESOURCE_GROUP

# Step 4: Tag the Docker image with the ACR login server
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "loginServer" --output tsv)
docker tag shiny-hello-world-shiny-app:latest $ACR_LOGIN_SERVER/$IMAGE_NAME

# Step 5: Push the Docker image to ACR
docker push $ACR_LOGIN_SERVER/$IMAGE_NAME

# Step 6: Create an App Service Plan
az appservice plan create --name $PLAN_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --sku B1 --is-linux

# Step 7: Create a Web App for Containers
az webapp create --resource-group $RESOURCE_GROUP --plan $PLAN_NAME --name $WEB_APP_NAME \
    --deployment-container-image-name $ACR_LOGIN_SERVER/$IMAGE_NAME

# Step 8: Configure Web App to Use ACR
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "username" --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "passwords[0].value" --output tsv)

az webapp config container set --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP \
    --container-image-name $ACR_LOGIN_SERVER/$IMAGE_NAME \
    --container-registry-url https://$ACR_LOGIN_SERVER \
    --container-registry-user $ACR_USERNAME \
    --container-registry-password $ACR_PASSWORD

# Step 9: Restart the Web App
az webapp restart --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP

# Step 10: Output the Web App URL
WEB_APP_URL=$(az webapp show --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP --query "defaultHostName" --output tsv)
echo "Your Shiny app is deployed and accessible at: http://$WEB_APP_URL"
