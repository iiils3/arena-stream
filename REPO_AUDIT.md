# Arena Stream — Repository Audit v0.2

## Search result

A fresh GitHub search found several relevant Godot beat'em-up projects.

### 1. Quiver Beat'em Up
https://github.com/quiver-dev/template-beat-em-up

Use as the primary structural candidate. It already contains the core architecture of a Godot beat'em-up and is explicitly designed for Streets-of-Rage-style games. It has detailed foreground/background environments, level blocking, configurable attacks, animation systems and state machines. Source is MIT; assets have a separate license file. citeturn0search0

### 2. Fury Fist
https://github.com/KFCheems/Fury-Fist

This is unusually relevant to Arena Stream because it is Godot 4.6, uses pseudo-3D/lane movement, and already supports 4-player scuffle plus 2v2 team battle. It also has hit flash, screen shake, health bars and combat presentation. Source is MIT. citeturn0search7

Decision: study this before implementing our movement/combat layer. Do not blindly merge it with Quiver.

### 3. Deathblood Lazer
https://github.com/ironmoose/deathblood-lazer

Strong reference for the desired Golden-Axe-like combat feel: belt-scroll, combo attacks, heavy attacks, dodge/i-frames, jump arc, hit-stop, screen shake and damage flash. Source is MIT, but art/audio/character designs are reserved. citeturn0search1turn0search3

Decision: use for combat feel and code-pattern research, not assets.

### 4. Mask-Off
https://github.com/W00jo/mask-off

A Godot 4.6 local 4-player beat'em-up. It is useful as a secondary reference for multi-character brawler structure, but it is not more relevant than Quiver/Fury Fist for the current target.

### 5. Iron Axe: Legacy
https://github.com/Kayforkind/iron-axe-legacy

Its description explicitly targets an original Golden-Axe-style side-scrolling beat'em-up in Godot 4. The repository is extremely small, so it is better treated as a reference/experiment than as a production base.

## Final architecture decision

Do NOT assemble five complete games.

Use:

Quiver
  + selected Fury Fist movement/combat patterns
  + selected Deathblood combat-feel patterns
  + Phantom Camera
  + Colyseus Native SDK
  + Arena Stream's own rules

Everything else stays optional.

## Why

Every additional full game base creates:
- duplicate scene trees
- conflicting input systems
- duplicate state machines
- incompatible animation conventions
- duplicated UI
- harder multiplayer authority
- license ambiguity

The target is a coherent game, not a museum of GitHub repositories.

## Golden-Axed feel decomposition

The reference game is a side-view fantasy beat'em-up / 2.5D scrolling action game. Sources also document direct character control and a short proof-of-concept/vertical-slice nature. citeturn1search0turn1search14

For Arena Stream, decompose that feeling into independent systems:

A. Belt movement
B. Depth sorting
C. Group camera
D. Character animation
E. Attack anticipation
F. Active hit window
G. Recovery
H. Hit-stop
I. Knockback
J. Screen shake
K. Layered environment
L. Lighting/shadow
M. Weapon readability
N. Character silhouettes
O. Crowd readability

This is the checklist the implementation must satisfy.

## Current blocker

The current Arena Stream repository is still a TypeScript/Phaser prototype.

We should NOT pretend that editing the old Phaser client can produce the requested visual quality. The correct next engineering action is to establish a Godot 4 client base and migrate the server/rules concept around it.

## Additional research pass — 2026-09-19

A broader search was run before extending the foundation. Several low-star/small repositories were useful even when they were not suitable as bases:

- GDQuest Godot 4 hitbox/hurtbox demo: useful confirmation of the Area2D separation between hitboxes and hurtboxes. We keep our own implementation so the multiplayer authority boundary stays under Arena Stream's control.
- LazerCube Godot multiplayer demo: useful prediction/interpolation/reconciliation ideas, but it targets an older Godot beta/.NET stack and is not suitable as a direct dependency.
- nullnxte server-authoritative networking demo: useful prediction/reconciliation architecture reference, but it is 3D and not a fit for direct reuse.
- Fury Fist remains especially relevant because it combines pseudo-3D/lane combat with 2v2 team battle and presentation feedback.
- Colyseus Native SDK remains the preferred networking integration because its current Godot extension targets Godot 4.x and is released separately; its current documentation explicitly describes the Godot extension as beta, so integration must be isolated behind an adapter and tested before gameplay is coupled to it.

The rule is therefore: search broadly, steal ideas—not licenses, assets, or incompatible foundations. A repository with zero stars can still provide a useful algorithm; a popular repository can still be rejected if its architecture or license does not fit.
