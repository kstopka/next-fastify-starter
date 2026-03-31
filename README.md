# Modern Fullstack Template

Modern fullstack application template built with **Next.js, Fastify, Prisma, PostgreSQL and Docker**.
Designed for **Linux-first development**, experimentation, and learning modern backend/frontend architecture.

This repository serves as:

- a **training project**
- a **fullstack template**
- a **sandbox for experimenting with modern technologies**

---

# Tech Stack

## Frontend

- **Next.js (App Router)**
- **TypeScript**
- **Tailwind CSS**
- **TanStack Query**
- **Zustand**
- **React Hook Form + Zod**

## Backend

- **Fastify**
- **TypeScript**
- **Prisma ORM**
- **PostgreSQL**

## Infrastructure

- **Docker Compose v2**
- **Linux-first development**
- **Healthchecks**
- **Multi-stage Docker builds**

## Authentication

- **JWT Access Token**
- **Refresh Token rotation**
- **HttpOnly Cookies**
- **argon2 password hashing**

---

# Project Goals

This project is intended to:

- practice **modern fullstack architecture**
- build a **reusable project template**
- experiment with **new technologies**
- develop **production-ready patterns**

The architecture prioritizes:

- maintainability
- security
- scalability
- clear separation of concerns

---

# Architecture

Detailed architecture documentation is available here:

```
ARCHITEKTURA_APLIKACJI_V2.md
```

The application consists of three main services:

- **Frontend** – Next.js application
- **Backend** – Fastify API server
- **Database** – PostgreSQL managed by Prisma

All services are containerized using **Docker Compose**.

---

# Repository Structure

```
.
├── backend/                  Fastify API
├── frontend/                 Next.js application
├── docker/                   Dockerfiles (backend, frontend)
├── .github/                  Copilot instructions
├── docker-compose.yml            ← DEV (hot reload)
├── docker-compose.production.yml ← PROD (built images)
├── .env.example                  ← template konfiguracji
├── setup.sh                      ← bootstrap środowiska
└── ARCHITEKTURA_APLIKACJI_V2.md
```

---

# Getting Started

## Requirements

- Linux / WSL2
- **Docker + Docker Compose v2** (the only requirement)
- Git

---

## 🚀 Installation (new machine / server)

```bash
git clone https://github.com/kstopka/next-fastify-starter.git
cd next-fastify-starter
./setup.sh
```

`setup.sh` automatically:

1. Creates `.env` from `.env.example` (if missing)
2. Builds production Docker images
3. Starts PostgreSQL and waits for it to be healthy
4. Runs Prisma migrations
5. Stops containers — ready to use

---

## 💻 Development (hot reload)

```bash
docker compose --file=docker-compose.yml up -d
```

| What        | How                                          |
| ----------- | -------------------------------------------- |
| Backend     | `tsx watch` — restarts on every `.ts` change |
| Frontend    | `next dev` — HMR / Fast Refresh              |
| Source code | mounted as volumes — no rebuilds             |
| Migrations  | run automatically on startup                 |

> First startup is slower (~30-60s) because `npm install` runs inside containers.
> Next startups are fast — deps cached in named volumes.

**Stop:**

```bash
docker compose --file=docker-compose.yml down
```

**Reset node_modules:**

```bash
docker compose --file=docker-compose.yml down -v
```

---

## ⚙️ Production (built images)

```bash
docker compose --file=docker-compose.production.yml up -d
```

Pre-built images from multi-stage Dockerfiles. No source code mounted.

---

## Services

| Service  | URL                   |
| -------- | --------------------- |
| Frontend | http://localhost:3000 |
| Backend  | http://localhost:4000 |
| Database | localhost:5432        |

---

# Authentication Flow

1. User logs in via backend
2. Backend validates credentials
3. Backend issues:
   - **Access token (short-lived)**
   - **Refresh token (stored in database)**

4. Refresh token stored in **HttpOnly cookie**
5. Access token refreshed automatically when needed

---

# Development Philosophy

This project follows several core principles:

- **Type safety first**
- **Feature-based architecture**
- **Small focused modules**
- **Separation of concerns**
- **Secure defaults**

---

# Roadmap

### Phase 1 – Core Template

- Authentication
- User management
- Dockerized environment

### Phase 2 – Production Improvements

- Redis
- Extended rate limiting
- Monitoring
- Logging improvements

### Phase 3 – Experiments

- WebSockets
- Event-driven architecture
- Queue system
- Feature flags

---

# Commit Convention

The project follows **Conventional Commits**.

Examples:

```
feat(auth): implement login endpoint
fix(api): correct token validation
refactor(user): improve service layer
docs: update architecture documentation
```

---

# License

MIT
