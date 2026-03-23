import Fastify from "fastify";

const PORT = Number(process.env.PORT ?? 4000);
const server = Fastify({ logger: true });

server.get("/health", async () => {
  return { status: "ok" };
});

const start = async () => {
  try {
    await server.listen({ port: PORT, host: "0.0.0.0" });
    server.log.info(`Server listening on ${PORT}`);
  } catch (err) {
    server.log.error(err);
    process.exit(1);
  }
};

if (process.env.NODE_ENV !== "test") start();

export default server;
