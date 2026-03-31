"use client";
import React, { useState } from "react";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setMessage(null);
    try {
      const res = await fetch("/api/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data?.error || "Login failed");
      setMessage("Zalogowano — access token otrzymany");
    } catch (err: any) {
      setMessage(err?.message ?? "Błąd");
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="min-h-screen flex items-center justify-center">
      <form className="w-full max-w-md p-6 border rounded" onSubmit={submit}>
        <h2 className="text-lg font-medium mb-4">Logowanie</h2>
        <label className="block mb-2">
          <span className="text-sm">Email</span>
          <input
            className="mt-1 block w-full border px-2 py-1 rounded"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            type="email"
            required
          />
        </label>
        <label className="block mb-4">
          <span className="text-sm">Hasło</span>
          <input
            className="mt-1 block w-full border px-2 py-1 rounded"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            type="password"
            required
          />
        </label>
        <button
          className="bg-blue-600 text-white px-4 py-2 rounded"
          type="submit"
          disabled={loading}
        >
          {loading ? "Trwa..." : "Zaloguj"}
        </button>
        {message && <p className="mt-4 text-sm">{message}</p>}
      </form>
    </main>
  );
}
