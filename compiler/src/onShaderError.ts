import type { WebGLDebug } from "three";
import download from "./download";

/**
 inspired by https://stackoverflow.com/users/3067608/jee7
 in https://stackoverflow.com/questions/75172794/how-can-i-see-the-whole-shaders-text-content-with-all-the-prepended-code-by-th
 */
const parseShader = (gl: WebGLRenderingContext, shader: WebGLShader) => {
  return gl
    .getShaderSource(shader)
    ?.replaceAll("\t", "  ")
    ?.replace(/^[ \t]+(?=precision)/gm, "") // remove space and tab before "precision" statements
    ?.slice(0, -1); // remove '/' at the end
};

const onShaderError: (name: string) => WebGLDebug["onShaderError"] =
  (materialName) => (gl, _, vs, fs) => {
    const vsShader = parseShader(gl, vs);
    const fsShader = parseShader(gl, fs);

    if (vsShader) download(`${materialName}.vert.compiled.glsl`, vsShader);
    if (fsShader) download(`${materialName}.frag.compiled.glsl`, fsShader);
  };

export default onShaderError;
