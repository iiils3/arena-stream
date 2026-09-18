import express from "express";
import { createServer } from "node:http";

const app = express();
const httpServer = createServer(app);
const port = Number(process.env.PORT ?? 2567);

app.get("/health", (_req, res) => {
  res.json({
    ok: true,
    service: "arena-stream-server",
    mode: "local"
  });
});

httpServer.listen(port, () => {
  console.log(`Arena server listening on http://localhost:${port}`);
});
