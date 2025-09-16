# TimeTracker Development Environment Manager (PowerShell)
# This script helps manage the local development environment

param(
    [Parameter(Mandatory=$false)]
    [string]$Command = "help",
    
    [Parameter(Mandatory=$false)]
    [string]$Service = ""
)

# Function to write colored output
function Write-Header() {
    Write-Host "================================" -ForegroundColor Magenta
    Write-Host "  TimeTracker Development Tool  " -ForegroundColor Magenta
    Write-Host "================================" -ForegroundColor Magenta
    Write-Host ""
}

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

# Check prerequisites
function Test-Prerequisites() {
    Write-Status "Checking prerequisites..."
    
    # Check Docker
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Error "Docker is not installed. Please install Docker first."
        exit 1
    }
    
    # Check Docker Compose
    if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
        Write-Error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    }
    
    # Check Node.js
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Warning "Node.js is not installed. You'll need it for local development."
    }
    
    # Check .NET
    if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
        Write-Warning ".NET SDK is not installed. You'll need it for local development."
    }
    
    Write-Success "Prerequisites check completed"
}

# Setup development environment
function Initialize-DevEnvironment() {
    Write-Status "Setting up development environment..."
    
    # Create .env.local if it doesn't exist
    if (-not (Test-Path "src/web/.env.local")) {
        Write-Status "Creating frontend environment file..."
        Copy-Item "src/web/.env.example" "src/web/.env.local"
        Write-Success "Created src/web/.env.local from template"
        Write-Warning "Please update the Azure AD B2C settings in .env.local"
    }
    
    # Install frontend dependencies
    Write-Status "Installing frontend dependencies..."
    Set-Location "src/web"
    npm install
    Set-Location "../.."
    Write-Success "Frontend dependencies installed"
    
    # Restore backend dependencies
    Write-Status "Restoring backend dependencies..."
    Set-Location "src/api"
    dotnet restore
    Set-Location "../.."
    Write-Success "Backend dependencies restored"
    
    Write-Success "Development environment setup completed!"
}

# Start services with Docker
function Start-DockerServices() {
    Write-Status "Starting services with Docker..."
    docker-compose up -d
    Write-Success "Services started! Check status with: .\dev.ps1 status"
}

# Start services locally (without Docker)
function Start-LocalServices() {
    Write-Status "Starting services locally..."
    
    # Start SQL Server with Docker (lightweight option)
    Write-Status "Starting SQL Server..."
    docker-compose up -d sqlserver
    
    # Wait for SQL Server to be ready
    Write-Status "Waiting for SQL Server to be ready..."
    Start-Sleep 10
    
    # Start API in background
    Write-Status "Starting .NET API..."
    $ApiJob = Start-Job -ScriptBlock {
        Set-Location $using:PWD
        Set-Location "src/api"
        dotnet run
    }
    
    # Start Frontend in background
    Write-Status "Starting React frontend..."
    $WebJob = Start-Job -ScriptBlock {
        Set-Location $using:PWD
        Set-Location "src/web"
        npm run dev
    }
    
    Write-Success "Services started locally!"
    Write-Host "API: http://localhost:5000" -ForegroundColor Cyan
    Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "SQL Server: localhost:1433" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press Ctrl+C to stop all services" -ForegroundColor Yellow
    
    # Wait for jobs or interruption
    try {
        while ($ApiJob.State -eq "Running" -or $WebJob.State -eq "Running") {
            Start-Sleep 1
        }
    }
    finally {
        Write-Status "Stopping services..."
        Stop-Job $ApiJob, $WebJob -ErrorAction SilentlyContinue
        Remove-Job $ApiJob, $WebJob -ErrorAction SilentlyContinue
        docker-compose stop sqlserver
    }
}

# Stop all services
function Stop-AllServices() {
    Write-Status "Stopping all services..."
    docker-compose down
    
    # Stop any running .NET or Node processes
    Get-Process | Where-Object { $_.ProcessName -like "*dotnet*" -or $_.ProcessName -like "*node*" } | 
        Where-Object { $_.MainWindowTitle -like "*TimeTracker*" } | 
        Stop-Process -Force -ErrorAction SilentlyContinue
    
    Write-Success "All services stopped"
}

# Show status
function Show-ServiceStatus() {
    Write-Status "Service Status:"
    Write-Host ""
    docker-compose ps
}

# Show logs
function Show-ServiceLogs($ServiceName) {
    if ([string]::IsNullOrEmpty($ServiceName)) {
        docker-compose logs -f
    } else {
        docker-compose logs -f $ServiceName
    }
}

# Clean up Docker resources
function Clear-DockerResources() {
    Write-Status "Cleaning up Docker resources..."
    docker-compose down -v --remove-orphans
    docker system prune -f
    Write-Success "Cleanup completed"
}

# Run tests
function Invoke-AllTests() {
    Write-Status "Running tests..."
    
    # Backend tests
    Write-Status "Running backend tests..."
    Set-Location "src/api"
    dotnet test
    Set-Location "../.."
    
    # Frontend tests (if configured)
    $packageJson = Get-Content "src/web/package.json" -Raw | ConvertFrom-Json
    if ($packageJson.scripts.test) {
        Write-Status "Running frontend tests..."
        Set-Location "src/web"
        npm test
        Set-Location "../.."
    }
    
    Write-Success "All tests completed"
}

# Database migrations
function Invoke-DatabaseMigrations() {
    Write-Status "Running database migrations..."
    Set-Location "src/api"
    dotnet ef database update
    Set-Location "../.."
    Write-Success "Database migrations completed"
}

# Build production images
function Build-ProductionImages() {
    Write-Status "Building production images..."
    docker-compose -f docker-compose.yml -f docker-compose.prod.yml build
    Write-Success "Production images built"
}

# Main script logic
function Main() {
    Write-Header
    
    switch ($Command.ToLower()) {
        "check" {
            Test-Prerequisites
        }
        "setup" {
            Test-Prerequisites
            Initialize-DevEnvironment
        }
        "start" {
            Test-Prerequisites
            Start-DockerServices
        }
        "start-local" {
            Test-Prerequisites
            Start-LocalServices
        }
        "stop" {
            Stop-AllServices
        }
        "restart" {
            Stop-AllServices
            Start-DockerServices
        }
        "status" {
            Show-ServiceStatus
        }
        "logs" {
            Show-ServiceLogs $Service
        }
        "test" {
            Invoke-AllTests
        }
        "migrate" {
            Invoke-DatabaseMigrations
        }
        "build" {
            Build-ProductionImages
        }
        "clean" {
            Clear-DockerResources
        }
        default {
            Write-Host "TimeTracker Development Tool" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Usage: .\dev.ps1 <command>" -ForegroundColor White
            Write-Host ""
            Write-Host "Commands:" -ForegroundColor Yellow
            Write-Host "  check        Check prerequisites"
            Write-Host "  setup        Setup development environment"
            Write-Host "  start        Start all services with Docker"
            Write-Host "  start-local  Start services locally (hybrid mode)"
            Write-Host "  stop         Stop all services"
            Write-Host "  restart      Restart all services"
            Write-Host "  status       Show service status"
            Write-Host "  logs [svc]   Show logs (optionally for specific service)"
            Write-Host "  test         Run all tests"
            Write-Host "  migrate      Run database migrations"
            Write-Host "  build        Build production images"
            Write-Host "  clean        Clean up Docker resources"
            Write-Host "  help         Show this help message"
            Write-Host ""
            Write-Host "Examples:" -ForegroundColor Green
            Write-Host "  .\dev.ps1 setup     # First time setup"
            Write-Host "  .\dev.ps1 start     # Start with Docker"
            Write-Host "  .\dev.ps1 logs api  # Show API logs"
        }
    }
}

# Run main function
Main