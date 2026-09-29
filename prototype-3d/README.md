# Arena Stream — real 3D combat foundation

An isolated **Three.js / WebGL** browser prototype on the `build/arena-3d-foundation` branch. It does not replace the legacy Phaser application.

## Run

```bash
cd prototype-3d
npm install
npm run dev
```

Open the local Vite URL in a desktop or mobile browser. For a production build: `npm run build`.

## Included
- Real 3D castle courtyard, first-person camera and simple first-person sword.
- Desktop WASD, mouse look (click to lock), click attack, Shift sprint.
- Mobile left-side movement pad, right-side swipe look, attack button.
- One pursuing melee enemy, basic hit/damage and enemy respawn.
- Health, stamina, hit feedback, kill counter, restart.
- Non-commercial placeholder banner surfaces reserved for future sponsor integration.

## Not included yet
Dedicated authoritative server, four-player networking, advanced melee/parry, stages, boss, YouTube chat, real ads or sponsorship integrations. No real sponsor logos or ad requests are loaded.

## Security
Never put YouTube API secrets or sponsor credentials in browser code. Server-side integration and publisher approval are prerequisites for live campaigns.
