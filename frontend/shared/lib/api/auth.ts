/**
 * Auth API — server-side calls via Next.js API routes (BFF pattern).
 * Frontend calls /api/auth/* which proxies to the Fastify backend.
 */

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
}

export interface RefreshResponse {
  accessToken: string;
}

/** Login through the BFF proxy (Next.js API Route) */
export async function loginApi(data: LoginRequest): Promise<LoginResponse> {
  const res = await fetch("/api/auth/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error ?? "Login failed");
  }
  return res.json();
}

/** Refresh through the BFF proxy */
export async function refreshApi(
  refreshToken: string,
): Promise<RefreshResponse> {
  const res = await fetch("/api/auth/refresh", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ refreshToken }),
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body?.error ?? "Refresh failed");
  }
  return res.json();
}

/** Logout through the BFF proxy */
export async function logoutApi(refreshToken: string): Promise<void> {
  await fetch("/api/auth/logout", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ refreshToken }),
  });
}
