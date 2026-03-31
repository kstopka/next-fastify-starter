import { NextRequest, NextResponse } from "next/server";

const BACKEND_URL = process.env.BACKEND_URL ?? "http://localhost:4000";

export async function POST(req: NextRequest) {
  try {
    const refreshToken = req.cookies.get("refreshToken")?.value;
    if (!refreshToken) {
      return NextResponse.json({ error: "No refresh token" }, { status: 401 });
    }

    const resp = await fetch(`${BACKEND_URL}/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken }),
    });
    const data = await resp.json().catch(() => ({}));

    if (!resp.ok) {
      // If refresh failed, clear cookies
      const response = NextResponse.json(
        { error: data?.error ?? "Refresh failed" },
        { status: resp.status },
      );
      response.cookies.delete("refreshToken");
      response.cookies.delete("logged_in");
      return response;
    }

    return NextResponse.json({ accessToken: data.accessToken });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "proxy error";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
