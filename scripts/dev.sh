#!/bin/bash

# TimeTracker Development Environment Manager
# This script helps manage the local development environment

set -e

# Global variables
DOCKER_COMPOSE_CMD=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}  TimeTracker Development Tool  ${NC}"
    echo -e "${PURPLE}================================${NC}"
    echo ""
}

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

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Docker Compose (support both old and new syntax)
    if command -v docker-compose &> /dev/null; then
        DOCKER_COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null; then
        DOCKER_COMPOSE_CMD="docker compose"
    else
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_warning "Node.js is not installed. You'll need it for local development."
    fi
    
    # Check .NET
    if ! command -v dotnet &> /dev/null; then
        print_warning ".NET SDK is not installed. You'll need it for local development."
    fi
    
    print_success "Prerequisites check completed"
}

# Setup development environment
setup_dev() {
    print_status "Setting up development environment..."
    
    # Create .env.local if it doesn't exist
    if [ ! -f "src/web/.env.local" ]; then
        print_status "Creating frontend environment file..."
        cp src/web/.env.example src/web/.env.local
        print_success "Created src/web/.env.local from template"
        print_warning "Please update the Azure AD B2C settings in .env.local"
    fi
    
    # Install frontend dependencies
    print_status "Installing frontend dependencies..."
    cd src/web && npm install && cd ../..
    print_success "Frontend dependencies installed"
    
    # Restore backend dependencies
    print_status "Restoring backend dependencies..."
    cd src/api && dotnet restore && cd ../..
    print_success "Backend dependencies restored"
    
    print_success "Development environment setup completed!"
}

# Start services with Docker
start_docker() {
    print_status "Starting full environment with Docker Compose..."
    $DOCKER_COMPOSE_CMD up -d
    print_success "Services started! Check status with: $0 status"
}

# Start services locally (without Docker)
start_local() {
    print_status "Starting services locally..."
    
    # Start SQL Server with Docker (lightweight option)
    print_status "Starting SQL Server..."
    $DOCKER_COMPOSE_CMD up -d sqlserver
    
    # Wait for SQL Server to be ready
    print_status "Waiting for SQL Server to be ready..."
    sleep 10
    
    # Start API
    print_status "Starting .NET API..."
    cd src/api && dotnet run &
    API_PID=$!
    cd ../..
    
    # Start Frontend
    print_status "Starting React frontend..."
    cd src/web && npm run dev &
    WEB_PID=$!
    cd ../..
    
    print_success "Services started locally!"
    echo "API: http://localhost:5000"
    echo "Frontend: http://localhost:3000"
    echo "SQL Server: localhost:1433"
    echo ""
    echo "Press Ctrl+C to stop all services"
    
    # Wait for interrupt
    trap "kill $API_PID $WEB_PID; $DOCKER_COMPOSE_CMD stop sqlserver; exit" INT
    wait
}

# Stop all services
stop() {
    print_status "Stopping all services..."
    # Set Docker Compose command if not already set
    if [ -z "$DOCKER_COMPOSE_CMD" ]; then
        if command -v docker-compose &> /dev/null; then
            DOCKER_COMPOSE_CMD="docker-compose"
        elif docker compose version &> /dev/null; then
            DOCKER_COMPOSE_CMD="docker compose"
        fi
    fi
    
    # Stop Docker services if command is available
    if [ -n "$DOCKER_COMPOSE_CMD" ]; then
        $DOCKER_COMPOSE_CMD down
    fi
    
    # Kill any local processes
    pkill -f "dotnet run" 2>/dev/null || true
    pkill -f "npm run dev" 2>/dev/null || true
    print_success "All services stopped"
}

# Show status
show_status() {
    print_status "Service Status:"
    echo ""
    $DOCKER_COMPOSE_CMD ps
}

# Show logs
show_logs() {
    if [ -z "$1" ]; then
        $DOCKER_COMPOSE_CMD logs -f
    else
        $DOCKER_COMPOSE_CMD logs -f "$1"
    fi
}

# Clean up Docker resources
cleanup() {
    print_status "Cleaning up Docker resources..."
    $DOCKER_COMPOSE_CMD down -v --remove-orphans
    docker system prune -f
    print_success "Cleanup completed"
}

# Run tests
run_tests() {
    print_status "Running tests..."
    
    # Backend tests
    print_status "Running backend tests..."
    cd src/api && dotnet test && cd ../..
    
    # Frontend tests (if configured)
    if [ -f "src/web/package.json" ] && grep -q "\"test\"" src/web/package.json; then
        print_status "Running frontend tests..."
        cd src/web && npm test && cd ../..
    fi
    
    print_success "All tests completed"
}

# Database migrations
run_migrations() {
    print_status "Running database migrations..."
    cd src/api && dotnet ef database update && cd ../..
    print_success "Database migrations completed"
}

# Build production images
build_prod() {
    print_status "Building production images..."
    $DOCKER_COMPOSE_CMD -f docker-compose.yml -f docker-compose.prod.yml build
    print_success "Production images built"
}

# Main command handler
main() {
    print_header
    
    case "${1:-help}" in
        "check")
            check_prerequisites
            ;;
        "setup")
            check_prerequisites
            setup_dev
            ;;
        "start")
            check_prerequisites
            start_docker
            ;;
        "start-local")
            check_prerequisites
            start_local
            ;;
        "stop")
            stop
            ;;
        "restart")
            stop
            start_docker
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs "$2"
            ;;
        "test")
            run_tests
            ;;
        "migrate")
            run_migrations
            ;;
        "build")
            build_prod
            ;;
        "clean")
            cleanup
            ;;
        "help"|*)
            echo "TimeTracker Development Tool"
            echo ""
            echo "Usage: $0 <command>"
            echo ""
            echo "Commands:"
            echo "  check        Check prerequisites"
            echo "  setup        Setup development environment"
            echo "  start        Start all services with Docker"
            echo "  start-local  Start services locally (hybrid mode)"
            echo "  stop         Stop all services"
            echo "  restart      Restart all services"
            echo "  status       Show service status"
            echo "  logs [svc]   Show logs (optionally for specific service)"
            echo "  test         Run all tests"
            echo "  migrate      Run database migrations"
            echo "  build        Build production images"
            echo "  clean        Clean up Docker resources"
            echo "  help         Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 setup     # First time setup"
            echo "  $0 start     # Start with Docker"
            echo "  $0 logs api  # Show API logs"
            ;;
    esac
}

# Run main function
main "$@"