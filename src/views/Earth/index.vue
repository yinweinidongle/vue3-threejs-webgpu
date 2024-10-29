<script setup>
import {onMounted} from "vue";
import * as THREE from 'three/webgpu'
import Base from "../Base";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import {GUI} from "three/examples/jsm/libs/lil-gui.module.min.js"
import { step, normalWorld, output, texture, vec3, vec4, normalize, positionWorld, bumpMap, cameraPosition, color, uniform, mix, uv, max } from 'three/webgpu';


let base,controls,gui,clock,sun,globe;
let material = null
onMounted(()=>{
    base = new Base()
    base.camera.position.z = 4
    base.camera.updateProjectionMatrix()
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    //gui = new GUI({width:300})
    clock = new THREE.Clock()
    //base.camera.position.set( 4.5, 2, 3 );
    
    window.addEventListener("resize",resize)
    //createBox();

     // light

     const sun = new THREE.DirectionalLight( '#ffffff', 2 );
		 sun.position.set( 0, 0, 3 );
		 base.scene.add( sun );

     // uniforms

		 const atmosphereDayColor = uniform( color( '#4db2ff' ) );
		 const atmosphereTwilightColor = uniform( color( '#bc490b' ) );
		 const roughnessLow = uniform( 0.25 );
		 const roughnessHigh = uniform( 0.35 );


     // textures

		 const textureLoader = new THREE.TextureLoader();

    const dayTexture = textureLoader.load( '/planet/earth_day_4096.jpg' );
    dayTexture.colorSpace = THREE.SRGBColorSpace;
    dayTexture.anisotropy = 8;

    const nightTexture = textureLoader.load( '/planet/earth_night_4096.jpg' );
    nightTexture.colorSpace = THREE.SRGBColorSpace;
    nightTexture.anisotropy = 8;

    const bumpRoughnessCloudsTexture = textureLoader.load( '/planet/earth_bump_roughness_clouds_4096.jpg' );
    bumpRoughnessCloudsTexture.anisotropy = 8;


    // fresnel

    const viewDirection = positionWorld.sub( cameraPosition ).normalize();
		const fresnel = viewDirection.dot( normalWorld ).abs().oneMinus().toVar();

		// sun orientation

		const sunOrientation = normalWorld.dot( normalize( sun.position ) ).toVar();

		// atmosphere color

		const atmosphereColor = mix( atmosphereTwilightColor, atmosphereDayColor, sunOrientation.smoothstep( - 0.25, 0.75 ) );



    // globe

    const globeMaterial = new THREE.MeshStandardNodeMaterial();

    const cloudsStrength = texture( bumpRoughnessCloudsTexture, uv() ).b.smoothstep( 0.2, 1 );

    globeMaterial.colorNode = mix( texture( dayTexture ), vec3( 1 ), cloudsStrength.mul( 2 ) );

    const roughness = max(
      texture( bumpRoughnessCloudsTexture ).g,
      step( 0.01, cloudsStrength )
    );
    globeMaterial.roughnessNode = roughness.remap( 0, 1, roughnessLow, roughnessHigh );

    const night = texture( nightTexture );
    const dayStrength = sunOrientation.smoothstep( - 0.25, 0.5 );

    const atmosphereDayStrength = sunOrientation.smoothstep( - 0.5, 1 );
    const atmosphereMix = atmosphereDayStrength.mul( fresnel.pow( 2 ) ).clamp( 0, 1 );

    let finalOutput = mix( night.rgb, output.rgb, dayStrength );
    finalOutput = mix( finalOutput, atmosphereColor, atmosphereMix );

    globeMaterial.outputNode = vec4( finalOutput, output.a );

    const bumpElevation = max(
      texture( bumpRoughnessCloudsTexture ).r,
      cloudsStrength
    );
    globeMaterial.normalNode = bumpMap( bumpElevation );

    const sphereGeometry = new THREE.SphereGeometry( 1, 64, 64 );
    globe = new THREE.Mesh( sphereGeometry, globeMaterial );
    base.scene.add( globe );


    // atmosphere

    const atmosphereMaterial = new THREE.MeshBasicNodeMaterial( { side: THREE.BackSide, transparent: true } );
		let alpha = fresnel.remap( 0.73, 1, 1, 0 ).pow( 3 );
		alpha = alpha.mul( sunOrientation.smoothstep( - 0.5, 1 ) );
		atmosphereMaterial.outputNode = vec4( atmosphereColor, alpha );

		const atmosphere = new THREE.Mesh( sphereGeometry, atmosphereMaterial );
		atmosphere.scale.setScalar( 1.04 );
		base.scene.add( atmosphere );


    // debug

    const gui = new GUI();

    gui
      .addColor( { color: atmosphereDayColor.value.getHex( THREE.SRGBColorSpace ) }, 'color' )
      .onChange( ( value ) => {

        atmosphereDayColor.value.set( value );

      } )
      .name( 'atmosphereDayColor' );

    gui
      .addColor( { color: atmosphereTwilightColor.value.getHex( THREE.SRGBColorSpace ) }, 'color' )
      .onChange( ( value ) => {

        atmosphereTwilightColor.value.set( value );

      } )
      .name( 'atmosphereTwilightColor' );

    gui.add( roughnessLow, 'value', 0, 1, 0.001 ).name( 'roughnessLow' );
    gui.add( roughnessHigh, 'value', 0, 1, 0.001 ).name( 'roughnessHigh' );


     


   


    update()


});

function createBox(){
    const geometry = new THREE.BoxGeometry(1,1,1)
    const materail = new THREE.MeshBasicMaterial({color:0x00ff00})
    const cube = new THREE.Mesh(geometry,materail)
    base.scene.add(cube)
}

function update() {

    const delta = clock.getDelta();
		globe.rotation.y += delta * 0.025;

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
