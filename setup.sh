#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# setup.sh — Build, migrate and start the fullstack application
# ============================================================

COMPOSE="docker compose"

# ---- Colors ----
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# ---- Pre-flight checks ----
command -v docker >/dev/null 2>&1 || { error "Docker is not installed."; exit 1; }
$COMPOSE version >/dev/null 2>&1 || { error "Docker Compose v2 is not available."; exit 1; }

# ---- Step 1: Build containers ----
info "Building Docker images..."
$COMPOSE build

# ---- Step 2: Start database and wait for it ----
info "Starting database..."
$COMPOSE up -d db

info "Waiting for PostgreSQL to be ready..."
RETRIES=30
until $COMPOSE exec db pg_isready -U postgres >/dev/null 2>&1; do
  RETRIES=$((RETRIES - 1))
  if [ "$RETRIES" -le 0 ]; then
    error "PostgreSQL did not become ready in time."
    exit 1
  fi
  sleep 1
done
info "PostgreSQL is ready."

# ---- Step 3: Run migrations ----
info "Running Prisma migrations..."
$COMPOSE run --rm backend sh -c "npx prisma migrate deploy"
info "Migrations applied."

# ---- Step 4: Start all services ----
info "Starting all services..."
$COMPOSE up -d

# ---- Done ----
echo ""
info "============================================"
info "  Application is running!"
info "  Frontend:  http://localhost:3000"
info "  Backend:   http://localhost:4000"
info "  Database:  localhost:5432"
info "============================================"
echo ""
info "Use '$COMPOSE logs -f' to follow logs."
info "Use '$COMPOSE down' to stop all services."