# 🚨 STRICT DEVELOPMENT MODE (MANDATORY)

You are working in **STEP-BY-STEP EXECUTION MODE**.

This is NOT a normal coding session.

You MUST follow these rules strictly.

---

# ❗ CORE RULE (MOST IMPORTANT)

You are ONLY allowed to work on **ONE STEP at a time**.

You MUST NOT:

- jump to next steps
- suggest future steps
- implement multiple steps at once
- assume something is done

If a step is not marked `[✅]`, you MUST STOP.

---

# 📄 SOURCE OF TRUTH

The file:

PLAN_ROZWOJU_APLIKACJI.md

is the ONLY source of truth.

You MUST:

1. Read the file
2. Find the FIRST step that is NOT `[✅]`
3. Work ONLY on that step

---

# 🔁 EXECUTION LOOP (MANDATORY)

For EVERY step you MUST follow this exact process:

---

## 1. UNDERSTAND STEP

Explain briefly:

- what this step is about
- what will be done

---

## 2. IMPLEMENTATION

Provide:

- exact commands
- exact code
- exact file paths

NO placeholders like:

- "add something"
- "configure as needed"

Everything must be concrete.

---

## 3. TEST / VERIFICATION

Provide:

- exact command to verify
- expected output

---

## 4. RESULT STATUS

After implementation you MUST say:

- If user still needs to run something:
  → mark as `[❓]`

- If step can be confirmed as done:
  → mark as `[✅]`

---

## 5. STOP

After finishing step:

You MUST STOP and wait.

You MUST ask:

"Confirm when step is completed or paste result."

DO NOT continue.

---

# 🛑 HARD STOP RULE

You are FORBIDDEN to:

- continue to next step automatically
- summarize future steps
- suggest roadmap
- generate full implementations ahead

---

# 🧠 CONTEXT RULES

Tech stack:

- Backend: Fastify + TypeScript + Prisma
- Frontend: Next.js (App Router) + Tailwind
- Auth: JWT + Refresh Tokens + HttpOnly cookies
- DB: PostgreSQL
- Infra: Docker Compose v2
- Environment: Linux-first

---

# 🧱 BACKEND RULES

- Use modular architecture (auth, user)
- Separate controller / service / repository
- Use Zod for validation
- Use argon2 for passwords
- Use Pino for logging

---

# 🎨 FRONTEND RULES

- Use App Router
- Prefer Server Components
- Use Tailwind
- Use React Query
- Use Zustand ONLY for small UI state

---

# 🐳 DOCKER RULES

- Use node:20-alpine
- Use PostgreSQL 16
- Use healthcheck `/health`
- Use named volumes

---

# ❌ FORBIDDEN

- Skipping steps
- Guessing completed steps
- Using outdated patterns (Express, CommonJS)
- Using `any`
- Writing pseudo-code

---

# ✅ RESPONSE FORMAT (MANDATORY)

Every response MUST follow this structure:

---

## STEP: <step name>

### 1. What we do

...

### 2. Implementation

(code + commands)

### 3. Verification

(command + expected result)

### 4. Status

[ ] / [❓] / [✅]

### 5. Next action

(wait for user)

---

# 🎯 GOAL

The goal is NOT speed.

The goal is:

- correctness
- step-by-step execution
- zero skipped steps
- production-quality setup

---

# FINAL RULE

If you are unsure:

DO NOT GUESS.

ASK.
