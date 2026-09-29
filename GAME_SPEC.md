# Arena Stream — Target Game Specification

Status: Discovery / Target concept v0.2
This document describes the intended product, not a claim that the current code already implements it.

## 1. Core concept
A browser-first Medieval combat experience designed as both a game and a live entertainment format.

4 real players → cooperate → fight an AI army → survive escalating stages → reach a final objective → create a match worth watching → audience participates at controlled checkpoints.

## 2. Players
- 4 human players per active squad.
- One shared team objective.
- Cooperative play is the default.
- Player replacement/queue is a later system.

## 3. Enemy army
Target layers: basic melee, ranged/support, heavy/elite, special enemies, boss/monster encounters.
The roster is intentionally undecided.

## 4. Stages
The match is divided into escalating stages. Each stage can change enemy count, composition, pressure, environmental conditions, objectives and special encounters.
Exact counts are provisional.

## 5. Match duration
Target maximum: approximately 10 minutes.
The match should have a clear beginning, escalation, climax and conclusion.

## 6. Final objective
The long-term concept includes progression toward a final objective / throne. The exact implementation is intentionally open.

## 7. Combat
Combat should emphasize directional attacks, timing, distance, positioning, defense, parry/counter opportunities, weapon identity and readable hit feedback.

Possible directions include Slash, Overhead, Stab, Block, Parry, Counter, Dodge and Stamina. These are design directions, not copied implementation.

## 8. Audience interaction
Audience interaction occurs at controlled checkpoints.
- Vote between predefined events.
- Select a challenge modifier.
- Trigger a controlled encounter.

Rules: predictable, limited, no arbitrary control over individual players, no permanent griefing, understandable to viewers.

## 9. Live-show structure
The match should naturally create tension, reversals, near-deaths, clutch moments, team saves, boss encounters, audience decisions and a clear ending.

## 10. Content generation
A single match should potentially produce: LIVE → HIGHLIGHTS → SHORTS → LONG-FORM VIDEO → COMMUNITY CONTENT.

Future automation may identify kills, near-deaths, comebacks, unusual events, audience decisions and boss moments.

## 11. Prototype success criteria
Before production infrastructure, test whether:
1. Four players understand the game immediately.
2. Combat feels responsive.
3. Multiple AI enemies remain readable.
4. Cooperation creates meaningful decisions.
5. The match escalates.
6. The match creates memorable moments.
7. Spectators understand what is happening.
8. Audience decisions add value.
9. A complete match fits the short format.
10. The prototype remains cheap to build and iterate.

## 12. Explicitly undecided
Do not treat these as finalized: exact weapons, classes, visual style, map, enemy roster, exact stage count, exact enemy counts, monetization, YouTube Playables integration, matchmaking, ranking, progression and art direction.

## 13. Technical philosophy
Build the smallest testable version:
1. One arena
2. One player
3. Basic movement
4. Basic melee combat
5. A few AI enemies
6. One escalation event
7. Four-player cooperative test
8. Audience interaction test
9. Short complete match
10. Only then expand infrastructure

Do not build the final system before proving the core loop.