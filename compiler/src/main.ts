import THREE from "./three";
import onBeforeCompile from "./onBeforeCompile";
import onShaderError from "./onShaderError";
import wait from "./wait";

window.h1Element.innerText = `Compiler ${__APP_VERSION__}`;
window.h2Element.innerText = `THREE version ${THREE.REVISION}`;
window.launchCompilation = async () => {
  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera();
  const geometry = new THREE.PlaneGeometry();
  const renderer = new THREE.WebGLRenderer();

  scene.add(camera);

  const names = Object.keys(THREE.ShaderLib);
  for (const name of names) {
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
    else if (materialName.match(/sprite/i))
      mesh = new THREE.Sprite(material as THREE.SpriteMaterial);
    else mesh = new THREE.Mesh(geometry, material);

    scene.add(mesh);
    renderer.debug.onShaderError = onShaderError(materialName);
    renderer.render(scene, camera);
    scene.clear();
    material.dispose();
    mesh = undefined;
    material = undefined;

    // waiting here because the browser wont auto download to much files at a time
    await wait(500);
  }
  // for (const shaderName in meshes) {
  //   const mesh = meshes[shaderName];
  //   if (Array.isArray(mesh.material)) continue;

  //   // downloads the uniforms and pre-compiled shaders
  //   mesh.material.onBeforeCompile = onBeforeCompile;
  //   // downloads the compiled shaders
  //   renderer.debug.onShaderError = onShaderError(shaderName);

  //   scene.add(mesh);
  //   renderer.render(scene, camera);
  //   scene.remove(mesh);

  //   mesh.material.dispose();
  // }

  geometry.dispose();
  scene.clear();
  camera.clear();
  renderer.dispose();

  const p = document.createElement("p");
  p.innerText = "Process ended";
  document.body.appendChild(p);
};
