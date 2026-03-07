# Repository Instructions for GitHub Copilot

## Project Overview

This repository contains a modern fullstack application built with:

-   Backend: Fastify + TypeScript + Prisma + PostgreSQL
-   Frontend: Next.js (App Router) + TypeScript + Tailwind CSS
-   Authentication: JWT (access + refresh) with HttpOnly cookies
-   Containerization: Docker Compose v2
-   Environment: Linux-first (WSL2 compatible, VPS-ready)

This project is designed as a long-term training and template
foundation. Code quality, clarity, and architecture consistency are
extremely important.

------------------------------------------------------------------------

# General Coding Rules

-   Always use TypeScript (no plain JavaScript).
-   Prefer explicit types over `any`.
-   Use strict typing and avoid unsafe casts.
-   Follow clean architecture principles.
-   Keep files small and responsibility-focused.
-   Do not introduce unnecessary dependencies.
-   Do not generate legacy patterns.
-   Do not use deprecated APIs.

------------------------------------------------------------------------

# Backend Rules (Fastify)

## Architecture

-   Follow feature-based modular structure:

src/ modules/ auth/ user/ plugins/ middleware/ utils/ app.ts server.ts

-   Separate controller, service, and repository logic.
-   Do not mix HTTP logic with business logic.
-   All validation must use Zod.
-   Prisma access must be isolated inside repositories or services.

## Authentication

-   Use access token (short-lived).
-   Use refresh token (stored in DB).
-   Store refresh tokens in Session table.
-   Use HttpOnly cookies for tokens.
-   Never expose refresh tokens to frontend JavaScript.

## Security

-   Use argon2 for password hashing.
-   Never store plain passwords.
-   Use rate limiting.
-   Use helmet.
-   Validate all input.
-   Return safe error messages.

## Logging

-   Use Pino for logging.
-   Avoid console.log in production code.

------------------------------------------------------------------------

# Database Rules (Prisma + PostgreSQL)

-   Use UUID as primary keys.
-   Always create migrations using `prisma migrate dev`.
-   Never use `db push` in production context.
-   Keep schema clean and normalized.
-   Use relations explicitly.
-   Always handle cascading deletes intentionally.

------------------------------------------------------------------------

# Frontend Rules (Next.js App Router)

## Architecture

Use feature-based structure:

src/ app/ features/ auth/ user/ shared/ components/ hooks/ lib/ types/

-   Prefer Server Components when possible.
-   Use Client Components only when necessary.
-   Keep business logic outside UI components.

## Styling

-   Use Tailwind CSS.
-   Prefer utility-first approach.
-   Avoid inline styles.
-   Keep design consistent and minimal.

## State Management

-   Use TanStack Query for server state.
-   Use Zustand only for small global UI state.
-   Use React Hook Form + Zod for forms.
-   Do not use Redux unless explicitly requested.
-   Avoid overusing React Context.

## API Layer

-   Use Next.js API Routes as BFF layer when needed.
-   Keep API calls centralized.
-   Handle token refresh logic properly.
-   Never expose sensitive tokens to client-side JS.

------------------------------------------------------------------------

# Docker Rules

-   Use multi-stage builds.
-   Keep images small (node:20-alpine).
-   Separate dev and prod profiles.
-   Do not hardcode secrets.
-   Use environment variables.
-   Always include healthcheck endpoint `/health`.

------------------------------------------------------------------------

# Code Quality

-   Prefer readable code over clever code.
-   Use descriptive variable names.
-   Avoid magic numbers.
-   Extract reusable logic.
-   Follow consistent formatting.

------------------------------------------------------------------------

# Commit Convention

Follow Conventional Commits:

-   feat: new feature
-   fix: bug fix
-   refactor: code improvement
-   chore: maintenance
-   docs: documentation
-   test: tests

------------------------------------------------------------------------

# What Copilot Should Avoid

-   Generating outdated Express patterns.
-   Using CommonJS syntax (use ESM).
-   Adding unnecessary global state.
-   Suggesting insecure authentication flows.
-   Mixing frontend and backend responsibilities.

------------------------------------------------------------------------

This repository prioritizes: - clarity - modern architecture -
security - scalability - maintainability

When generating code, always align with these principles.
