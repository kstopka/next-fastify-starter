#!/usr/bin/env bash
set -euo pipefail

# Ensure we're running from repository root (script lives in bin/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# ============================================================
# setup.sh — Bootstrap the fullstack application
#
# This script is broken into functions for readability and
# easier testing. `main` runs these functions in order.
# ============================================================

DEV_FILE="docker-compose.yml"
PROD_FILE="docker-compose.production.yml"

# default mode: dev. Pass `prod` to run production setup.
MODE=${1:-dev}

if [ "$MODE" = "prod" ]; then
  COMPOSE_FILE="$PROD_FILE"
else
  COMPOSE_FILE="$DEV_FILE"
fi

COMPOSE="docker compose --file=$COMPOSE_FILE"

# ---- Colors ----
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

ensure_prereqs() {
  command -v docker >/dev/null 2>&1 || { error "Docker is not installed."; exit 1; }
  docker compose version >/dev/null 2>&1 || { error "Docker Compose v2 is not available."; exit 1; }
}


create_env_if_missing() {
  if [ ! -f .env ]; then
    if [ -f .env.example ]; then
      cp .env.example .env
      info "Created .env from .env.example"
      warn "Review .env and set JWT_SECRET before production use!"

      echo
      info "Chcesz teraz uzupełnić wartości w .env? (y) lub Enter, aby pominąć: "
      read -r FILL_ANS
      if [[ "$FILL_ANS" =~ ^[Yy] ]]; then
        # Prompt for every key in .env (skip comments/blank lines)
        while IFS= read -r line; do
          [[ "$line" =~ ^# ]] && continue
          [[ -z "$line" ]] && continue
          if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            key=${BASH_REMATCH[1]}
            cur=${BASH_REMATCH[2]}
            # strip surrounding quotes for display
            disp=$(printf '%s' "$cur" | sed -e 's/^"//' -e 's/"$//')
            # If this is DATABASE_URL, build it from components and skip prompting
            if [ "$key" = "DATABASE_URL" ]; then
              scheme=$(grep -E '^SCHEME=' .env | head -1 | cut -d'=' -f2-)
              puser=$(grep -E '^POSTGRES_USER=' .env | head -1 | cut -d'=' -f2-)
              ppass=$(grep -E '^POSTGRES_PASSWORD=' .env | head -1 | cut -d'=' -f2-)
              phost=$(grep -E '^HOST=' .env | head -1 | cut -d'=' -f2-)
              pport=$(grep -E '^PORT=' .env | head -1 | cut -d'=' -f2-)
              pdb=$(grep -E '^POSTGRES_DB=' .env | head -1 | cut -d'=' -f2-)
              scheme=${scheme:-postgres}
              puser=${puser:-postgres}
              ppass=${ppass:-postgres}
              phost=${phost:-db}
              pport=${pport:-5432}
              pdb=${pdb:-app_db}
              url="${scheme}://${puser}:${ppass}@${phost}:${pport}/${pdb}"
              esc=$(printf '%s' "$url" | sed 's/[&/\\]/\\&/g')
              sed -i "s|^$key=.*|$key=$esc|" .env
              info "Set $key from components"
              continue
            fi
            if [[ "$key" =~ _?PASSWORD|SECRET|JWT|TOKEN|KEY ]]; then
              printf "Aktualna wartość dla %s: (ukryta). Naciśnij Enter, aby pozostawić obecną wartość, lub wprowadź nową: " "$key" > /dev/tty
              read -rsp "" new_val < /dev/tty
              echo
            else
              printf "Aktualna wartość dla %s: '%s'. Naciśnij Enter, aby pozostawić obecną wartość, lub wprowadź nową: " "$key" "$disp" > /dev/tty
              read -r new_val < /dev/tty
            fi
            if [ -n "$new_val" ]; then
              esc=$(printf '%s' "$new_val" | sed 's/[&/\\]/\\&/g')
              sed -i "s|^$key=.*|$key=$esc|" .env
            fi
          fi
        done < .env
      else
        info "Pominięto uzupełnianie wartości .env — możesz edytować plik ręcznie."
      fi
    else
      error ".env.example not found. Cannot create .env."
      exit 1
    fi
  else
    info ".env already exists — skipping copy."
  fi
}

sync_backend_env() {
  DATABASE_URL_VAL=$(grep -E '^DATABASE_URL=' .env | head -1 | cut -d'=' -f2-)
  HOST_VAL=$(grep -E '^HOST=' .env | head -1 | cut -d'=' -f2-)

  if [ -n "$DATABASE_URL_VAL" ] || [ -n "$HOST_VAL" ]; then
    mkdir -p backend
    : > backend/.env

    if [ -n "$DATABASE_URL_VAL" ]; then
      printf 'DATABASE_URL=%s\n' "$DATABASE_URL_VAL" >> backend/.env
      info "Synced DATABASE_URL to backend/.env"
    fi

    if [ -n "$HOST_VAL" ]; then
      printf 'HOST=%s\n' "$HOST_VAL" >> backend/.env
      info "Synced HOST to backend/.env"
    fi
  else
    warn "DATABASE_URL or HOST not found in .env — backend/.env not created/updated."
  fi
}

build_images_if_needed() {
  if [ "$MODE" = "prod" ]; then
    info "Building production Docker images..."
    $COMPOSE build
  else
    info "Preparing development environment (no image build)."
  fi
}

start_db_and_wait() {
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
}

run_migrations() {
  info "Applying Prisma migrations (non-interactive)..."
  ./bin/migrate.sh setup
  info "Migrations applied (if any)."
}

prompt_create_user() {
  read -rp "Create a new user now? (y/n): " CREATE_USER_ANS
  if [[ "$CREATE_USER_ANS" =~ ^[Yy] ]]; then
    read -rp "Email: " NEW_USER_EMAIL
    read -rsp "Password: " NEW_USER_PASSWORD
    echo

    info "Creating user in backend container..."
    $COMPOSE run --rm -v "$REPO_ROOT":/app -e "NEW_USER_EMAIL=$NEW_USER_EMAIL" -e "NEW_USER_PASSWORD=$NEW_USER_PASSWORD" -e "NEW_USER_ROLE=ADMIN" -e "DATABASE_URL=${DATABASE_URL_VAL}" backend sh -c "node /app/backend/scripts/create_user.cjs"
    info "User creation finished."
  fi
}

install_frontend_deps() {
  info "Installing frontend dependencies (populating node_modules volume)..."
  # --no-deps: only the frontend container, do not start backend/db again
  $COMPOSE run --rm --no-deps -T frontend sh -c "npm install"
  info "Frontend dependencies installed."
}

install_local_deps() {
  # This must run BEFORE any `docker compose` command so that the node_modules
  # directories are created with the current user's permissions. Docker would
  # otherwise create them as root (mount-point placeholder for named volumes).
  info "Installing local dependencies for IDE support (TypeScript LSP / autocomplete)..."
  if command -v npm >/dev/null 2>&1; then
    info "Installing frontend/node_modules on host..."
    (cd "$REPO_ROOT/frontend" && npm install)
    info "Installing backend/node_modules on host..."
    (cd "$REPO_ROOT/backend" && npm install)
    info "Local node_modules ready — IDE autocomplete will work."
  else
    warn "npm not found on host — skipping local install."
    warn "Run 'npm install' manually inside frontend/ and backend/ for IDE autocomplete."
  fi
}

teardown_or_start_services() {
  if [ "$MODE" = "prod" ]; then
    info "Stopping production containers (setup finished)."
    $COMPOSE down
  else
    info "Stopping all containers — setup complete."
    $COMPOSE down
  fi
}

print_summary() {
  echo ""
  info "============================================"
  info "  Setup complete!"
  echo ""
  if [ "$MODE" = "prod" ]; then
    info "  Start production:"
    info "    docker compose --file=$PROD_FILE up -d"
  else
    info "  Start development (hot reloading):"
    info "    docker compose --file=$DEV_FILE up -d"
    echo ""
    info "  Services:"
    info "    Frontend : http://localhost:3000  (Next.js — HMR)"
    info "    Backend  : http://localhost:4000  (Fastify — tsx watch)"
    info "    Database : localhost:5432"
  fi
  info "============================================"
}

main() {
  ensure_prereqs
  create_env_if_missing
  sync_backend_env
  install_local_deps        # BEFORE any docker compose — ensures host owns node_modules dirs
  build_images_if_needed
  start_db_and_wait
  run_migrations
  install_frontend_deps
  prompt_create_user
  teardown_or_start_services
  print_summary
}

# Run the main function
main "$@"
