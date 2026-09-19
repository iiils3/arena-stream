# Arena Stream — Godot Foundation Status

## Current state

Branch: `godot-foundation`

**The previous 4v4 human-vs-human prototype is frozen.**

The authoritative gameplay specification is now:

- `GAME_SPEC.md` — **Arena Stream Game Specification v1.0**

The new game direction is:

**4 human players vs AI medieval/fantasy army + audience events + first-come queue + evolving survivors + stage progression toward the throne.**

The old Godot 4v4 code remains preserved as prototype/reference material. It must not be treated as the production gameplay direction.

---

## New production target

The first production milestone is a **Chivalry-style medieval melee combat vertical slice**, redesigned for:

- horizontal mobile play;
- four-player cooperative combat;
- AI enemies;
- touch controls;
- cinematic 2.5D presentation.

The visual/experience reference is the quality and combat language of Chivalry-style medieval melee games. All final game assets, characters, environments, names, animations, audio and code must be original or explicitly licensed.

---

## New core loop

- 4 real players enter from the first-come-first-served queue.
- Stage maximum: 10 minutes.
- Each player has two lives/deaths for the run.
- Players do not repeatedly respawn.
- Every stage has a progression requirement.
- Default requirements: 8, 10, 12, 14, 16, 18... (+2 per stage).
- Normal enemy kill = +1 progression.
- Monster kill = +2 progression.
- If requirement is completed, surviving players advance.
- Empty survivor seats are filled from the queue.
- If requirement is not completed by 10 minutes, the whole current team exits.
- The next team starts the same stage again.
- Exactly one minute is reserved between stages.
- During the transition, the next danger/monster can be shown to the audience.
- The ultimate objective is reaching the throne.

---

## Audience system

Audience voting occurs only while the stage is still active:

- Minute 5: first vote.
- Minute 9: second vote.
- One selected event per voting window.

Initial event pool:

- Darkness — 1 minute.
- Rain — 2 minutes.
- Falcon — fast non-lethal attack.
- Meteor — nearby impact with damage/knockback.
- Monster — joins combat; kill is worth +2 progression.
- Weapon Swap — 2 minutes.

---

## Broadcast schedule

Active gameplay:

- 5 hours/day.
- 6 days/week.
- Tuesday off.

The broadcast may continue outside active gameplay with:

- dashboard;
- rankings;
- highlights;
- queue;
- statistics;
- countdown;
- monster/throne presentation.

---

## Dashboard target

The web dashboard is a first-class product component.

It must eventually include:

- Live view.
- Current stage and location.
- Current four players.
- Progress/timer.
- Current audience event/vote.
- Player leaderboard.
- Top two kill performers per completed run/team.
- Player profiles.
- Username/display name.
- Kills/deaths.
- Monster kills.
- Highest stage.
- Throne completions.
- Run history.
- Stage records.
- Rules.
- How-to-play guide.
- Visual control/combat explanations.
- Registration/queue status.
- Live/watch entry point.

---

## Combat vertical slice — immediate gate

Do not expand to the full world until the combat slice feels correct.

Minimum slice:

1. One player.
2. One AI enemy.
3. Horizontal medieval environment.
4. Slash.
5. Overhead.
6. Stab.
7. Windup.
8. Release/active window.
9. Recovery.
10. Real weapon-path tracing.
11. Block.
12. Parry.
13. Counter.
14. Kick.
15. Dodge.
16. Stamina.
17. Hit reaction.
18. Knockback/stagger.
19. Death/ragdoll presentation.
20. Cinematic camera.
21. Mobile landscape controls.

After this passes:

- 4-player networking;
- AI army;
- stage progression;
- queue replacement;
- audience voting;
- world stages;
- throne;
- dashboard;
- broadcast integration.

---

## Repository policy

The old 4v4 prototype is retained because it contains useful experiments for:

- belt-style movement;
- depth sorting;
- camera;
- combat timing;
- Godot scene structure;
- hitbox/hurtbox separation;
- test/CI setup.

Those systems may be reused only where they fit the new design.

Do not preserve old 4v4 rules merely because code already exists.

For every new subsystem, evaluate:

1. Godot compatibility.
2. License.
3. Maintainability.
4. Dependencies.
5. Multiplayer suitability.
6. Mobile performance.
7. Removal/replacement cost.
8. Visual quality.
9. Testability.

---

## Validation rule

Do not merge the new production direction into `main` until:

- the combat vertical slice is playable;
- Godot CI passes;
- no parser/runtime blocker remains;
- server authority boundaries are defined;
- mobile controls are tested;
- the combat quality gate is passed.

The local development environment does not currently contain a Godot executable, so CI remains an important runtime validation gate.

---

## Source-of-truth rule

When an older document or prototype conflicts with `GAME_SPEC.md` v1.0:

**`GAME_SPEC.md` v1.0 wins.**

The project should be built from the new design rather than progressively patching the old 4v4 game.
