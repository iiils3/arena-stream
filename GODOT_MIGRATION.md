# Arena Stream — Godot Migration Plan

## Decision
The old Phaser prototype is no longer the visual foundation. It remains a reference for rules and server logic only.

The new client foundation is Godot 4.

## Base candidate
Use Quiver's open-source Beat'em Up template as the initial architecture/reference because it already covers configurable characters/attacks, detailed foreground/background environments, level blocking, animation systems and state machines.

Repository:
https://github.com/quiver-dev/template-beat-em-up

It is MIT licensed, but its bundled assets have separate licensing terms. We will not assume its art can ship in Arena Stream without checking the asset license.

## Reference / modules
- Deathblood Lazer: combat feel and Godot 4.6 structure reference only. Its source is MIT, but its art/audio/character designs are not licensed for reuse.
- Phantom Camera: dynamic camera/group framing.
- Colyseus Native SDK: authoritative multiplayer client for Godot.
- State Charts: optional state-machine module if Quiver's state system is insufficient.
- Hitbox/Hurtbox: use a clean Godot implementation for combat.
- VFX library: use only compatible/licensed effects or recreate them.
- YouTube chat and OBS integrations come later.

## Architecture target

Godot client
  -> input
  -> local presentation/interpolation
  -> camera
  -> animation/VFX/audio
  -> spectator HUD

Authoritative server
  -> player input validation
  -> movement
  -> attacks/hit detection
  -> damage
  -> lives/respawns
  -> pickups
  -> events
  -> voting
  -> round progression

External stream layer
  -> YouTube Live chat
  -> audience vote adapter
  -> OBS/browser overlay

## First build order
1. Import/establish Godot beat'em-up base.
2. Strip unrelated demo/game content.
3. Create Arena scene.
4. Replace demo characters with 8 Arena character slots.
5. Implement 4v4 teams and 2F+2M composition.
6. Implement 2.5D/belt movement and depth.
7. Implement sword/spear/bow.
8. Implement hitbox/hurtbox combat.
9. Implement dynamic 8-player camera.
10. Connect Colyseus.
11. Recreate lives/respawn/final-life rules.
12. Add pickups.
13. Add falcon anti-camping.
14. Add audience events.
15. Add YouTube chat voting.
16. Add OBS/browser spectator layer.
17. Polish original art, animation, sound and VFX.

## Hard rule
Do not merge many repositories into one giant codebase.

Use one base plus small, isolated modules. Every imported module must pass:
- Godot 4 compatibility check
- license check
- dependency check
- multiplayer compatibility check
- performance check
- removal/replacement test

## Definition of done for vertical slice
A tester can open the game, enter a real 4v4 room, move through a depth-based arena, attack opponents with all 3 weapons, see hits/deaths/respawns, watch the camera frame all active players, and complete a short test round without Phaser.
