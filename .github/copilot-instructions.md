# Project Context

## Overview

Fullstack template built with Next.js App Router, Fastify, Prisma, PostgreSQL and Docker.
All services are containerized with Docker Compose v2. Linux-first environment.

## Stack

| Layer    | Technology                                                                                   |
| -------- | -------------------------------------------------------------------------------------------- |
| Frontend | Next.js (App Router), TypeScript, Tailwind CSS v4, TanStack Query, React Hook Form + Zod     |
| Backend  | Fastify, TypeScript, Prisma ORM, Zod, argon2, JWT                                            |
| Database | PostgreSQL 16                                                                                |
| Auth     | JWT access token (15min) + refresh token (7d, stored in DB), HttpOnly cookie, token rotation |
| Infra    | Docker Compose v2, multi-stage Dockerfiles, healthchecks                                     |

## Repository Structure

```
backend/
  src/
    modules/auth/         auth.controller.ts · auth.service.ts · auth.repository.ts
    server.ts             Fastify app entry point
  prisma/
    schema.prisma         User + Session models
    migrations/

frontend/
  app/
    api/auth/             BFF proxy routes (login · logout · refresh)
    dashboard/            Protected route
    login/                Login page
    layout.tsx            Root layout (QueryProvider)
  features/
    auth/
      login/              LoginForm.tsx
      hooks/              useAuth.ts (useLogin mutation)
  shared/
    lib/api/              client.ts · auth.ts · index.ts
    providers/            QueryProvider.tsx
  middleware.ts           Route protection via `logged_in` cookie

docker/
  backend.Dockerfile      Multi-stage: builder → runner
  frontend.Dockerfile     Multi-stage: deps → builder → runner (standalone)
```

## Conventions

- **Module pattern** — every feature lives in `modules/<name>/` (backend) or `features/<name>/` (frontend)
- **Controller / Service / Repository** — strict separation in backend modules
- **BFF pattern** — frontend never calls Fastify directly from browser; all API calls go through `app/api/*` Next.js routes
- **Validation** — Zod schemas on both frontend (forms) and backend (request body)
- **Commits** — Conventional Commits (`feat`, `fix`, `refactor`, `docs`, `chore`)
- **TypeScript strict mode** — both frontend and backend

## Implemented Features (Phase 1 — complete)

- [x] Docker Compose dev + production setup
- [x] PostgreSQL + Prisma migrations
- [x] Fastify server with `/health` endpoint
- [x] Auth module: login, refresh, logout
- [x] argon2 password hashing
- [x] JWT access token + refresh token rotation
- [x] Next.js BFF API routes
- [x] LoginForm with React Hook Form + Zod
- [x] TanStack Query integration
- [x] Route protection via middleware
- [x] Multi-stage Dockerfiles
- [x] setup.sh bootstrap script

## Potential Next Steps (Phase 2+)

- User profile endpoint + frontend page
- Role-based access control (User / Admin roles already in schema)
- Redis for session caching / rate limiting
- Extended rate limiting with `@fastify/rate-limit`
- Monitoring / structured logging with Pino
- Audit log
- WebSockets
- Email verification

---
