<script setup>
import {onMounted} from "vue";
import * as THREE from 'three/webgpu'
import Base from "../Base";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import {GUI} from "three/examples/jsm/libs/lil-gui.module.min.js"
import { range, texture, mix, uv, color, rotateUV, positionLocal, timerLocal } from 'three/webgpu';

let base,controls,gui,clock,sun,globe;
let material = null
onMounted(()=>{
    base = new Base()
    base.camera.position.z = 4
    base.camera.updateProjectionMatrix()
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    //gui = new GUI({width:300})
    clock = new THREE.Clock()
    base.camera.position.set( 1300, 500, 0 );
    
    window.addEventListener("resize",resize)
    //createBox();

     // light

     const sun = new THREE.DirectionalLight( '#ffffff', 2 );
		 sun.position.set( 0, 0, 3 );
		 base.scene.add( sun );


     //textures
     const textureLoader = new THREE.TextureLoader()
     const map = textureLoader.load('/smoke1.png')

     //create nodes
     const lifeRange = range(0.1,1)
     const offsetRange = range(new THREE.Vector3(-2,3,-2),new THREE.Vector3(2,5,2))
     const timer = timerLocal(.2,1)
     const lifeTime = timer.mul(lifeRange).mod(1)
     const scaleRange = range(.3,2)
     const rotateRange = range(.1,4)

     const life = lifeTime.div(lifeRange)

     const fakeLightEffect = positionLocal.y.oneMinus().max(0.2)
     const textureNode = texture(map,rotateUV(uv(),timer.mul(rotateRange)))
     const opacityNode = textureNode.a.mul(life.oneMinus())
     const smokeColor = mix(color(0x2c1501),color(0x222222),positionLocal.y.mul(3).clamp())

     //create particles
     const smokeNodeMaterial = new THREE.SpriteNodeMaterial()
     smokeNodeMaterial.colorNode = mix(color(0xf27d0c),smokeColor,life.mul(2.5).min( 1 ) ).mul( fakeLightEffect );
     smokeNodeMaterial.opacityNode = opacityNode
     smokeNodeMaterial.positionNode = offsetRange.mul(lifeTime)
     smokeNodeMaterial.scaleNode = scaleRange.mul(lifeTime.max(0.3))
     smokeNodeMaterial.depthWrite = false;
		 smokeNodeMaterial.transparent = true;

			const smokeInstancedSprite = new THREE.Mesh( new THREE.PlaneGeometry( 1, 1 ), smokeNodeMaterial );
			smokeInstancedSprite.scale.setScalar( 400 );
			smokeInstancedSprite.count = 2000;
			base.scene.add( smokeInstancedSprite );



      //

				const fireNodeMaterial = new THREE.SpriteNodeMaterial();
				fireNodeMaterial.colorNode = mix( color( 0xb72f17 ), color( 0xb72f17 ), life );
				fireNodeMaterial.positionNode = range( new THREE.Vector3( - 1, 1, - 1 ), new THREE.Vector3( 1, 2, 1 ) ).mul( lifeTime );
				fireNodeMaterial.scaleNode = smokeNodeMaterial.scaleNode;
				fireNodeMaterial.opacityNode = opacityNode;
				fireNodeMaterial.blending = THREE.AdditiveBlending;
				fireNodeMaterial.transparent = true;
				fireNodeMaterial.depthWrite = false;

				const fireInstancedSprite = new THREE.Mesh( new THREE.PlaneGeometry( 1, 1 ), fireNodeMaterial );
				fireInstancedSprite.scale.setScalar( 400 );
				fireInstancedSprite.count = 100;
				fireInstancedSprite.position.y = - 100;
				fireInstancedSprite.renderOrder = 1;
				base.scene.add( fireInstancedSprite );

        //Grid helper
        const helper = new THREE.GridHelper( 3000, 40, 0x303030, 0x303030 );
				helper.position.y = - 75;
				base.scene.add( helper );

   



     


   


    update()


});

function createBox(){
    const geometry = new THREE.BoxGeometry(1,1,1)
    const materail = new THREE.MeshBasicMaterial({color:0x00ff00})
    const cube = new THREE.Mesh(geometry,materail)
    base.scene.add(cube)
}

function update() {

  

    requestAnimationFrame(update)
    base.update()
    controls.update()
    
}

function resize(){
    base.resize();
}

</script>

<template>
  
</template>

<style scoped>

</style>
