import Fastify from "fastify";

const PORT = Number(process.env.PORT || 4000);

const app = Fastify({ logger: true });

app.get("/health", async (request, reply) => {
  return { status: "ok" };
});

const start = async () => {
  try {
    await app.listen({ port: PORT, host: "0.0.0.0" });
    app.log.info(`Server listening on ${PORT}`);
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
};

if (process.env.NODE_ENV !== "test") {
  start();
}

export default app;
