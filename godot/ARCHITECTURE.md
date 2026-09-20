# Arena Stream — Godot Architecture

## Scene ownership

ArenaStream
- ArenaController
- Players
- Pickups
- CameraRig
- WorldLayers
- CombatFX
- HUD

## Runtime authority

The Godot client never decides authoritative damage, kills, lives, pickups or vote results.

Client:
- captures input
- predicts/local-presents movement where appropriate
- renders remote state
- plays animation/VFX/audio
- owns camera presentation

Server:
- validates input
- simulates authoritative state
- validates attacks and hit results
- owns damage/kills/lives/respawns
- owns weapon possession and pickups
- owns match timer/events
- owns promotion rules

## Belt movement

World coordinates use X for stage progression and Y for depth lane. Z is reserved for presentation/animation.

Depth is clamped to the playable belt. Render ordering is derived from Y, not network arrival order.

## Camera

Camera target is the centroid of living players. Zoom is derived from the bounding box of living players with minimum/maximum limits and smooth interpolation. Dead/respawning players do not keep camera weight.

## Networking boundary

The networking adapter must expose intent/state messages without coupling gameplay code to one transport.

Target transport: Colyseus Native SDK for Godot.

## Asset rule

No third-party asset is production-safe until its license is explicitly checked and recorded.
