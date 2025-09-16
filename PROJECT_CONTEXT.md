# TimeTracker Project Context & Session Memory

**Last Updated**: September 16, 2025  
**Repository**: https://github.com/pjusken75/timetracker  
**Owner**: pjusken75

## Project Overview

A professional, cloud-native time tracker web application built with modern best practices.

### Tech Stack & Requirements

#### Frontend
- **Framework**: React with TypeScript
- **Build Tool**: Vite
- **UI Library**: Mantine (recommended and implemented)
- **Routing**: TanStack Router
- **State Management**: TanStack Query
- **Forms**: React Hook Form + Zod validation
- **Authentication**: MSAL for Azure AD B2C
- **Icons**: @tabler/icons-react
- **Date Handling**: dayjs

#### Backend
- **Framework**: .NET 9 Web API
- **Database**: Azure SQL Database with Entity Framework Core
- **Authentication**: Azure AD B2C integration
- **Validation**: FluentValidation
- **Mapping**: AutoMapper
- **API Documentation**: Swashbuckle/OpenAPI

#### Infrastructure & DevOps
- **Cloud Platform**: Azure
- **Infrastructure as Code**: Bicep templates
- **Containerization**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **Hosting**: 
  - Frontend: Azure Static Web Apps
  - Backend: Azure App Service
  - Database: Azure SQL Database
- **Additional Services**: Azure Key Vault, Application Insights

## Current Project Status

### ✅ Completed Components

1. **Project Structure**: Full professional project structure created
2. **Frontend Setup**: 
   - Vite + React + TypeScript configured
   - Mantine UI integrated
   - TanStack Router setup with route generation
   - MSAL authentication configured
   - Environment configuration ready
3. **Backend Setup**:
   - .NET 9 Web API project created
   - Entity Framework Core configured
   - Models: User, Project, TimeEntry
   - DTOs and AutoMapper profiles
   - Azure AD B2C authentication setup
4. **Infrastructure**:
   - Complete Bicep templates for Azure resources
   - Parameters files for dev/prod environments
5. **DevOps**:
   - Docker containerization for both frontend and backend
   - docker-compose for local development
   - GitHub Actions CI/CD pipeline
   - Development scripts (Bash and PowerShell) with Docker Compose compatibility
6. **Documentation**:
   - Azure AD B2C setup guide
   - Development environment guide
   - Deployment instructions

### 🔧 Recent Fixes & Updates

- **Docker Compose Compatibility**: Updated both `dev.sh` and `dev.ps1` scripts to support both legacy `docker-compose` and modern `docker compose` commands
- **Git Repository**: All code committed and pushed to GitHub
- **Environment Setup**: Scripts tested and working for prerequisites checking

## Next Steps & TODO Items

### High Priority
1. **Azure AD B2C Configuration**:
   - Set up Azure AD B2C tenant
   - Configure application registrations
   - Update environment variables with actual B2C settings
   
2. **Database Setup**:
   - Deploy Azure SQL Database
   - Run Entity Framework migrations
   - Set up connection strings in Azure Key Vault

3. **Local Development Environment**:
   - Complete first-time setup with `./scripts/dev.sh setup`
   - Test local development workflow
   - Verify frontend and backend integration

### Medium Priority
4. **Core Features Implementation**:
   - User authentication flow (login/logout)
   - Project management (CRUD operations)
   - Time entry tracking
   - Dashboard with time reports
   - User profile management

5. **UI/UX Development**:
   - Implement Mantine-based components
   - Create responsive layouts
   - Add time tracking interfaces
   - Implement data visualization for reports

### Lower Priority
6. **Advanced Features**:
   - Multi-factor authentication (MFA)
   - Advanced reporting and analytics
   - Export functionality
   - Team collaboration features
   - Mobile responsiveness optimization

## Development Workflow

### Getting Started Commands
```bash
# Check prerequisites
./scripts/dev.sh check

# First-time setup
./scripts/dev.sh setup

# Start development environment
./scripts/dev.sh start-local    # Hybrid mode (recommended for development)
./scripts/dev.sh start          # Full Docker mode

# Other useful commands
./scripts/dev.sh status         # Check service status
./scripts/dev.sh logs           # View logs
./scripts/dev.sh stop           # Stop all services
```

### Key File Locations
- Frontend: `/src/web/`
- Backend: `/src/api/`
- Infrastructure: `/infrastructure/`
- Scripts: `/scripts/`
- Documentation: `/docs/`

## Architecture Decisions Made

1. **UI Framework**: Chose Mantine over Material-UI for better TypeScript support and modern design
2. **Authentication**: Azure AD B2C for enterprise-grade user management
3. **Database**: Azure SQL for reliability and integration with Azure ecosystem
4. **Deployment**: Separate Static Web App (frontend) and App Service (backend) for scalability
5. **Development Scripts**: Cross-platform support (Bash + PowerShell) for team flexibility

## Environment Configuration

### Required Environment Variables
- Frontend (`.env.local`):
  - Azure AD B2C tenant information
  - API endpoints
- Backend (`appsettings.json`):
  - Database connection strings
  - Azure AD B2C configuration
  - Azure Key Vault settings

### Azure Resources Needed
- Resource Group
- Azure AD B2C tenant
- Azure SQL Database
- Azure App Service
- Azure Static Web Apps
- Azure Key Vault
- Application Insights

## Known Issues & Solutions

### Docker Compose Compatibility
- **Issue**: Modern Docker uses `docker compose` instead of `docker-compose`
- **Solution**: Scripts now auto-detect and support both versions

### Development Environment
- **Prerequisites**: Docker, Node.js, .NET SDK required for local development
- **Recommendation**: Use hybrid mode (`start-local`) for faster development iteration

## Contact & Context for Future Sessions

When starting a new Copilot session, reference this file and mention:
- "I'm working on the TimeTracker project - check PROJECT_CONTEXT.md for full context"
- Current focus area (authentication, features, deployment, etc.)
- Any specific issues or goals for the session

This ensures continuity and efficient collaboration across sessions.