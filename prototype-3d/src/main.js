import * as THREE from 'three';
import './style.css';
import { addCastleDetail, detailEnemy } from './visuals.js';

const app = document.querySelector('#app');
app.innerHTML = `
  <div id="hud"><div class="brand">⚔ ARENA STREAM <small>3D COMBAT PROTOTYPE</small></div>
    <div class="meters"><label>HEALTH <b id="hp">100</b></label><div class="meter"><i id="hpbar"></i></div>
    <label>STAMINA <b id="st">100</b></label><div class="meter stamina"><i id="stbar"></i></div></div>
    <div id="stats">KILLS <b id="kills">0</b> · ENEMY <b id="enemyhp">100</b></div></div>
  <div id="crosshair">+</div><div id="flash"></div><div id="message">انقر داخل اللعبة لتحريك الكاميرا · WASD للحركة · انقر للهجوم</div>
  <div id="mobile"><div id="pad"><div id="knob"></div></div><button id="attack" aria-label="Attack">⚔<span>هجوم</span></button></div>
  <div id="gameover" hidden><h1>انتهت المحاولة</h1><p>عدد الأعداء: <b id="finalkills">0</b></p><button id="restart">إعادة اللعب</button></div>`;
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x9ba9ae);
scene.fog = new THREE.Fog(0x9ba9ae, 30, 105);
const camera = new THREE.PerspectiveCamera(76, 1, .08, 140);
const renderer = new THREE.WebGLRenderer({ antialias: true, powerPreference: 'high-performance' });
renderer.setPixelRatio(Math.min(devicePixelRatio, 1.6));
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.outputColorSpace = THREE.SRGBColorSpace;
app.prepend(renderer.domElement);
scene.add(new THREE.HemisphereLight(0xc5e0ff, 0x5a4936, 2.1));
const sun = new THREE.DirectionalLight(0xffe2ac, 2.3);
sun.position.set(-15, 27, 12); sun.castShadow = true; sun.shadow.mapSize.set(1024, 1024);
sun.shadow.camera.left = -38; sun.shadow.camera.right = 38; sun.shadow.camera.top = 38; sun.shadow.camera.bottom = -38;
scene.add(sun);
const mat = (color, roughness=1) => new THREE.MeshStandardMaterial({color,roughness});
const stone=mat(0x77756e), darkStone=mat(0x575650), groundMat=mat(0x857a65), wood=mat(0x473427), iron=mat(0x454b50,.55), gold=mat(0xb89a54,.5);
function block(w,h,d,x,y,z,m=stone,shadow=true) {
  const mesh=new THREE.Mesh(new THREE.BoxGeometry(w,h,d),m);
  mesh.position.set(x,y,z);mesh.castShadow=shadow;mesh.receiveShadow=true;scene.add(mesh);return mesh;
}
block(68,.5,68,0,-.3,0,groundMat,false);
for(let i=-31;i<=31;i+=4) for(let j=-31;j<=31;j+=4) {
  if(Math.random()>.35)block(3.7,.035,3.7,i,.005,j,mat(Math.random()>.5?0x918773:0x796f5f),false);
}
for(const x of [-32,32]) {block(3,10,68,x,5,0);for(let z=-32;z<=32;z+=5)block(3,2,2.7,x,11,z,darkStone);}
for(const z of [-32,32]) {block(68,10,3,0,5,z);for(let x=-32;x<=32;x+=5)block(2.7,2,3,x,11,z,darkStone);}
for(const x of [-30,30])for(const z of [-30,30]) {
  block(6,13,6,x,6.5,z,darkStone);block(7,1.2,7,x,13.4,z,stone);
}
block(14,8,3,0,4,-31,wood);block(15,1,3,0,8.6,-31,iron);
for(let x=-5;x<=5;x+=2)block(.15,7,.25,x,4,-29.4,iron);
function banner(x,z,rotation=0){
  const pole=block(.18,6,.18,x,5,z,wood);
  const cloth=block(2.6,3,.09,x+1.3,5.8,z,mat(0x403e36));
  cloth.rotation.y=rotation;
  const label=block(2.1,.55,.11,x+1.3,5.7,z+.08,mat(0xbca46e));
  label.rotation.y=rotation;
  return {pole,cloth,label};
}
banner(-12,-28);banner(10,-28);
for(const x of [-19,19])for(const z of [-17,5,21]) {
  block(2.6,2.3,2.6,x,1.15,z,wood);
  block(2.9,.2,2.9,x,2.35,z,darkStone);
}
const player={pos:new THREE.Vector3(0,1.7,19),yaw:0,pitch:0,hp:100,stamina:100,kills:0,alive:true};
camera.rotation.order='YXZ';
const sword=new THREE.Group();
const blade=new THREE.Mesh(new THREE.BoxGeometry(.13,1.25,.16),mat(0xc3cbd0,.25));
blade.position.set(0,.75,0);sword.add(blade);
const tip=new THREE.Mesh(new THREE.ConeGeometry(.095,.28,4),mat(0xd4dbe0,.25));
tip.position.set(0,1.52,0);tip.rotation.y=Math.PI/4;sword.add(tip);
const guard=new THREE.Mesh(new THREE.BoxGeometry(.68,.11,.17),gold);guard.position.y=.12;sword.add(guard);
const handle=new THREE.Mesh(new THREE.CylinderGeometry(.06,.07,.5,8),wood);handle.position.y=-.16;sword.add(handle);
sword.position.set(.58,-.68,-.8);sword.rotation.set(-.15,0,-.2);camera.add(sword);scene.add(camera);
const enemy=new THREE.Group();
function enemyPart(w,h,d,y,m,x=0,z=0){const o=new THREE.Mesh(new THREE.BoxGeometry(w,h,d),m);o.position.set(x,y,z);o.castShadow=true;enemy.add(o);}
enemyPart(.9,1.05,.48,1.25,iron);enemyPart(.65,.58,.62,2.12,darkStone);
enemyPart(.33,.8,.36,.4,darkStone,-.27);enemyPart(.33,.8,.36,.4,darkStone,.27);
enemyPart(.3,.8,.35,1.34,darkStone,-.65);enemyPart(.3,.8,.35,1.34,darkStone,.65);
enemyPart(.8,.14,.2,1.85,gold);enemyPart(.12,1.5,.12,1.1,mat(0xb5b8b5),.95,.1);
detailEnemy(enemy);
scene.add(enemy);
const visualDetails = addCastleDetail(scene, { mobile: matchMedia('(pointer: coarse)').matches });
let enemyHp=100,enemyAlive=true,enemyAttackTimer=0,respawnTimer=0,attackTimer=0,swing=0,damageFlash=0;
function spawnEnemy(){enemy.position.set((Math.random()-.5)*16,0,-10-Math.random()*9);enemyHp=100;enemyAlive=true;enemy.visible=true;enemyAttackTimer=0;document.querySelector('#enemyhp').textContent=100;}
spawnEnemy();
const keys=new Set();let moveX=0,moveY=0,lookTouch=null,padTouch=null,padOrigin=null;
const mobile=matchMedia('(pointer: coarse)').matches;
if(mobile){document.querySelector('#mobile').style.display='block';document.querySelector('#message').textContent='اسحب يسار الشاشة للحركة ويمينها للنظر';}
addEventListener('keydown',e=>{keys.add(e.code);if(['Space','ArrowUp','ArrowDown','ArrowLeft','ArrowRight'].includes(e.code))e.preventDefault();});
addEventListener('keyup',e=>keys.delete(e.code));
renderer.domElement.addEventListener('click',()=>{if(!mobile && player.alive && document.pointerLockElement!==renderer.domElement)renderer.domElement.requestPointerLock();else if(player.alive)attack();});
addEventListener('mousemove',e=>{if(document.pointerLockElement===renderer.domElement)look(e.movementX,e.movementY);});
function look(dx,dy){player.yaw-=dx*.0025;player.pitch=THREE.MathUtils.clamp(player.pitch-dy*.0025,-1.35,1.35);}
function attack(){
 if(!player.alive||attackTimer>0||player.stamina<18)return;
 attackTimer=.48;swing=1;player.stamina-=18;
 if(enemyAlive){
  const toEnemy=enemy.position.clone().sub(player.pos);toEnemy.y=0;
  const forward=new THREE.Vector3(-Math.sin(player.yaw),0,-Math.cos(player.yaw));
  if(toEnemy.length()<3.2&&forward.dot(toEnemy.normalize())>.48){
   enemyHp=Math.max(0,enemyHp-34);document.querySelector('#enemyhp').textContent=enemyHp;
   enemy.children.forEach(c=>{if(c.material.emissive)c.material.emissive.setHex(0x772020);});
   setTimeout(()=>enemy.children.forEach(c=>{if(c.material.emissive)c.material.emissive.setHex(0x000000);}),140);
   if(enemyHp===0){enemyAlive=false;enemy.visible=false;respawnTimer=2;player.kills++;document.querySelector('#kills').textContent=player.kills;}
  }
 }
}
document.querySelector('#attack').addEventListener('pointerdown',e=>{e.preventDefault();attack();});
const pad=document.querySelector('#pad'),knob=document.querySelector('#knob');
pad.addEventListener('pointerdown',e=>{padTouch=e.pointerId;pad.setPointerCapture(e.pointerId);padOrigin={x:e.clientX,y:e.clientY};});
pad.addEventListener('pointermove',e=>{if(e.pointerId!==padTouch)return;moveX=THREE.MathUtils.clamp((e.clientX-padOrigin.x)/48,-1,1);moveY=THREE.MathUtils.clamp((e.clientY-padOrigin.y)/48,-1,1);knob.style.transform=`translate(${moveX*38}px,${moveY*38}px)`;});
function clearPad(e){if(e.pointerId===padTouch){padTouch=null;moveX=moveY=0;knob.style.transform='';}}
pad.addEventListener('pointerup',clearPad);pad.addEventListener('pointercancel',clearPad);
renderer.domElement.addEventListener('pointerdown',e=>{if(mobile&&e.clientX>innerWidth*.38){lookTouch={id:e.pointerId,x:e.clientX,y:e.clientY};renderer.domElement.setPointerCapture(e.pointerId);}});
renderer.domElement.addEventListener('pointermove',e=>{if(lookTouch?.id===e.pointerId){look(e.clientX-lookTouch.x,e.clientY-lookTouch.y);lookTouch.x=e.clientX;lookTouch.y=e.clientY;}});
renderer.domElement.addEventListener('pointerup',e=>{if(lookTouch?.id===e.pointerId)lookTouch=null;});
document.querySelector('#restart').onclick=()=>{player.pos.set(0,1.7,19);player.hp=100;player.stamina=100;player.kills=0;player.alive=true;document.querySelector('#kills').textContent=0;document.querySelector('#gameover').hidden=true;spawnEnemy();};
function updateUI(){
 document.querySelector('#hp').textContent=Math.ceil(player.hp);
 document.querySelector('#st').textContent=Math.ceil(player.stamina);
 document.querySelector('#hpbar').style.width=player.hp+'%';
 document.querySelector('#stbar').style.width=player.stamina+'%';
 document.querySelector('#flash').style.opacity=damageFlash;
}
const clock=new THREE.Clock();
function frame(){
 requestAnimationFrame(frame);
 const dt=Math.min(clock.getDelta(),.05);
 if(player.alive){
  const x=(keys.has('KeyD')?1:0)-(keys.has('KeyA')?1:0)+moveX;
  const z=(keys.has('KeyS')?1:0)-(keys.has('KeyW')?1:0)+moveY;
  const v=new THREE.Vector3(x,0,z);
  if(v.lengthSq()>1)v.normalize();
  const sprint=keys.has('ShiftLeft')&&player.stamina>2&&v.lengthSq()>.01;
  if(sprint)player.stamina=Math.max(0,player.stamina-dt*18);
  else player.stamina=Math.min(100,player.stamina+dt*13);
  v.applyAxisAngle(new THREE.Vector3(0,1,0),player.yaw);
  player.pos.addScaledVector(v,dt*(sprint?8:5));
  player.pos.x=THREE.MathUtils.clamp(player.pos.x,-29,29);
  player.pos.z=THREE.MathUtils.clamp(player.pos.z,-29,29);
  camera.position.copy(player.pos);
  camera.rotation.set(player.pitch,player.yaw,0);
  attackTimer=Math.max(0,attackTimer-dt);
  swing=Math.max(0,swing-dt*3);
  sword.rotation.z=-.2-swing*1.35;sword.rotation.x=-.15-swing*.8;
  if(enemyAlive){
   const delta=player.pos.clone().sub(enemy.position);delta.y=0;
   const distance=delta.length();
   enemy.rotation.y=Math.atan2(delta.x,delta.z);
   if(distance>1.65){enemy.position.addScaledVector(delta.normalize(),dt*2.1);}
   else {enemyAttackTimer-=dt;if(enemyAttackTimer<=0){enemyAttackTimer=1.35;player.hp=Math.max(0,player.hp-12);damageFlash=.6;if(player.hp===0){player.alive=false;document.exitPointerLock?.();document.querySelector('#finalkills').textContent=player.kills;document.querySelector('#gameover').hidden=false;}}}
  } else {respawnTimer-=dt;if(respawnTimer<=0)spawnEnemy();}
 }
 damageFlash=Math.max(0,damageFlash-dt*1.7);updateUI();
 visualDetails.update(clock.elapsedTime);
 renderer.render(scene,camera);
}
function resize(){renderer.setSize(innerWidth,innerHeight);camera.aspect=innerWidth/innerHeight;camera.updateProjectionMatrix();}
addEventListener('resize',resize);resize();frame();
