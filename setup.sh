#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# setup.sh — Bootstrap the fullstack application
#
# What it does:
#   1. Creates .env from .env.example (if missing)
#   2. Builds production Docker images
#   3. Starts PostgreSQL and waits for it
#   4. Runs Prisma migrations
#   5. Stops — ready to use
#
# After setup:
#   Dev:   docker compose --file=docker-compose.yml up -d
#   Prod:  docker compose --file=docker-compose.production.yml up -d
# ============================================================

PROD_FILE="docker-compose.production.yml"
COMPOSE="docker compose --file=$PROD_FILE"

# ---- Colors ----
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# ---- Pre-flight checks ----
command -v docker >/dev/null 2>&1 || { error "Docker is not installed."; exit 1; }
docker compose version >/dev/null 2>&1 || { error "Docker Compose v2 is not available."; exit 1; }

# ---- Step 0: Create .env if missing ----
if [ ! -f .env ]; then
  if [ -f .env.example ]; then
    cp .env.example .env
    info "Created .env from .env.example"
    warn "Review .env and set JWT_SECRET before production use!"
  else
    error ".env.example not found. Cannot create .env."
    exit 1
  fi
else
  info ".env already exists — skipping copy."
fi

# ---- Step 1: Build production images ----
info "Building production Docker images..."
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

# ---- Step 4: Stop production services ----
$COMPOSE down

# ---- Done ----
echo ""
info "============================================"
info "  Setup complete!"
info ""
info "  Start development:"
info "    docker compose --file=docker-compose.yml up -d"
info ""
info "  Start production:"
info "    docker compose --file=docker-compose.production.yml up -d"
info ""
info "  Services:"
info "    Frontend:  http://localhost:3000"
info "    Backend:   http://localhost:4000"
info "    Database:  localhost:5432"
info "============================================"