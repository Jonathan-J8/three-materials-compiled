#define SHADER_TYPE RawShaderMaterial
#define SHADER_NAME 
void main() {
  gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}