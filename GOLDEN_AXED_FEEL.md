# Arena Stream — Golden-Axed Feel Specification

This document defines the *feel* we are targeting, not a visual or asset copy.

## Reference characteristics

Golden Axed: A Cancelled Prototype is documented as a side-view fantasy beat'em-up with direct control, scrolling, 2.5D presentation and co-op/multiplayer characteristics. It was a vertical-slice/proof-of-concept rather than a full finished game. citeturn1search0turn1search14

Arena Stream should borrow the useful design language:
- grounded fantasy scale
- readable belt-scroll movement
- characters rendered with convincing depth against layered environments
- camera that frames the combat space rather than behaving like a fixed platformer camera
- attacks with commitment, anticipation and impact
- enemies/players that occupy lanes in depth
- strong hit feedback
- cinematic transitions around combat

We must NOT copy Golden Axe characters, animations, environments, names, UI, audio or other protected creative assets.

## Movement model

The Arena plane is a 2.5D belt:
- X = forward/back along the stage.
- Y = depth lane.
- Z/screen height is presentation/animation, not a free 3D traversal axis.
- Movement uses acceleration and deceleration rather than instant velocity.
- Direction changes have a short turn/stop response.
- Depth movement is constrained to the walkable combat lanes.
- Characters sort by depth so the nearer character visually covers the farther one.
- Crossing another fighter's lane should feel natural rather than like two sprites sliding through independent 2D coordinates.

Recommended starting tuning:
- walk speed: 190–240 px/s equivalent
- acceleration: 900–1200
- deceleration: 1100–1500
- depth speed: 150–210
- attack movement lock: 0.10–0.35 s depending on attack
- dodge/jump movement must preserve lane readability

These are starting values, not final balance.

## Combat feel

Arena Stream is not a button-spam simulator.

Every attack has:
1. anticipation
2. active hit window
3. recovery
4. hit reaction
5. optional knockback
6. camera/audio/VFX feedback

Use:
- input buffering
- attack priority
- hit-stop
- screen shake
- damage flash
- directional knockback
- readable attack arcs/projectiles
- hurtbox/hitbox separation

A useful reference here is Deathblood Lazer, whose public Godot 4.6 prototype explicitly implements a 3-hit light combo, heavy attacks, dodge with invulnerability frames, jump arcs, hit-stop, screen shake and damage flash. Its source is MIT, but its art/audio/character designs are separately reserved, so Arena Stream should use its architecture/ideas only. citeturn0search1turn0search3

## Attack language

We need more than one generic "attack" button.

Target controls:
- Light attack
- Heavy attack
- Dodge / evasive move
- Jump
- Weapon action
- Special/context action later

For melee weapons:
- Sword = fastest general melee, short reach.
- Spear = longer reach, narrower lane tolerance.
- Bow = ranged, lower close-range control.

The old prototype's hit-count rules remain the Arena Stream balance layer:
- sword: 5
- spear: 4
- bow: 2

Those numbers are server-side combat rules, not animation counts.

## Camera

The camera is one of the most important systems.

It must:
- follow the combat group, not one player
- keep all living players inside a preferred framing zone where possible
- zoom out when the group spreads
- zoom in when the group compresses
- avoid excessive zoom oscillation
- have minimum and maximum zoom
- respect arena boundaries
- smoothly pan instead of snapping
- provide short impact shake without destroying readability
- temporarily bias toward a major event only when useful

Use a "combat centroid" based on living players, but weight:
- players near the action slightly higher
- off-screen/far players higher when the group splits
- event locations during Heart/Bounty moments
- dead/respawning players at zero camera weight

Phantom Camera is a strong module candidate because its Godot 4 implementation supports smooth following, damping, group framing, zoom and multiple-node tracking. citeturn0search0

## Arena composition

The first playable map should look like a believable fantasy location, not a flat rectangle.

Layer it into:
1. distant skyline / towers
2. mid-background buildings
3. playable street/courtyard
4. foreground walls, pillars, banners, torches
5. combat characters
6. foreground occluders used sparingly

Depth should communicate location:
- distant objects move less during camera pan
- foreground elements move more
- characters cast/receive readable shadows
- lighting direction stays consistent

## Intro sequence

Before combat:
1. Wide view of ancient city/castle.
2. Camera slowly approaches the arena.
3. A gate or central landmark establishes scale.
4. Four Team A and four Team B characters enter/assemble.
5. Weapons are presented/collected.
6. Camera settles into combat framing.
7. Match timer starts.

The intro should be skippable after the first play or in competitive/test mode.

## Character presentation

Eight simultaneous fighters must remain visually distinguishable.

Each fighter needs:
- unique silhouette
- gender presentation
- team identity
- weapon readability
- name tag
- life indicator
- hit reaction
- death/respawn state

Do not make the characters eight recolors of one mesh.

A practical MVP:
- 4 base body archetypes
- 2 female + 2 male per team
- swap armor, hair, silhouette, weapon stance and palette
- later upgrade each into a fully unique hero

## Four-vs-four readability

The biggest danger with eight fighters is visual chaos.

Rules:
- team color is visible but never replaces natural materials
- local player gets a subtle outline
- target gets a short attack/lock-on cue
- hit reactions use animation/VFX rather than giant permanent circles
- nameplates disappear or shrink at long distance
- HUD handles exact stats; world view stays clean

## Multiplayer

The Godot client is presentation/input.
The authoritative server owns:
- movement validation
- combat
- damage
- kills
- lives
- respawns
- pickups
- event state
- vote results
- round promotion

Never trust a client for:
- "I hit this player"
- "I killed this player"
- "I captured Heart"
- "I have this weapon"
- "I deserve a kill"

## Repository strategy

### Primary base
Quiver Beat'em Up Template:
- Godot 4
- character/enemy architecture
- configurable attacks
- AnimationPlayer/AnimationTree
- state machines
- foreground/background environment
- level blocking
- debugging tools
- MIT source license
- separate asset license file

It is the best current candidate for the structural base, but we must audit every imported asset license before redistribution. citeturn0search0

### Combat reference
Fury Fist:
- Godot 4.6
- pseudo-3D/lane movement
- 4-player scuffle
- 2v2 team battle
- grapples/throws
- hit flash
- screen shake
- health/life UI
- bilingual UI

Its code is MIT. It is useful because it is already close to our lane-based combat problem, although its network model is not our target. citeturn0search7

### Golden-Axe-style combat reference
Deathblood Lazer:
- Godot 4.6
- belt-scroll combat
- combo attacks
- dodge/i-frames
- jump arc
- hit-stop
- screen shake
- damage flash

Use source patterns, not creative assets. citeturn0search1

### Not a base
Mask-Off:
- interesting 4-player Godot beat'em-up
- useful only for additional design ideas
- no need to add another base unless a specific system is clearly better

## Vertical slice acceptance test

The first Godot build is successful only if all of this is true:

- 8 players can enter.
- 4v4 teams are deterministic.
- 2 female + 2 male per team.
- Players move naturally in X/Y belt lanes.
- Near/far depth reads correctly.
- Characters do not look like geometric placeholders.
- Camera frames the group.
- Camera smoothly zooms as the group spreads.
- Sword, spear and bow are visually distinct.
- Melee hit timing is readable.
- Bow projectiles are readable.
- Hit-stop exists.
- Screen shake exists but is subtle.
- Knockback/reaction exists.
- Death and respawn work.
- 2 lives work.
- Final Life works.
- Pickup weapons work.
- No friendly fire.
- Server owns damage/kills.
- A short test match can finish without desync.

Only after this passes do we add:
- Heart
- Bounty
- audience voting
- YouTube chat
- OBS automation
- promotion rounds
- production art

## Quality bar

If the result still looks like:
- circles
- polygons
- stick figures
- flat colored rectangles
- floating weapons
- generic procedural city

then it is not ready.

We stop and improve the presentation layer before adding more gameplay systems.
