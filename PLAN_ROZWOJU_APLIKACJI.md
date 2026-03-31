# PLAN_ROZWOJU_APLIKACJI.md

Plan budowy nowoczesnej aplikacji fullstack zgodnie z dokumentem `ARCHITEKTURA_APLIKACJI_V2.md`.

**Zasada pracy:**

- Każdy krok zaczyna się jako `[ ]`.
- Po wykonaniu zmień na `[❓]`.
- Testy -> sprawdzenie wykonanego kroku, dopiero po pozytywnym wyniku zmień na `[✅]`.
- **Nie przechodź dalej, jeśli poprzedni krok nie ma `[✅]`.**
- Po zakończeniu etapu wykonaj commit z sekcji **COMMIT**.

Środowisko: **Linux-first (Linux / WSL2)**
Konteneryzacja: **Docker Compose v2**

---

# ETAP 0 — FUNDAMENT PROJEKTU (Repozytorium + Struktura)

## [✅] 0.1 Utworzenie repozytorium projektu

**Co instalujemy**

- Git (jeśli brak)

**Co konfigurujemy**

- Repozytorium GitHub (np. `modern-fullstack-template`)
- Branch `main`

**Co tworzymy**

- Repozytorium z README

**Dlaczego**
Repozytorium jest fundamentem pracy i historii projektu.

**Weryfikacja**
Repozytorium istnieje i można je sklonować.

**Komenda testowa**

```bash
git clone <repo-url>
```

---

## [✅] 0.2 Inicjalizacja struktury katalogów

**Co instalujemy**

- nic

**Co konfigurujemy**

- podstawową strukturę repo

**Co tworzymy**

```
backend/
frontend/
docker/
.github/
ARCHITEKTURA_APLIKACJI_V2.md
README.md
setup.sh
docker-compose.yml
.gitignore
```

**Dlaczego**
Oddzielenie frontend/backend/infrastruktury.

**Weryfikacja**
Struktura istnieje.

**Komenda testowa**

```bash
tree -L 1
```

---

## [✅] 0.3 Konfiguracja `.gitignore`

**Co instalujemy**

- nic

**Co konfigurujemy**
ignorowanie plików:

```
node_modules
.env
dist
.next
coverage
```

**Dlaczego**
zapobieganie commitowaniu plików tymczasowych.

**Weryfikacja**

```bash
git status
```

`node_modules` nie pojawia się.

---

## COMMIT

```
chore(repo): initialize repository structure
```

---

# ETAP 1 — DOCKER FOUNDATION

## [✅] 1.1 Utworzenie podstawowego `docker-compose.yml`

**Co instalujemy**

- Docker
- Docker Compose v2

**Co konfigurujemy**
serwisy:

- postgres
- backend
- frontend

**Co tworzymy**

`docker-compose.yml`

serwis postgres:

- postgres:16
- port 5432

**Dlaczego**
Baza danych musi działać w kontenerze.

**Weryfikacja**

```bash
docker compose up db
```

**Komenda testowa**

```bash
docker ps
```

---

## [✅] 1.2 Dodanie dedykowanej sieci Docker

**Co konfigurujemy**

```
networks:
  app-network:
    driver: bridge
```

**Dlaczego**
kontenery komunikują się przez nazwę serwisu.

**Weryfikacja**

```bash
docker network ls
```

---

## [✅] 1.3 Dodanie wolumenu dla PostgreSQL

**Co konfigurujemy**

```
volumes:
  postgres_data:
```

**Dlaczego**
dane bazy nie znikają po restarcie.

**Weryfikacja**

```bash
docker volume ls
```

---

## COMMIT

```
feat(docker): add base docker compose configuration
```

---

# ETAP 2 — BACKEND BOOTSTRAP

## [✅] 2.1 Inicjalizacja projektu backend

**Co instalujemy**

- Node.js 20
- npm

**Co konfigurujemy**

projekt Node w katalogu backend

**Co tworzymy**

```
backend/package.json
backend/src
backend/tsconfig.json
```

**Dlaczego**
backend musi mieć własny projekt Node.

**Komenda**

```bash
cd backend
npm init -y
```

**Weryfikacja**

```bash
node -v
```

---

## [✅] 2.2 Instalacja Fastify

**Co instalujemy**

```
fastify
```

**Komenda**

```bash
npm install fastify
```

**Dlaczego**
framework backendowy.

**Weryfikacja**

utworzenie minimalnego serwera.

---

## [✅] 2.3 Instalacja TypeScript

**Co instalujemy**

```
typescript
ts-node
@types/node
```

**Komenda**

```bash
npm install -D typescript ts-node @types/node
```

**Dlaczego**
TypeScript zapewnia bezpieczeństwo typów.

**Weryfikacja**

```
npx tsc --init
```

---

## [✅] 2.4 Utworzenie minimalnego serwera Fastify

**Co tworzymy**

```
src/server.ts
```

endpoint:

```
GET /health
```

**Dlaczego**
healthcheck dla Dockera.

**Weryfikacja**

```
curl localhost:4000/health
```

---

## COMMIT

```
feat(backend): bootstrap fastify server
```

---

# ETAP 3 — PRISMA I BAZA DANYCH

## [✅] 3.1 Instalacja Prisma

**Co instalujemy**

```
prisma
@prisma/client
```

**Komenda**

```bash
npm install prisma @prisma/client
```

---

## [✅] 3.2 Inicjalizacja Prisma

```
npx prisma init
```

Tworzy:

```
prisma/schema.prisma
```

---

## [✅] 3.3 Konfiguracja PostgreSQL

```
DATABASE_URL=postgres://postgres:postgres@db:5432/app_db
```

w `.env` (ustawione i sprawdzone — połączenie działa, baza jest obecnie pusta)

---

## [✅] 3.4 Implementacja modeli

Dodano modele `User` i `Session` do `prisma/schema.prisma` i uruchomiono migrację inicjalną.

- `User`:
  - `id` UUID, `email` (unique), `passwordHash`, `createdAt`, `updatedAt`
- `Session`:
  - `id` UUID, `userId` → relacja do `User`, `refreshToken` (unique), `revoked`, `createdAt`, `expiresAt`

Migracja utworzona w `prisma/migrations/*_init/migration.sql` i zastosowana do bazy.

---

## [✅] 3.5 Migracja bazy danych

```
npx prisma migrate dev --name init
```

Wykonano migrację inicjalną (utworzono katalog `prisma/migrations/*_init/migration.sql` i zastosowano ją do bazy). Wygenerowano także Prisma Client (`npx prisma generate`) do `backend/src/generated/prisma`.

---

## Weryfikacja

```
# sprawdź migracje
npx prisma migrate status --schema=prisma/schema.prisma

# uruchom studio (opcjonalnie)
npx prisma studio
```

---

## COMMIT

```
feat(database): add prisma schema and migrations
```

---

# ETAP 4 — AUTORYZACJA

## [✅] 4.1 Instalacja bibliotek auth

```
argon2
jsonwebtoken
zod
```

---

## [✅] 4.2 Implementacja modułu auth

```
src/modules/auth
```

Pliki:

```
auth.controller.ts
auth.service.ts
auth.repository.ts
```

---

## [✅] 4.3 Endpoint login

```
POST /login
```

Flow:

- sprawdzenie hasła
- generacja tokenów
- zapis refresh tokenu

---

## [✅] 4.4 Endpoint refresh

```
POST /refresh
```

---

## COMMIT

```
feat(auth): implement authentication flow
```

---

# ETAP 5 — FRONTEND BOOTSTRAP

## [✅] 5.1 Inicjalizacja Next.js

**Komenda**

```
npx create-next-app@latest frontend
```

Opcje:

- TypeScript
- App Router
- Tailwind

Zaktualizowano do Next.js 16, React 19, Tailwind CSS v4 z `@tailwindcss/postcss`. Build przechodzi pomyślnie.

---

## [✅] 5.2 Struktura katalogów

```
app/
features/
shared/
types/
styles/
```

Utworzono katalogi `features/`, `shared/`, `types/` z `.gitkeep`. Katalog `app/` z App Router (layout, page, login, api).

---

## [✅] 5.3 Konfiguracja Tailwind

Tailwind CSS v4.2.2 z `@tailwindcss/postcss`. CSS używa `@import "tailwindcss"` (składnia v4). Klasy utility działają poprawnie (`npm run build` przechodzi).

---

## Weryfikacja

```
npm run dev
```

---

## COMMIT

```
feat(frontend): bootstrap nextjs application
```

---

# ETAP 6 — INTEGRACJA FRONTEND ↔ BACKEND

## [✅] 6.1 Implementacja API layer

frontend:

```
shared/lib/api/client.ts   — uniwersalny fetch wrapper (GET/POST/PUT/DELETE)
shared/lib/api/auth.ts     — loginApi, refreshApi, logoutApi
shared/lib/api/index.ts    — barrel export
```

BFF pattern: API routes w `app/api/auth/{login,refresh,logout}/route.ts` proxy do Fastify. Refresh token w HttpOnly cookie.

---

## [✅] 6.2 Implementacja logowania

formularz:

```
features/auth/login/LoginForm.tsx
features/auth/login/index.ts
```

Komponent `LoginForm` z walidacją, obsługą błędów, redirectem na `/dashboard`. Strona `/login` importuje z `@/features/auth/login`.

---

## [✅] 6.3 Integracja TanStack Query

`@tanstack/react-query` zainstalowany. `QueryProvider` w `shared/providers/QueryProvider.tsx`, podpięty w `app/layout.tsx`. Hook `useLogin` w `features/auth/hooks/useAuth.ts` używany w `LoginForm`.

---

## [✅] 6.4 Middleware auth

`middleware.ts` w root frontendu. Chroni `/dashboard` (redirect na `/login`). Zalogowani użytkownicy z `/login` → redirect na `/dashboard`. Oparte na cookie `logged_in`.

---

## COMMIT

```
feat(integration): connect frontend with backend api
```

---

# ETAP 7 — DOCKERIZACJA APLIKACJI

## [✅] 7.1 Dockerfile backend

`docker/backend.Dockerfile` — multi-stage (builder → runner). node:20-alpine, `npm ci`, `prisma generate`, `tsc`, healthcheck via `wget /health`.

---

## [✅] 7.2 Dockerfile frontend

`docker/frontend.Dockerfile` — 3-stage (deps → builder → runner). `output: "standalone"` w next.config.js. Non-root user `nextjs`. Port 3000.

---

## [✅] 7.3 Integracja z docker-compose

serwisy:

- db (postgres:16, healthcheck `pg_isready`)
- backend (build z `docker/backend.Dockerfile`, depends_on db healthy)
- frontend (build z `docker/frontend.Dockerfile`, `BACKEND_URL=http://backend:4000`)

---

## Weryfikacja

```
docker compose up --build
```

---

## COMMIT

```
feat(docker): dockerize fullstack application
```

---

# ETAP 8 — SKRYPT `setup.sh`

## [✅] 8.1 Implementacja setup script

Skrypt `setup.sh`:

1. Pre-flight checks (docker, compose)
2. `docker compose build`
3. Start db + wait for `pg_isready`
4. `prisma migrate deploy`
5. `docker compose up -d`
6. Print URLs (frontend :3000, backend :4000, db :5432)

---

## Weryfikacja

```
./setup.sh
```

---

## COMMIT

```
feat(dev): add environment setup script
```

---

# KONIEC ETAPU 1 (MINIMALNY TEMPLATE)

Projekt zawiera:

- docker
- postgres
- prisma
- fastify
- nextjs
- auth
- integrację frontend/backend

Gotowy fundament pod dalszy rozwój.
