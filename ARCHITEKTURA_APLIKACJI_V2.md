# ARCHITEKTURA APLIKACJI V2

## Cel projektu

Nowoczesna aplikacja fullstack budowana w środowisku Linux-first,
konteneryzowana przy użyciu Docker Compose v2, z backendem opartym na
Fastify oraz frontendem w Next.js (App Router).

Projekt ma charakter treningowy oraz ewolucyjny --- będzie rozwijany
etapami i może w przyszłości stać się szablonem (template) pod kolejne
aplikacje.

------------------------------------------------------------------------

# 0️⃣ Dockeryzacja

## Założenia

-   Jedno repozytorium (db + backend + frontend)
-   Budowanie całego środowiska jednym skryptem `setup.sh`
-   Środowisko Linux-first (WSL2 / Linux / VPS)
-   Profile dev / prod
-   Multi-stage Dockerfile
-   Healthcheck backendu

## Serwisy

-   postgres (PostgreSQL 16)
-   backend (Fastify + TypeScript)
-   frontend (Next.js 14+)
-   pgadmin (tylko dev -- opcjonalnie)
-   redis (opcjonalnie -- etap 2)

## Sieć

-   Dedykowana sieć Docker `app-network`
-   Komunikacja backend → db przez nazwę serwisu

## Healthcheck

Backend posiada endpoint `/health` sprawdzany przez Docker, aby
monitorować czy aplikacja działa poprawnie.

------------------------------------------------------------------------

# 1️⃣ Baza Danych

## System

-   PostgreSQL 16
-   Prisma ORM
-   Migracje: `prisma migrate dev`

## Model User

``` prisma
model User {
  id            String   @id @default(uuid())
  email         String   @unique
  passwordHash  String
  role          Role     @default(USER)
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt

  sessions      Session[]
}

enum Role {
  USER
  ADMIN
}
```

## Model Session (Refresh Tokens)

``` prisma
model Session {
  id           String   @id @default(uuid())
  userId       String
  refreshToken String
  expiresAt    DateTime
  createdAt    DateTime @default(now())

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

## Hasła

-   Algorytm: argon2
-   W bazie przechowywany wyłącznie hash hasła

------------------------------------------------------------------------

# 2️⃣ Backend

## Stack

-   Node.js 20-alpine
-   Fastify
-   TypeScript
-   Prisma
-   Zod (walidacja)
-   argon2 (hashowanie)
-   JWT (access + refresh)
-   HttpOnly cookies
-   Pino (logger)
-   @fastify/rate-limit
-   Helmet
-   Vitest (testy)

## Architektura

Struktura modułowa (feature-based):

    src/
      modules/
        user/
        auth/
      middleware/
      plugins/
      utils/
      app.ts
      server.ts

## Autoryzacja

-   Access Token (15 minut)
-   Refresh Token (7 dni)
-   Refresh przechowywany w bazie
-   Token rotation
-   Możliwość unieważnienia sesji

Flow: 1. Login → weryfikacja hasła 2. Generacja access + refresh 3.
Refresh zapisany w DB 4. HttpOnly cookie 5. Endpoint `/refresh` wydaje
nowy access

------------------------------------------------------------------------

# 3️⃣ Frontend

## Stack

-   Next.js 14+ (App Router)
-   TypeScript
-   Tailwind CSS
-   shadcn/ui (UI components)
-   TanStack Query (server state)
-   Zustand (global UI state)
-   React Hook Form + Zod
-   Middleware auth

## Architektura

Feature-based:

    src/
      app/
      features/
        auth/
        user/
      shared/
        components/
        hooks/
        lib/
      types/

## Autoryzacja

-   Logowanie przez Next.js API Routes (BFF)
-   HttpOnly cookies
-   Middleware chroni trasy
-   Automatyczne odświeżanie access tokenu

------------------------------------------------------------------------

# Etapy Rozwoju

## Etap 1 -- Minimalny Template

-   Auth
-   User
-   Docker
-   Fastify
-   Next.js
-   Prisma

## Etap 2 -- Produkcyjny Template

-   Redis
-   Rate limiting rozszerzony
-   Monitoring
-   Audit log

## Etap 3 -- Eksperymenty

-   Websocket
-   Queue system
-   Event-driven
-   Feature flags

------------------------------------------------------------------------

# Środowisko

-   Linux-first
-   Gotowe do wdrożenia na VPS
-   Jeden skrypt `setup.sh` budujący całe środowisko

------------------------------------------------------------------------

To jest baza architektoniczna pod nowoczesny, rozwijalny projekt
fullstack.
