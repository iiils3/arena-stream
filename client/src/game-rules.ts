export const MATCH_DURATION_MS = 15 * 60 * 1000;
export const EVENT_INTERVAL_MS = 5 * 60 * 1000;
export const MAX_PLAYERS = 10;
export const TEAM_SIZE = 5;

export const DAMAGE_TO_KILL = {
  sword: 5,
  spear: 4,
  bow: 2,
} as const;

export type Weapon = keyof typeof DAMAGE_TO_KILL;
