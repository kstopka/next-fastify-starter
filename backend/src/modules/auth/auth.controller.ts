import { FastifyInstance } from "fastify";
import { z } from "zod";
import { login, refresh, logout } from "./auth.service.js";

export default async function registerAuthRoutes(server: FastifyInstance) {
  const loginSchema = z.object({
    email: z.string().email(),
    password: z.string().min(1),
  });
  server.post("/login", async (request, reply) => {
    try {
      const body = loginSchema.parse(request.body);
      const result = await login(body);
      if (!result)
        return reply.status(401).send({ error: "Invalid credentials" });
      return reply.send(result);
    } catch (err) {
      return reply.status(400).send({ error: "Bad request" });
    }
  });

  const refreshSchema = z.object({ refreshToken: z.string().min(1) });
  server.post("/refresh", async (request, reply) => {
    try {
      const { refreshToken } = refreshSchema.parse(request.body);
      const result = await refresh(refreshToken);
      if (!result)
        return reply.status(401).send({ error: "Invalid refresh token" });
      return reply.send(result);
    } catch (err) {
      return reply.status(400).send({ error: "Bad request" });
    }
  });

  server.post("/logout", async (request, reply) => {
    try {
      const { refreshToken } = refreshSchema.parse(request.body);
      await logout(refreshToken);
      return reply.send({ ok: true });
    } catch (err) {
      return reply.status(400).send({ error: "Bad request" });
    }
  });
}
