import { PrismaClient } from "@prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";

const DATABASE_URL = process.env.DATABASE_URL;
if (!DATABASE_URL) {
  throw new Error("DATABASE_URL environment variable is required");
}

const adapter = new PrismaPg({ connectionString: DATABASE_URL });
const prisma = new PrismaClient({ adapter });

export const findUserByEmail = async (email: string): Promise<any> => {
  return prisma.user.findUnique({ where: { email } });
};

export const createSession = async (data: {
  userId: string;
  refreshToken: string;
  expiresAt: Date;
}): Promise<any> => {
  return prisma.session.create({ data });
};

export const findSessionByToken = async (token: string): Promise<any> => {
  return prisma.session.findUnique({ where: { refreshToken: token } });
};

export const revokeSession = async (id: string): Promise<any> => {
  return prisma.session.update({ where: { id }, data: { revoked: true } });
};
