import { Client, Room } from "colyseus";
import { ArenaState, PlayerState, Team, Weapon } from "./state.js";

const WIDTH=930, HEIGHT=540, OX=70, OY=100, MAX=10, MATCH=15*60*1000, EVENT=5*60*1000;
const HP: Record<Weapon,number>={sword:5,spear:4,bow:2};
const EVENTS=["ظلام تام","انكماش الساحة","تبديل السلاح","فخ أرضي","مكافأة على القائد","القلب"];
const DEV=process.env.ARENA_DEV==="1";
type Input={up?:boolean;down?:boolean;left?:boolean;right?:boolean};

export class ArenaRoom extends Room<ArenaState> {
  maxClients=MAX; state=new ArenaState();
  private inputs=new Map<string,Input>();
  private timers=new Map<string,ReturnType<typeof setTimeout>>();
  private attacks=new Map<string,number>();
  private votes=new Map<string,number>();
  private joinOrder=new Map<string,number>();
  private seatCounter=0;

  onCreate(){
    this.setPatchRate(50); this.prepareVote();
    this.onMessage("input",(c,p:Input)=>this.inputs.set(c.sessionId,{up:!!p?.up,down:!!p?.down,left:!!p?.left,right:!!p?.right}));
    this.onMessage("attack",c=>this.attack(c));
    this.onMessage("weapon",c=>this.weapon(c));
    this.onMessage("vote",(c,p:{option?:number})=>{const n=Number(p?.option);if(n>=1&&n<=3)this.votes.set(c.sessionId,n);});
    this.setSimulationInterval(d=>this.tick(d),50);
  }

  onJoin(c:Client,o:{name?:string}){
    if(this.state.phase==="finished") this.resetRound();
    const p=new PlayerState(),i=this.state.players.size;
    p.name=String(o?.name||"Player").slice(0,16); p.team=i<5?"A":"B";
    p.x=OX+80+(i%5)*175; p.y=OY+(i<5?95:360);
    p.weapon=(["sword","spear","bow"] as Weapon[])[i%3]; p.maxHp=HP[p.weapon]; p.hp=p.maxHp;
    this.state.players.set(c.sessionId,p); this.inputs.set(c.sessionId,{}); this.joinOrder.set(c.sessionId,this.seatCounter++);
    if(this.state.players.size===MAX || (DEV && this.state.players.size>=1))this.state.phase="playing";
  }

  onLeave(c:Client){
    this.inputs.delete(c.sessionId); this.attacks.delete(c.sessionId); this.joinOrder.delete(c.sessionId);
    const t=this.timers.get(c.sessionId); if(t)clearTimeout(t); this.timers.delete(c.sessionId);
    this.state.players.delete(c.sessionId);
    if(this.state.players.size<MAX && !DEV)this.state.phase="waiting";
  }

  private tick(d:number){
    if(this.state.phase!=="playing")return;
    this.state.remainingMs=Math.max(0,this.state.remainingMs-d);
    this.state.eventRemainingMs=Math.max(0,this.state.eventRemainingMs-d);
    if(this.state.eventRemainingMs<=0){this.event();this.state.eventRemainingMs=EVENT;}

    const bounds=this.getBounds();
    for(const [id,p] of this.state.players){
      if(!p.alive)continue;
      const q=this.inputs.get(id)||{};
      const dx=(q.right?1:0)-(q.left?1:0),dy=(q.down?1:0)-(q.up?1:0),l=Math.hypot(dx,dy)||1,s=.22*d;
      p.x=Math.max(bounds.left+25,Math.min(bounds.right-25,p.x+dx/l*s));
      p.y=Math.max(bounds.top+25,Math.min(bounds.bottom-25,p.y+dy/l*s));
      if(this.state.activeEvent==="فخ أرضي" && Math.hypot(p.x-this.state.trapX,p.y-this.state.trapY)<42 && Math.random()<.035)this.damageTrap(p,id);
      if(this.state.activeEvent==="القلب" && Math.hypot(p.x-this.state.heartX,p.y-this.state.heartY)<30 && !this.state.heartTeam){this.captureHeart(p.team);}
    }
    if(this.state.remainingMs<=0)this.finish();
  }

  private getBounds(){const s=this.state.arenaScale;const mx=(WIDTH*(1-s))/2,my=(HEIGHT*(1-s))/2;return{left:OX+mx,top:OY+my,right:OX+WIDTH-mx,bottom:OY+HEIGHT-my};}

  private attack(c:Client){
    if(this.state.phase!=="playing")return;
    const a=this.state.players.get(c.sessionId); if(!a?.alive)return;
    const now=Date.now(); if(now-(this.attacks.get(c.sessionId)||0)<350)return; this.attacks.set(c.sessionId,now);
    let t:PlayerState|undefined,tid="",best=Infinity;
    for(const [id,p] of this.state.players){
      if(id===c.sessionId||!p.alive||p.team===a.team)continue;
      const d=Math.hypot(p.x-a.x,p.y-a.y),r=a.weapon==="bow"?240:a.weapon==="spear"?85:58;
      if(d<=r&&d<best){best=d;t=p;tid=id;}
    }
    if(!t)return;
    this.broadcast("attack-fx",{x1:a.x,y1:a.y,x2:t.x,y2:t.y,weapon:a.weapon});
    t.hp--; if(t.hp<=0)this.kill(a,t,tid);
  }

  private kill(a:PlayerState,t:PlayerState,tid:string){
    a.kills++; t.lives--; t.alive=false; t.weakened=t.lives<=0;
    this.state.lastKill=`${a.name} أسقط ${t.name}`;
    this.broadcast("kill-fx",{x:t.x,y:t.y,name:t.name});
    const delay=t.lives>0?3000:(t.weakened?180000:300000);
    const timer=setTimeout(()=>{
      if(!this.state.players.has(tid))return;
      if(t.lives<=0)t.lives=1;
      t.maxHp=t.weakened?1:HP[t.weapon]; t.hp=t.maxHp;
      const b=this.getBounds(); t.x=b.left+35+Math.random()*Math.max(1,b.right-b.left-70); t.y=b.top+35+Math.random()*Math.max(1,b.bottom-b.top-70);
      t.alive=true; this.timers.delete(tid);
    },delay);
    this.timers.set(tid,timer);
  }

  private damageTrap(p:PlayerState,id:string){
    p.hp--; this.broadcast("trap-fx",{x:p.x,y:p.y});
    if(p.hp<=0){const killer=[...this.state.players.values()].find(x=>x.team!==p.team&&x.alive); if(killer)this.kill(killer,p,id); else {p.hp=1;}}
  }

  private weapon(c:Client){
    const p=this.state.players.get(c.sessionId); if(!p?.alive)return;
    const w:Weapon[]=["sword","spear","bow"]; p.weapon=w[(w.indexOf(p.weapon)+1)%3];
    p.maxHp=p.weakened?1:HP[p.weapon]; p.hp=Math.min(p.hp,p.maxHp);
  }

  private prepareVote(){
    const pool=[...EVENTS].sort(()=>Math.random()-.5).slice(0,3);
    [this.state.vote1,this.state.vote2,this.state.vote3]=pool;
    this.state.votes1=0;this.state.votes2=0;this.state.votes3=0;this.votes.clear();
  }

  private event(){
    for(const n of this.votes.values()){if(n===1)this.state.votes1++;else if(n===2)this.state.votes2++;else this.state.votes3++;}
    const options=[this.state.vote1,this.state.vote2,this.state.vote3],counts=[this.state.votes1,this.state.votes2,this.state.votes3];
    const winner=counts.indexOf(Math.max(...counts)); const name=options[winner]||EVENTS[this.state.eventIndex%EVENTS.length];
    this.state.eventIndex++; this.state.activeEvent=name; this.state.lastEvent=`الجمهور اختار: ${name}`;
    this.state.darkness=false; this.state.arenaScale=1; this.state.trapX=0; this.state.trapY=0; this.state.bountyId=""; this.state.heartTeam="";
    if(name==="ظلام تام") this.state.darkness=true;
    if(name==="انكماش الساحة") this.state.arenaScale=.68;
    if(name==="فخ أرضي"){this.state.trapX=OX+120+Math.random()*(WIDTH-240);this.state.trapY=OY+90+Math.random()*(HEIGHT-180);}
    if(name==="تبديل السلاح")for(const p of this.state.players.values()){const w:Weapon[]=["sword","spear","bow"];p.weapon=w[(w.indexOf(p.weapon)+1)%3];p.maxHp=p.weakened?1:HP[p.weapon];p.hp=Math.min(p.hp,p.maxHp);}
    if(name==="مكافأة على القائد"){
      const leader=[...this.state.players.values()].sort((a,b)=>b.kills-a.kills)[0]; if(leader)this.state.bountyId=[...this.state.players.entries()].find(([,p])=>p===leader)?.[0]||"";
    }
    if(name==="القلب"){this.state.heartX=OX+WIDTH/2;this.state.heartY=OY+HEIGHT/2;}
    this.prepareVote();
  }

  private captureHeart(team:Team){
    this.state.heartTeam=team;
    for(const p of this.state.players.values())if(p.team===team){p.lives+=3;p.weakened=false;p.maxHp=HP[p.weapon];p.hp=p.maxHp;}
    this.state.lastEvent=`الفريق ${team} استولى على القلب +3 حياة لكل لاعب`;
  }

  private resetRound(){
    this.state.remainingMs=MATCH; this.state.eventRemainingMs=EVENT; this.state.phase="waiting";
    this.state.activeEvent=""; this.state.lastKill=""; this.state.lastEvent="";
    this.state.darkness=false; this.state.arenaScale=1; this.state.heartTeam=""; this.state.bountyId="";
    this.prepareVote();
  }

  private finish(){
    if(this.state.phase==="finished")return;
    this.state.phase="finished";
    const players=[...this.state.players.entries()];
    const sorted=players.sort((a,b)=>b[1].kills-a[1].kills || (this.joinOrder.get(a[0])||0)-(this.joinOrder.get(b[0])||0));
    const topTwo=sorted.slice(0,2);
    const leaders=topTwo.length===2 && topTwo[0][1].team===topTwo[1][1].team && topTwo[0][1].kills-(sorted.find(x=>x[1].team!==topTwo[0][1].team)?.[1].kills??0)<2
      ? [topTwo[0]]
      : topTwo;
    const leaderIds=new Set(leaders.map(([id])=>id));
    this.broadcast("round-result",leaders.map(([,p])=>({name:p.name,team:p.team,kills:p.kills})));
    for(const [id,p] of players)if(!leaderIds.has(id)){const c=this.clients.find(x=>x.sessionId===id);c?.leave(4000);p.alive=false;}
    if(leaders.length){setTimeout(()=>{this.state.players.forEach((p,id)=>{if(!leaderIds.has(id))return;p.kills=0;p.lives=2;p.weakened=false;p.maxHp=HP[p.weapon];p.hp=p.maxHp;p.alive=true;});this.resetRound();if(this.state.players.size===MAX||(DEV&&this.state.players.size>=1))this.state.phase="playing";},1500);}
  }
}
