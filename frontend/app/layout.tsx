import "../styles/globals.css";
import React from "react";

export const metadata = {
  title: "App",
  description: "Next + Fastify Starter",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="pl">
      <body>{children}</body>
    </html>
  );
}
