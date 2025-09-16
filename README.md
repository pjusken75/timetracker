# TimeTracker - Professional Time Tracking Application

A modern, cloud-native time tracking web application built with React TypeScript frontend, .NET 9 backend, and Azure cloud infrastructure.

## Tech Stack

### Frontend
- **React 18** with TypeScript
- **Vite** for build tooling and dev server
- **Mantine UI** for modern component library
- **TanStack Router** for type-safe routing
- **TanStack Query** for server state management
- **MSAL** for Azure AD B2C authentication
- **React Hook Form + Zod** for form validation

### Backend
- **.NET 9 Web API** with minimal APIs
- **Entity Framework Core** for database operations
- **Azure AD B2C** integration for authentication
- **AutoMapper** for object mapping
- **FluentValidation** for input validation
- **Swashbuckle/OpenAPI** for API documentation

### Infrastructure
- **Azure Cloud** hosting (App Service + Static Web Apps)
- **Azure SQL Database** for data persistence
- **Azure Key Vault** for secrets management
- **Application Insights** for monitoring
- **Docker** containers for local development
- **GitHub Actions** for CI/CD

## Prerequisites

Before you begin, ensure you have the following installed on your development machine:

- **Docker Desktop** - For containerized development environment
- **Node.js 18+** - For frontend development
- **.NET 9 SDK** - For backend development
- **Git** - For version control

### Quick Prerequisites Check
```bash
./scripts/dev.sh check
```

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/pjusken75/timetracker.git
cd timetracker
```

### 2. Initial Setup
```bash
# Run the setup script to install dependencies and configure environment
./scripts/dev.sh setup
```

This will:
- Install frontend dependencies (npm packages)
- Restore backend dependencies (.NET packages)
- Create local environment files
- Set up development configuration

### 3. Development Options

#### Option A: Hybrid Local Development (Recommended)
Run frontend and backend locally with Docker database:
```bash
./scripts/dev.sh start-local
```

This provides:
- ✅ Fast hot-reload for both frontend and backend
- ✅ Easy debugging and development
- ✅ Containerized database (SQL Server)
- ✅ Optimal development experience

**Services:**
- Frontend: http://localhost:3000
- Backend API: http://localhost:5000
- Database: SQL Server in Docker (localhost:1433)

#### Option B: Full Docker Environment
Run everything in containers:
```bash
./scripts/dev.sh start
```

This provides:
- ✅ Production-like environment
- ✅ Complete isolation
- ✅ All services containerized
- ✅ Good for integration testing

**Services:**
- Frontend: http://localhost:3000
- Backend API: http://localhost:5001
- Database: SQL Server in Docker
- Redis: For caching (optional)

### 4. Development Workflow

#### Available Commands
```bash
# Development Environment
./scripts/dev.sh check        # Check prerequisites
./scripts/dev.sh setup        # Initial setup
./scripts/dev.sh start-local  # Start hybrid development
./scripts/dev.sh start        # Start full Docker environment
./scripts/dev.sh stop         # Stop all services
./scripts/dev.sh restart      # Restart services

# Monitoring & Debugging
./scripts/dev.sh status       # Show service status
./scripts/dev.sh logs         # Show all logs
./scripts/dev.sh logs api     # Show API logs only
./scripts/dev.sh logs web     # Show frontend logs only

# Database
./scripts/dev.sh migrate      # Run database migrations

# Production
./scripts/dev.sh build        # Build production images
./scripts/dev.sh clean        # Clean up Docker resources
```

#### PowerShell Support (Windows)
```powershell
# All commands also available in PowerShell
.\scripts\dev.ps1 start-local
.\scripts\dev.ps1 status
# ... etc
```

## Project Structure

```
timetracker/
├── src/
│   ├── web/          # React frontend application
│   └── api/          # .NET Web API backend
├── infrastructure/   # Azure Bicep templates
├── docs/            # Project documentation
├── scripts/         # Build and deployment scripts
└── README.md        # This file
```

## Getting Started

1. **Prerequisites**
   - Node.js 18+
   - .NET 8 SDK
   - Azure CLI
   - Docker (optional)

2. **Local Development**
   ```bash
   # Install frontend dependencies
   cd src/web
   npm install
   
   # Run frontend
   npm run dev
   
   # Run backend (in separate terminal)
   cd src/api
   dotnet run
   ```

3. **Azure Deployment**
   ```bash
   # Deploy infrastructure
   cd infrastructure
   az deployment group create --resource-group rg-timetracker --template-file main.bicep
   
   # Deploy applications
   ./scripts/deploy.sh
   ```

## Features

- ✅ User registration and authentication (Azure AD B2C)
- ✅ Time tracking (check-in/check-out)
- ✅ Professional UI with Mantine components
- ✅ Real-time updates with TanStack Query
- ✅ Responsive design
- ✅ Azure cloud deployment

## Development

See [Development Guide](./docs/development.md) for detailed setup instructions.

## Deployment

See [Deployment Guide](./docs/deployment.md) for Azure deployment instructions.