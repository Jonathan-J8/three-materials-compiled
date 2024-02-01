import { ShaderChunk, type Material } from 'three';
import download from './download';

const chunks = Object.keys(ShaderChunk);

const chunksExluded = [
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

const onBeforeCompile: Material['onBeforeCompile'] = (shader) => {
  const { shaderType, uniforms } = shader;
  let { fragmentShader, vertexShader } = shader;

  download(`${shaderType}.frag.pre.compiled.glsl`, fragmentShader);
  download(`${shaderType}.vert.pre.compiled.glsl`, vertexShader);
  download(`${shaderType}.uniforms.json`, JSON.stringify(uniforms, undefined, 2));

  chunks.forEach((key) => {
    if (chunksExluded.includes(key)) return;

    const from = `#include <${key}>`;
    const to = `
// start <${key}> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/${key}.glsl.js
#include <${key}>
// end <${key}>
`;

    fragmentShader = fragmentShader.replace(from, to);
    vertexShader = vertexShader.replace(from, to);
  });

  // adding '/' at the end to provoke error
  shader.fragmentShader = fragmentShader + '/';
  shader.vertexShader = vertexShader + '/';
};

export default onBeforeCompile;
