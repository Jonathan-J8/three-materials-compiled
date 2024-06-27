import {
  Line,
  Mesh,
  PerspectiveCamera,
  PlaneGeometry,
  Points,
  RawShaderMaterial,
  Scene,
  Sprite,
  WebGLRenderer,
} from 'three';

import {
  LineBasicMaterial,
  LineDashedMaterial,
  MeshBasicMaterial,
  MeshDepthMaterial,
  MeshLambertMaterial,
  MeshMatcapMaterial,
  MeshNormalMaterial,
  MeshPhongMaterial,
  MeshPhysicalMaterial,
  MeshStandardMaterial,
  MeshToonMaterial,
  PointsMaterial,
  ShaderMaterial,
  ShadowMaterial,
  SpriteMaterial,
} from 'three';

import wait from './wait';
import onShaderError from './onShaderError';
import onBeforeCompile from './onBeforeCompile';

const canvas = document.createElement('canvas');
const scene = new Scene();
const camera = new PerspectiveCamera();
const geometry = new PlaneGeometry();
const renderer = new WebGLRenderer({ canvas });

const meshes: Record<string, Mesh | Line | Points | Sprite> = {
  // Material,
  // MeshDistanceMaterial,

  LineBasicMaterial: new Line(geometry, new LineBasicMaterial()),
  LineDashedMaterial: new Line(geometry, new LineDashedMaterial()),
  MeshBasicMaterial: new Mesh(geometry, new MeshBasicMaterial()),
  MeshDepthMaterial: new Mesh(geometry, new MeshDepthMaterial()),
  MeshLambertMaterial: new Mesh(geometry, new MeshLambertMaterial()),
  MeshMatcapMaterial: new Mesh(geometry, new MeshMatcapMaterial()),
  MeshNormalMaterial: new Mesh(geometry, new MeshNormalMaterial()),
  MeshPhongMaterial: new Mesh(geometry, new MeshPhongMaterial()),
  MeshPhysicalMaterial: new Mesh(geometry, new MeshPhysicalMaterial()),
  MeshStandardMaterial: new Mesh(geometry, new MeshStandardMaterial()),
  MeshToonMaterial: new Mesh(geometry, new MeshToonMaterial()),
  PointsMaterial: new Points(geometry, new PointsMaterial()),
  RawShaderMaterial: new Mesh(geometry, new RawShaderMaterial()),
  ShaderMaterial: new Mesh(geometry, new ShaderMaterial()),
  ShadowMaterial: new Mesh(geometry, new ShadowMaterial()),
  SpriteMaterial: new Sprite(new SpriteMaterial()),
};

const main = async () => {
  for (const shaderName in meshes) {
    const mesh = meshes[shaderName];
    if (Array.isArray(mesh.material)) continue;

    // waiting here because the browser wont auto download to much files at a time
    await wait(500);
    // downloads the uniforms and pre-compiled shaders
    mesh.material.onBeforeCompile = onBeforeCompile;
    // downloads the compiled shaders
    renderer.debug.onShaderError = onShaderError(shaderName);

    scene.add(mesh);
    renderer.render(scene, camera);
    scene.remove(mesh);

    mesh.material.dispose();
  }

  geometry.dispose();
  scene.clear();
  camera.clear();
  renderer.dispose();

  const p = document.createElement('p');
  p.innerText = 'Process ended';
  document.body.appendChild(p);
};

main();
