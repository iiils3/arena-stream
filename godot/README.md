# Arena Stream — Godot Foundation

This folder is the new client foundation for Arena Stream.

## Direction

- Godot 4 client.
- 4v4 / 8 seats.
- Exactly 2 female + 2 male fighters per team.
- Belt-style 2.5D movement.
- Server-authoritative multiplayer target.
- Quiver Beat'em Up is a structural reference, not a locked dependency.
- Arena Stream owns the rules, networking boundary, camera policy and presentation.

## Current build order

1. Keep the Godot scene bootable and CI-validated.
2. Lock the 4v4 roster, depth movement and camera.
3. Lock combat data, hitboxes, projectiles and weapon pickups.
4. Lock lives, respawn and Final Life behavior.
5. Add anti-camping / falcon rules.
6. Add animation-driven attack frame data and combat feedback.
7. Integrate the Colyseus Godot SDK behind a transport adapter.
8. Move authoritative movement/combat/lives/pickups to the server.
9. Add match timer, round-end and promotion logic.
10. Add audience events/voting.
11. Add spectator HUD and OBS/browser-source integration.
12. Replace temporary visuals with original/licensed production art, VFX and audio.

## Validation

The branch has a headless smoke test at:

`res://tests/smoke_test.gd`

It checks the parts most likely to drift during refactors:
- 8 players.
- 4 players per team.
- 2 female + 2 male per team.
- 5 / 4 / 2 weapon hit thresholds.
- friendly-fire prohibition.
- 16 weapon pickups.
- 2 starting lives.
- 3-second first respawn.
- 180-second Final Life entry delay.
- Final-Life state.

Do not merge to `main` while CI is failing or unavailable.

## Asset rule

No third-party character, environment, audio or VFX asset is production-safe until its exact license is checked and recorded.

The visual target is a detailed original fantasy city/castle with layered depth, readable silhouettes, lighting, shadows and cinematic camera motion.

Golden Axed is used only as a gameplay/feel reference. No Golden Axe/Golden Axed characters, names, proprietary assets, extracted data or proprietary code are being copied.
