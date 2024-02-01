import {
  Line,
  Mesh,
  PlaneGeometry,
  Points,
  ShaderChunk,
  Sprite,
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

import download from './download';

const geometry = new PlaneGeometry();
const chunkKeys = Object.keys(ShaderChunk);

const excludedChunks = [
  'background_vert',
  'background_frag',
  'backgroundCube_vert',
  'backgroundCube_frag',
  'cube_vert',
  'cube_frag',
  'depth_vert',
  'depth_frag',
  'distanceRGBA_vert',
  'distanceRGBA_frag',
  'equirect_vert',
  'equirect_frag',
  'linedashed_vert',
  'linedashed_frag',
  'meshbasic_vert',
  'meshbasic_frag',
  'meshlambert_vert',
  'meshlambert_frag',
  'meshmatcap_vert',
  'meshmatcap_frag',
  'meshnormal_vert',
  'meshnormal_frag',
  'meshphong_vert',
  'meshphong_frag',
  'meshphysical_vert',
  'meshphysical_frag',
  'meshtoon_vert',
  'meshtoon_frag',
  'points_vert',
  'points_frag',
  'shadow_vert',
  'shadow_frag',
  'sprite_vert',
  'sprite_frag',
];

const meshes: Record<string, Mesh | Line | Points | Sprite> = {
  // Material,
  // new RawShaderMaterial(),
  // new MeshDistanceMaterial(),
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
  ShaderMaterial: new Mesh(geometry, new ShaderMaterial()),
  ShadowMaterial: new Mesh(geometry, new ShadowMaterial()),
  SpriteMaterial: new Sprite(new SpriteMaterial()),
};

const createMeshes = () => {
  Object.values(meshes).forEach((mesh) => {
    if (Array.isArray(mesh.material)) return;

    mesh.material.onBeforeCompile = (shader) => {
      download(`${shader.shaderType}.frag.pre.glsl`, shader.fragmentShader);
      download(`${shader.shaderType}.vert.pre.glsl`, shader.vertexShader);
      download(`${shader.shaderType}.uniforms.json`, JSON.stringify(shader.uniforms, undefined, 2));

      let fs = shader.fragmentShader;
      let vs = shader.vertexShader;

      chunkKeys.forEach((key) => {
        if (excludedChunks.includes(key)) return;
        const from = `#include <${key}>`;
        const to = `
				// start <${key}> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/${key}.glsl.js
				#include <${key}>
				// end <${key}>
				`;

        fs = fs.replace(from, to);
        vs = vs.replace(from, to);
      });

      // adding '/' at the end to provoke error
      shader.fragmentShader = fs + '/';
      shader.vertexShader = vs + '/';
    };
  });
  return meshes;
};

export default createMeshes;
