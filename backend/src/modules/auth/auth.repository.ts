import { PrismaClient } from "../../generated/prisma/client";

const prisma = new PrismaClient();

export const findUserByEmail = async (email: string) => {
  return prisma.user.findUnique({ where: { email } });
};

export const createSession = async (data: {
  userId: string;
  refreshToken: string;
  expiresAt: Date;
}) => {
  return prisma.session.create({ data });
};

export const findSessionByToken = async (token: string) => {
  return prisma.session.findUnique({ where: { refreshToken: token } });
};

export const revokeSession = async (id: string) => {
  return prisma.session.update({ where: { id }, data: { revoked: true } });
};
