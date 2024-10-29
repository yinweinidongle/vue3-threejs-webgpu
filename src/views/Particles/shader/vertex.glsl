//attribute vec3 positions;

//uniform float time;
// uniform vec3 emitterPosition; // 水管出口位置
// uniform vec3 velocity; // 粒子平均速度
// uniform float spread; // 速度随机散布范围
// uniform float decayRate; // 粒子生命衰减率


uniform vec2 uFrequency;
uniform float uTime;

varying vec2 vUv;

varying float vElevation;


void main() {
  //vec3 newPosition = modelPosition.xyz + 5 * time + randomInUnitSphere() * 5; // 更新位置
  //gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position,1.0);

  vec4 modelPosition = modelMatrix * vec4(position,1.0);

  float elevation = sin(modelPosition.x *uFrequency.x-uTime)*0.1;
  elevation += sin(modelPosition.y *uFrequency.y-uTime)*0.1;

 
  modelPosition.z = elevation;

  vec4 viewPosition = viewMatrix * modelPosition;
  vec4 projectedPosition = projectionMatrix * viewPosition;
  gl_Position = projectedPosition;

  vUv = uv;
  vElevation = elevation;

  // 计算并传递剩余生命值
  //vLife = max(0.0, 6.0 - time * 4.0);
}