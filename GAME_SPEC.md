# Arena Stream — Game Rules v0.2

## Identity
Arena Stream is an original 4v4 fantasy 2.5D beat'em-up built for live streaming and audience interaction.
Golden Axe / Golden Axed are visual/gameplay references only; Arena Stream must use original characters, art, names and assets.

## Match
- 8 total player seats.
- 4 players per team.
- Each team: 2 female + 2 male characters.
- 15 minutes.
- No friendly fire.
- Individual kills are tracked.
- Player name/code is visible above the character.
- Spectator view shows timer, teams, lives, kills, kill feed and current event.

## Weapons
Each team has:
- 2 swords
- 2 spears
- 4 bows

Players start with a bow and can pick up team loot.
Normal kill thresholds:
- Sword: 5 hits
- Spear: 4 hits
- Bow: 2 arrows

## Lives
- Every player starts with 2 lives.
- First death: lose one life and respawn after 3 seconds.
- Losing the second starting life: out for 3 minutes.
- Then return with one Final Life, weakened, with HP = 1.
- Death on Final Life: out for 5 minutes if the match still has time.
- Final-Life state cannot be made stronger by normal weapon changes.

## Combat
- Server is authoritative for movement, attacks, damage, kills, lives and match state.
- Client sends input/intent; it does not decide hits or damage.
- Friendly fire is impossible.
- Combat should use proper hitbox/hurtbox logic in the Godot build.
- Hit-stop, impact VFX, knockback and readable attack telegraphs are part of the target feel.

## Arena / camera
- Fantasy ancient city / castle arena with foreground and background depth.
- Start with a short castle/city intro and weapon presentation before combat.
- Dynamic camera keeps living combatants visible:
  - players spread apart -> camera zooms out;
  - players converge -> camera zooms in.
- Players may leave the combat square.
- Leaving the combat square does NOT make a player safe from enemies.

## Anti-camping / anti-idle
After 30 seconds of meaningful inactivity OR remaining outside the combat zone:
- Falcon attack/event triggers.
- Falcon damage is always non-lethal.
- HP is clamped to at least 1.
- The goal is to prevent camping, not to kill players.

## Audience events
Every 5 minutes the audience votes on 3 presented options.
Event pool:
1. Darkness / blackout
2. Shrinking arena
3. Forced weapon swap
4. Ground trap
5. Bounty on leader
6. Heart

### Heart
- Appears in a risky location.
- A team that captures it gives +3 lives to every current team member.
- Opposing team loses nothing.
- If a weakened/final-life player receives the Heart benefit, the exact recovery rule must be implemented and tested before competitive launch.

### Bounty
- Marks the current team leader/highest-kill player.
- The reward effect is a separate mechanic and must be implemented before competitive launch.

## Round transition
At match end:
- Normally highest-kill player from Team A and highest-kill player from Team B become leaders.
- If the top two overall killers are from opposite teams, both advance.
- If the top two overall killers are from the same team AND the second same-team player has at least 2 more kills than the best opposing player, both advance.
- Deterministic tie-break: earlier join order wins ties.

Next round:
- 2 returning leaders.
- 8 new player seats.
- Maximum 10 seats is NOT part of the current design; the current Arena Stream match is 8 players.
- A player who leaves early forfeits their current round position.

## Streaming architecture
- Godot game client renders the spectator/player view.
- Authoritative game server handles multiplayer state.
- OBS captures the spectator output.
- YouTube Live distributes the stream.
- Audience chat is an external input source for future voting integration.
- Spectator HUD should eventually be a separate browser-source overlay so stream presentation can evolve independently of the game.

## Development target
First milestone is not the full game.
Milestone 1 is a Godot vertical slice proving:
1. 4v4 scene.
2. Belt/2.5D movement and depth sorting.
3. 8 visible characters.
4. Real melee/ranged combat.
5. Dynamic group camera.
6. Pickups.
7. Server-authoritative multiplayer.
8. Polished original placeholder art direction.

Only after that do we add audience events, YouTube chat, OBS automation and tournament progression.
