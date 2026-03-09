# PLAN_ROZWOJU_APLIKACJI.md

Plan budowy nowoczesnej aplikacji fullstack zgodnie z dokumentem `ARCHITEKTURA_APLIKACJI_V2.md`.

**Zasada pracy:**

- Każdy krok zaczyna się jako `[ ]`.
- Po wykonaniu zmień na `[✅]`.
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

## [ ] 0.3 Konfiguracja `.gitignore`

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

## [ ] 1.1 Utworzenie podstawowego `docker-compose.yml`

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

## [ ] 1.2 Dodanie dedykowanej sieci Docker

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

## [ ] 1.3 Dodanie wolumenu dla PostgreSQL

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

## [ ] 2.1 Inicjalizacja projektu backend

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

## [ ] 2.2 Instalacja Fastify

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

## [ ] 2.3 Instalacja TypeScript

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

## [ ] 2.4 Utworzenie minimalnego serwera Fastify

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

## [ ] 3.1 Instalacja Prisma

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

## [ ] 3.2 Inicjalizacja Prisma

```
npx prisma init
```

Tworzy:

```
prisma/schema.prisma
```

---

## [ ] 3.3 Konfiguracja PostgreSQL

```
DATABASE_URL
```

w `.env`

---

## [ ] 3.4 Implementacja modeli

Dodaj modele:

- User
- Session

zgodnie z architekturą.

---

## [ ] 3.5 Migracja bazy danych

```
npx prisma migrate dev --name init
```

---

## Weryfikacja

```
npx prisma studio
```

---

## COMMIT

```
feat(database): add prisma schema and migrations
```

---

# ETAP 4 — AUTORYZACJA

## [ ] 4.1 Instalacja bibliotek auth

```
argon2
jsonwebtoken
zod
```

---

## [ ] 4.2 Implementacja modułu auth

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

## [ ] 4.3 Endpoint login

```
POST /login
```

Flow:

- sprawdzenie hasła
- generacja tokenów
- zapis refresh tokenu

---

## [ ] 4.4 Endpoint refresh

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

## [ ] 5.1 Inicjalizacja Next.js

**Komenda**

```
npx create-next-app@latest frontend
```

Opcje:

- TypeScript
- App Router
- Tailwind

---

## [ ] 5.2 Struktura katalogów

```
src/
app/
features/
shared/
types/
```

---

## [ ] 5.3 Konfiguracja Tailwind

instalacja i weryfikacja stylów.

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

## [ ] 6.1 Implementacja API layer

frontend:

```
shared/lib/api
```

---

## [ ] 6.2 Implementacja logowania

formularz:

```
features/auth/login
```

---

## [ ] 6.3 Integracja TanStack Query

server state.

---

## [ ] 6.4 Middleware auth

ochrona tras.

---

## COMMIT

```
feat(integration): connect frontend with backend api
```

---

# ETAP 7 — DOCKERIZACJA APLIKACJI

## [ ] 7.1 Dockerfile backend

node:20-alpine
multi-stage

---

## [ ] 7.2 Dockerfile frontend

Next.js build

---

## [ ] 7.3 Integracja z docker-compose

serwisy:

- db
- backend
- frontend

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

## [ ] 8.1 Implementacja setup script

Skrypt:

- build
- migrate
- start

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
