# HowItWork — Jak poznać ten projekt

Ten dokument opisuje krok-po-kroku sposób poznania i zrozumienia repozytorium — od pliku instalacyjnego `setup.sh` do frontendu, który wyświetla stronę docelową.

## Szybkie Wprowadzenie

- Stack: Next.js (App Router) frontend, Fastify backend, Prisma + PostgreSQL, Docker Compose.
- Celem tego przewodnika jest przejście przez najważniejsze etapy eksploracji kodu i uruchomienia aplikacji lokalnie.

## Kroki eksploracji (kolejność)

1. Setup i uruchomienie środowiska
   - Plik startowy: `setup.sh` — uruchom go lokalnie aby przygotować środowisko (kopiuje `.env`, uruchamia DB, wykonuje migracje, startuje serwisy dev/prod).
   - Pliki powiązane: `docker-compose.yml`, `docker-compose.production.yml`, `docker/backend.Dockerfile`, `docker/frontend.Dockerfile`, `.env.example`.
   - Co sprawdzić: czy kontenery DB, backend i frontend uruchamiają się; czy Prisma wykonał migracje.

2. Baza danych i migracje
   - Pliki: `backend/prisma/schema.prisma`, `backend/prisma/migrations/*`.
   - Cel: zrozumieć modele (User, Session itp.) i sposób migracji.

3. Backend (Fastify)
   - Główne pliki: `backend/src/server.ts` — punkt wejścia serwera.
   - Moduły: `backend/src/modules/auth/*` — `auth.controller.ts`, `auth.service.ts`, `auth.repository.ts`.
   - Endpoints: healthcheck (`/health`), auth endpoints używane przez BFF (login/refresh/logout).
   - Co sprawdzić: jak wygląda logika logowania, rotacja refresh tokenów, użycie argon2 i JWT.

4. Frontend (Next.js)
   - Główne pliki: `frontend/app/layout.tsx`, `frontend/app/page.tsx`.
   - BFF (proxy API): `frontend/app/api/auth/*/route.ts` (login, logout, refresh) — te route'y komunikują się z backendem z serwera Next.js.
   - UI: `frontend/app/login/page.tsx`, `frontend/features/auth/login/LoginForm.tsx` — formularz logowania z Zod + React Hook Form.
   - Ochrona tras: `frontend/middleware.ts` — sprawdza cookie `logged_in` i przekierowuje.

5. Klient API i tanstack query
   - Pliki: `frontend/shared/lib/api/client.ts`, `frontend/shared/lib/api/auth.ts` — klient API i helpery auth.
   - Sprawdź, jak zachowywana jest sesja, gdzie trafia cookie z refresh tokenem i jak odświeżane są tokeny.

6. Testy i uruchomienie lokalne
   - Backend tests: `backend/src/__tests__/health.test.ts` — przykład prostego testu endpointu.
   - Jak uruchomić lokalnie: polecenia z `README.md` oraz `setup.sh` (dev/prod tryby).

## Szczegóły `setup.sh` (co robi i dlaczego)

- Tworzy `.env` z `.env.example`, jeśli brakuje.
- Dla trybu `prod` buduje obrazy Docker (`docker compose --file=... build`).
- Uruchamia serwis DB (`docker compose up -d db`) i czeka aż PostgreSQL odpowie (`pg_isready`).
- Wykonuje migracje Prisma: `npx prisma migrate deploy` uruchomione w kontenerze backend.
- W trybie dev uruchamia cały zestaw serwisów dev z HMR: `docker compose up -d`.

## Porządek plików do sprawdzenia (szybka lista)

- [backend/src/server.ts](backend/src/server.ts)
- [backend/src/modules/auth/auth.controller.ts](backend/src/modules/auth/auth.controller.ts)
- [backend/src/modules/auth/auth.service.ts](backend/src/modules/auth/auth.service.ts)
- [backend/src/modules/auth/auth.repository.ts](backend/src/modules/auth/auth.repository.ts)
- [backend/prisma/schema.prisma](backend/prisma/schema.prisma)
- [frontend/app/api/auth/login/route.ts](frontend/app/api/auth/login/route.ts)
- [frontend/app/api/auth/refresh/route.ts](frontend/app/api/auth/refresh/route.ts)
- [frontend/app/api/auth/logout/route.ts](frontend/app/api/auth/logout/route.ts)
- [frontend/middleware.ts](frontend/middleware.ts)
- [frontend/app/login/page.tsx](frontend/app/login/page.tsx)
- [frontend/features/auth/login/LoginForm.tsx](frontend/features/auth/login/LoginForm.tsx)
- [frontend/shared/lib/api/client.ts](frontend/shared/lib/api/client.ts)

## Prompt AI — użycie

Below znajduje się gotowy prompt, który wkleisz do AI i w którym podasz tylko nazwę punktu (np. „Analiza setup.sh” lub „Backend — auth.service.ts”). AI zwróci krok-po-kroku wyjaśnienie.

Prompt (wklej i zastąp {NAZWA_PUNKTU} nazwą punktu):

"Jesteś ekspertem pomagającym programiście zrozumieć repozytorium Next.js + Fastify. Otrzymasz nazwę punktu: '{NAZWA_PUNKTU}'. Wyjaśnij to w następującym formacie:

1. Krótki cel: 1-2 zdania, po co jest ten element.
2. Pliki/ścieżki powiązane: wymień ścieżki w repozytorium.
3. Szczegółowe kroki działania: krok-po-kroku jak to działa (wewnętrzna logika, wywołania sieciowe, tokeny itp.).
4. Jak przetestować lokalnie: konkretne komendy i kroki do weryfikacji działania.
5. Gdzie szukać błędów/typowe problemy: 3-5 punktów diagnostycznych i wskazówek naprawczych.
   Użyj prostego, technicznego języka po polsku i podaj przykładowe komendy do terminala, gdy to istotne. Weź pod uwagę, że środowisko jest Linux i aplikacja używa Docker Compose."

Przykład użycia: jeśli podasz "Analiza setup.sh", AI zwróci szczegółowe wyjaśnienie każdego polecenia w `setup.sh` oraz sposoby testowania i debugowania.

---

Plik ten powstał jako przewodnik szybkiego startu i jako podstawa do dalszego tłumaczenia poszczególnych plików przez AI — wklej do AI tylko nazwę interesującego punktu, a dostaniesz szczegółowe wyjaśnienie.
