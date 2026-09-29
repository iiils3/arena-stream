import * as THREE from 'three';

// Geometry-only art pass: no paid assets, no brand artwork, no external requests.
// Decorative pieces are kept separate from gameplay collisions for this prototype.
export function addCastleDetail(scene, { mobile = false } = {}) {
  const stone = new THREE.MeshStandardMaterial({color:0xaaa092,roughness:.98});
  const mortar = new THREE.MeshStandardMaterial({color:0x575149,roughness:1});
  const trim = new THREE.MeshStandardMaterial({color:0x6c6258,roughness:.95});
  const brass = new THREE.MeshStandardMaterial({color:0xc39a53,metalness:.62,roughness:.35});
  const iron = new THREE.MeshStandardMaterial({color:0x252b30,metalness:.72,roughness:.42});
  const red = new THREE.MeshStandardMaterial({color:0x852c29,side:THREE.DoubleSide,roughness:.93});
  const fire = new THREE.MeshBasicMaterial({color:0xffa53a});
  const stoneGeo = new THREE.BoxGeometry(1,1,1);
  function cube(x,y,z,w,h,d,material,cast=false) {
    const mesh=new THREE.Mesh(stoneGeo,material);
    mesh.position.set(x,y,z);mesh.scale.set(w,h,d);mesh.castShadow=cast;mesh.receiveShadow=true;
    scene.add(mesh);return mesh;
  }
  // Instanced stone courses add masonry depth without one draw call per brick.
  const brickCount=mobile?700:1250;
  const bricks=new THREE.InstancedMesh(stoneGeo,stone,brickCount);
  const matrix=new THREE.Matrix4(),position=new THREE.Vector3(),scale=new THREE.Vector3(),rotation=new THREE.Quaternion();
  let index=0;
  const brick=(x,y,z,w,h,d)=>{
    if(index>=brickCount)return;
    position.set(x,y,z);scale.set(w,h,d);
    matrix.compose(position,rotation,scale);bricks.setMatrixAt(index++,matrix);
  };
  for(const side of [-1,1]){
    for(let course=0;course<8;course++){
      const y=.48+course*1.12,shift=course%2?1.35:0;
      for(let t=-30;t<30;t+=2.8){
        brick(side*33.58,y,t+shift, .18,1.03,2.55);
        brick(t+shift,y,side*33.58,2.55,1.03,.18);
      }
    }
  }
  bricks.count=index;bricks.instanceMatrix.needsUpdate=true;scene.add(bricks);
  // Towers: cylindrical silhouettes, stepped cornices, merlons and narrow arrow slits.
  const towerMat=new THREE.MeshStandardMaterial({color:0x7c766c,roughness:1});
  for(const x of [-30,30])for(const z of [-30,30]){
    const body=new THREE.Mesh(new THREE.CylinderGeometry(3.75,4.25,16,12),towerMat);
    body.position.set(x,8,z);body.castShadow=true;body.receiveShadow=true;scene.add(body);
    const crown=new THREE.Mesh(new THREE.CylinderGeometry(4.55,4.55,1,12),trim);
    crown.position.set(x,16.2,z);scene.add(crown);
    for(let i=0;i<12;i++){
      const a=i*Math.PI/6;
      cube(x+4.05*Math.sin(a),17.15,z+4.05*Math.cos(a),1.55,1.9,1.3,stone);
    }
    for(let i=0;i<8;i++){
      const a=i*Math.PI/4;
      cube(x+3.83*Math.sin(a),9,z+3.83*Math.cos(a),.17,1.35,.18,mortar);
    }
  }
  // A distant fortified keep gives the forward direction a strong focal point.
  cube(0,14,-39,19,28,12,trim,true);
  for(let x=-9;x<=9;x+=3)cube(x,29,-39,2,3,3,stone);
  for(const x of [-12,12]){
    const t=new THREE.Mesh(new THREE.CylinderGeometry(3.4,4,32,12),towerMat);
    t.position.set(x,16,-40);t.castShadow=true;scene.add(t);
    const roof=new THREE.Mesh(new THREE.ConeGeometry(4.7,8,12),iron);
    roof.position.set(x,36,-40);scene.add(roof);
  }
  // Stone gate frame and a readable pointed arch, leaving the current prototype gate intact.
  cube(-7,8.8,-29.2,2.2,15.5,2.2,stone,true);
  cube(7,8.8,-29.2,2.2,15.5,2.2,stone,true);
  cube(0,16,-29.2,16,2.2,2.2,stone,true);
  for(let i=0;i<7;i++)cube(-6+i*2,18,-29.2,1.25,1.5,2.2,trim);
  // Torches and warm pools of light. Limit expensive dynamic lights on mobile.
  const torches=[];
  const torchPositions=[[-9,-27],[9,-27],[-25,-20],[25,-20],[-25,15],[25,15],[-9,15],[9,15]];
  for(let i=0;i<torchPositions.length;i++){
    const [x,z]=torchPositions[i];
    cube(x,1.5,z,.2,2.8,.2,iron);
    const bowl=new THREE.Mesh(new THREE.CylinderGeometry(.4,.26,.25,8),brass);
    bowl.position.set(x,2.9,z);scene.add(bowl);
    const flame=new THREE.Mesh(new THREE.ConeGeometry(.26,.85,7),fire);
    flame.position.set(x,3.45,z);scene.add(flame);
    if(!mobile||i<4){
      const light=new THREE.PointLight(0xff8736,10,11,2);
      light.position.set(x,3.45,z);scene.add(light);torches.push({flame,light,i});
    }else torches.push({flame,light:null,i});
  }
  // Vertical war banners, deliberately unbranded until a licensed ad is approved.
  for(const [x,z] of [[-15,-28],[15,-28],[-29,-9],[29,-9]]){
    cube(x,7,z,.18,7,.18,brass);
    const cloth=cube(x,6.9,z+.12,2.15,4,.08,red);
    cloth.rotation.z=x<0?-.035:.035;
    cube(x,8.3,z+.22,1.5,.14,.1,brass);
  }
  // A few ground props, using pooled geometry and fixed locations.
  for(const [x,z] of [[-20,-23],[21,-15],[-21,12],[20,16]]){
    cube(x,.4,z,1.7,.8,1.2,trim,true);
    cube(x+.6,.85,z+.2,.8,.9,.8,stone,true);
  }
  return {update(time){
    for(const t of torches){
      const flicker=1+.12*Math.sin(time*8+t.i*2.7)+.06*Math.sin(time*17+t.i);
      t.flame.scale.y=flicker;
      if(t.light)t.light.intensity=9*flicker;
    }
  }};
}

export function detailEnemy(enemy) {
  const steel=new THREE.MeshStandardMaterial({color:0x929b9d,metalness:.82,roughness:.3});
  const dark=new THREE.MeshStandardMaterial({color:0x202329,metalness:.45,roughness:.67});
  const red=new THREE.MeshStandardMaterial({color:0x87372e,roughness:.88});
  const gold=new THREE.MeshStandardMaterial({color:0xc6a35e,metalness:.72,roughness:.34});
  const add=(geo,mat,x,y,z,rx=0,ry=0,rz=0)=>{
    const m=new THREE.Mesh(geo,mat);m.position.set(x,y,z);m.rotation.set(rx,ry,rz);m.castShadow=true;enemy.add(m);return m;
  };
  // Existing body remains the gameplay hit target; these are visual armor layers.
  add(new THREE.CylinderGeometry(.39,.48,.9,10),steel,0,1.33,.04);
  add(new THREE.SphereGeometry(.41,12,8),steel,0,2.19,0);
  add(new THREE.CylinderGeometry(.43,.49,.18,10),dark,0,2.04,0);
  add(new THREE.BoxGeometry(.52,.1,.15),dark,0,2.21,.4);
  add(new THREE.ConeGeometry(.3,.48,8),steel,0,2.63,0);
  for(const side of [-1,1]){
    add(new THREE.SphereGeometry(.3,9,7),steel,side*.63,1.68,0);
    add(new THREE.BoxGeometry(.12,.48,.28),gold,side*.63,1.28,.02);
    add(new THREE.CylinderGeometry(.19,.22,.58,8),steel,side*.27,.48,.04);
  }
  add(new THREE.BoxGeometry(.84,.1,.51),gold,0,1.75,0);
  add(new THREE.BoxGeometry(.52,.72,.07),red,0,.87,-.32);
  const shield=add(new THREE.CylinderGeometry(.56,.47,.11,8),steel,-.87,1.26,.37,Math.PI/2);
  shield.rotation.z=Math.PI/8;
  add(new THREE.BoxGeometry(.08,.72,.12),gold,-.87,1.26,.46);
  add(new THREE.BoxGeometry(.55,.08,.12),gold,-.87,1.26,.47);
}
