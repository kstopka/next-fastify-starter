import "../styles/globals.css";
import { QueryProvider } from "@/shared/providers";

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
      <body>
        <QueryProvider>{children}</QueryProvider>
      </body>
    </html>
  );
}
