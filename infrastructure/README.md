# Azure Infrastructure for TimeTracker

This directory contains the Infrastructure as Code (IaC) templates for deploying the TimeTracker application to Azure.

## Architecture Overview

The infrastructure consists of:

- **App Service Plan** - Hosts the .NET API
- **App Service** - Runs the .NET 9 Web API
- **Static Web App** - Hosts the React frontend  
- **SQL Server & Database** - Data storage
- **Azure AD B2C** - User authentication
- **Application Insights** - Monitoring and analytics
- **Key Vault** - Secure secret storage

## Prerequisites

1. **Azure CLI** installed and authenticated
2. **Azure subscription** with appropriate permissions
3. **Resource Group** created for the deployment

## Quick Deploy

### 1. Create Resource Group
```bash
az group create --name rg-timetracker-dev --location "East US"
```

### 2. Deploy Infrastructure
```bash
# Deploy to development
az deployment group create \
  --resource-group rg-timetracker-dev \
  --template-file main.bicep \
  --parameters @parameters.dev.json

# Deploy to production  
az deployment group create \
  --resource-group rg-timetracker-prod \
  --template-file main.bicep \
  --parameters @parameters.prod.json
```

### 3. Configure Azure AD B2C

After deployment, you'll need to manually configure Azure AD B2C:

1. Go to the Azure portal
2. Navigate to your B2C tenant
3. Create user flows for sign-up/sign-in
4. Register applications for API and Frontend
5. Update the configuration in your applications

## Environment-Specific Parameters

### Development (`parameters.dev.json`)
- Uses Basic/Standard SKUs for cost optimization
- Enables development features
- Uses development-friendly settings

### Production (`parameters.prod.json`)  
- Uses Premium SKUs for performance
- Enables production security features
- Optimized for scale and reliability

## Post-Deployment Configuration

1. **Database Setup**
   - Run Entity Framework migrations
   - Seed initial data if needed

2. **Application Settings**
   - Update connection strings
   - Configure Azure AD B2C settings
   - Set up Application Insights

3. **SSL Certificates**
   - Configure custom domains (production)
   - Set up SSL certificates

4. **CI/CD Pipeline**
   - Configure GitHub Actions
   - Set up deployment slots

## Monitoring and Maintenance

- **Application Insights** provides real-time monitoring
- **Key Vault** securely stores all secrets
- **SQL Database** includes automatic backups
- **App Service** includes built-in scaling options

## Cost Optimization

Development environment uses:
- **App Service Plan**: Basic B1 (~$13/month)
- **SQL Database**: Standard S0 (~$15/month)  
- **Static Web App**: Free tier
- **Application Insights**: Pay-as-you-go

Total estimated cost for development: ~$30/month

## Security Features

- **HTTPS Only** enforced on all web services
- **SQL Server** with firewall rules
- **Key Vault** for secret management
- **Azure AD B2C** for secure authentication
- **Managed Identity** for service-to-service auth

## Scaling

The infrastructure is designed to scale:
- **App Service** supports auto-scaling
- **SQL Database** can scale up/out as needed
- **Static Web App** scales automatically
- **Application Insights** scales with usage