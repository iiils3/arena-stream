# Current Prototype — Reality Check

This file prevents future contributors/AI agents from confusing the legacy implementation with the target product.

## Current implementation
The repository contains a Phaser + TypeScript + Vite browser client and a Colyseus server with browser multiplayer, player movement, basic PvP attacks, sword/spear/bow states, health/lives, weapon pickups, audience vote messages, timed events, HUD, mobile touch controls and Arabic RTL interface elements.

## Known divergence
The old code contains conflicting historical assumptions:
- previous docs described 5v5,
- server capacity is currently 8,
- client HUD contains 4v4 wording,
- the target product is 4 human players versus an AI army.

This is historical prototype residue, not the final game rule.

## Not yet implemented
- AI enemy army
- cooperative 4-player PvE rules
- stage progression
- final throne/goal sequence
- robust audience system
- production matchmaking
- queue replacement
- replay/highlight extraction
- YouTube integration
- Playables integration

## Engineering rule
Do not hide these gaps. Establish the smallest working target prototype first, then remove or repurpose legacy PvP systems.

Reuse infrastructure where it genuinely helps; do not preserve old game rules merely because code already exists.