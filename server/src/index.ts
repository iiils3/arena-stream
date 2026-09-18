import express from "express";
import { createServer } from "node:http";
import { Server } from "colyseus";

const app = express();
const httpServer = createServer(app);
const port = Number(process.env.PORT ?? 2567);
const gameServer = new Server({ server: httpServer });

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "arena-stream-server", mode: "local", playersPerMatch: 10 });
});

// Networking rooms are intentionally the next layer: first lock the local gameplay loop,
// then expose authoritative state through Colyseus.
void gameServer;

httpServer.listen(port, () => {
  console.log(`Arena server listening on http://localhost:${port}`);
});
