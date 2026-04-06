-- Add Role enum and role column to users
CREATE TYPE "Role" AS ENUM ('USER', 'ADMIN');

ALTER TABLE "users"
ADD COLUMN "role" "Role" NOT NULL DEFAULT 'USER';
