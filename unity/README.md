# Arena Stream — Unity 6 combat foundation

This folder is a **Unity source scaffold**, not a tested Unity build or finished game. It deliberately does not import or pretend to convert the earlier Three.js prototype.

## Unity Editor
- Open the `unity/` folder using Unity Hub with **Unity 6 (6000.0.x)**. The exact editor patch in `ProjectVersion.txt` may require selecting another installed Unity 6 patch.
- Enable **Active Input Handling = Both** or **Input Manager (Old)** in Player settings: this initial prototype uses the built-in legacy input axes.
- Add a scene with a floor collider, a GameObject with `ArenaInput`, a player capsule with `CharacterController`, `ArenaFighter` and `ArenaPlayer`, plus a child Camera at eye height.
- Add an enemy capsule with collider, `ArenaFighter` and `ArenaEnemy`. Ensure the enemy collider is on a layer included in `ArenaPlayer.enemyLayers`.
- Add an EventSystem, Canvas and GraphicRaycaster. On mobile, create a left-side Image with `ArenaTouchZone (Move)`, a right-side transparent Image with `ArenaTouchZone (Look)`, and six UI buttons with `ArenaTouchButton` actions. UI Images must have Raycast Target enabled.
- For WebGL, install Unity's Web Build Support module and use Build Profiles. Confirm performance on real mobile browsers before selecting final render pipeline.

## Controls
| Action | PC | Mobile |
|---|---|---|
| Move | WASD | Left joystick |
| Look | Mouse | Swipe right-side look zone |
| Light attack | Left click | Attack |
| Heavy attack | Q | Heavy |
| Block | Hold right click | Hold shield |
| Dodge | Space | Dodge |
| Sprint | Hold left Shift | Hold sprint |
| Interact | E | Interact |

The controls are wired as a starting point. Animation, directional hit windows, physics-safe AI navigation, camera feel, sound, controller support, networking, stage flow and responsive HUD still need implementation and testing.

## Production boundaries
- No real sponsorship SDKs or logos; publisher approval and YouTube disclosure checks come first.
- Never put YouTube credentials or publisher secrets in Unity client assets.
- Four-player co-op requires an authoritative server and synchronized combat; local prototype logic is **not** production multiplayer.
- Existing `prototype-3d/` is the historical Three.js experiment, not the Unity production project.
