"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useLogin } from "@/features/auth/hooks";

export default function LoginForm() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const loginMutation = useLogin();

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();

    loginMutation.mutate(
      { email, password },
      {
        onSuccess(data) {
          if (data.accessToken) {
            sessionStorage.setItem("accessToken", data.accessToken);
          }
          router.push("/dashboard");
        },
      },
    );
  };

  return (
    <form
      className="w-full max-w-md p-6 border border-gray-200 rounded-lg shadow-sm"
      onSubmit={submit}
    >
      <h2 className="text-xl font-semibold mb-6">Logowanie</h2>

      {loginMutation.isError && (
        <div className="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 text-sm rounded">
          {loginMutation.error instanceof Error
            ? loginMutation.error.message
            : "Błąd logowania"}
        </div>
      )}

      <label className="block mb-3">
        <span className="text-sm font-medium text-gray-700">Email</span>
        <input
          className="mt-1 block w-full border border-gray-300 px-3 py-2 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          type="email"
          placeholder="user@example.com"
          required
        />
      </label>

      <label className="block mb-6">
        <span className="text-sm font-medium text-gray-700">Hasło</span>
        <input
          className="mt-1 block w-full border border-gray-300 px-3 py-2 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          type="password"
          placeholder="••••••••"
          required
        />
      </label>

      <button
        className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium px-4 py-2 rounded-md transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        type="submit"
        disabled={loginMutation.isPending}
      >
        {loginMutation.isPending ? "Logowanie..." : "Zaloguj się"}
      </button>
    </form>
  );
}
