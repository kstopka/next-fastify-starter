# Next.js + Fastify Starter

Fullstack template — **Next.js App Router · Fastify · Prisma · PostgreSQL · Docker**.

> Linux-first. One command to start development.

---

## Tech Stack

| Layer    | Technology                                                     |
| -------- | -------------------------------------------------------------- |
| Frontend | Next.js (App Router), TypeScript, Tailwind CSS, TanStack Query |
| Backend  | Fastify, TypeScript, Prisma ORM, Zod                           |
| Database | PostgreSQL 16                                                  |
| Auth     | JWT (access + refresh tokens), HttpOnly cookies, argon2        |
| Infra    | Docker Compose v2, multi-stage builds, healthchecks            |

---

## Quick Start

### Requirements

- Docker + Docker Compose v2
- Git

### Development (hot reload)

```bash
git clone https://github.com/kstopka/next-fastify-starter.git
cd next-fastify-starter
cp .env.example .env
docker compose up -d
```

Backend uses `tsx watch`, frontend uses `next dev` — both hot-reload on every file save.

> First startup takes ~60s (npm install inside containers). Next starts are fast — deps cached in named volumes.

**Stop:**

```bash
docker compose down
```

**Reset node_modules:**

```bash
docker compose down -v
```

### Production vs Development setup

The `setup.sh` script prepares the environment. By default it prepares the **development** environment. Pass `prod` to prepare production assets.

Development (prepare DB, apply migrations and start dev services with HMR):

```bash
./setup.sh        # default — prepares development environment and starts services
# or
./setup.sh dev
```

Production (build optimized images, apply migrations):

```bash
./setup.sh prod
docker compose -f docker-compose.production.yml up -d
```

When run with `prod`, `setup.sh` builds production images, waits for PostgreSQL, and runs Prisma migrations automatically.

---

## Services

| Service     | URL                   |
| ----------- | --------------------- |
| Frontend    | http://localhost:3000 |
| Backend API | http://localhost:4000 |
| Database    | localhost:5432        |

---

## Project Structure

```
.
├── backend/                    Fastify API
│   ├── src/
│   │   ├── modules/auth/       Controller / Service / Repository
│   │   └── server.ts
│   └── prisma/                 Schema + migrations
├── frontend/                   Next.js App Router
│   ├── app/
│   │   ├── api/auth/           BFF proxy routes
│   │   ├── dashboard/          Protected page
│   │   └── login/              Login page
│   ├── features/auth/          Login form, hooks
│   ├── shared/                 API client, providers
│   └── middleware.ts           Route protection
├── docker/
│   ├── backend.Dockerfile
│   └── frontend.Dockerfile
├── docker-compose.yml              Development
├── docker-compose.production.yml   Production
├── setup.sh                    First-time setup script
└── .env.example                Environment template
```

---

## Environment Variables

Copy `.env.example` to `.env` before starting.

| Variable            | Description              | Default                  |
| ------------------- | ------------------------ | ------------------------ |
| `POSTGRES_USER`     | DB user                  | `postgres`               |
| `POSTGRES_PASSWORD` | DB password              | `postgres`               |
| `POSTGRES_DB`       | Database name            | `app_db`                 |
| `DATABASE_URL`      | Prisma connection string | see `.env.example`       |
| `JWT_SECRET`        | JWT signing secret       | **change in production** |

---

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed documentation:

- Service diagrams
- Authentication flow
- Data models
- API reference
- Docker setup details

---

## Commit Convention

Conventional Commits:

```
feat(auth): implement login endpoint
fix(api): correct token validation
refactor(user): improve service layer
docs: update architecture documentation
```

---

## License

MIT
