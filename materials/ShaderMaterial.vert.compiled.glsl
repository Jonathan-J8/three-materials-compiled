#version 300 es

precision mediump sampler2DArray;
#define attribute in
#define varying out
#define texture2D texture
precision highp float;
  precision highp int;
  precision highp sampler2D;
  precision highp samplerCube;
  precision highp sampler3D;
    precision highp sampler2DArray;
    precision highp sampler2DShadow;
    precision highp samplerCubeShadow;
    precision highp sampler2DArrayShadow;
    precision highp isampler2D;
    precision highp isampler3D;
    precision highp isamplerCube;
    precision highp isampler2DArray;
    precision highp usampler2D;
    precision highp usampler3D;
    precision highp usamplerCube;
    precision highp usampler2DArray;
    
#define HIGH_PRECISION
#define SHADER_TYPE ShaderMaterial
#define SHADER_NAME 
uniform mat4 modelMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat3 normalMatrix;
uniform vec3 cameraPosition;
uniform bool isOrthographic;
#ifdef USE_INSTANCING
  attribute mat4 instanceMatrix;
#endif
#ifdef USE_INSTANCING_COLOR
  attribute vec3 instanceColor;
#endif
attribute vec3 position;
attribute vec3 normal;
attribute vec2 uv;
#ifdef USE_UV1
  attribute vec2 uv1;
#endif
#ifdef USE_UV2
  attribute vec2 uv2;
#endif
#ifdef USE_UV3
  attribute vec2 uv3;
#endif
#ifdef USE_TANGENT
  attribute vec4 tangent;
#endif
#if defined( USE_COLOR_ALPHA )
  attribute vec4 color;
#elif defined( USE_COLOR )
  attribute vec3 color;
#endif
#if ( defined( USE_MORPHTARGETS ) && ! defined( MORPHTARGETS_TEXTURE ) )
  attribute vec3 morphTarget0;
  attribute vec3 morphTarget1;
  attribute vec3 morphTarget2;
  attribute vec3 morphTarget3;
  #ifdef USE_MORPHNORMALS
    attribute vec3 morphNormal0;
    attribute vec3 morphNormal1;
    attribute vec3 morphNormal2;
    attribute vec3 morphNormal3;
  #else
    attribute vec3 morphTarget4;
    attribute vec3 morphTarget5;
    attribute vec3 morphTarget6;
    attribute vec3 morphTarget7;
  #endif
#endif
#ifdef USE_SKINNING
  attribute vec4 skinIndex;
  attribute vec4 skinWeight;
#endif

void main() {
  gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}