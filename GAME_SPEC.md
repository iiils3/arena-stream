# Arena Stream — Game Specification v1.0

> **Current direction — authoritative design document**
>
> This document replaces the previous 4v4 team-vs-team concept for the new game direction.
> The old 4v4 prototype remains preserved as historical/reference work and must not drive new gameplay implementation.

---

## 1. Game Identity

**Arena Stream** is an original medieval/fantasy action game built specifically for live streaming.

The core experience is:

- **4 real players** enter together.
- They fight an **AI-controlled medieval/fantasy army**.
- The audience is an active third force that can trigger controlled events against the players.
- The players advance through a sequence of increasingly dangerous locations.
- Each successful stage moves the surviving players closer to the **Prince's Throne**.
- There is no conventional "winner" after every stage.
- A stage is either **cleared** and the survivors advance, or **failed** and the whole current team is replaced by a new team.
- The ultimate objective is to **reach the throne**.

The game should deliver the cinematic, physical, readable medieval melee feeling of **Chivalry 2** as a design/experience reference, while remaining an original game with original characters, environments, names, assets, animation, audio, UI and code.

**Important:** Chivalry 2 is a reference for combat feel, camera language, medieval presentation, animation timing, weapon readability, battlefield spectacle and stage progression. Arena Stream must not copy its copyrighted characters, factions, maps, assets, audio, animations, branding or code.

---

# 2. Core Game Loop

1. Players register with a username/display name.
2. Players enter a first-come-first-served queue.
3. Every available group is assembled from the first four eligible players in the queue.
4. A one-minute preparation interval occurs before a new round.
5. The four players enter the current stage.
6. They fight AI enemies.
7. The audience may intervene at scheduled voting windows.
8. The team must reach the required kill/progression value before the 10-minute limit.
9. If the requirement is reached:
   - surviving players advance;
   - empty seats are filled from the queue;
   - the next stage/location begins after exactly one minute of preparation.
10. If the requirement is NOT reached:
   - the entire current team leaves the run;
   - no surviving player advances;
   - the next team from the queue starts the same stage again after the one-minute interval.
11. The process continues stage by stage until the surviving team reaches the throne.
12. Reaching the throne is the ultimate completion of the run.

A player does not need to stay with the original four players for the entire journey. The advancing team can change as players die.

---

# 3. Player Count

## Active combat team

Exactly **4 player slots** are available in a stage.

All four are real human players.

There are no human enemy teams in the current design.

## AI opposition

All enemies are controlled by the game server/AI system.

The number and type of enemies increase as the team progresses.

---

# 4. Player Queue

The queue is **first-come-first-served**.

## Registration

A player registers:

- username/account
- display name shown in-game
- required account/profile data
- queue timestamp/position

The queue displays useful information such as:

- current position
- number of players ahead
- estimated next group
- readiness status

## Group creation

The first four eligible players form the next team.

Example:

- Player 1
- Player 2
- Player 3
- Player 4

become Team/Run A.

Players 5–8 form the following available group, subject to players being consumed by ongoing stage replacement.

## No-show replacement

If a registered player does not appear when their group is being prepared:

- a short readiness window is allowed;
- the missing seat is immediately replaced by an eligible player from the queue;
- the game does not wait indefinitely for absent players.

The objective is to keep the live broadcast moving.

## Returning survivors

A player who successfully clears a stage remains eligible to continue into the next stage.

Their previous team does not have to remain intact.

If a stage is cleared with:

- 4 survivors → 4 continue;
- 3 survivors → 3 continue + 1 new queued player;
- 2 survivors → 2 continue + 2 new queued players;
- 1 survivor → 1 continue + 3 new queued players.

The incoming players occupy the empty seats.

This creates a persistent evolving team during a successful run.

## Failed stage

If the required stage objective is not completed before the 10-minute limit:

- all four current players are removed from that run;
- no one advances;
- the next four eligible queued players become the new team;
- the same stage/location is replayed.

The world does not progress until a team successfully clears the stage.

---

# 5. Stage Timer

Each stage has a maximum duration of:

**10 minutes.**

The timer starts when the combat stage begins.

The one-minute preparation interval between stages is NOT part of the 10-minute combat timer.

A stage may finish earlier if its progression requirement is completed.

---

# 6. Lives

Every player starts a stage/run with:

**2 lives.**

There is **no normal respawn**.

### First death

- Player loses one life.
- Player returns to the current stage only if the design later explicitly enables a temporary revive mechanic; the default rule is that a death removes the player from active combat.

### Second death

- Player is permanently removed from the current run.
- Their seat becomes eligible for replacement at the next stage.

The core new design intentionally gives deaths meaningful consequences and avoids endless respawning.

**Implementation note:** The exact presentation of the first death must remain consistent with the final combat vertical slice. The authoritative rule is that each player has a maximum of two deaths/lives for the run and cannot repeatedly respawn.

---

# 7. Stage Progression / Kill Requirement

Each stage has a required progression value.

The default progression starts at:

| Stage | Required normal-enemy value |
|---|---:|
| 1 | 8 |
| 2 | 10 |
| 3 | 12 |
| 4 | 14 |
| 5 | 16 |
| 6 | 18 |
| 7 | 20 |
| ... | +2 per stage |

The progression value is not necessarily a literal count of enemies spawned.

It is a **progress score**.

## Normal enemy

One qualifying normal enemy kill:

**+1 progression**

## Monster

A qualifying monster kill:

**+2 progression**

Example:

Stage requirement = 8.

The team kills:

- 6 normal enemies = 6
- 1 monster = 2

Total:

**8 / 8**

The stage is cleared.

This allows the audience's monster event to be dangerous while also giving the team a possible shortcut.

---

# 8. Enemy Waves

The game is not restricted to spawning exactly the required number of enemies.

The AI director controls:

- spawn timing
- enemy type
- wave composition
- difficulty
- spacing
- elite encounters
- monsters
- boss encounters
- environmental pressure

The objective value is separate from the number of enemies physically spawned.

This allows a stage to feel like a real battle instead of a counter with enemies attached.

---

# 9. Enemy Archetypes

The initial AI roster should support different combat roles.

Examples:

### Basic Soldier
- Slash
- Block
- simple positioning

### Spearman
- long-range stab
- spacing
- anti-rush behavior

### Heavy
- slow movement
- heavy overhead attacks
- high stagger resistance

### Archer
- ranged attacks
- weak close combat
- repositioning

### Assassin
- fast movement
- dodge
- flank behavior

### Elite
- advanced block
- feints
- counters
- better positioning

### Monster
- large body
- large attack arcs
- area attacks
- strong stagger/knockback
- unique combat behavior

Enemy AI must eventually use the same combat rules that players use wherever practical.

---

# 10. Stage / World Progression

Every successful stage changes the physical location, environment, lighting and threat level.

The world should communicate progression visually so the audience immediately understands that the team is getting closer to the throne.

Initial example journey:

### Stage 1 — Distant Battlefield
- remote open arena
- night
- early enemy types
- requirement: 8

### Stage 2 — Valley
- morning
- valley terrain
- requirement: 10

### Stage 3 — Dirt Road
- afternoon
- medieval road
- requirement: 12

### Stage 4 — Castle Gate
- major fortress gate
- stronger defenders
- requirement: 14

### Stage 5 — Inside the Castle
- interior fortress environment
- corridors/courtyards
- requirement: 16

### Stage 6 — Prince's Gate
- major defensive area
- large monster
- two guards / elite defenders
- requirement: 18

### Later stages
- castle corridors
- courtyards
- throne approaches
- ceremonial halls
- inner palace
- throne room

The exact final number of stages is not fixed.

The system must allow stages to be added without rewriting the game core.

---

# 11. Throne / Final Objective

The run continues until the players reach the throne.

The throne is not simply a menu screen.

The final sequence should feel like a culmination of the entire journey.

The final area can contain:

- Prince
- elite guards
- final monster/boss
- cinematic entrance
- unique environment
- special audience interaction
- final combat
- completion sequence

The exact final boss rules are to be designed after the core combat system is proven.

---

# 12. One-Minute Transition

There is always a **one-minute preparation period between combat stages**.

During this minute:

- surviving players are identified;
- dead/removed players are replaced from the queue;
- the next location loads;
- AI wave data is prepared;
- the next stage objective is shown;
- the audience sees the upcoming threat;
- the live HUD shows the transition.

## Monster throne presentation

During the transition, the major monster for the upcoming stage can be shown **sitting on its throne** or in a prepared cinematic pose.

The monster is not fighting during this transition.

This gives the audience a visual preview of the danger ahead.

The transition is deliberately fixed at one minute so the live show has a predictable rhythm.

---

# 13. Audience Control

The audience is a controlled gameplay force.

The audience does NOT directly control the players.

The audience votes for a gameplay event.

## Scheduled voting windows

There are two possible voting windows during a stage:

### Minute 5
If the stage is still active:

**Audience Vote #1**

### Minute 9
If the stage is still active:

**Audience Vote #2**

If the stage has already been cleared, no vote is started.

Each voting window produces **one selected event**.

The game must never allow unlimited audience event spam.

---

# 14. Audience Event Pool

Initial event pool:

1. Darkness
2. Rain
3. Falcon
4. Meteor
5. Monster
6. Weapon Swap

Additional events can be added later only after the base system is stable.

---

# 15. Darkness Event

Duration:

**1 minute**

The game becomes heavily darkened.

The player must still be able to understand enough of the battlefield to play.

Do not make the screen completely unreadable.

Required readability:

- player silhouettes
- attack flashes
- important hit effects
- limited HUD
- audio cues
- danger indicators where necessary

The goal is pressure, not an impossible state.

---

# 16. Rain Event

Duration:

**2 minutes**

Rain changes the atmosphere and may affect gameplay/presentation.

Possible effects to be tuned:

- wet environment
- reduced visual clarity
- reflections
- soundscape
- movement/friction modifiers if technically justified

Rain must never make the game feel uncontrollable.

---

# 17. Falcon Event

The falcon makes a fast attack and immediately leaves.

The falcon:

- selects a valid living player;
- dives in;
- causes damage;
- exits immediately;
- never kills a player.

The final damage calculation must always clamp the player to a survivable state.

The falcon is a pressure mechanic, not an execution mechanic.

---

# 18. Meteor Event

A meteor impacts **beside** the players rather than directly targeting them for guaranteed death.

The event should show:

1. warning/impact indicator;
2. short anticipation;
3. impact;
4. damage;
5. knockback/stagger;
6. environmental effect.

The meteor must be dangerous but readable.

The audience should feel that they caused chaos without receiving a direct "kill button".

---

# 19. Monster Event

The audience may vote to summon a monster during an active stage.

The monster:

- joins the battle;
- attacks the players;
- follows its own AI;
- can be killed;
- is worth **+2 progression** when killed.

Example:

Requirement = 8.

Team achieves:

6 normal kills + monster kill (2) = 8.

The stage clears.

## Monster leaderboard kill

A monster kill is recorded for the player who contributed the highest qualifying damage to that monster.

Example:

- Player A: 45% damage
- Player B: 35%
- Player C: 20%

Player A receives the monster kill credit.

If contribution is tied, use a deterministic secondary rule such as the final qualifying damaging contribution.

---

# 20. Weapon Swap Event

Duration:

**2 minutes**

The audience event temporarily changes the available weapon setup.

The exact weapon pool and forced/optional behavior must be data-driven.

The event must not permanently destroy a player's progression or make the game unwinnable.

---

# 21. Combat Philosophy — Chivalry 2 Inspired

The most important visual/gameplay target is the **feel of a cinematic medieval melee game**.

The reference target includes:

- weighty weapons
- readable windups
- real attack arcs
- directional attacks
- blocking
- parrying
- countering
- feints
- kicks
- dodges
- stamina
- hit reactions
- knockback
- stagger
- impact effects
- physical-looking animation
- cinematic camera
- environmental scale
- battlefield spectacle

Arena Stream must translate these principles to a **horizontal mobile-friendly 2.5D presentation**.

---

# 22. Core Attacks

Initial attack vocabulary:

### Slash
Horizontal swing.

Use:
- multiple enemies
- open spaces
- crowd control

### Overhead
Vertical downward attack.

Use:
- heavy damage
- single-target pressure
- breaking through certain defensive situations

### Stab
Direct thrust.

Use:
- narrow spaces
- single target
- reach advantage

The player should be able to select the attack direction without filling the screen with oversized buttons.

---

# 23. Mobile Control Model

The game runs in:

**Landscape orientation only.**

## Left side

A transparent circular movement joystick.

It provides analog directional movement rather than four separate movement buttons.

## Right side

Medium-sized transparent action buttons:

- Attack
- Jump
- Pick Up / Interact
- Block / Parry
- Dodge

The final layout must remain readable and comfortable.

Buttons must be:

- transparent enough not to cover the action;
- large enough for reliable touch input;
- not oversized;
- separated to avoid accidental presses;
- visually consistent;
- responsive.

Attack direction can be combined with movement/aim input rather than requiring three huge attack buttons.

---

# 24. Combat State Machine

Every attack follows explicit timing.

### Windup
- weapon preparation;
- attack is readable;
- feint/cancel opportunities;
- movement may be restricted.

### Release / Active
- weapon becomes dangerous;
- real weapon trace is active;
- hit detection is authoritative.

### Recovery
- attack completes;
- movement/attack options are temporarily restricted;
- player returns to neutral.

The exact timing is weapon-specific.

---

# 25. Weapon Trace / Hit Detection

The final combat system must not rely on a single generic circular hitbox for melee attacks.

For a melee weapon:

- define tracer points along the weapon;
- record previous-frame positions;
- record current-frame positions;
- sweep/trace between them during the active attack window;
- detect intersection with the enemy's valid hurt/physics body;
- calculate the hit on the authoritative server.

This allows:

- real blade movement;
- attacks missing because the weapon passes beside the target;
- dodging by moving away;
- directional accuracy;
- readable weapon reach.

The prototype may use simplified hitboxes temporarily, but the final combat system must move toward weapon-path tracing.

---

# 26. Accel / Drag Translation

Chivalry-style acceleration and drag principles should be adapted to the horizontal game.

### Accel
Movement/rotation toward the target during the attack can cause the weapon to reach the target earlier in its active path.

### Drag
Changing movement/attack direction to delay the weapon path can make the hit arrive later.

This must remain readable and controllable on mobile.

---

# 27. Defense

### Block
Consumes stamina over time.

### Parry
Timed defensive action that can stop an incoming attack.

### Counter
Reading the incoming attack and matching the appropriate attack direction/timing can negate the attack and create an advantage.

### Riposte
Successful defense can lead directly into a faster counterattack window.

### Kick
Breaks a defensive opponent under the appropriate conditions.

### Dodge
Short evasive movement that consumes stamina.

These mechanics should be introduced in stages during development rather than all being built simultaneously.

---

# 28. Stamina

Stamina is part of combat balance.

It should govern:

- blocking pressure
- dodge
- certain advanced actions
- potentially counter/defensive interactions

The goal is to prevent infinite blocking and repeated defensive abuse.

Stamina must be visible enough for competitive understanding without covering the screen.

---

# 29. Damage / Armor

The new combat design should not use the old prototype's fixed rule of:

- sword = 5 hits
- spear = 4 hits
- bow = 2 hits

Those rules belong to the retired prototype.

The new combat system should use:

- weapon damage;
- attack type;
- armor/defense where applicable;
- hit location where justified;
- stamina;
- stagger;
- knockback;
- enemy/player archetype.

The system must remain simple enough for mobile play.

---

# 30. Ragdoll / Impact

Target presentation includes:

- hit stop;
- directional hit reaction;
- knockback;
- stagger;
- camera shake;
- weapon impact VFX;
- blood/impact effects where appropriate;
- strong death reaction;
- ragdoll where technically useful.

Full dynamic dismemberment is **not a first milestone requirement**.

Combat feel takes priority over gore technology.

---

# 31. Camera

The camera should feel cinematic and readable.

It must:

- keep active players and important enemies visible;
- follow the combat group;
- zoom out when the combat spreads;
- zoom in when combat compresses;
- support attack impact;
- support boss/monster presentation;
- avoid excessive camera motion that harms mobile play.

The camera is horizontal/side-oriented.

The game must feel like a cinematic medieval battle viewed from a controlled side/2.5D perspective, not like a flat stick-figure fighter.

---

# 32. Visual Direction

The visual target is:

**high-quality medieval cinematic action presentation.**

Important characteristics:

- detailed medieval armor;
- readable silhouettes;
- physically convincing weapons;
- castle architecture;
- dirt roads;
- valleys;
- gates;
- banners;
- torches;
- atmospheric lighting;
- fog;
- rain;
- shadows;
- foreground/midground/background depth;
- strong attack effects;
- cinematic entrances;
- environmental storytelling.

The world should feel like a real medieval battlefield, not a generic procedural prototype.

---

# 33. Character Presentation

Characters must be visually distinguishable.

Differences can include:

- armor silhouette;
- weapon;
- body shape;
- helmet;
- colors;
- movement style;
- attack style;
- role.

Do not use generic circles, stick figures or placeholder polygons as the final visual target.

Temporary debug art is allowed only during engineering.

---

# 34. Stage Presentation

Every stage should have an establishing moment.

Example:

1. wide environment shot;
2. reveal the next location;
3. show the incoming danger;
4. show the four players;
5. show major enemy/monster;
6. combat framing;
7. stage objective;
8. timer starts.

This should create the feeling of progressing through a medieval campaign.

---

# 35. Audience / Broadcast Presentation

The live stream is part of the product.

The spectator presentation should show:

- current stage;
- location name;
- timer;
- required progress;
- current progress;
- four player names;
- player status/lives;
- kills;
- active event;
- voting countdown;
- next event;
- kill feed;
- queue/next team where appropriate.

The audience should understand the game without needing external explanation.

---

# 36. Broadcast Schedule

The game runs:

**5 hours of active gameplay per day.**

It runs:

**6 days per week.**

**Tuesday = no active gameplay.**

The live broadcast can continue outside active gameplay hours if desired.

The broadcast can show:

- dashboard;
- rankings;
- previous highlights;
- player statistics;
- queue;
- upcoming session countdown;
- the monster on its throne;
- other non-combat presentation.

---

# 37. Round Rhythm

Each combat stage:

**maximum 10 minutes**

Between stages:

**exactly 1 minute preparation**

This gives the broadcast a predictable rhythm.

The one-minute transition is used to:

- replace missing/dead players;
- load next location;
- prepare AI;
- prepare the next stage;
- show the monster/coming danger;
- show player names;
- show the stage objective.

---

# 38. The Dashboard

The game must have a dedicated web dashboard.

The dashboard is part of the product, not an optional later page.

## Main sections

### Home / Live
- current live stage;
- current four players;
- current location;
- timer;
- progress;
- current event;
- audience vote;
- next transition;
- live status.

### Leaderboards

#### Best Players
Each player record includes:

- display name;
- registered username;
- total kills;
- highest stage;
- highest progression;
- throne completions;
- monster kills;
- deaths;
- appearances;
- other useful statistics.

#### Best Teams / Runs
Because the team can change between stages, a "team" leaderboard should represent a run/group identity rather than incorrectly pretending the same four people remained together.

Possible metrics:

- highest stage reached;
- throne completions;
- total progression;
- total enemy kills;
- run duration;
- survival count.

### Stage Records
- stage number;
- location;
- required progression;
- best progression;
- best time;
- most successful runs.

### Player Profile
Every registered player can have:

- username;
- display name;
- statistics;
- highest stage;
- kills;
- deaths;
- monster kills;
- throne completions;
- history of appearances.

### How to Play
A complete explanation of:

- registration;
- queue;
- controls;
- movement;
- attack;
- defense;
- weapons;
- stamina;
- lives;
- stage progression;
- audience events;
- monsters;
- failure;
- advancement;
- throne objective.

### Rules
A dedicated page containing the complete competitive rules.

### Visual Guide
Use explanatory images/diagrams for:

- controls;
- attack directions;
- block/parry;
- dodge;
- stage progression;
- audience voting;
- lives;
- monster value;
- queue system.

### Live / Watch
A clear path to the live stream and current broadcast status.

---

# 39. Leaderboard Eligibility

Not every participant needs to appear in the public leaderboard.

The public player ranking should highlight the **top two kill performers from each completed team/run**, according to the finalized scoring rules.

For each stage/run, the system records all participants internally.

The public ranking selects the required top performers.

This keeps the leaderboard meaningful rather than filling it with every temporary participant.

---

# 40. Kill Scoring

Basic kills are tracked per player.

Monster kills are credited to the highest qualifying damage contributor.

The system must keep separate:

- normal kills;
- elite kills if introduced;
- monster kills;
- total kills;
- progression contribution.

The leaderboard can use total kills as the main visible performance metric while preserving richer statistics for future ranking.

---

# 41. Fairness Rules

Audience interaction must create pressure without making the game mathematically impossible.

Rules:

- no direct audience kill command;
- falcon cannot kill;
- meteor should not guarantee a kill;
- darkness must retain basic readability;
- events have fixed durations;
- only one event per voting window;
- event frequency is limited;
- monster is dangerous but gives +2 progression if killed;
- the server remains authoritative;
- stage requirements remain deterministic;
- queue order remains deterministic.

---

# 42. Server Authority

The server is authoritative for:

- player state;
- movement validation;
- attack state;
- weapon traces;
- hit confirmation;
- damage;
- stamina;
- deaths;
- lives;
- enemy AI;
- monster AI;
- stage progress;
- stage transition;
- queue;
- player replacement;
- audience events;
- votes;
- timers;
- leaderboards;
- run completion.

Clients are responsible for:

- input;
- local presentation;
- animation;
- camera;
- VFX;
- audio;
- UI;
- prediction/interpolation where appropriate.

The client must never be trusted to decide final damage or kills.

---

# 43. Network Architecture

The target architecture is:

**Godot client**
+
**authoritative game server**
+
**web dashboard**
+
**broadcast/spectator layer**
+
**audience voting adapter**

The networking technology is an implementation decision to be validated during the build.

The system must support at least four simultaneous players with stable real-time melee combat and must be designed so the spectator/broadcast view is deterministic and authoritative.

---

# 44. Dashboard / Game Account Model

Each player has:

- account ID;
- username;
- display name;
- queue timestamp;
- statistics;
- run history;
- leaderboard data.

The username is the stable identity.

The display name is what is shown above the character and on the broadcast UI.

Account security and abuse prevention are required before public launch.

---

# 45. Anti-Abuse / Queue Integrity

The production system should prevent:

- duplicate queue positions;
- multiple active registrations from one account;
- fake leaderboard submissions;
- client-side kill manipulation;
- vote spam;
- automated vote flooding;
- reconnect abuse;
- intentional queue blocking.

The exact authentication and anti-bot strategy is an implementation phase.

---

# 46. Development Priorities

The build must NOT start by building the dashboard, YouTube automation or all stages.

The correct order is:

## Phase 1 — Combat Vertical Slice
One player + one AI enemy.

Must prove:

- horizontal movement;
- jump;
- dodge;
- Slash;
- Overhead;
- Stab;
- Windup;
- Release;
- Recovery;
- weapon trace;
- damage;
- block;
- parry;
- stamina;
- hit reaction;
- knockback;
- death;
- camera;
- animation.

If this does not feel good, stop and fix it.

## Phase 2 — Four-player combat
- 4 connected players;
- authoritative server;
- synchronization;
- enemy AI;
- friendly team behavior;
- player replacement.

## Phase 3 — Stage system
- 10-minute timer;
- progression requirement;
- waves;
- death/removal;
- success;
- failure;
- one-minute transition;
- queue replacement.

## Phase 4 — Audience system
- voting;
- minute 5;
- minute 9;
- darkness;
- rain;
- falcon;
- meteor;
- monster;
- weapon swap.

## Phase 5 — World progression
- multiple environments;
- lighting/time of day;
- castle journey;
- monster presentations;
- throne.

## Phase 6 — Dashboard
- accounts;
- player profiles;
- leaderboards;
- live state;
- stage records;
- rules;
- visual guide.

## Phase 7 — Broadcast
- spectator camera;
- OBS;
- YouTube Live;
- audience input;
- stream overlays.

## Phase 8 — Production hardening
- reconnects;
- queue abuse;
- server recovery;
- telemetry;
- moderation;
- performance;
- mobile optimization;
- load testing.

---

# 47. Technical Quality Gate

No feature is considered finished because it merely appears on screen.

A subsystem must pass:

1. Functional test.
2. Multiplayer/authority test where applicable.
3. Failure/reconnect test where applicable.
4. Mobile input test.
5. Performance test.
6. Broadcast readability test.
7. Visual quality review.
8. Determinism/fairness review.
9. Removal/replacement test.

---

# 48. Visual Quality Gate

The game must not settle for:

- circles;
- stick figures;
- generic polygon characters;
- flat colored rectangles;
- generic procedural environments;
- weak placeholder animation;
- static attack poses.

Temporary placeholders are acceptable only while the underlying system is being proven.

The target is a **cinematic medieval melee game presentation** with strong depth, animation, lighting, impact and environment composition.

---

# 49. Mobile-First Requirement

The primary player device is mobile.

Therefore:

- landscape;
- touch controls;
- stable frame rate;
- low input latency;
- readable UI;
- no tiny buttons;
- no oversized controls;
- effects must scale;
- camera must remain readable on small screens;
- network usage must be controlled.

Desktop/spectator clients can receive a richer presentation.

---

# 50. Original IP Rule

Arena Stream may be inspired by the feel and systems of existing medieval games.

It must remain an original product.

Do not copy:

- Chivalry factions;
- characters;
- maps;
- names;
- logos;
- voice lines;
- animations;
- models;
- textures;
- audio;
- proprietary code;
- proprietary UI.

Use the reference to understand the quality bar and interaction philosophy, then create an original world.

---

# 51. Current Product Definition

The project is now officially:

> **Arena Stream — 4-player cooperative medieval melee survival/progression game with audience-controlled events, a first-come-first-served live queue, evolving teams, cinematic stage progression and a final journey to the throne.**

The primary experience target is:

> **Chivalry-style physical medieval melee combat and cinematic presentation, redesigned for horizontal mobile play and four-player cooperative AI battles.**

The audience is:

> **an active gameplay force, not a passive viewer.**

The progression is:

> **battlefield → valley → road → castle → inner castle → prince → throne.**

The competitive/public identity is:

> **players and runs are recorded permanently through the dashboard and leaderboards.**

---

# 52. Old 4v4 Prototype Status

The previous 4v4 human-vs-human design is **frozen**.

It remains in Git history/branches as:

- reference;
- reusable technical experiments;
- networking/combat prototypes;
- discarded design history.

New gameplay development must follow this v1.0 document instead.

Do not continue adding new gameplay features to the old 4v4 design unless explicitly requested.

---

# 53. Immediate Next Build Gate

Before building the complete game:

**Create a polished combat vertical slice inspired by the feel of Chivalry-style melee combat.**

Required:

- 1 player;
- 1 AI enemy;
- 1 medieval environment slice;
- 3 attack directions;
- weapon-path tracing;
- block;
- parry;
- counter;
- dodge;
- kick;
- stamina;
- hit reaction;
- knockback;
- death;
- cinematic horizontal camera;
- mobile touch controls.

Only after this passes the quality gate should the project expand to four players, the AI army, stage progression, audience events and dashboard.

---

## Design Principle

**Do not build breadth before proving combat quality.**

If the sword does not feel good in the first vertical slice, adding 20 stages and a dashboard will not save the game.

The combat, visual presentation and live-show loop are the foundation.
