# Arena Stream

> Project status: Discovery / Prototype transition
>
> Arena Stream is a browser-first Medieval combat live-show concept. The long-term product is not intended to be a Chivalry clone.

## Product vision

GAME + LIVE SHOW + YOUTUBE CONTENT ENGINE

Target experience:
- 4 real players cooperate as one team.
- They fight an AI-controlled enemy army.
- The team advances through escalating stages toward a final objective / throne.
- Enemy pressure increases between stages.
- Stronger enemies / monsters can appear.
- A match targets roughly 10 minutes.
- Audience interaction happens at deliberate checkpoints.
- Successful survivors can continue; replacement/queue is a future system.
- A match should naturally create live-stream moments, highlights and Shorts.

Exact numbers are provisional and must be validated.

## What this is NOT
- Not a Chivalry 2 clone.
- Not a conventional 5v5 competitive PvP game.
- Not a Battle Royale.
- Not an MMO.
- Not a large-budget medieval game.

## Content loop

GAME → PLAYERS → LIVE SHOW → VIEWERS → CONTENT → NEW PLAYERS → DATA → GAME IMPROVEMENT

A match should be useful twice: as gameplay and as watchable content.

Potential outputs: live streams, highlights, Shorts, gameplay videos, challenges and community interaction.

## Audience interaction
Viewers should have limited, predictable influence: predefined events, challenge modifiers or controlled encounters. Audience actions must not arbitrarily ruin a player's match.

## Combat direction
Target combat emphasizes directional attacks, timing, distance, positioning, defense/parry opportunities, weapon identity and readable hit feedback.

Slash, Overhead, Stab, Block, Parry, Counter, Dodge and Stamina are design directions, not a requirement to copy another game's implementation.

## AI army
AI enemies are a core part of the target concept: readable waves, escalating pressure, varied encounters, elite/boss threats, teamwork opportunities and spectator-readable moments.

## Cost philosophy
Initial development targets zero / near-zero upfront cost. Prefer open-source tools, free tiers, local development, minimal infrastructure, reusable assets and AI-assisted development where it genuinely reduces cost/time.

## Current technical prototype
The repository currently contains an older PvP multiplayer scaffold using Phaser + TypeScript + Vite and Colyseus, with basic weapons, health/lives, pickups and audience-vote mechanics.

IMPORTANT: the existing code is not the final 4-player-vs-AI design. Some legacy constants and systems still describe a PvP prototype. Do not interpret those implementation details as final product decisions.

## Local development
From the repository root:

    npm install
    npm run dev:server
    npm run dev:client

For the current prototype:

    ARENA_DEV=1 npm run dev:server

Then open the Vite client. A player name can be supplied with ?name=Ali.

## Repository documents
- GAME_SPEC.md — target game concept and provisional rules.
- PROJECT_BRIEF.md — product/business vision and evaluation framework.
- ROADMAP.md — transition from legacy prototype to validated MVP.
- CURRENT_PROTOTYPE.md — explicit inventory of what the existing code actually does.

## Development principle
Do not build the whole game before proving the core loop.

HYPOTHESIS → MICRO TEST → PROTOTYPE → REAL USER SIGNAL → ITERATE → MVP → SCALE

If the core loop is not fun, watchable, affordable, or sufficiently automatable, change or kill the direction early.