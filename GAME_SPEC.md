# Arena Stream — Game Rules v0.1

## Match
- 5v5
- 10 total player seats
- 15 minutes, uninterrupted
- Individual kills are tracked
- No friendly fire
- Player code/name is visible above the character
- Full live ranking is visible to spectators

## Lives and damage
Normal state:
- Sword: 5 hits to kill
- Spear: 4 hits to kill
- Bow: 2 arrows to kill

After a player loses both starting lives:
- Out for 3 minutes
- Returns with 1 weaker life
- Sword/spear thresholds are reduced
- One bow arrow kills

After that life is lost:
- Returns after 5 minutes if the round still has time

## Respawn
A player respawns from a random safe corner/zone near the action, never directly inside an active fight.

## Anti-camping
After 3 minutes without meaningful movement, trigger a non-lethal nudge event such as a nearby meteor impact or a bird peck.

## Audience events
Every 5 minutes, spectators vote. The event list is selected from:
1. Darkness / blackout
2. Shrinking map
3. Forced weapon swap
4. Ground trap
5. Leader bounty
6. Heart

Heart:
- Appears in a risky location
- Capturing team gains +3 lives for every team member
- Opposing team loses nothing
- If a player is weakened, the Heart restores them to the normal state

## Round transition
Normally the highest killer from each team becomes a leader.

If the top two killers are from opposite teams, both advance.

If the top two killers are from the same team and the opposing team is at least 2 kills behind, both may advance.

Ambiguous ties need a deterministic tie-break rule before competitive launch.

## Next round
- 2 returning leaders
- 8 new players
- Once 10 seats are filled, no additional player joins that round
- A player who leaves early forfeits their turn
