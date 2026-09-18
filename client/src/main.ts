import Phaser from "phaser";
import "./style.css";

const WIDTH = 1280;
const HEIGHT = 720;

class ArenaScene extends Phaser.Scene {
  private elapsed = 0;

  constructor() {
    super("ArenaScene");
  }

  create() {
    this.cameras.main.setBackgroundColor("#0d0b10");

    const g = this.add.graphics();
    g.fillStyle(0x18141c, 1);
    g.fillRect(0, 0, WIDTH, HEIGHT);

    // Ancient-city arena placeholder: the layout will be replaced with final art.
    g.lineStyle(3, 0x3b303d, 1);
    for (let x = 80; x < WIDTH - 80; x += 160) {
      g.strokeRect(x, 100, 120, 520);
    }

    this.add.text(32, 24, "ARENA STREAM", {
      fontFamily: "system-ui",
      fontSize: "28px",
      color: "#f1e8d8",
      fontStyle: "bold"
    });

    this.add.text(32, 62, "5v5  •  15:00  •  الجولة التجريبية", {
      fontFamily: "system-ui",
      fontSize: "16px",
      color: "#b8aebc"
    });

    this.createHud();
    this.createDemoPlayers();
  }

  update(_: number, delta: number) {
    this.elapsed += delta;
  }

  private createHud() {
    const panel = this.add.graphics();
    panel.fillStyle(0x100d14, 0.92);
    panel.fillRoundedRect(WIDTH - 270, 24, 238, 250, 14);

    this.add.text(WIDTH - 248, 42, "الترتيب — القتلات", {
      fontFamily: "system-ui",
      fontSize: "18px",
      color: "#f1e8d8",
      fontStyle: "bold"
    });

    const names = ["A-01", "B-07", "A-04", "B-02", "A-09", "B-05", "A-03", "B-10", "A-06", "B-08"];
    names.forEach((name, i) => {
      this.add.text(WIDTH - 248, 76 + i * 18, `${i + 1}. ${name}     ${Math.max(0, 5 - Math.floor(i / 3))}`, {
        fontFamily: "monospace",
        fontSize: "13px",
        color: i < 2 ? "#f5d58a" : "#c9c2cc"
      });
    });

    this.add.text(32, HEIGHT - 56, "تصويت الجمهور القادم بعد 05:00", {
      fontFamily: "system-ui",
      fontSize: "18px",
      color: "#e8d9c8"
    });
  }

  private createDemoPlayers() {
    const positions = [
      [260, 210], [430, 500], [620, 250], [780, 500], [930, 260],
      [340, 380], [520, 180], [700, 420], [860, 180], [1040, 430]
    ];

    positions.forEach(([x, y], i) => {
      const teamA = i % 2 === 0;
      const halo = this.add.circle(x, y, 30, teamA ? 0x9b59ff : 0x45d6e8, 0.16);
      this.add.circle(x, y, 17, 0x111016, 1);
      this.add.circle(x, y, 11, teamA ? 0x9b59ff : 0x45d6e8, 0.85);
      this.add.text(x, y - 48, teamA ? `A-${String(i + 1).padStart(2, "0")}` : `B-${String(i + 1).padStart(2, "0")}`, {
        fontFamily: "monospace",
        fontSize: "12px",
        color: "#eee7f0",
        backgroundColor: "#0c0a10",
        padding: { x: 5, y: 3 }
      }).setOrigin(0.5);
      this.tweens.add({
        targets: halo,
        scale: 1.12,
        alpha: 0.08,
        duration: 900 + i * 40,
        yoyo: true,
        repeat: -1,
        ease: "Sine.inOut"
      });
    });
  }
}

new Phaser.Game({
  type: Phaser.AUTO,
  parent: "game",
  width: WIDTH,
  height: HEIGHT,
  scale: {
    mode: Phaser.Scale.FIT,
    autoCenter: Phaser.Scale.CENTER_BOTH
  },
  render: { antialias: true },
  scene: [ArenaScene]
});
