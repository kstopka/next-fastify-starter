#!/usr/bin/env bash
set -euo pipefail

echo "Prisma migrate: applying pending migrations and generating client"
MODE=${1:-migrate}

if [ -f "backend/.env" ]; then
  # shellcheck disable=SC1090
  set -a
  . backend/.env
  set +a
fi

if [ ! -d "backend" ]; then
  echo "Error: backend directory not found"
  exit 1
fi

cd backend

if [ -z "${HOST:-}" ]; then
  echo "Error: HOST is not set. Set it in the environment or in backend/.env"
  exit 1
fi


echo "Checking service 'db'..."
CONTAINER_ID=$(docker compose ps -q "db" || true)
if [ -n "$CONTAINER_ID" ]; then
  RUNNING=$(docker inspect -f '{{.State.Running}}' "$CONTAINER_ID" 2>/dev/null || echo "false")
  if [ "$RUNNING" != "true" ]; then
    echo "Service 'db' exists but is not running — starting..."
    docker compose up -d db
  else
    echo "Service 'db' is already running."
  fi
else
  echo "Service 'db' is not created — starting..."
  docker compose up -d db
fi

if [ "$MODE" = "setup" ]; then
  echo "Running migrations inside a one-off backend container (setup mode)..."
  docker compose run --rm -T backend sh -c "npm install && npx prisma migrate dev --schema=./prisma/schema.prisma && npx prisma generate --schema=./prisma/schema.prisma"
  echo "Done (setup mode)."
else
  echo "Running migrations inside a one-off backend container..."
  docker compose run --rm -T backend sh -c "npx prisma migrate deploy --schema=./prisma/schema.prisma && npx prisma generate --schema=./prisma/schema.prisma"
  echo "Done (inside container)."
fi

echo "Migrate done."
