# Arena Stream — Godot Foundation Status

## Current state

Branch: `godot-foundation`

The Godot client is now a testable gameplay foundation, but it is still not the final visual build and it is not network-authoritative yet.

### Implemented

- Dedicated 4v4 arena with exactly 8 fighters.
- Team assignment: 4 + 4.
- Gender assignment: exactly 2 female + 2 male per team.
- Belt-style X/Y depth movement and Y-based draw order.
- Dodge movement and depth clamping.
- Group camera based on living fighters, with real frame delta.
- 15-minute match clock exposed by `get_match_time_remaining()`.
- Temporary original fantasy-city courtyard presentation.
- Temporary distinct fighter silhouettes and weapon silhouettes.
- Sword / spear / bow data with 5 / 4 / 2 hit thresholds.
- Melee Area2D hitboxes and bow projectile hit detection.
- Friendly-fire protection.
- Knockback and hit flash foundation.
- Weapon pickup spawning: 2 swords + 2 spears + 4 bows per team.
- Kill tracking foundation.
- Starting lives: 2.
- First death: 3-second respawn.
- After both starting lives: 180-second elimination, then Final Life.
- Final Life: one hit defeats the fighter regardless of weapon threshold.
- Final-Life death: 300-second elimination timer.
- GitHub Actions Godot 4.5.1 validation workflow.
- Headless smoke test covering player count, team/gender composition, weapon thresholds, friendly-fire rules, pickup count and life timing.

### Deliberately not production-complete yet

- Authoritative multiplayer / Colyseus.
- Input replication and reconciliation.
- Proper attack frame data driven by animations.
- AnimationPlayer / AnimationTree fighter animation library.
- Final original character art.
- Final environment art, lighting, shadows, particles and audio.
- Falcon anti-camping system.
- Audience events and voting.
- Spectator HUD / OBS browser overlay.
- Round promotion logic.
- Final match-end flow.
- Real network soak test with 8 clients.

### Validation rule

Do not merge into `main` until the Godot CI smoke test and headless boot pass. The local environment used for development does not contain a Godot executable, so CI is the runtime gate for this branch.

## Repository research policy

The implementation is not locked to one upstream repository.

For each subsystem, repositories and official documentation are evaluated independently for:
1. Godot-version compatibility.
2. License compatibility.
3. Code quality and maintainability.
4. Dependency weight.
5. Multiplayer compatibility.
6. Performance.
7. Whether the subsystem can be removed cleanly later.

Current references include Quiver Beat'em Up for structural beat'em-up architecture, GDQuest's Godot 4 hitbox/hurtbox demo for combat separation, and Colyseus Native SDK for the planned Godot networking layer. These are references/components, not permission to copy third-party assets blindly.

Golden Axed remains a feel/reference target only. Arena Stream will use original or explicitly licensed characters, environments, effects, audio and names.

## Merge rule

No merge to `main` until:
- CI passes.
- The local 4v4 combat loop is playable.
- The networking boundary is defined.
- No known script/parser/runtime blocker remains.
