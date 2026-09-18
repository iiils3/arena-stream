import express from "express";
import { createServer } from "node:http";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { Server } from "colyseus";
import { ArenaRoom } from "./ArenaRoom.js";

const app = express();
const httpServer = createServer(app);
const port = Number(process.env.PORT || 2567);

const gameServer = new Server({ server: httpServer });
gameServer.define("arena", ArenaRoom);

app.get("/health", (_req, res) =>
  res.json({ ok: true, service: "arena-stream-server", room: "arena", playersPerMatch: 10 })
);

const here = dirname(fileURLToPath(import.meta.url));
const clientDist = resolve(here, "../../client/dist");

app.use(express.static(clientDist));

app.get("/", (_req, res) => {
  res.sendFile(resolve(clientDist, "index.html"));
});

httpServer.listen(port, () => console.log(`Arena server listening on port ${port}`));
