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
