import { NextRequest, NextResponse } from "next/server";

const BACKEND_URL = process.env.BACKEND_URL ?? "http://localhost:4000";

export async function POST(req: NextRequest) {
  try {
    const refreshToken = req.cookies.get("refreshToken")?.value;
    if (refreshToken) {
      await fetch(`${BACKEND_URL}/logout`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ refreshToken }),
      });
    }

    const response = NextResponse.json({ ok: true });
    response.cookies.delete("refreshToken");
    response.cookies.delete("logged_in");
    return response;
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "proxy error";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
