import pkg from "@prisma/client";

const PrismaPkg: any = pkg;
const PrismaClient =
  PrismaPkg.PrismaClient ??
  PrismaPkg.default?.PrismaClient ??
  PrismaPkg.default ??
  PrismaPkg;
const prisma = new PrismaClient();

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
