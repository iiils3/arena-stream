import express from "express";
import { createServer } from "node:http";
import { Server } from "colyseus";
import { ArenaRoom } from "./ArenaRoom.js";
const app=express(); const httpServer=createServer(app); const port=Number(process.env.PORT||2567);
const gameServer=new Server({server:httpServer}); gameServer.define("arena",ArenaRoom);
app.get("/health",(_req,res)=>res.json({ok:true,service:"arena-stream-server",room:"arena",playersPerMatch:10}));
httpServer.listen(port,()=>console.log(`Arena server listening on http://localhost:${port}`));
