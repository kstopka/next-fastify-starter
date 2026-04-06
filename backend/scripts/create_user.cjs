const { PrismaClient } = require("@prisma/client");
const { PrismaPg } = require("@prisma/adapter-pg");
const argon2 = require("argon2");

async function main() {
  const email = process.env.NEW_USER_EMAIL;
  const password = process.env.NEW_USER_PASSWORD;
  const role = process.env.NEW_USER_ROLE || "USER";

  if (!email || !password) {
    console.error(
      "NEW_USER_EMAIL and NEW_USER_PASSWORD environment variables are required",
    );
    process.exit(2);
  }

  // initialize PrismaClient with the PrismaPg adapter (matches backend setup)
  const DATABASE_URL =
    process.env.DATABASE_URL || "postgres://postgres:postgres@db:5432/app_db";
  const adapter = new PrismaPg({ connectionString: DATABASE_URL });
  const prisma = new PrismaClient({ adapter });
  try {
    const hash = await argon2.hash(password);
    const user = await prisma.user.create({
      data: {
        email,
        passwordHash: hash,
        role,
      },
    });
    console.log("Created user:", user.id, user.email, user.role);
  } catch (err) {
    console.error("Failed to create user:", err.message || err);
    process.exitCode = 1;
  } finally {
    await prisma.$disconnect();
  }
}

main();
