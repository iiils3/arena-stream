# Arena Stream — Godot Foundation

This folder is the new client foundation for Arena Stream.

## Direction

- Godot 4 client.
- 4v4 / 8 seats.
- Belt-style 2.5D movement.
- Server-authoritative multiplayer.
- Quiver Beat'em Up remains the primary structural reference.
- Arena Stream owns the rules, networking adapter, camera policy and presentation.

## Important

This foundation intentionally does not copy third-party character art or audio.

The final presentation layer will use original/licensed assets. The visual target is a detailed fantasy city/castle with layered foreground/background, readable silhouettes, lighting, shadows and cinematic camera motion.

## Build order

1. Import/adapt the Quiver beat'em-up foundation.
2. Replace its demo stage with ArenaStreamArena.
3. Add 8 player slots and 4v4 team assignment.
4. Add belt movement/depth sorting.
5. Add the group camera.
6. Add Arena weapons/combat rules.
7. Add Colyseus transport.
8. Add lives/respawns/pickups.
9. Add audience/stream systems after the vertical slice passes.

The old Phaser client is not the visual foundation anymore.
