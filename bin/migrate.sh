#!/usr/bin/env bash
set -euo pipefail

echo "Prisma migrate: applying pending migrations and generating client"

# Load backend/.env if present to populate DATABASE_URL
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

if [ -z "${DATABASE_URL:-}" ]; then
  echo "Error: DATABASE_URL is not set. Set it in the environment or in backend/.env"
  exit 1
fi

# If DATABASE_URL points to the compose service host 'db', run migrations inside the
# backend container so the hostname resolves on the compose network.
if echo "${DATABASE_URL}" | grep -q "@db:"; then
  echo "Detected DATABASE_URL pointing to 'db' — running migrations inside Docker Compose"
  # ensure db service is up so the backend can connect
  docker compose up -d db

  docker compose run --rm backend sh -c "npm install && npx prisma migrate deploy --schema=./prisma/schema.prisma && npx prisma generate --schema=./prisma/schema.prisma"
  echo "Done (inside container)."
  exit 0
fi

echo "Applying migrations..."
npx prisma migrate deploy --schema=./prisma/schema.prisma

echo "Generating Prisma client..."
npx prisma generate --schema=./prisma/schema.prisma

echo "Done."
