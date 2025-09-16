# Development Guide

This guide will help you set up and work with the TimeTracker application locally.

## Quick Start

### Prerequisites

1. **Docker & Docker Compose** - Required for database and containerized development
2. **Node.js 18+** - For frontend development
3. **.NET 9 SDK** - For backend development
4. **Git** - For version control

### One-Command Setup

```bash
# Setup everything
./scripts/dev.sh setup

# Start all services
./scripts/dev.sh start
```

**That's it!** Your application will be running at:
- **Frontend**: http://localhost:3000
- **API**: http://localhost:5000
- **Database**: localhost:1433

## Development Modes

### 1. Full Docker Mode (Recommended for consistency)
```bash
./scripts/dev.sh start
```
- All services run in containers
- Consistent environment across all developers
- Automatic service dependencies

### 2. Hybrid Mode (Best for active development)
```bash
./scripts/dev.sh start-local
```
- Database runs in Docker
- API and Frontend run locally with hot reload
- Faster development iteration

### 3. Pure Local Mode
```bash
# Terminal 1: Start database
docker-compose up -d sqlserver

# Terminal 2: Start API
cd src/api && dotnet run

# Terminal 3: Start Frontend
cd src/web && npm run dev
```

## Development Commands

### Using the Development Script

```bash
# Check prerequisites
./scripts/dev.sh check

# Setup development environment
./scripts/dev.sh setup

# Start services
./scripts/dev.sh start

# Stop services
./scripts/dev.sh stop

# View logs
./scripts/dev.sh logs
./scripts/dev.sh logs api

# Run tests
./scripts/dev.sh test

# Run database migrations
./scripts/dev.sh migrate

# Clean up Docker resources
./scripts/dev.sh clean
```

### Manual Commands

#### Frontend Development
```bash
cd src/web

# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Run linting
npm run lint

# Fix linting issues
npm run lint:fix

# Format code
npm run format

# Type checking
npm run type-check

# Generate routes
npm run routes:generate
```

#### Backend Development
```bash
cd src/api

# Restore packages
dotnet restore

# Run the application
dotnet run

# Run tests
dotnet test

# Build the application
dotnet build

# Create migration
dotnet ef migrations add <MigrationName>

# Update database
dotnet ef database update

# Watch for changes (hot reload)
dotnet watch run
```

## Project Structure

```
timetracker/
├── src/
│   ├── web/                 # React Frontend
│   │   ├── src/
│   │   │   ├── routes/      # TanStack Router routes
│   │   │   ├── components/  # Reusable components
│   │   │   └── hooks/       # Custom React hooks
│   │   ├── package.json     # Frontend dependencies
│   │   └── vite.config.ts   # Vite configuration
│   │
│   └── api/                 # .NET API
│       ├── Controllers/     # API controllers
│       ├── Models/          # Domain models
│       ├── DTOs/            # Data transfer objects
│       ├── Services/        # Business logic
│       ├── Data/            # Entity Framework context
│       └── Program.cs       # Application entry point
│
├── infrastructure/          # Azure Bicep templates
├── scripts/                # Development and deployment scripts
├── docker/                 # Docker configurations
├── docs/                   # Documentation
├── docker-compose.yml      # Docker Compose configuration
└── README.md              # Project overview
```

## Environment Configuration

### Frontend Environment Variables

Create `src/web/.env.local`:

```bash
# API Configuration
VITE_API_BASE_URL=http://localhost:5000/api

# Azure AD B2C Configuration
VITE_AZURE_CLIENT_ID=your-client-id
VITE_AZURE_TENANT_ID=your-tenant-name
VITE_AZURE_POLICY_NAME=B2C_1_signupsignin
VITE_AZURE_DOMAIN=your-tenant.onmicrosoft.com
VITE_AZURE_INSTANCE=https://your-tenant.b2clogin.com

# Application Configuration
VITE_APP_NAME=TimeTracker
VITE_APP_VERSION=1.0.0
```

### Backend Configuration

Update `src/api/appsettings.Development.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost,1433;Database=TimeTrackerDb;User Id=sa;Password=TimeTracker123!;TrustServerCertificate=true;"
  },
  "AzureAdB2C": {
    "Instance": "https://your-tenant.b2clogin.com",
    "Domain": "your-tenant.onmicrosoft.com",
    "TenantId": "your-tenant-id",
    "ClientId": "your-api-client-id"
  }
}
```

## Database Management

### Using Entity Framework

```bash
cd src/api

# Add a new migration
dotnet ef migrations add AddNewFeature

# Update database
dotnet ef database update

# Remove last migration
dotnet ef migrations remove

# Generate SQL script
dotnet ef migrations script
```

### Database Connection

**Local Development:**
- Host: `localhost`
- Port: `1433`
- Database: `TimeTrackerDb`
- Username: `sa`
- Password: `TimeTracker123!`

## Testing

### Backend Tests
```bash
cd src/api
dotnet test --verbosity normal
```

### Frontend Tests
```bash
cd src/web
npm run test
```

### End-to-End Tests
```bash
# Start all services first
./scripts/dev.sh start

# Run E2E tests (if configured)
npm run test:e2e
```

## Debugging

### API Debugging
- Use Visual Studio Code with the C# extension
- Set breakpoints in your code
- Press F5 or use "Run and Debug"

### Frontend Debugging
- Use browser developer tools
- React Developer Tools extension
- TanStack Router Devtools (built-in)
- TanStack Query Devtools (built-in)

### Database Debugging
- Use Azure Data Studio or SQL Server Management Studio
- Connection: `localhost,1433`
- Or use VS Code with SQL Server extension

## Code Quality

### Frontend
- **ESLint** for code linting
- **Prettier** for code formatting
- **TypeScript** for type safety
- **Husky** for git hooks (if configured)

### Backend
- **Built-in analyzers** for .NET
- **EditorConfig** for consistent formatting
- **Code coverage** with `dotnet test --collect:"XPlat Code Coverage"`

## Performance Monitoring

### Development
- **React DevTools Profiler**
- **TanStack Query DevTools** for cache inspection
- **.NET Hot Reload** for faster iteration

### Production-like Testing
```bash
# Build and run production images
./scripts/dev.sh build
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Find and kill process using port 3000 or 5000
   lsof -ti:3000 | xargs kill -9
   lsof -ti:5000 | xargs kill -9
   ```

2. **Database Connection Issues**
   ```bash
   # Restart SQL Server container
   docker-compose restart sqlserver
   
   # Check SQL Server logs
   docker-compose logs sqlserver
   ```

3. **Node Modules Issues**
   ```bash
   cd src/web
   rm -rf node_modules package-lock.json
   npm install
   ```

4. **Docker Issues**
   ```bash
   # Clean up Docker resources
   ./scripts/dev.sh clean
   
   # Rebuild containers
   docker-compose build --no-cache
   ```

5. **Hot Reload Not Working**
   - Check file watchers limit on Linux: `echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf`
   - Restart development servers

### Getting Help

1. Check the [GitHub Issues](https://github.com/pjusken75/timetracker/issues)
2. Review the logs: `./scripts/dev.sh logs`
3. Verify prerequisites: `./scripts/dev.sh check`

## Best Practices

### Development Workflow
1. Always work on feature branches
2. Run tests before committing
3. Use conventional commit messages
4. Keep commits small and focused

### Code Style
- Follow the established patterns in the codebase
- Use TypeScript strictly (no `any` types)
- Write meaningful component and function names
- Add JSDoc comments for public APIs

### Performance
- Use React.memo for expensive components
- Implement proper loading states
- Use TanStack Query for server state management
- Optimize database queries with proper indexing

## Next Steps

After getting the development environment running:

1. **Set up Azure AD B2C** (see `docs/azure-ad-b2c-setup.md`)
2. **Implement authentication** in the frontend
3. **Create time tracking features**
4. **Add comprehensive testing**
5. **Set up CI/CD pipeline**