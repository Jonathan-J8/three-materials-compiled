import THREE from "./three";
import type { Material, WebGLProgramParametersWithUniforms } from "three";
import download from "./download";

const chunks = Object.keys(THREE.ShaderChunk);

const onBeforeCompile: Material["onBeforeCompile"] = (
  shader: WebGLProgramParametersWithUniforms
) => {
  const { shaderType, uniforms } = shader;
  let { fragmentShader, vertexShader } = shader;

  download(`${shaderType}.frag.glsl`, fragmentShader);
  download(`${shaderType}.vert.glsl`, vertexShader);
  download(`${shaderType}.uniforms.json`, JSON.stringify(uniforms, undefined, 2));

  chunks.forEach((key) => {
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
  shader.fragmentShader = fragmentShader + "/";
  shader.vertexShader = vertexShader + "/";
};

export default onBeforeCompile;
