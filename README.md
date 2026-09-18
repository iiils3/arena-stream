# Arena Stream

Browser-first 5v5 fantasy arena built for live spectator interaction.

## Stack
- Phaser 4 + TypeScript + Vite
- Colyseus authoritative multiplayer server
- Local-first development; Azure deployment later
- OBS + YouTube Live for broadcasting

## Game loop
10 players enter a 15-minute match. Spectators vote on world events every 5 minutes. Individual kills determine the two returning leaders for the next round.

## Development
Frontend and server are kept separate so the game can be tested locally before any cloud deployment.


## Local multiplayer

Install dependencies from the repository root:

```bash
npm install
```

Run the server in development mode (allows one local player):

```bash
ARENA_DEV=1 npm run dev:server
```

In a second terminal:

```bash
npm run dev:client
```

Open the Vite URL. Add `?name=Ali` to choose a player name.

Controls: WASD movement, Space attack, E weapon swap, 1/2/3 audience vote.

For the real match rule, remove `ARENA_DEV=1`; the room then waits for all 10 seats before starting.
