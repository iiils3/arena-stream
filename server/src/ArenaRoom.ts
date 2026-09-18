import { Client, Room } from "colyseus";
import { ArenaState, PlayerState, WeaponPickup, Team, Weapon, Gender } from "./state.js";

const WIDTH=1800, HEIGHT=900, MAX=8, MATCH=15*60*1000, EVENT=5*60*1000;
const HP:Record<Weapon,number>={sword:5,spear:4,bow:2};
const EVENTS=["ظلام تام","انكماش الساحة","تبديل السلاح","فخ أرضي","مكافأة على القائد","القلب"];
const DEV=process.env.ARENA_DEV==="1";
type Input={up?:boolean;down?:boolean;left?:boolean;right?:boolean};
const clamp=(n:number,a:number,b:number)=>Math.max(a,Math.min(b,n));

export class ArenaRoom extends Room<ArenaState>{
 maxClients=MAX; state=new ArenaState();
 private inputs=new Map<string,Input>(); private timers=new Map<string,ReturnType<typeof setTimeout>>();
 private attacks=new Map<string,number>(); private outsideSince=new Map<string,number>(); private idleSince=new Map<string,number>(); private lastPos=new Map<string,{x:number;y:number}>(); private votes=new Map<string,number>(); private joinOrder=new Map<string,number>(); private seatCounter=0;

 onCreate(){
  this.setPatchRate(50); this.prepareVote(); this.state.arenaX=120;this.state.arenaY=110;this.state.arenaW=1560;this.state.arenaH=680;
  this.onMessage("input",(c,p:Input)=>this.inputs.set(c.sessionId,{up:!!p?.up,down:!!p?.down,left:!!p?.left,right:!!p?.right}));
  this.onMessage("attack",c=>this.attack(c));
  this.onMessage("weapon",c=>this.weapon(c));
  this.onMessage("vote",(c,p:{option?:number})=>{const n=Number(p?.option);if(n>=1&&n<=3)this.votes.set(c.sessionId,n);});
  this.onMessage("pickup",c=>this.pickup(c));
  this.setSimulationInterval(d=>this.tick(d),50);
 }
 onJoin(c:Client,o:{name?:string}){
  if(this.state.phase==="finished")this.resetRound();
  const p=new PlayerState(),i=this.state.players.size;
  p.name=String(o?.name||"Player").slice(0,16);p.team=i<4?"A":"B";p.gender=(i%4===0||i%4===1)?"female":"male";
  const teamIndex=i%4;p.x=p.team==="A"?280+teamIndex*110:1520-teamIndex*110;p.y=450+(teamIndex%2?100:-100);
  p.facing=p.team==="A"?1:-1;p.weapon="bow";p.maxHp=HP[p.weapon];p.hp=p.maxHp;p.finalLife=false;
  this.state.players.set(c.sessionId,p);this.inputs.set(c.sessionId,{});this.joinOrder.set(c.sessionId,this.seatCounter++);
  if(this.state.players.size===MAX||(DEV&&this.state.players.size>=1)){this.spawnLoot();this.state.phase="playing";}
 }
 onLeave(c:Client){this.inputs.delete(c.sessionId);this.attacks.delete(c.sessionId);this.outsideSince.delete(c.sessionId);this.idleSince.delete(c.sessionId);this.lastPos.delete(c.sessionId);this.joinOrder.delete(c.sessionId);const t=this.timers.get(c.sessionId);if(t)clearTimeout(t);this.timers.delete(c.sessionId);this.state.players.delete(c.sessionId);if(this.state.players.size<MAX&&!DEV)this.state.phase="waiting";}
 private tick(d:number){
  if(this.state.phase!=="playing")return;
  this.state.remainingMs=Math.max(0,this.state.remainingMs-d);this.state.eventRemainingMs=Math.max(0,this.state.eventRemainingMs-d);
  if(this.state.eventRemainingMs<=0){this.event();this.state.eventRemainingMs=EVENT;}
  const b=this.bounds();
  for(const [id,p] of this.state.players){
   if(!p.alive)continue;const q=this.inputs.get(id)||{},dx=(q.right?1:0)-(q.left?1:0),dy=(q.down?1:0)-(q.up?1:0),l=Math.hypot(dx,dy)||1,s=.30*d;
   if(dx)p.facing=dx>0?1:-1;p.x=clamp(p.x+dx/l*s,b.left,b.right);p.y=clamp(p.y+dy/l*s,b.top,b.bottom);const prev=this.lastPos.get(id);if(prev&&Math.hypot(p.x-prev.x,p.y-prev.y)<1){this.idleSince.set(id,this.idleSince.get(id)||Date.now());}else{this.idleSince.delete(id);this.lastPos.set(id,{x:p.x,y:p.y});}const zone={left:375,right:1425,top:170,bottom:730};const outside=p.x<zone.left||p.x>zone.right||p.y<zone.top||p.y>zone.bottom;if(outside||this.idleSince.has(id)){const map=outside?this.outsideSince:this.idleSince;const since=map.get(id)||Date.now();map.set(id,since);if(Date.now()-since>=30000){p.hp=Math.max(1,p.hp-1);this.broadcast("hawk-fx",{x:p.x,y:p.y});map.set(id,Date.now());}}
   if(this.state.activeEvent==="فخ أرضي"&&Math.hypot(p.x-this.state.trapX,p.y-this.state.trapY)<50&&Math.random()<.035)this.damageTrap(p,id);
   for(const [pid,it] of this.state.pickups){if(!it.active||it.team!==p.team)continue;if(Math.hypot(p.x-it.x,p.y-it.y)<55){it.active=false;p.weapon=it.weapon;p.maxHp=p.weakened?1:HP[p.weapon];p.hp=Math.min(p.hp,p.maxHp);this.broadcast("pickup-fx",{x:it.x,y:it.y,weapon:it.weapon});}}
  }
  if(this.state.remainingMs<=0)this.finish();
 }
 private bounds(){const s=this.state.arenaScale;const w=this.state.arenaW*s,h=this.state.arenaH*s;return{left:this.state.arenaX+(this.state.arenaW-w)/2+35,top:this.state.arenaY+(this.state.arenaH-h)/2+35,right:this.state.arenaX+(this.state.arenaW+w)/2-35,bottom:this.state.arenaY+(this.state.arenaH+h)/2-35};}
 private attack(c:Client){
  if(this.state.phase!=="playing")return;const a=this.state.players.get(c.sessionId);if(!a?.alive)return;const now=Date.now();if(now-(this.attacks.get(c.sessionId)||0)<380)return;this.attacks.set(c.sessionId,now);
  let t:PlayerState|undefined,tid="",best=Infinity;
  for(const [id,p] of this.state.players){if(id===c.sessionId||!p.alive||p.team===a.team)continue;const dx=p.x-a.x,dy=p.y-a.y,dist=Math.hypot(dx,dy),range=a.weapon==="bow"?430:a.weapon==="spear"?125:90;const front=dx*a.facing>=-15;if(dist<=range&&front&&dist<best){best=dist;t=p;tid=id;}}
  if(!t)return;this.broadcast("attack-fx",{x1:a.x,y1:a.y,x2:t.x,y2:t.y,weapon:a.weapon});t.hp--;if(t.hp<=0)this.kill(a,t,tid);
 }
 private kill(a:PlayerState,t:PlayerState,tid:string){
  a.kills++;t.lives--;t.alive=false;t.weakened=t.lives<=0;this.state.lastKill=`${a.name} أسقط ${t.name}`;this.broadcast("kill-fx",{x:t.x,y:t.y,name:t.name});
  const delay=t.lives>0?3000:(t.finalLife?300000:180000);
  const timer=setTimeout(()=>{if(!this.state.players.has(tid))return;if(t.lives<=0){t.lives=1;t.finalLife=true;t.weakened=true;}t.maxHp=t.finalLife?1:HP[t.weapon];t.hp=t.maxHp;const b=this.bounds();t.x=b.left+Math.random()*(b.right-b.left);t.y=b.top+Math.random()*(b.bottom-b.top);t.alive=true;this.timers.delete(tid);},delay);
  this.timers.set(tid,timer);
 }
 private damageTrap(p:PlayerState,id:string){p.hp--;this.broadcast("trap-fx",{x:p.x,y:p.y});if(p.hp<=0){const k=[...this.state.players.values()].find(x=>x.team!==p.team&&x.alive);if(k)this.kill(k,p,id);else p.hp=1;}}
 private weapon(c:Client){const p=this.state.players.get(c.sessionId);if(!p?.alive)return;const w:Weapon[]=["sword","spear","bow"];p.weapon=w[(w.indexOf(p.weapon)+1)%3];p.maxHp=p.weakened?1:HP[p.weapon];p.hp=Math.min(p.hp,p.maxHp);}
 private pickup(c:Client){const p=this.state.players.get(c.sessionId);if(!p?.alive)return;let best:WeaponPickup|undefined;let bid="";for(const [id,it] of this.state.pickups){if(it.active&&it.team===p.team&&Math.hypot(p.x-it.x,p.y-it.y)<80){best=it;bid=id;break;}}if(best){best.active=false;p.weapon=best.weapon;p.maxHp=p.weakened?1:HP[p.weapon];p.hp=p.maxHp;this.broadcast("pickup-fx",{x:best.x,y:best.y,weapon:best.weapon});}}
 private spawnLoot(){this.state.pickups.clear();const weapons:Weapon[]=["sword","sword","spear","spear","bow","bow","bow","bow"];for(const team of ["A","B"] as Team[]){weapons.forEach((w,i)=>{const it=new WeaponPickup();it.weapon=w;it.team=team;const side=team==="A"?1:-1;it.x=900+side*(220+(i%4)*85);it.y=270+Math.floor(i/4)*330+(i%2?55:0);this.state.pickups.set(`${team}-${i}`,it);});}}
 private prepareVote(){const pool=[...EVENTS].sort(()=>Math.random()-.5).slice(0,3);[this.state.vote1,this.state.vote2,this.state.vote3]=pool;this.state.votes1=0;this.state.votes2=0;this.state.votes3=0;this.votes.clear();}
 private event(){for(const n of this.votes.values()){if(n===1)this.state.votes1++;else if(n===2)this.state.votes2++;else this.state.votes3++;}const options=[this.state.vote1,this.state.vote2,this.state.vote3],counts=[this.state.votes1,this.state.votes2,this.state.votes3],name=options[counts.indexOf(Math.max(...counts))]||EVENTS[this.state.eventIndex%EVENTS.length];this.state.eventIndex++;this.state.activeEvent=name;this.state.lastEvent=`الجمهور اختار: ${name}`;this.state.darkness=false;this.state.arenaScale=1;this.state.trapX=0;this.state.trapY=0;this.state.bountyId="";this.state.heartTeam="";if(name==="ظلام تام")this.state.darkness=true;if(name==="انكماش الساحة")this.state.arenaScale=.68;if(name==="فخ أرضي"){this.state.trapX=900;this.state.trapY=450;}if(name==="تبديل السلاح")for(const p of this.state.players.values()){const w:Weapon[]=["sword","spear","bow"];p.weapon=w[(w.indexOf(p.weapon)+1)%3];p.maxHp=p.weakened?1:HP[p.weapon];p.hp=Math.min(p.hp,p.maxHp);}if(name==="مكافأة على القائد"){const leader=[...this.state.players.values()].sort((a,b)=>b.kills-a.kills)[0];if(leader)this.state.bountyId=[...this.state.players.entries()].find(([,p])=>p===leader)?.[0]||"";}if(name==="القلب"){this.state.heartX=900;this.state.heartY=450;}this.prepareVote();}
 private resetRound(){this.state.remainingMs=MATCH;this.state.eventRemainingMs=EVENT;this.state.phase="waiting";this.state.activeEvent="";this.state.lastKill="";this.state.lastEvent="";this.state.darkness=false;this.state.arenaScale=1;this.state.heartTeam="";this.state.bountyId="";this.spawnLoot();this.prepareVote();}
 private finish(){if(this.state.phase==="finished")return;this.state.phase="finished";const players=[...this.state.players.entries()];const sorted=[...players].sort((a,b)=>b[1].kills-a[1].kills||(this.joinOrder.get(a[0])||0)-(this.joinOrder.get(b[0])||0));const teamA=sorted.filter(([,p])=>p.team==="A"),teamB=sorted.filter(([,p])=>p.team==="B");const bestA=teamA[0],bestB=teamB[0];let leaders=[bestA,bestB].filter(Boolean);const top2=sorted.slice(0,2);if(top2.length===2&&top2[0][1].team===top2[1][1].team){const other=top2[0][1].team==="A"?bestB:bestA;if(top2[1][1].kills-(other?.[1].kills??0)>=2)leaders=top2;}const ids=new Set(leaders.map(([id])=>id));this.broadcast("round-result",leaders.map(([,p])=>({name:p.name,team:p.team,kills:p.kills})));for(const [id] of players)if(!ids.has(id)){const c=this.clients.find(x=>x.sessionId===id);c?.leave(4000);}setTimeout(()=>{this.state.players.forEach((p,id)=>{if(!ids.has(id))return;p.kills=0;p.lives=2;p.weakened=false;p.finalLife=false;p.maxHp=HP[p.weapon];p.hp=p.maxHp;p.alive=true;});this.resetRound();if(this.state.players.size===MAX||(DEV&&this.state.players.size>=1))this.state.phase="playing";},1500);}
}