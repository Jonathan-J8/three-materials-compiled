import THREE from "./three";
import onBeforeCompile from "./onBeforeCompile";
import onShaderError from "./onShaderError";
import wait from "./wait";
import type { SpriteMaterial } from "three";

window.h1Element.innerText = `Compiler ${__APP_VERSION__}`;
window.h2Element.innerText = `THREE version ${THREE.REVISION}`;
window.btnElement.onclick = async () => {
  window.btnElement.innerText = "COMPILATION STARTED";

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera();
  const geometry = new THREE.PlaneGeometry();
  const renderer = new THREE.WebGLRenderer();
  const shaderNames = Object.keys(THREE.ShaderLib);

  scene.add(camera);

  for (const name of shaderNames) {
    let mesh: any, material: any;
    const regex = new RegExp(`${name}material`, "i");
    const materialName = Object.keys(THREE).find((name) => name.match(regex));
    if (!materialName) continue;
    try {
      material = new THREE[materialName]();
    } catch (e) {
      console.error(e);
      continue;
    }
    material.onBeforeCompile = onBeforeCompile;

    if (materialName.match(/points/i)) mesh = new THREE.Line(geometry, material);
    else if (materialName.match(/line/i)) mesh = new THREE.Points(geometry, material);
    else if (materialName.match(/sprite/i)) mesh = new THREE.Sprite(material as SpriteMaterial);
    else mesh = new THREE.Mesh(geometry, material);

    scene.add(mesh);
    renderer.debug.onShaderError = onShaderError(materialName);
    renderer.render(scene, camera);
    scene.remove(mesh);
    material.dispose();
    mesh = undefined;
    material = undefined;

    // waiting here because the browser wont auto download to much files at a time
    await wait(500);
  }

  geometry.dispose();
  scene.clear();
  camera.clear();
  renderer.dispose();

  window.btnElement.innerText = "RELAUNCH COMPILATION";
  window.appState = "done";
  return true;
};
