# Arena Stream — Godot Foundation Status

## Current state

Branch: `godot-foundation`

The repository now has a dedicated Godot client foundation alongside the old Phaser prototype.

Added:
- Godot 4 project configuration.
- Arena scene shell.
- 4v4 / 8-slot team-state controller.
- Belt-style player movement controller.
- Living-player group camera foundation.
- Godot architecture contract and build order.

## Upstream decision

Quiver Beat'em Up remains the primary structural base because it already provides beat'em-up architecture, configurable attacks, animation/state systems, stage blocking and layered environments. Its source is MIT; its bundled assets have a separate license file that must be checked before shipping any asset. See: https://github.com/quiver-dev/template-beat-em-up

## Not claimed yet

This branch has not been declared a finished playable vertical slice. Godot runtime testing, Quiver import/adaptation, real character assets, hitbox/hurtbox combat, Colyseus networking and full camera integration still need to be completed.

We do not merge the foundation into `main` until it survives a Godot runtime check.
