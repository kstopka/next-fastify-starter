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

# CONTAINER_DB is the compose service name for the database (defaults to HOST for backwards compat)
SVC_DB=${CONTAINER_DB:-${HOST}}
SVC_BACKEND=${CONTAINER_BACKEND:-backend}

echo "Checking service '${SVC_DB}'..."
CONTAINER_ID=$(docker compose ps -q "${SVC_DB}" || true)
if [ -n "$CONTAINER_ID" ]; then
  RUNNING=$(docker inspect -f '{{.State.Running}}' "$CONTAINER_ID" 2>/dev/null || echo "false")
  if [ "$RUNNING" != "true" ]; then
    echo "Service '${SVC_DB}' exists but is not running — starting..."
    docker compose up -d "${SVC_DB}"
  else
    echo "Service '${SVC_DB}' is already running."
  fi
else
  echo "Service '${SVC_DB}' is not created — starting..."
  docker compose up -d "${SVC_DB}"
fi

if [ "$MODE" = "setup" ]; then
  docker compose up -d $SVC_BACKEND
  docker compose exec -T $SVC_BACKEND sh -c "npm install && npx prisma migrate dev --schema=./prisma/schema.prisma && npx prisma generate --schema=./prisma/schema.prisma"
  echo "Done (setup mode)."
  else
  echo "Running migrations inside a one-off backend container..."
  docker compose run --rm -T $SVC_BACKEND sh -c "npx prisma migrate deploy --schema=./prisma/schema.prisma && npx prisma generate --schema=./prisma/schema.prisma"
  echo "Done (inside container)."
fi

echo "Migrate done."
