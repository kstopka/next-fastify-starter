# Architecture

Technical documentation for the Next.js + Fastify starter.

---

## Overview

```
Browser
  │
  │  HTTP/HTTPS
  ▼
┌─────────────────────┐
│  Next.js  :3000     │  ← App Router, SSR, BFF proxy
│  (frontend)         │
└────────┬────────────┘
         │  Internal HTTP  (app-network)
         ▼
┌─────────────────────┐
│  Fastify  :4000     │  ← REST API, auth, business logic
│  (backend)          │
└────────┬────────────┘
         │  Prisma ORM
         ▼
┌─────────────────────┐
│  PostgreSQL  :5432  │  ← Persistent data
│  (db)               │
└─────────────────────┘
```

All services run in Docker containers connected via the `app-network` bridge network.

---

## Services

### Frontend — Next.js (port 3000)

| Property     | Value                      |
| ------------ | -------------------------- |
| Framework    | Next.js with App Router    |
| Language     | TypeScript                 |
| Styling      | Tailwind CSS v4            |
| Server state | TanStack Query             |
| Forms        | React Hook Form + Zod      |
| Pattern      | BFF (Backend For Frontend) |

The frontend never calls Fastify directly from the browser. All API calls go through
Next.js API routes (`app/api/*`) which proxy requests to the backend. This keeps the
refresh token cookie isolated to the Next.js origin.

**Directory structure:**

```
frontend/
  app/
    api/
      auth/
        login/route.ts      POST /api/auth/login   → proxies to Fastify POST /login
        logout/route.ts     POST /api/auth/logout  → proxies to Fastify POST /logout
        refresh/route.ts    POST /api/auth/refresh → proxies to Fastify POST /refresh
    dashboard/page.tsx      Protected page (requires auth)
    login/page.tsx          Login page
    layout.tsx              Root layout with providers
  features/
    auth/
      login/
        LoginForm.tsx       Form component with validation
      hooks/
        useAuth.ts          useLogin hook (TanStack Query mutation)
  shared/
    lib/api/
      client.ts             Universal fetch wrapper (GET/POST/PUT/DELETE)
      auth.ts               loginApi, refreshApi, logoutApi helpers
    providers/
      QueryProvider.tsx     TanStack Query client provider
  middleware.ts             Route protection (redirects unauthenticated users)
```

### Backend — Fastify (port 4000)

| Property         | Value                  |
| ---------------- | ---------------------- |
| Framework        | Fastify                |
| Language         | TypeScript             |
| ORM              | Prisma                 |
| Validation       | Zod                    |
| Password hashing | argon2                 |
| Authentication   | JWT (access + refresh) |

**Directory structure:**

```
backend/
  src/
    modules/
      auth/
        auth.controller.ts    Route handlers — request/response
        auth.service.ts       Business logic — token generation, validation
        auth.repository.ts    Database access — Prisma queries
    server.ts                 Fastify instance + plugin registration + startup
  prisma/
    schema.prisma             Data models
    migrations/               Applied migration history
```

### Database — PostgreSQL 16 (port 5432)

Managed exclusively via Prisma. Data is persisted in a project-scoped Docker
volume created by Docker Compose (for example `<project>_postgres_data`) and survives container restarts.

---

## Authentication

### Flow

```
Client                  Next.js BFF              Fastify
  │                         │                       │
  │  POST /api/auth/login   │                       │
  ├────────────────────────►│                       │
  │                         │  POST /login          │
  │                         ├──────────────────────►│
  │                         │                       │ verify password (argon2)
  │                         │                       │ generate accessToken (JWT, 15min)
  │                         │                       │ generate refreshToken (JWT, 7d)
  │                         │                       │ save refreshToken to DB (Session)
  │                         │◄──────────────────────┤
  │                         │  { accessToken }       │
  │                         │  Set-Cookie: refreshToken (HttpOnly)
  │◄────────────────────────┤                       │
  │  { accessToken }        │                       │
  │  Cookie: refreshToken   │                       │
```

### Token refresh

When a request fails with `401`, the frontend automatically calls `POST /api/auth/refresh`,
which rotates the refresh token (old one is revoked in DB, new one is issued).

### Route protection

`middleware.ts` checks for the presence of a `logged_in` cookie:

- Unauthenticated users accessing `/dashboard` → redirect to `/login`
- Authenticated users accessing `/login` → redirect to `/dashboard`

### Tokens

| Token         | Lifetime   | Storage                              | Notes               |
| ------------- | ---------- | ------------------------------------ | ------------------- |
| Access Token  | 15 minutes | Memory (TanStack Query state)        | JWT, not persisted  |
| Refresh Token | 7 days     | DB (Session table) + HttpOnly cookie | Rotated on each use |

---

## Data Models

```prisma
model User {
  id           String    @id @default(uuid())
  email        String    @unique
  passwordHash String                          // argon2 hash — never plain text
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt
  sessions     Session[]
}

model Session {
  id           String   @id @default(uuid())
  userId       String
  refreshToken String   @unique
  revoked      Boolean  @default(false)        // set to true on logout or rotation
  createdAt    DateTime @default(now())
  expiresAt    DateTime
  user         User     @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

---

## API Endpoints

| Method | Path       | Auth   | Description                                                   |
| ------ | ---------- | ------ | ------------------------------------------------------------- |
| `GET`  | `/health`  | —      | Health check (used by Docker healthcheck)                     |
| `POST` | `/login`   | —      | Authenticate user, returns access token + sets refresh cookie |
| `POST` | `/refresh` | Cookie | Rotate refresh token, returns new access token                |
| `POST` | `/logout`  | Cookie | Revoke session                                                |

---

## Docker Setup

### Development (`docker-compose.yml`)

- Uses the official `node:22-alpine` image directly — no build step required
- Source code is mounted as volumes; changes are reflected immediately
- Backend: `tsx watch` — restarts on every `.ts` file change
- Frontend: `next dev` — HMR / Fast Refresh
- `npm install` runs on first start, cached in named volumes (`backend_nm`, `frontend_nm`)

### Production (`docker-compose.production.yml`)

- Multi-stage Dockerfiles produce minimal, optimised images
- Backend image: `app-backend` (builder → runner, non-root)
- Frontend image: `app-frontend` (deps → builder → runner with `output: standalone`)
- No source code included in images

### Networks & Volumes

| Resource        | Type             | Purpose                                                              |
| --------------- | ---------------- | -------------------------------------------------------------------- |
| `app-network`   | Network (bridge) | Service-to-service communication by name                             |
| `postgres_data` | Volume           | Project-scoped persistent DB volume (e.g. `<project>_postgres_data`) |
| `backend_nm`    | Volume           | Cached node_modules — dev only                                       |
| `frontend_nm`   | Volume           | Cached node_modules — dev only                                       |

---

## Environment Variables

Defined in `.env` (copied from `.env.example`).

| Variable            | Used by | Description                                                 |
| ------------------- | ------- | ----------------------------------------------------------- |
| `POSTGRES_USER`     | db      | PostgreSQL user                                             |
| `POSTGRES_PASSWORD` | db      | PostgreSQL password                                         |
| `POSTGRES_DB`       | db      | Database name                                               |
| `DATABASE_URL`      | backend | Prisma connection string                                    |
| `JWT_SECRET`        | backend | Secret for signing JWTs — **must be changed in production** |
