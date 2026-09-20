# Arena Stream — Godot Build Plan v1.0

## Source of truth

The previous Phaser and 4v4 human-vs-human prototype is frozen as reference material.

The authoritative documents are:

- `GAME_SPEC.md` v1.0 — product/game rules.
- `godot/STATUS.md` — current implementation status.

The production target is:

**4 human players vs AI medieval/fantasy army + audience-controlled events + first-come queue + evolving survivors + progressive medieval stages + final throne objective.**

---

## Engine Direction

Godot 4 remains the target engine.

The game must be built as a real horizontal mobile action game, not as a collection of placeholder procedural shapes.

### Chivalry-style reference

The main experience reference is Chivalry-style medieval melee for:

- combat timing;
- weapon weight;
- directional attacks;
- block/parry/counter;
- feint;
- kick;
- dodge;
- stamina;
- hit reactions;
- cinematic presentation;
- battlefield atmosphere;
- stage progression.

This is a reference for experience and system design, not permission to copy characters, maps, assets, animations, audio, branding or proprietary code.

Open-source Godot projects may be studied or selectively reused only after checking license, Godot compatibility, dependencies, multiplayer suitability, mobile performance and removability.

---

# Target Architecture

## Godot Client

Responsible for:

- touch input;
- local presentation;
- animation;
- camera;
- VFX;
- audio;
- HUD;
- spectator presentation;
- interpolation/prediction where justified.

## Authoritative Game Server

Responsible for:

- session state;
- queue;
- player assignment;
- input validation;
- movement validation;
- attack state;
- weapon traces/hit confirmation;
- damage;
- stamina;
- deaths/lives;
- enemy AI;
- monster AI;
- stage timer;
- progression;
- stage success/failure;
- player replacement;
- audience events;
- vote results;
- leaderboard statistics.

## Web Dashboard

Responsible for:

- accounts;
- queue status;
- live match state;
- player profiles;
- leaderboards;
- run history;
- stage records;
- rules;
- visual guide;
- live/watch presentation.

## Broadcast Layer

Responsible for:

- spectator output;
- OBS;
- YouTube Live;
- browser-source overlays;
- audience input adapter.

---

# Combat Architecture

Combat is the first production gate.

Every attack follows:

`READY → WINDUP → RELEASE/ACTIVE → RECOVERY → READY`

Attack types:

- Slash
- Overhead
- Stab

Defense:

- Block
- Parry
- Counter
- Riposte
- Kick
- Dodge

Resources:

- health/life state;
- stamina;
- weapon state.

Final melee combat should use weapon-path tracing:

- tracer points along the weapon;
- previous-frame positions;
- current-frame positions;
- sweep/trace between them;
- server-authoritative hit result.

Temporary generic hitboxes are acceptable only for early prototypes.

---

# Animation

Use Godot animation systems suitable for:

- idle;
- walk/run;
- jump;
- dodge;
- Slash;
- Overhead;
- Stab;
- Block;
- Parry;
- Counter;
- Kick;
- hit;
- stagger;
- death;
- interaction;
- victory/throne presentation.

Animation timing must synchronize with the combat state machine.

---

# AI Architecture

The AI director controls:

- enemy spawn timing;
- wave composition;
- enemy roles;
- difficulty;
- spacing;
- elite encounters;
- monster encounters;
- stage-specific behavior.

Initial AI roles:

- Soldier
- Spearman
- Heavy
- Archer
- Assassin
- Elite
- Monster

Enemy combat should use the same core attack/defense language wherever practical.

---

# Stage System

Each stage should be data-driven and define:

- stage ID;
- location;
- time of day;
- environment;
- maximum combat time;
- required progression;
- enemy wave tables;
- elite tables;
- monster availability;
- audience event availability;
- audio;
- transition presentation;
- next stage.

This allows new locations to be added without rewriting the game core.

---

# Queue System

Queue data tracks:

- account;
- username;
- display name;
- queue timestamp;
- status;
- current run/stage;
- readiness;
- disconnect/no-show state.

Rules:

- first four eligible players form a team;
- absent players are replaced;
- surviving players retain their positions in a successful run;
- empty survivor seats are filled from the queue;
- failed runs remove all four current players;
- the queue never waits indefinitely for one absent player.

---

# Stage Transition

Every transition is exactly one minute.

During the minute:

1. determine survivors;
2. remove dead players;
3. fill empty seats;
4. load the next environment;
5. prepare AI;
6. prepare the objective;
7. show the upcoming danger;
8. show the monster on its throne where applicable;
9. start the next combat stage.

---

# Audience System

Voting is controlled by the server.

If combat is still active:

- 05:00 → Vote 1.
- 09:00 → Vote 2.

Only one event is selected per voting window.

Initial events:

- Darkness — 1 minute.
- Rain — 2 minutes.
- Falcon — fast non-lethal attack.
- Meteor — nearby impact with damage/knockback.
- Monster — joins combat and is worth +2 progression when killed.
- Weapon Swap — 2 minutes.

---

# Broadcast

Active gameplay:

- 5 hours/day;
- 6 days/week;
- Tuesday off.

The broadcast can continue outside active gameplay with:

- dashboard;
- rankings;
- highlights;
- queue;
- statistics;
- countdown;
- monster/throne presentation.

The final active daily UTC window is an implementation/scheduling decision to be selected using global audience coverage rather than guessed.

---

# Dashboard

The dashboard is a first-class product component.

It includes:

### Live
- current stage;
- location;
- four players;
- timer;
- progression;
- active event;
- vote;
- transition status.

### Players
- username;
- display name;
- kills;
- deaths;
- monster kills;
- highest stage;
- throne completions;
- appearances.

### Leaderboards
- top two kill performers from each completed run/team;
- best players;
- best runs;
- highest stages;
- throne completions;
- monster performance.

### Rules
Complete game rules.

### How to Play
Controls and mechanics.

### Visual Guide
Images/diagrams for controls, combat, progression and audience events.

### History
Past runs, stages and player records.

---

# Development Order

## Gate 1 — Combat

1. One player.
2. One AI.
3. Horizontal environment.
4. Movement.
5. Slash.
6. Overhead.
7. Stab.
8. Windup.
9. Release.
10. Recovery.
11. Weapon trace.
12. Block.
13. Parry.
14. Counter.
15. Kick.
16. Dodge.
17. Stamina.
18. Hit reaction.
19. Knockback.
20. Death.
21. Animation.
22. Mobile controls.
23. Camera.

Do not proceed until the combat feels correct.

## Gate 2 — Multiplayer

- 4 players;
- server authority;
- input synchronization;
- combat synchronization;
- reconnect handling;
- spectator state.

## Gate 3 — AI Army

- enemy roles;
- wave system;
- AI director;
- monster.

## Gate 4 — Progression

- 10-minute stage timer;
- progression requirement;
- stage success;
- stage failure;
- one-minute transition;
- queue replacement;
- survivors.

## Gate 5 — Audience

- vote system;
- minute 5;
- minute 9;
- all initial events.

## Gate 6 — World

- multiple locations;
- time-of-day;
- weather;
- castle progression;
- throne.

## Gate 7 — Dashboard

- authentication;
- profiles;
- leaderboards;
- live state;
- rules;
- visual guide;
- history.

## Gate 8 — Broadcast

- spectator;
- OBS;
- YouTube;
- audience adapter.

## Gate 9 — Production

- mobile optimization;
- load tests;
- network soak;
- abuse prevention;
- monitoring;
- recovery;
- moderation.

---

# Quality Gates

A subsystem is not complete until it passes:

- functional tests;
- authority/security tests;
- reconnect/failure tests where relevant;
- mobile input tests;
- performance tests;
- visual review;
- broadcast readability review;
- deterministic/fairness review.

---

# Hard Rule

Do not build breadth before proving combat quality.

The first deliverable must prove:

**one player + one enemy + real medieval melee combat + mobile controls + cinematic horizontal presentation.**

If that slice does not reach the target feel, stop and improve it before adding the army, queue, stages, audience or dashboard.
