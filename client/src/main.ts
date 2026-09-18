import Phaser from "phaser";
import "./style.css";

const WIDTH = 1280;
const HEIGHT = 720;
const WORLD = { x: 70, y: 100, w: 930, h: 540 };

type Team = "A" | "B";
type Weapon = "sword" | "spear" | "bow";

type Fighter = {
  id: number;
  code: string;
  team: Team;
  x: number;
  y: number;
  kills: number;
  lives: number;
  weapon: Weapon;
  hp: number;
  maxHp: number;
  deadUntil: number;
  weakened: boolean;
  moving: boolean;
  body: Phaser.GameObjects.Arc;
  halo: Phaser.GameObjects.Arc;
  label: Phaser.GameObjects.Text;
  hpBar: Phaser.GameObjects.Rectangle;
};

const WEAPON_MAX: Record<Weapon, number> = { sword: 5, spear: 4, bow: 2 };
const WEAPONS: Weapon[] = ["sword", "spear", "bow"];

class ArenaScene extends Phaser.Scene {
  private fighters: Fighter[] = [];
  private matchMs = 15 * 60 * 1000;
  private remainingMs = this.matchMs;
  private eventMs = 5 * 60 * 1000;
  private eventIndex = 0;
  private eventNames = ["ظلام تام", "انكماش الساحة", "تبديل السلاح", "فخ أرضي", "مكافأة على القائد", "القلب"];
  private clockText!: Phaser.GameObjects.Text;
  private eventText!: Phaser.GameObjects.Text;
  private feedText!: Phaser.GameObjects.Text;
  private rankText!: Phaser.GameObjects.Text;
  private phaseText!: Phaser.GameObjects.Text;
  private arenaGraphics!: Phaser.GameObjects.Graphics;
  private keys!: { up: Phaser.Input.Keyboard.Key; down: Phaser.Input.Keyboard.Key; left: Phaser.Input.Keyboard.Key; right: Phaser.Input.Keyboard.Key; attack: Phaser.Input.Keyboard.Key };

  constructor() { super("ArenaScene"); }

  create() {
    this.drawArena();
    this.createHud();
    this.createFighters();
    this.createControls();
    this.startDemoSimulation();
  }

  update(_time: number, delta: number) {
    this.remainingMs = Math.max(0, this.remainingMs - delta);
    this.eventMs -= delta;

    if (this.eventMs <= 0 && this.remainingMs > 0) {
      this.eventMs += 5 * 60 * 1000;
      this.triggerEvent();
    }

    this.updateDemoMovement(delta);
    this.updateUi();
    this.updateRespawns();
  }

  private drawArena() {
    this.cameras.main.setBackgroundColor("#09080c");
    this.arenaGraphics = this.add.graphics();
    this.arenaGraphics.fillStyle(0x151119, 1);
    this.arenaGraphics.fillRect(0, 0, WIDTH, HEIGHT);

    // Stylized ancient-city blocks and alleys.
    this.arenaGraphics.fillStyle(0x211b25, 1);
    this.arenaGraphics.fillRect(WORLD.x, WORLD.y, WORLD.w, WORLD.h);
    this.arenaGraphics.lineStyle(3, 0x4b3d4b, 1);
    for (let x = WORLD.x + 45; x < WORLD.x + WORLD.w; x += 150) {
      this.arenaGraphics.strokeRect(x, WORLD.y + 28, 92, WORLD.h - 56);
    }
    for (let y = WORLD.y + 130; y < WORLD.y + WORLD.h; y += 150) {
      this.arenaGraphics.lineBetween(WORLD.x + 25, y, WORLD.x + WORLD.w - 25, y);
    }
    this.arenaGraphics.lineStyle(2, 0x6b526c, 0.5);
    this.arenaGraphics.strokeRect(WORLD.x + 8, WORLD.y + 8, WORLD.w - 16, WORLD.h - 16);
  }

  private createHud() {
    this.add.text(32, 22, "ARENA STREAM", {
      fontFamily: "system-ui", fontSize: "28px", color: "#f1e8d8", fontStyle: "bold"
    });
    this.phaseText = this.add.text(32, 60, "الجولة التجريبية • 5v5", {
      fontFamily: "system-ui", fontSize: "15px", color: "#a99fac"
    });

    const top = this.add.graphics();
    top.fillStyle(0x100d14, 0.95);
    top.fillRoundedRect(430, 18, 330, 62, 12);
    this.clockText = this.add.text(448, 30, "15:00", {
      fontFamily: "monospace", fontSize: "30px", color: "#f4ead9", fontStyle: "bold"
    });
    this.eventText = this.add.text(570, 40, "تصويت الجمهور: 05:00", {
      fontFamily: "system-ui", fontSize: "13px", color: "#c8bdc9"
    });

    const side = this.add.graphics();
    side.fillStyle(0x100d14, 0.94);
    side.fillRoundedRect(1020, 18, 228, 390, 14);
    this.add.text(1042, 36, "الترتيب — القتلات", {
      fontFamily: "system-ui", fontSize: "18px", color: "#f1e8d8", fontStyle: "bold"
    });
    this.rankText = this.add.text(1042, 72, "", {
      fontFamily: "monospace", fontSize: "13px", color: "#d6ced8", lineSpacing: 5
    });

    this.add.text(1020, 430, "آخر الأحداث", {
      fontFamily: "system-ui", fontSize: "16px", color: "#f1e8d8", fontStyle: "bold"
    });
    this.feedText = this.add.text(1020, 458, "الجولة بدأت • 10 مقاعد ممتلئة", {
      fontFamily: "system-ui", fontSize: "12px", color: "#aaa1ad", lineSpacing: 7,
      wordWrap: { width: 228 }
    });

    this.add.text(32, 662, "WASD للحركة • SPACE للهجوم • النموذج الحالي يحاكي القتال تلقائيًا", {
      fontFamily: "system-ui", fontSize: "14px", color: "#938895"
    });
  }

  private createFighters() {
    const positions: [number, number][] = [
      [155, 175], [300, 505], [470, 175], [650, 505], [850, 210],
      [235, 360], [400, 285], [590, 360], [760, 285], [900, 500]
    ];

    positions.forEach(([x, y], i) => {
      const team: Team = i < 5 ? "A" : "B";
      const code = `${team}-${String(i + 1).padStart(2, "0")}`;
      const weapon = WEAPONS[i % WEAPONS.length];
      const halo = this.add.circle(x, y, 31, team === "A" ? 0x9b59ff : 0x45d6e8, 0.13);
      const body = this.add.circle(x, y, 17, 0x0e0d12, 1);
      this.add.circle(x, y, 10, team === "A" ? 0xb77cff : 0x66e7f5, 0.8);
      const label = this.add.text(x, y - 49, code, {
        fontFamily: "monospace", fontSize: "12px", color: "#eee7f0",
        backgroundColor: "#0b0910", padding: { x: 5, y: 3 }
      }).setOrigin(0.5);
      const hpBar = this.add.rectangle(x, y + 27, 36, 4, 0x79e06e).setOrigin(0.5);

      this.tweens.add({
        targets: halo, scale: 1.12, alpha: 0.07, duration: 850 + i * 50,
        yoyo: true, repeat: -1, ease: "Sine.inOut"
      });

      this.fighters.push({
        id: i, code, team, x, y, kills: 0, lives: 2, weapon, hp: WEAPON_MAX[weapon],
        maxHp: WEAPON_MAX[weapon], deadUntil: 0, weakened: false, moving: false,
        body, halo, label, hpBar
      });
    });
  }

  private createControls() {
    if (!this.input.keyboard) return;
    this.keys = {
      up: this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.W),
      down: this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.S),
      left: this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.A),
      right: this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.D),
      attack: this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.SPACE)
    };
  }

  private startDemoSimulation() {
    this.time.addEvent({
      delay: 1350,
      loop: true,
      callback: () => {
        const active = this.fighters.filter(f => f.deadUntil <= this.time.now);
        if (active.length < 2 || this.remainingMs <= 0) return;
        const attacker = Phaser.Utils.Array.GetRandom(active);
        const targets = active.filter(f => f.team !== attacker.team && f.id !== attacker.id);
        if (!targets.length) return;
        const target = Phaser.Utils.Array.GetRandom(targets);
        this.dealDamage(attacker, target, 1);
      }
    });
  }

  private dealDamage(attacker: Fighter, target: Fighter, amount: number) {
    if (target.deadUntil > this.time.now || attacker.team === target.team) return;
    target.hp -= amount;
    this.add.text(target.x, target.y - 72, `-${amount}`, {
      fontFamily: "monospace", fontSize: "16px", color: "#f3b1b1"
    }).setOrigin(0.5).setDepth(10);
    if (target.hp <= 0) this.killFighter(attacker, target);
    else this.refreshFighter(target);
  }

  private killFighter(attacker: Fighter, target: Fighter) {
    attacker.kills++;
    target.lives--;
    this.add.text(target.x, target.y, "✦", {
      fontFamily: "system-ui", fontSize: "34px", color: "#f5e1a0"
    }).setOrigin(0.5).setDepth(10);

    const recovery = target.lives > 0 ? 2500 : 3000;
    target.deadUntil = this.time.now + recovery;
    target.x = Phaser.Math.Between(WORLD.x + 35, WORLD.x + WORLD.w - 35);
    target.y = Phaser.Math.Between(WORLD.y + 35, WORLD.y + WORLD.h - 35);
    target.hp = target.maxHp;
    target.weakened = target.lives <= 0;
    target.body.setVisible(false);
    target.halo.setVisible(false);
    target.label.setVisible(false);
    target.hpBar.setVisible(false);

    this.feedText.setText(`${attacker.code} أسقط ${target.code}\n${this.feedText.text}`.split("\n").slice(0, 5).join("\n"));
  }

  private updateRespawns() {
    for (const f of this.fighters) {
      if (f.deadUntil > 0 && this.time.now >= f.deadUntil) {
        f.deadUntil = 0;
        if (f.lives <= 0) f.lives = 1;
        f.hp = f.weakened ? 1 : f.maxHp;
        f.body.setVisible(true);
        f.halo.setVisible(true);
        f.label.setVisible(true);
        f.hpBar.setVisible(true);
        this.refreshFighter(f);
      }
    }
  }

  private updateDemoMovement(delta: number) {
    const t = this.time.now / 1000;
    for (const f of this.fighters) {
      if (f.deadUntil > this.time.now) continue;
      const dx = Math.sin(t * (0.35 + f.id * 0.015)) * 18;
      const dy = Math.cos(t * (0.28 + f.id * 0.011)) * 12;
      f.x = Phaser.Math.Clamp(f.x + dx * delta / 1000, WORLD.x + 25, WORLD.x + WORLD.w - 25);
      f.y = Phaser.Math.Clamp(f.y + dy * delta / 1000, WORLD.y + 25, WORLD.y + WORLD.h - 25);
      f.moving = Math.abs(dx) + Math.abs(dy) > 1;
      this.refreshFighter(f);
    }
  }

  private refreshFighter(f: Fighter) {
    f.body.setPosition(f.x, f.y);
    f.halo.setPosition(f.x, f.y);
    f.label.setPosition(f.x, f.y - 49);
    f.hpBar.setPosition(f.x, f.y + 27);
    f.hpBar.setScale(Math.max(0, f.hp / Math.max(1, f.maxHp)), 1);
  }

  private triggerEvent() {
    const name = this.eventNames[this.eventIndex % this.eventNames.length];
    this.eventIndex++;
    this.eventText.setText(`حدث الجمهور: ${name}`);
    this.feedText.setText(`الجمهور اختار: ${name}\n${this.feedText.text}`.split("\n").slice(0, 5).join("\n"));

    if (name === "تبديل السلاح") {
      for (const f of this.fighters) {
        f.weapon = WEAPONS[(WEAPONS.indexOf(f.weapon) + 1) % WEAPONS.length];
        f.maxHp = WEAPON_MAX[f.weapon];
        f.hp = Math.min(f.hp, f.maxHp);
      }
    }
  }

  private updateUi() {
    const seconds = Math.ceil(this.remainingMs / 1000);
    this.clockText.setText(`${Math.floor(seconds / 60).toString().padStart(2, "0")}:${(seconds % 60).toString().padStart(2, "0")}`);
    const eventSeconds = Math.max(0, Math.ceil(this.eventMs / 1000));
    this.eventText.setText(`تصويت الجمهور بعد ${Math.floor(eventSeconds / 60).toString().padStart(2, "0")}:${(eventSeconds % 60).toString().padStart(2, "0")}`);

    const sorted = [...this.fighters].sort((a, b) => b.kills - a.kills || a.id - b.id);
    this.rankText.setText(sorted.map((f, i) => `${String(i + 1).padStart(2, " ")}. ${f.code}   ⚔ ${f.kills}   ♥ ${Math.max(0, f.lives)}`).join("\n"));
  }
}

new Phaser.Game({
  type: Phaser.AUTO,
  parent: "game",
  width: WIDTH,
  height: HEIGHT,
  scale: { mode: Phaser.Scale.FIT, autoCenter: Phaser.Scale.CENTER_BOTH },
  render: { antialias: true },
  scene: [ArenaScene]
});
