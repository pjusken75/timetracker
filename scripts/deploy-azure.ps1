# TimeTracker Azure Deployment Script (PowerShell)
# This script deploys the complete infrastructure to Azure

param(
    [Parameter(Mandatory=$true)]
    [string]$Environment
)

# Configuration
$AppName = "timetracker"
$Location = "East US"
$ResourceGroup = "rg-$AppName-$Environment"

# Function to write colored output
function Write-Status($Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success($Message) {
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning($Message) {
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error($Message) {
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

try {
    Write-Status "Starting deployment for $Environment environment..."

    # Check if Azure CLI is installed
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        Write-Error "Azure CLI is not installed. Please install it first."
        exit 1
    }

    # Check if user is logged in
    $account = az account show 2>$null
    if (-not $account) {
        Write-Warning "You are not logged in to Azure. Please run 'az login' first."
        exit 1
    }

    Write-Status "Checking if resource group exists..."
    $rgExists = az group show --name $ResourceGroup 2>$null
    if (-not $rgExists) {
        Write-Status "Creating resource group: $ResourceGroup"
        az group create --name $ResourceGroup --location $Location
        Write-Success "Resource group created successfully"
    } else {
        Write-Status "Resource group $ResourceGroup already exists"
    }

    # Change to infrastructure directory
    $ScriptDir = Split-Path $MyInvocation.MyCommand.Path
    $InfraDir = Join-Path (Split-Path $ScriptDir) "infrastructure"
    Set-Location $InfraDir

    # Validate Bicep template
    Write-Status "Validating Bicep template..."
    $validation = az deployment group validate --resource-group $ResourceGroup --template-file "main.bicep" --parameters "@parameters.$Environment.json" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Template validation passed"
    } else {
        Write-Error "Template validation failed"
        exit 1
    }

    # Deploy infrastructure
    Write-Status "Deploying infrastructure to Azure..."
    $DeploymentName = "timetracker-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

    $deployment = az deployment group create --name $DeploymentName --resource-group $ResourceGroup --template-file "main.bicep" --parameters "@parameters.$Environment.json"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Infrastructure deployed successfully!"
        
        # Get deployment outputs
        Write-Status "Retrieving deployment information..."
        
        $ApiUrl = az deployment group show --name $DeploymentName --resource-group $ResourceGroup --query "properties.outputs.apiAppServiceUrl.value" -o tsv
        $WebUrl = az deployment group show --name $DeploymentName --resource-group $ResourceGroup --query "properties.outputs.staticWebAppUrl.value" -o tsv
        $SqlServer = az deployment group show --name $DeploymentName --resource-group $ResourceGroup --query "properties.outputs.sqlServerName.value" -o tsv
        
        Write-Host ""
        Write-Success "🎉 Deployment completed successfully!"
        Write-Host ""
        Write-Host "📱 Application URLs:" -ForegroundColor Cyan
        Write-Host "   Frontend: $WebUrl"
        Write-Host "   API:      $ApiUrl"
        Write-Host ""
        Write-Host "💾 Database:" -ForegroundColor Cyan
        Write-Host "   SQL Server: $SqlServer.database.windows.net"
        Write-Host ""
        Write-Host "📋 Next steps:" -ForegroundColor Cyan
        Write-Host "   1. Configure Azure AD B2C settings"
        Write-Host "   2. Run database migrations"
        Write-Host "   3. Deploy application code"
        Write-Host "   4. Configure CI/CD pipeline"
        Write-Host ""
        
    } else {
        Write-Error "Deployment failed!"
        exit 1
    }
    
} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    exit 1
}