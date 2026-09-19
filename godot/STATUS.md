# Arena Stream — Godot Foundation Status

## Current state

Branch: `godot-foundation`

The Godot client has moved from documentation-only scaffolding into a first local playable vertical-slice foundation.

### Implemented in this pass
- Dedicated 4v4 arena scene with 8 spawned fighters.
- Team/gender assignment: 2 female + 2 male per team.
- Belt-style X/Y depth movement with depth-based draw order.
- Dodge movement and edge/depth clamping.
- Group camera is now wired to the live player list and ignores defeated players.
- Original temporary fantasy-city courtyard presentation with layered skyline, fortress, banners, torches and combat square.
- Distinct temporary fighter silhouettes with team/gender readability.
- Sword/spear/bow weapon silhouettes.
- Attack state timing and one-resolution-per-attack protection.
- Team-safe damage checks.
- Weapon-specific hit thresholds remain sourced from `weapon_data.gd`.
- Knockback and hit flash foundation.
- Player defeat signal and kill tracking foundation.
- Dedicated player scene with CharacterBody2D + collision + hurtbox.

### Important limitation

This is still **not the final art quality** and **not the networked game**.

The temporary fighter/environment drawing exists only to make the gameplay loop testable before the real art direction/assets arrive. It must be replaced/refined after the user's reference images are supplied.

### Not completed yet
- Real animation library / AnimationTree adaptation.
- Proper Area2D hitbox/projectile implementation for production combat.
- Pickup/weapon spawning.
- Full lives + 3-minute / 5-minute elimination flow.
- Falcon anti-camping system.
- Audience events and voting.
- Spectator HUD / OBS browser overlay.
- Colyseus authoritative networking.
- Godot runtime verification on an actual Godot 4 environment.
- Final original characters, environment art, VFX and audio.

## Upstream decision

Quiver Beat'em Up remains the primary structural reference because it already provides beat'em-up architecture, configurable attacks, animation/state systems, stage blocking and layered environments. Its source is MIT; bundled assets have a separate license that must be checked before shipping any asset.

Golden Axed is a **feel/reference target only**: 2.5D fantasy beat'em-up presentation, staging, depth, combat readability and cinematic framing. Arena Stream does not copy its characters, names, proprietary assets, code or extracted game data.

## Merge rule

Do not merge this branch into `main` until a Godot 4 runtime check passes and the first 4v4 local combat loop is playable.
