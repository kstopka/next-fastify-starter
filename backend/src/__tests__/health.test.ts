import { describe, it, expect, afterAll } from "vitest";
import app from "../server";

describe("GET /health", () => {
  it("returns status ok", async () => {
    const res = await app.inject({ method: "GET", url: "/health" });
    expect(res.statusCode).toBe(200);
    expect(JSON.parse(res.payload)).toEqual({ status: "ok" });
  });

  afterAll(async () => {
    try {
      await app.close();
    } catch (err) {
      // ignore
    }
  });
});
