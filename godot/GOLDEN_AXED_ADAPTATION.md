# Arena Stream — Golden Axed Adaptation

Golden Axed: A Cancelled Prototype is a reference for the *feel and presentation language* of Arena Stream, not an asset or code source.

## What we intentionally carry over

- 2.5D fantasy beat'em-up presentation.
- Side-facing combat readability with meaningful depth movement.
- Strong character silhouettes and readable weapons.
- Layered environments: distant architecture, playable ground, foreground occluders.
- Cinematic staging before combat.
- Fast direct melee feedback: anticipation -> active hit -> reaction -> recovery.
- Impact feedback: hit-stop, directional knockback, camera shake, animation/VFX/audio emphasis.
- Camera that presents the fight as a composed scene instead of a fixed debug camera.
- Dark fantasy / ancient-world atmosphere with strong landmarks.

Golden Axed was a one-level proof-of-concept / vertical slice and is documented as a 2.5D beat'em-up/hack-and-slash prototype. We use those design lessons as reference only.

## What changes for Arena Stream

- 8 players total: 4v4.
- Each team: 2 female + 2 male fighters.
- Original characters, original names, original world and original assets.
- Sword, spear and bow.
- Player-vs-player combat instead of a single-player enemy-horde loop.
- Audience events and live-stream spectator presentation.
- Server-authoritative combat/lives/kills.
- 15-minute competitive rounds.
- Individual kill ranking and promotion logic.
- Non-lethal anti-camping falcon.

## Visual target

Do not fall back to circles, stick figures, flat polygons or a generic procedural city as the final presentation.

Temporary primitives are allowed only for engineering tests. The production direction is layered 2.5D fantasy art with:

1. readable fighter silhouettes;
2. believable weapon proportions;
3. animated attack/reaction poses;
4. environmental depth;
5. lighting and shadow separation;
6. foreground framing;
7. cinematic camera composition;
8. readable team differentiation.

## Implementation rule

When a system can be implemented in more than one way, prefer the solution that improves:

1. combat readability;
2. responsiveness;
3. spectator readability;
4. performance for eight simultaneous players;
5. maintainability in Godot 4.

Never import SEGA/Golden Axe assets, characters, names, proprietary code or extracted game data as Arena Stream content.
