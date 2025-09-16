#!/bin/bash

# TimeTracker Azure Deployment Script
# This script deploys the complete infrastructure to Azure

set -e

# Configuration
APP_NAME="timetracker"
LOCATION="East US"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if environment parameter is provided
if [ -z "$1" ]; then
    print_error "Usage: $0 <environment>"
    print_error "Example: $0 dev"
    print_error "Example: $0 prod"
    exit 1
fi

ENVIRONMENT=$1
RESOURCE_GROUP="rg-${APP_NAME}-${ENVIRONMENT}"

print_status "Starting deployment for ${ENVIRONMENT} environment..."

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    print_warning "You are not logged in to Azure. Please run 'az login' first."
    exit 1
fi

print_status "Checking if resource group exists..."
if ! az group show --name $RESOURCE_GROUP &> /dev/null; then
    print_status "Creating resource group: $RESOURCE_GROUP"
    az group create --name $RESOURCE_GROUP --location "$LOCATION"
    print_success "Resource group created successfully"
else
    print_status "Resource group $RESOURCE_GROUP already exists"
fi

# Validate Bicep template
print_status "Validating Bicep template..."
if az deployment group validate \
    --resource-group $RESOURCE_GROUP \
    --template-file main.bicep \
    --parameters @parameters.${ENVIRONMENT}.json > /dev/null; then
    print_success "Template validation passed"
else
    print_error "Template validation failed"
    exit 1
fi

# Deploy infrastructure
print_status "Deploying infrastructure to Azure..."
DEPLOYMENT_NAME="timetracker-deployment-$(date +%Y%m%d-%H%M%S)"

if az deployment group create \
    --name $DEPLOYMENT_NAME \
    --resource-group $RESOURCE_GROUP \
    --template-file main.bicep \
    --parameters @parameters.${ENVIRONMENT}.json; then
    
    print_success "Infrastructure deployed successfully!"
    
    # Get deployment outputs
    print_status "Retrieving deployment information..."
    
    API_URL=$(az deployment group show --name $DEPLOYMENT_NAME --resource-group $RESOURCE_GROUP --query "properties.outputs.apiAppServiceUrl.value" -o tsv)
    WEB_URL=$(az deployment group show --name $DEPLOYMENT_NAME --resource-group $RESOURCE_GROUP --query "properties.outputs.staticWebAppUrl.value" -o tsv)
    SQL_SERVER=$(az deployment group show --name $DEPLOYMENT_NAME --resource-group $RESOURCE_GROUP --query "properties.outputs.sqlServerName.value" -o tsv)
    
    echo ""
    print_success "🎉 Deployment completed successfully!"
    echo ""
    echo "📱 Application URLs:"
    echo "   Frontend: $WEB_URL"
    echo "   API:      $API_URL"
    echo ""
    echo "💾 Database:"
    echo "   SQL Server: $SQL_SERVER.database.windows.net"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Configure Azure AD B2C settings"
    echo "   2. Run database migrations"
    echo "   3. Deploy application code"
    echo "   4. Configure CI/CD pipeline"
    echo ""
    
else
    print_error "Deployment failed!"
    exit 1
fi