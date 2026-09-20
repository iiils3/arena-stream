# Arena Stream — 3D Vertical Slice

This branch is the visual reset after the earlier 2D procedural prototype.

## Target composition

- Four human players are visible together in one readable third-person battlefield view.
- The team fights a larger AI-controlled medieval enemy group.
- The scene is original and procedural: no Chivalry 2 assets, maps, characters, UI, or proprietary files are imported.
- The current pass is a **3D composition/technology slice**, not the final art pass.

## What this proves

1. Godot is now rendering a real 3D battlefield.
2. Four distinct player silhouettes can be read simultaneously.
3. A larger enemy formation creates the intended 4-vs-army composition.
4. Camera, lighting, fortress depth, materials, weapons and spectator-facing framing are now built in 3D.
5. The existing server, queue, stage, audience and combat systems remain separate foundations; this slice is intentionally focused on replacing the old 2D presentation.

## Next visual gates

- Replace procedural fighters with authored/rigged original 3D characters.
- Add skeletal animation and animation-driven weapon traces.
- Add real combat reactions, hit effects, ragdolls and sound.
- Add terrain/props with authored PBR materials.
- Connect this 3D presentation to the existing stage/queue/audience runtime.


Build gate: Android APK workflow is enabled on this branch so the visual slice can be installed and reviewed before any merge.
