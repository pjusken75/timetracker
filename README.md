# TimeTracker Application

A modern time tracking application built with React, .NET, and Azure.

## Architecture

- **Frontend**: React + TypeScript + Vite + Mantine UI
- **Backend**: .NET 8 Web API + Entity Framework Core
- **Database**: Azure SQL Database
- **Authentication**: Azure AD B2C
- **Cloud**: Microsoft Azure
- **Infrastructure**: Bicep Templates

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