import Phaser from "phaser";
import { Client, getStateCallbacks, Room } from "colyseus.js";
import "./style.css";

const W=1800,H=900;
type Input={up?:boolean;down?:boolean;left?:boolean;right?:boolean};
type Actor={c:Phaser.GameObjects.Container;body:Phaser.GameObjects.Polygon;weapon:Phaser.GameObjects.Graphics;label:Phaser.GameObjects.Text;team:string;gender:string;name:string;x:number;y:number;facing:number;alive:boolean;weaponName:string};

class ArenaScene extends Phaser.Scene{
 private room!:Room; private actors=new Map<string,Actor>(); private pickups=new Map<string,Phaser.GameObjects.Container>();
 private keys!:Record<string,Phaser.Input.Keyboard.Key>; private connected=false; private intro=true;
 private clock!:Phaser.GameObjects.Text; private status!:Phaser.GameObjects.Text; private rank!:Phaser.GameObjects.Text; private feed!:Phaser.GameObjects.Text; private vote!:Phaser.GameObjects.Text; private title!:Phaser.GameObjects.Text; private dark?:Phaser.GameObjects.Rectangle;

 constructor(){super("ArenaScene");}
 async create(){
  this.cameras.main.setBackgroundColor("#120d0b");this.drawCity();this.makeHud();this.makeKeys();this.makeTouch();
  this.cameras.main.setBounds(0,0,W,H);this.cameras.main.centerOn(W/2,H/2);this.cameras.main.setZoom(.62);
  this.title=this.add.text(W/2,105,"قلعة الساحة القديمة",{fontFamily:"serif",fontSize:"42px",fontStyle:"bold",color:"#f0dfbd",stroke:"#1a0e09",strokeThickness:8}).setOrigin(.5).setDepth(100);
  this.status.setText("جاري الاتصال بالساحة...");
  await this.connect();
 }
 private drawCity(){
  const bg=this.add.graphics();bg.fillStyle(0x110b09,1);bg.fillRect(0,0,W,H);
  for(let i=0;i<36;i++){const x=i*55+(i%3)*12,h=120+(i%5)*35;bg.fillStyle(i%2?0x2b211e:0x342823,1);bg.fillRect(x,105-h,48,h);bg.fillStyle(0x171313,1);bg.fillRect(x+10,125-h,12,22);bg.fillRect(x+29,145-h,10,18);}
  bg.fillStyle(0x4a3122,1);bg.fillRect(0,430,W,470);
  for(let x=0;x<W;x+=80){bg.lineStyle(2,0x70503a,.22);bg.lineBetween(x,430,x+35,900);}
  for(let y=470;y<900;y+=70){bg.lineStyle(2,0x70503a,.16);bg.lineBetween(0,y,W,y);}
  this.add.rectangle(W/2,455,1510,620,0x3a2924,.35).setStrokeStyle(5,0x846045,.7);
  this.drawGate(120,360);this.drawGate(1680,360);this.add.rectangle(900,450,1050,560,0x000000,0).setStrokeStyle(4,0xc48b52,.55);this.add.text(900,165,"ميدان الاشتباك",{fontFamily:"serif",fontSize:"18px",color:"#d5a875"}).setOrigin(.5);
  for(let i=0;i<12;i++){const flame=this.add.circle(160+i*135,395,8,0xe6a24a,.8);this.tweens.add({targets:flame,scale:1.35,duration:500+i*20,yoyo:true,repeat:-1});}
 }
 private drawGate(x:number,y:number){
  const g=this.add.graphics();g.fillStyle(0x211817,1);g.fillRect(x-65,y-90,130,230);g.lineStyle(8,0x76533d,1);g.strokeRect(x-65,y-90,130,230);g.fillStyle(0x090808,1);g.fillRect(x-38,y-65,76,205);g.fillStyle(0x4e3326,1);g.fillRect(x-78,y-110,18,250);g.fillRect(x+60,y-110,18,250);g.lineStyle(4,0xa77b4e,.6);g.strokeRect(x-48,y-75,96,215);
 }
 private makeHud(){
  this.add.rectangle(900,38,1760,76,0x100c0a,.88).setScrollFactor(0).setDepth(80);
  this.add.text(36,18,"ARENA STREAM",{fontFamily:"serif",fontSize:"28px",fontStyle:"bold",color:"#ead7b7"}).setScrollFactor(0).setDepth(81);
  this.status=this.add.text(36,54,"",{fontSize:"13px",color:"#aaa09a"}).setScrollFactor(0).setDepth(81);
  this.clock=this.add.text(900,16,"15:00",{fontFamily:"monospace",fontSize:"30px",fontStyle:"bold",color:"#f5e6cc"}).setOrigin(.5,0).setScrollFactor(0).setDepth(81);
  this.add.text(900,54,"4 ضد 4 • ساحة فانتازية",{fontSize:"12px",color:"#a99d92"}).setOrigin(.5).setScrollFactor(0).setDepth(81);
  this.rank=this.add.text(1570,105,"",{fontFamily:"monospace",fontSize:"12px",color:"#eee2d0",lineSpacing:4,backgroundColor:"#0d0a09dd",padding:{x:12,y:10}}).setOrigin(1,0).setScrollFactor(0).setDepth(80);
  this.feed=this.add.text(30,650,"",{fontSize:"13px",color:"#f0dfc9",lineSpacing:6,backgroundColor:"#0d0a09aa",padding:{x:10,y:8}}).setScrollFactor(0).setDepth(80);
  this.vote=this.add.text(900,665,"",{fontSize:"13px",color:"#e8d6bd",align:"center",backgroundColor:"#0d0a09cc",padding:{x:16,y:10}}).setOrigin(.5).setScrollFactor(0).setDepth(80);
 }
 private makeKeys(){const k=this.input.keyboard;if(!k)return;this.keys={up:k.addKey("W"),down:k.addKey("S"),left:k.addKey("A"),right:k.addKey("D"),attack:k.addKey("SPACE"),weapon:k.addKey("E"),vote1:k.addKey("ONE"),vote2:k.addKey("TWO"),vote3:k.addKey("THREE")};}
 private makeTouch(){
  const wrap=document.createElement("div");wrap.className="touch-controls";wrap.style.cssText="position:fixed;inset:0;pointer-events:none;z-index:20";
  const button=(txt:string,cls:string,fn:()=>void)=>{const b=document.createElement("button");b.className="touch-btn "+cls;b.textContent=txt;b.onpointerdown=e=>{e.preventDefault();fn()};wrap.appendChild(b);return b;};
  const hold=(txt:string,cls:string,v:Input)=>{const b=button(txt,cls,()=>this.room&&this.room.send("input",v));const stop=()=>this.room&&this.room.send("input",{up:false,down:false,left:false,right:false});b.onpointerup=stop;b.onpointercancel=stop;return b;};
  hold("▲","up",{up:true});hold("▼","down",{down:true});hold("◀","left",{left:true});hold("▶","right",{right:true});
  button("⚔","attack",()=>this.room&&this.room.send("attack"));button("↻","weapon",()=>this.room&&this.room.send("weapon"));
  button("1","vote1",()=>this.room&&this.room.send("vote",{option:1}));button("2","vote2",()=>this.room&&this.room.send("vote",{option:2}));button("3","vote3",()=>this.room&&this.room.send("vote",{option:3}));
  document.body.appendChild(wrap);
 }
 private async connect(){
  try{
   const url=(globalThis as any).__ARENA_SERVER_URL__||(location.protocol==="https:"?"wss://"+location.host:"ws://localhost:2567");
   const client=new Client(url);const name=new URLSearchParams(location.search).get("name")||("Warrior-"+Math.floor(100+Math.random()*900));
   this.room=await client.joinOrCreate("arena",{name});this.connected=true;this.status.setText("متصل • 4v4");
   const $=getStateCallbacks(this.room);
   $(this.room.state).players.onAdd((p,id)=>this.addPlayer(p,id));$(this.room.state).players.onRemove((_p,id)=>this.removePlayer(id));
   $(this.room.state).pickups.onAdd((p,id)=>this.addPickup(p,id));$(this.room.state).pickups.onRemove((_p,id)=>this.removePickup(id));
   this.room.onMessage("attack-fx",(f:any)=>this.attackFx(f));this.room.onMessage("hawk-fx",(f:any)=>this.hawkFx(f));this.room.onMessage("kill-fx",(f:any)=>this.killFx(f));this.room.onMessage("pickup-fx",(f:any)=>this.pickupFx(f));
   this.room.onMessage("round-result",(x:any)=>this.feed.setText("قادة الجولة القادمة:\n"+x.map((p:any)=>"⚔ "+p.name+" • "+p.kills).join("\n")));
  }catch(e){this.status.setText("فشل اتصال WebSocket");console.error(e);}
 }
 private addPlayer(p:any,id:string){
  const c=this.add.container(p.x,p.y).setDepth(20);
  const shadow=this.add.ellipse(0,20,54,20,0x000000,.45);
  const body=this.add.polygon(0,0,[-20,25,-14,-18,0,-34,15,-18,22,25],p.team==="A"?0x40265f:0x194c55,1);
  const head=this.add.circle(0,-45,13,p.gender==="female"?0xc48f79:0xb67b63,1);
  const cape=this.add.triangle(0,-5,0,0,-25,48,25,48,p.team==="A"?0x5b3280:0x206a72,.9);
  const glow=this.add.circle(0,-18,37,p.team==="A"?0xb05cff:0x42d7e4,.10);
  const weapon=this.add.graphics();const label=this.add.text(0,-78,p.name,{fontFamily:"monospace",fontSize:"12px",color:"#fff",backgroundColor:"#0b0807cc",padding:{x:4,y:2}}).setOrigin(.5);
  c.add([glow,shadow,cape,body,head,weapon,label]);
  this.actors.set(id,{c,body,weapon,label,team:p.team,gender:p.gender,name:p.name,x:p.x,y:p.y,facing:p.facing,alive:p.alive,weaponName:p.weapon});
  this.drawWeapon(this.actors.get(id)!);
 }
 private removePlayer(id:string){const a=this.actors.get(id);if(a){a.c.destroy();this.actors.delete(id);}}
 private drawWeapon(a:Actor){
  a.weapon.clear();const f=a.facing||1;a.weapon.lineStyle(a.weaponName==="bow"?4:7,a.weaponName==="bow"?0xd7a65c:0xd8d0c7,1);
  if(a.weaponName==="sword"){a.weapon.lineBetween(17*f,-20,58*f,-62);a.weapon.lineStyle(6,0x76543b,1);a.weapon.lineBetween(10*f,-13,25*f,-27);}
  else if(a.weaponName==="spear"){a.weapon.lineBetween(15*f,-15,78*f,-18);a.weapon.fillStyle(0xc8c5bb,1);a.weapon.fillTriangle(78*f,-18,67*f,-25,67*f,-11);}
  else{a.weapon.arc(20*f,-28,28,.5,2.6,false);a.weapon.lineBetween(20*f,-56,20*f,0);a.weapon.lineBetween(20*f,-28,65*f,-28);}
 }
 private addPickup(p:any,id:string){
  const c=this.add.container(p.x,p.y).setDepth(12);const glow=this.add.circle(0,0,24,p.team==="A"?0xa85cff:0x42d9e7,.12);const g=this.add.graphics();g.lineStyle(4,p.weapon==="bow"?0xd7a65c:0xd8d0c7,1);
  if(p.weapon==="sword")g.lineBetween(-18,15,22,-28);else if(p.weapon==="spear")g.lineBetween(-25,8,30,0);else{g.arc(0,0,22,.5,2.6,false);g.lineBetween(0,-22,0,20);}
  c.add([glow,g]);this.pickups.set(id,c);
 }
 private removePickup(id:string){const c=this.pickups.get(id);if(c){c.destroy();this.pickups.delete(id);}}
 private attackFx(f:any){const line=this.add.graphics().setDepth(40);line.lineStyle(f.weapon==="bow"?5:12,f.weapon==="bow"?0xe0a65b:0xf3e1c1,.95);line.lineBetween(f.x1,f.y1,f.x2,f.y2);this.tweens.add({targets:line,alpha:0,duration:130,onComplete:()=>line.destroy()});}
 private hawkFx(f:any){const t=this.add.text(f.x,f.y-130,"🦅",{fontSize:"42px"}).setOrigin(.5).setDepth(55);this.tweens.add({targets:t,x:f.x+20,y:f.y-20,rotation:.35,duration:420});this.time.delayedCall(430,()=>{t.destroy();});const hit=this.add.text(f.x,f.y-52,"✦",{fontSize:"30px",color:"#f0c98a"}).setOrigin(.5).setDepth(55);this.tweens.add({targets:hit,alpha:0,y:f.y-85,duration:300,onComplete:()=>hit.destroy()});}
 private killFx(f:any){const t=this.add.text(f.x,f.y-45,"✦",{fontSize:"42px",color:"#fff4d2",stroke:"#3b170d",strokeThickness:5}).setOrigin(.5).setDepth(50);this.tweens.add({targets:t,y:f.y-100,alpha:0,scale:1.5,duration:650,onComplete:()=>t.destroy()});}
 private pickupFx(f:any){const t=this.add.text(f.x,f.y-30,"⚔",{fontSize:"26px",color:"#f2d19a"}).setOrigin(.5).setDepth(50);this.tweens.add({targets:t,y:f.y-65,alpha:0,duration:450,onComplete:()=>t.destroy()});}
 update(){
  if(!this.connected)return;const k=this.keys;
  this.room.send("input",{up:k.up.isDown,down:k.down.isDown,left:k.left.isDown,right:k.right.isDown});
  if(Phaser.Input.Keyboard.JustDown(k.attack))this.room.send("attack");if(Phaser.Input.Keyboard.JustDown(k.weapon))this.room.send("weapon");if(Phaser.Input.Keyboard.JustDown(k.vote1))this.room.send("vote",{option:1});if(Phaser.Input.Keyboard.JustDown(k.vote2))this.room.send("vote",{option:2});if(Phaser.Input.Keyboard.JustDown(k.vote3))this.room.send("vote",{option:3});
  const s:any=this.room.state,secs=Math.ceil(s.remainingMs/1000);this.clock.setText(String(Math.floor(secs/60)).padStart(2,"0")+":"+String(secs%60).padStart(2,"0"));
  this.vote.setText("تصويت الجمهور\n1) "+s.vote1+"  2) "+s.vote2+"  3) "+s.vote3+"\n"+(s.lastEvent||""));
  if(s.lastKill)this.feed.setText(s.lastKill);
  const pts:any[]=[];let minX=W,maxX=0,minY=H,maxY=0;
  s.players.forEach((p:any,id:string)=>{const a=this.actors.get(id);if(!a)return;a.x=p.x;a.y=p.y;a.facing=p.facing;a.alive=p.alive;a.weaponName=p.weapon;a.c.setPosition(p.x,p.y);a.c.setVisible(p.alive);a.body.setFillStyle(p.team==="A"?0x4b2b70:0x205c65);this.drawWeapon(a);if(p.alive){pts.push(p);minX=Math.min(minX,p.x);maxX=Math.max(maxX,p.x);minY=Math.min(minY,p.y);maxY=Math.max(maxY,p.y);}});
  pts.sort((a,b)=>b.kills-a.kills);this.rank.setText(pts.map((p,i)=>(i+1)+". "+p.name+" ⚔"+p.kills+" ♥"+p.lives).join("\n"));
  if(pts.length){const cx=(minX+maxX)/2,cy=(minY+maxY)/2,spread=Math.max(maxX-minX,maxY-minY),z=Phaser.Math.Clamp(1.08-spread/1250,.62,1.05);this.cameras.main.zoom=Phaser.Math.Linear(this.cameras.main.zoom,z,.045);this.cameras.main.pan(cx,cy,.045,"Sine.easeOut");}
  if(s.darkness){this.dark=this.dark||this.add.rectangle(W/2,H/2,W,H,0x000000,.72).setScrollFactor(0).setDepth(70);}else if(this.dark){this.dark.destroy();this.dark=undefined;}
  if(this.intro&&this.connected){this.intro=false;this.tweens.add({targets:this.title,alpha:0,y:60,duration:1400,delay:1100});}
 }
}
new Phaser.Game({type:Phaser.AUTO,parent:"game",width:W,height:H,backgroundColor:"#120d0b",scale:{mode:Phaser.Scale.FIT,autoCenter:Phaser.Scale.CENTER_BOTH},render:{antialias:true},scene:[ArenaScene]});
