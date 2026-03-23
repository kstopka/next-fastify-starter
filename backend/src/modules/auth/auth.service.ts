import * as argon2 from "argon2";
import jwt from "jsonwebtoken";
import { z } from "zod";
import {
  findUserByEmail,
  createSession,
  findSessionByToken,
  revokeSession,
} from "./auth.repository.js";
import crypto from "node:crypto";

const JWT_SECRET = process.env.JWT_SECRET ?? "change_me";
const ACCESS_EXPIRES_SECONDS = Number(
  process.env.ACCESS_EXPIRES_SECONDS ?? 60 * 15,
); // 15 min
const REFRESH_EXPIRES_DAYS = Number(process.env.REFRESH_EXPIRES_DAYS ?? 30);

export const hashPassword = async (plain: string) => {
  return argon2.hash(plain);
};

export const verifyPassword = async (hash: string, plain: string) => {
  return argon2.verify(hash, plain);
};

export const generateAccessToken = (payload: object) => {
  return jwt.sign(payload, JWT_SECRET, {
    expiresIn: `${ACCESS_EXPIRES_SECONDS}s`,
  });
};

export const login = async ({
  email,
  password,
}: {
  email: string;
  password: string;
}) => {
  const user = await findUserByEmail(email);
  if (!user || !user.passwordHash) return null;

  const ok = await verifyPassword(user.passwordHash, password);
  if (!ok) return null;

  const accessToken = generateAccessToken({ sub: user.id, email: user.email });
  const refreshToken = crypto.randomUUID();
  const expiresAt = new Date(
    Date.now() + REFRESH_EXPIRES_DAYS * 24 * 60 * 60 * 1000,
  );

  await createSession({ userId: user.id, refreshToken, expiresAt });

  return { accessToken, refreshToken };
};

export const refresh = async (token: string) => {
  const session = await findSessionByToken(token);
  if (!session) return null;
  if (session.revoked) return null;
  if (session.expiresAt && session.expiresAt.getTime() < Date.now())
    return null;

  // load user id from session
  const payload = { sub: session.userId };
  const accessToken = generateAccessToken(payload);
  return { accessToken };
};

export const logout = async (token: string) => {
  const session = await findSessionByToken(token);
  if (!session) return null;
  await revokeSession(session.id);
  return true;
};
