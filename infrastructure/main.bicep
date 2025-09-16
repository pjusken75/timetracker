// Main Bicep template for TimeTracker infrastructure
// This template creates all Azure resources needed for the application

@description('Name of the application')
param appName string = 'timetracker'

@description('Environment (dev, staging, prod)')
param environment string = 'dev'

@description('Location for all resources')
param location string = resourceGroup().location

@description('SKU for App Service Plan')
@allowed(['F1', 'B1', 'B2', 'S1', 'S2', 'P1v2', 'P2v2'])
param appServicePlanSku string = 'B1'

@description('SKU for SQL Database')
@allowed(['Basic', 'S0', 'S1', 'S2', 'P1', 'P2'])
param sqlDatabaseSku string = 'S0'

@description('Admin username for SQL Server')
param sqlAdminLogin string = 'sqladmin'

@description('Admin password for SQL Server')
@secure()
param sqlAdminPassword string

// Variables
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 6)
var resourcePrefix = '${appName}-${environment}-${uniqueSuffix}'

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${resourcePrefix}-plan'
  location: location
  sku: {
    name: appServicePlanSku
    tier: appServicePlanSku == 'F1' ? 'Free' : appServicePlanSku == 'B1' ? 'Basic' : 'Standard'
  }
  properties: {
    reserved: false
  }
  tags: {
    Environment: environment
    Application: appName
  }
}

// Web API App Service
resource apiAppService 'Microsoft.Web/sites@2023-01-01' = {
  name: '${resourcePrefix}-api'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v9.0'
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: environment == 'prod' ? 'Production' : 'Development'
        }
        {
          name: 'ConnectionStrings__DefaultConnection'
          value: 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDatabase.name};Persist Security Info=False;User ID=${sqlAdminLogin};Password=${sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
        }
        {
          name: 'AzureAdB2C__Instance'
          value: 'https://${azureAdB2CTenant.name}.b2clogin.com'
        }
        {
          name: 'AzureAdB2C__Domain'
          value: '${azureAdB2CTenant.name}.onmicrosoft.com'
        }
      ]
    }
  }
  tags: {
    Environment: environment
    Application: appName
    Type: 'API'
  }
}

// Frontend Static Web App
resource staticWebApp 'Microsoft.Web/staticSites@2023-01-01' = {
  name: '${resourcePrefix}-web'
  location: location
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {
    repositoryUrl: 'https://github.com/pjusken75/timetracker'
    branch: 'main'
    buildProperties: {
      appLocation: '/src/web'
      apiLocation: ''
      outputLocation: 'dist'
    }
  }
  tags: {
    Environment: environment
    Application: appName
    Type: 'Frontend'
  }
}

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: '${resourcePrefix}-sql'
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
  tags: {
    Environment: environment
    Application: appName
  }
}

// SQL Database
resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: '${appName}-${environment}-db'
  location: location
  sku: {
    name: sqlDatabaseSku
    tier: sqlDatabaseSku == 'Basic' ? 'Basic' : 'Standard'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2GB
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
  }
  tags: {
    Environment: environment
    Application: appName
  }
}

// SQL Server Firewall Rule for Azure Services
resource sqlFirewallRule 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Azure AD B2C Tenant (Note: This requires manual setup as B2C tenants can't be created via ARM/Bicep)
resource azureAdB2CTenant 'Microsoft.AzureActiveDirectory/b2cDirectories@2021-04-01' = {
  name: '${resourcePrefix}b2c'
  location: 'United States'
  properties: {
    createTenantProperties: {
      displayName: '${appName} ${environment} B2C'
      countryCode: 'US'
    }
  }
  sku: {
    name: 'PremiumP1'
    tier: 'A0'
  }
  tags: {
    Environment: environment
    Application: appName
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${resourcePrefix}-insights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtension'
  }
  tags: {
    Environment: environment
    Application: appName
  }
}

// Key Vault for storing secrets
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${resourcePrefix}-kv'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    accessPolicies: [
      {
        tenantId: tenant().tenantId
        objectId: apiAppService.identity.principalId
        permissions: {
          secrets: ['get', 'list']
        }
      }
    ]
    enableRbacAuthorization: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
  tags: {
    Environment: environment
    Application: appName
  }
}

// Outputs
output apiAppServiceName string = apiAppService.name
output apiAppServiceUrl string = 'https://${apiAppService.properties.defaultHostName}'
output staticWebAppName string = staticWebApp.name
output staticWebAppUrl string = 'https://${staticWebApp.properties.defaultHostname}'
output sqlServerName string = sqlServer.name
output sqlDatabaseName string = sqlDatabase.name
output applicationInsightsConnectionString string = appInsights.properties.ConnectionString
output keyVaultName string = keyVault.name
output resourceGroupName string = resourceGroup().name