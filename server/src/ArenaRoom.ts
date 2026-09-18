import { Client, Room } from "colyseus";
import { ArenaState, PlayerState, Team, Weapon } from "./state.js";
const WIDTH=930, HEIGHT=540, OX=70, OY=100, MAX=10, MATCH=15*60*1000, EVENT=5*60*1000;
const HP: Record<Weapon,number>={sword:5,spear:4,bow:2};
const EVENTS=["ظلام تام","انكماش الساحة","تبديل السلاح","فخ أرضي","مكافأة على القائد","القلب"];
type Input={up?:boolean;down?:boolean;left?:boolean;right?:boolean};
export class ArenaRoom extends Room<ArenaState> {
 maxClients=MAX; state=new ArenaState();
 private inputs=new Map<string,Input>(); private timers=new Map<string,ReturnType<typeof setTimeout>>(); private attacks=new Map<string,number>(); private votes=new Map<string,number>();
 onCreate(){
  this.setPatchRate(50);
  this.prepareVote();
  this.onMessage("input",(c,p:Input)=>this.inputs.set(c.sessionId,{up:!!p?.up,down:!!p?.down,left:!!p?.left,right:!!p?.right}));
  this.onMessage("attack",c=>this.attack(c)); this.onMessage("weapon",c=>this.weapon(c));
  this.onMessage("vote",(c,p:{option?:number})=>{const n=Number(p?.option);if(n>=1&&n<=3)this.votes.set(c.sessionId,n);});
  this.setSimulationInterval(d=>this.tick(d),50);
 }
 onJoin(c:Client,o:{name?:string}){
  const p=new PlayerState(),i=this.state.players.size; p.name=String(o?.name||"Player").slice(0,16); p.team=i<5?"A":"B";
  p.x=OX+80+(i%5)*175; p.y=OY+(i<5?95:360); p.weapon=(["sword","spear","bow"] as Weapon[])[i%3]; p.maxHp=HP[p.weapon]; p.hp=p.maxHp;
  this.state.players.set(c.sessionId,p); this.inputs.set(c.sessionId,{}); if(this.state.players.size===MAX)this.state.phase="playing";
 }
 onLeave(c:Client){this.inputs.delete(c.sessionId);this.attacks.delete(c.sessionId);const t=this.timers.get(c.sessionId);if(t)clearTimeout(t);this.timers.delete(c.sessionId);this.state.players.delete(c.sessionId);if(this.state.players.size<MAX)this.state.phase="waiting";}
 private tick(d:number){
  if(this.state.phase!=="playing")return; this.state.remainingMs=Math.max(0,this.state.remainingMs-d);this.state.eventRemainingMs=Math.max(0,this.state.eventRemainingMs-d);
  if(this.state.eventRemainingMs<=0){this.event();this.state.eventRemainingMs=EVENT;}
  for(const [id,p] of this.state.players){if(!p.alive)continue;const q=this.inputs.get(id)||{};const dx=(q.right?1:0)-(q.left?1:0),dy=(q.down?1:0)-(q.up?1:0),l=Math.hypot(dx,dy)||1,s=.22*d;p.x=Math.max(OX+25,Math.min(OX+WIDTH-25,p.x+dx/l*s));p.y=Math.max(OY+25,Math.min(OY+HEIGHT-25,p.y+dy/l*s));}
  if(this.state.remainingMs<=0)this.finish();
 }
 private attack(c:Client){
  if(this.state.phase!=="playing")return;const a=this.state.players.get(c.sessionId);if(!a?.alive)return;const now=Date.now();if(now-(this.attacks.get(c.sessionId)||0)<350)return;this.attacks.set(c.sessionId,now);
  let t:PlayerState|undefined,tid="",best=Infinity;for(const [id,p] of this.state.players){if(id===c.sessionId||!p.alive||p.team===a.team)continue;const d=Math.hypot(p.x-a.x,p.y-a.y),r=a.weapon==="bow"?240:a.weapon==="spear"?85:58;if(d<=r&&d<best){best=d;t=p;tid=id;}}
  if(!t)return;t.hp--;if(t.hp<=0)this.kill(a,t,tid);
 }
 private kill(a:PlayerState,t:PlayerState,tid:string){a.kills++;t.lives--;t.alive=false;t.weakened=t.lives<=0;this.state.lastKill=`${a.name} أسقط ${t.name}`;const delay=t.lives>0?3000:180000;
  const timer=setTimeout(()=>{if(!this.state.players.has(tid))return;if(t.lives<=0)t.lives=1;t.maxHp=t.weakened?1:HP[t.weapon];t.hp=t.maxHp;t.x=OX+35+Math.random()*(WIDTH-70);t.y=OY+35+Math.random()*(HEIGHT-70);t.alive=true;this.timers.delete(tid);},delay);this.timers.set(tid,timer);
 }
 private weapon(c:Client){const p=this.state.players.get(c.sessionId);if(!p?.alive)return;const w:Weapon[]=["sword","spear","bow"];p.weapon=w[(w.indexOf(p.weapon)+1)%3];p.maxHp=p.weakened?1:HP[p.weapon];p.hp=Math.min(p.hp,p.maxHp);}
 private prepareVote(){
  const pool=[...EVENTS].sort(()=>Math.random()-.5).slice(0,3);
  [this.state.vote1,this.state.vote2,this.state.vote3]=pool;
  this.state.votes1=0;this.state.votes2=0;this.state.votes3=0;this.votes.clear();
}

 private event(){
  for(const n of this.votes.values()){if(n===1)this.state.votes1++;else if(n===2)this.state.votes2++;else this.state.votes3++;}
  const options=[this.state.vote1,this.state.vote2,this.state.vote3];const counts=[this.state.votes1,this.state.votes2,this.state.votes3];
  const winner=counts.indexOf(Math.max(...counts));
  const name=options[winner]||EVENTS[this.state.eventIndex%EVENTS.length];this.state.eventIndex++;this.state.activeEvent=name;this.state.lastEvent=`الجمهور اختار: ${name}`;
  if(name==="تبديل السلاح")for(const p of this.state.players.values()){const w:Weapon[]=["sword","spear","bow"];p.weapon=w[(w.indexOf(p.weapon)+1)%3];p.maxHp=p.weakened?1:HP[p.weapon];p.hp=Math.min(p.hp,p.maxHp);}
  this.prepareVote();
  if(name==="القلب"){const total={A:0,B:0};for(const p of this.state.players.values())total[p.team]+=p.kills;const win:Team=total.A>=total.B?"A":"B";for(const p of this.state.players.values())if(p.team===win){p.lives+=3;p.weakened=false;p.maxHp=HP[p.weapon];p.hp=p.maxHp;}}
 }
 private finish(){this.state.phase="finished";const top=[...this.state.players.values()].sort((a,b)=>b.kills-a.kills).slice(0,2);this.broadcast("round-result",top.map(p=>({name:p.name,team:p.team,kills:p.kills})));}
}
