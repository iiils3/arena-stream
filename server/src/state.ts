import { MapSchema, Schema, type } from "@colyseus/schema";
export type Team = "A" | "B";
export type Weapon = "sword" | "spear" | "bow";

export class PlayerState extends Schema {
  @type("string") name = "";
  @type("string") team: Team = "A";
  @type("number") x = 0;
  @type("number") y = 0;
  @type("string") weapon: Weapon = "sword";
  @type("number") kills = 0;
  @type("number") lives = 2;
  @type("number") hp = 5;
  @type("number") maxHp = 5;
  @type("boolean") alive = true;
  @type("boolean") weakened = false;
}

export class ArenaState extends Schema {
  @type({ map: PlayerState }) players = new MapSchema<PlayerState>();
  @type("number") remainingMs = 15 * 60 * 1000;
  @type("number") eventRemainingMs = 5 * 60 * 1000;
  @type("string") phase = "waiting";
  @type("string") activeEvent = "";
  @type("number") eventIndex = 0;
  @type("string") lastEvent = "";
  @type("string") lastKill = "";
  @type("string") vote1 = "";
  @type("string") vote2 = "";
  @type("string") vote3 = "";
  @type("number") votes1 = 0;
  @type("number") votes2 = 0;
  @type("number") votes3 = 0;
  @type("boolean") darkness = false;
  @type("number") arenaScale = 1;
  @type("number") trapX = 0;
  @type("number") trapY = 0;
  @type("string") bountyId = "";
  @type("number") heartX = 0;
  @type("number") heartY = 0;
  @type("string") heartTeam = "";
}
