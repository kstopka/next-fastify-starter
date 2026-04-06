export type Role = "USER" | "ADMIN";

export interface User {
  id: string;
  email: string;
  role: Role;
  createdAt: string;
  updatedAt: string;
}

export default User;
