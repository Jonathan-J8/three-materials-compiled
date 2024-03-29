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
#define SHADER_TYPE PointsMaterial
#define SHADER_NAME 
#define USE_SIZEATTENUATION
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

uniform float size;
uniform float scale;

// start <common> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/common.glsl.js
#define PI 3.141592653589793
#define PI2 6.283185307179586
#define PI_HALF 1.5707963267948966
#define RECIPROCAL_PI 0.3183098861837907
#define RECIPROCAL_PI2 0.15915494309189535
#define EPSILON 1e-6
#ifndef saturate
#define saturate( a ) clamp( a, 0.0, 1.0 )
#endif
#define whiteComplement( a ) ( 1.0 - saturate( a ) )
float pow2( const in float x ) { return x*x; }
vec3 pow2( const in vec3 x ) { return x*x; }
float pow3( const in float x ) { return x*x*x; }
float pow4( const in float x ) { float x2 = x*x; return x2*x2; }
float max3( const in vec3 v ) { return max( max( v.x, v.y ), v.z ); }
float average( const in vec3 v ) { return dot( v, vec3( 0.3333333 ) ); }
highp float rand( const in vec2 uv ) {
  const highp float a = 12.9898, b = 78.233, c = 43758.5453;
  highp float dt = dot( uv.xy, vec2( a,b ) ), sn = mod( dt, PI );
  return fract( sin( sn ) * c );
}
#ifdef HIGH_PRECISION
  float precisionSafeLength( vec3 v ) { return length( v ); }
#else
  float precisionSafeLength( vec3 v ) {
    float maxComponent = max3( abs( v ) );
    return length( v / maxComponent ) * maxComponent;
  }
#endif
struct IncidentLight {
  vec3 color;
  vec3 direction;
  bool visible;
};
struct ReflectedLight {
  vec3 directDiffuse;
  vec3 directSpecular;
  vec3 indirectDiffuse;
  vec3 indirectSpecular;
};
#ifdef USE_ALPHAHASH
  varying vec3 vPosition;
#endif
vec3 transformDirection( in vec3 dir, in mat4 matrix ) {
  return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );
}
vec3 inverseTransformDirection( in vec3 dir, in mat4 matrix ) {
  return normalize( ( vec4( dir, 0.0 ) * matrix ).xyz );
}
mat3 transposeMat3( const in mat3 m ) {
  mat3 tmp;
  tmp[ 0 ] = vec3( m[ 0 ].x, m[ 1 ].x, m[ 2 ].x );
  tmp[ 1 ] = vec3( m[ 0 ].y, m[ 1 ].y, m[ 2 ].y );
  tmp[ 2 ] = vec3( m[ 0 ].z, m[ 1 ].z, m[ 2 ].z );
  return tmp;
}
float luminance( const in vec3 rgb ) {
  const vec3 weights = vec3( 0.2126729, 0.7151522, 0.0721750 );
  return dot( weights, rgb );
}
bool isPerspectiveMatrix( mat4 m ) {
  return m[ 2 ][ 3 ] == - 1.0;
}
vec2 equirectUv( in vec3 dir ) {
  float u = atan( dir.z, dir.x ) * RECIPROCAL_PI2 + 0.5;
  float v = asin( clamp( dir.y, - 1.0, 1.0 ) ) * RECIPROCAL_PI + 0.5;
  return vec2( u, v );
}
vec3 BRDF_Lambert( const in vec3 diffuseColor ) {
  return RECIPROCAL_PI * diffuseColor;
}
vec3 F_Schlick( const in vec3 f0, const in float f90, const in float dotVH ) {
  float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );
  return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );
}
float F_Schlick( const in float f0, const in float f90, const in float dotVH ) {
  float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );
  return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );
} // validated
// end <common>


// start <color_pars_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/color_pars_vertex.glsl.js
#if defined( USE_COLOR_ALPHA )
  varying vec4 vColor;
#elif defined( USE_COLOR ) || defined( USE_INSTANCING_COLOR )
  varying vec3 vColor;
#endif
// end <color_pars_vertex>


// start <fog_pars_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/fog_pars_vertex.glsl.js
#ifdef USE_FOG
  varying float vFogDepth;
#endif
// end <fog_pars_vertex>


// start <morphtarget_pars_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/morphtarget_pars_vertex.glsl.js
#ifdef USE_MORPHTARGETS
  uniform float morphTargetBaseInfluence;
  #ifdef MORPHTARGETS_TEXTURE
    uniform float morphTargetInfluences[ MORPHTARGETS_COUNT ];
    uniform sampler2DArray morphTargetsTexture;
    uniform ivec2 morphTargetsTextureSize;
    vec4 getMorph( const in int vertexIndex, const in int morphTargetIndex, const in int offset ) {
      int texelIndex = vertexIndex * MORPHTARGETS_TEXTURE_STRIDE + offset;
      int y = texelIndex / morphTargetsTextureSize.x;
      int x = texelIndex - y * morphTargetsTextureSize.x;
      ivec3 morphUV = ivec3( x, y, morphTargetIndex );
      return texelFetch( morphTargetsTexture, morphUV, 0 );
    }
  #else
    #ifndef USE_MORPHNORMALS
      uniform float morphTargetInfluences[ 8 ];
    #else
      uniform float morphTargetInfluences[ 4 ];
    #endif
  #endif
#endif
// end <morphtarget_pars_vertex>


// start <logdepthbuf_pars_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/logdepthbuf_pars_vertex.glsl.js
#ifdef USE_LOGDEPTHBUF
  #ifdef USE_LOGDEPTHBUF_EXT
    varying float vFragDepth;
    varying float vIsPerspective;
  #else
    uniform float logDepthBufFC;
  #endif
#endif
// end <logdepthbuf_pars_vertex>


// start <clipping_planes_pars_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/clipping_planes_pars_vertex.glsl.js
#if 0 > 0
  varying vec3 vClipPosition;
#endif
// end <clipping_planes_pars_vertex>

#ifdef USE_POINTS_UV
  varying vec2 vUv;
  uniform mat3 uvTransform;
#endif
void main() {
  #ifdef USE_POINTS_UV
    vUv = ( uvTransform * vec3( uv, 1 ) ).xy;
  #endif
  
// start <color_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/color_vertex.glsl.js
#if defined( USE_COLOR_ALPHA )
  vColor = vec4( 1.0 );
#elif defined( USE_COLOR ) || defined( USE_INSTANCING_COLOR )
  vColor = vec3( 1.0 );
#endif
#ifdef USE_COLOR
  vColor *= color;
#endif
#ifdef USE_INSTANCING_COLOR
  vColor.xyz *= instanceColor.xyz;
#endif
// end <color_vertex>

  
// start <morphcolor_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/morphcolor_vertex.glsl.js
#if defined( USE_MORPHCOLORS ) && defined( MORPHTARGETS_TEXTURE )
  vColor *= morphTargetBaseInfluence;
  for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
    #if defined( USE_COLOR_ALPHA )
      if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ) * morphTargetInfluences[ i ];
    #elif defined( USE_COLOR )
      if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ).rgb * morphTargetInfluences[ i ];
    #endif
  }
#endif
// end <morphcolor_vertex>

  
// start <begin_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/begin_vertex.glsl.js
vec3 transformed = vec3( position );
#ifdef USE_ALPHAHASH
  vPosition = vec3( position );
#endif
// end <begin_vertex>

  
// start <morphtarget_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/morphtarget_vertex.glsl.js
#ifdef USE_MORPHTARGETS
  transformed *= morphTargetBaseInfluence;
  #ifdef MORPHTARGETS_TEXTURE
    for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
      if ( morphTargetInfluences[ i ] != 0.0 ) transformed += getMorph( gl_VertexID, i, 0 ).xyz * morphTargetInfluences[ i ];
    }
  #else
    transformed += morphTarget0 * morphTargetInfluences[ 0 ];
    transformed += morphTarget1 * morphTargetInfluences[ 1 ];
    transformed += morphTarget2 * morphTargetInfluences[ 2 ];
    transformed += morphTarget3 * morphTargetInfluences[ 3 ];
    #ifndef USE_MORPHNORMALS
      transformed += morphTarget4 * morphTargetInfluences[ 4 ];
      transformed += morphTarget5 * morphTargetInfluences[ 5 ];
      transformed += morphTarget6 * morphTargetInfluences[ 6 ];
      transformed += morphTarget7 * morphTargetInfluences[ 7 ];
    #endif
  #endif
#endif
// end <morphtarget_vertex>

  
// start <project_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/project_vertex.glsl.js
vec4 mvPosition = vec4( transformed, 1.0 );
#ifdef USE_BATCHING
  mvPosition = batchingMatrix * mvPosition;
#endif
#ifdef USE_INSTANCING
  mvPosition = instanceMatrix * mvPosition;
#endif
mvPosition = modelViewMatrix * mvPosition;
gl_Position = projectionMatrix * mvPosition;
// end <project_vertex>

  gl_PointSize = size;
  #ifdef USE_SIZEATTENUATION
    bool isPerspective = isPerspectiveMatrix( projectionMatrix );
    if ( isPerspective ) gl_PointSize *= ( scale / - mvPosition.z );
  #endif
  
// start <logdepthbuf_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/logdepthbuf_vertex.glsl.js
#ifdef USE_LOGDEPTHBUF
  #ifdef USE_LOGDEPTHBUF_EXT
    vFragDepth = 1.0 + gl_Position.w;
    vIsPerspective = float( isPerspectiveMatrix( projectionMatrix ) );
  #else
    if ( isPerspectiveMatrix( projectionMatrix ) ) {
      gl_Position.z = log2( max( EPSILON, gl_Position.w + 1.0 ) ) * logDepthBufFC - 1.0;
      gl_Position.z *= gl_Position.w;
    }
  #endif
#endif
// end <logdepthbuf_vertex>

  
// start <clipping_planes_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/clipping_planes_vertex.glsl.js
#if 0 > 0
  vClipPosition = - mvPosition.xyz;
#endif
// end <clipping_planes_vertex>

  
// start <worldpos_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/worldpos_vertex.glsl.js
#if defined( USE_ENVMAP ) || defined( DISTANCE ) || defined ( USE_SHADOWMAP ) || defined ( USE_TRANSMISSION ) || 0 > 0
  vec4 worldPosition = vec4( transformed, 1.0 );
  #ifdef USE_BATCHING
    worldPosition = batchingMatrix * worldPosition;
  #endif
  #ifdef USE_INSTANCING
    worldPosition = instanceMatrix * worldPosition;
  #endif
  worldPosition = modelMatrix * worldPosition;
#endif
// end <worldpos_vertex>

  
// start <fog_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/fog_vertex.glsl.js
#ifdef USE_FOG
  vFogDepth = - mvPosition.z;
#endif
// end <fog_vertex>

}