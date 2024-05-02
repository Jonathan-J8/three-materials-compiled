#version 300 es

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
#define SHADER_TYPE ShadowMaterial
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
#ifdef USE_INSTANCING_MORPH
  uniform sampler2D morphTexture;
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


// start <batching_pars_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/batching_pars_vertex.glsl.js
#ifdef USE_BATCHING
  attribute float batchId;
  uniform highp sampler2D batchingTexture;
  mat4 getBatchingMatrix( const in float i ) {
    int size = textureSize( batchingTexture, 0 ).x;
    int j = int( i ) * 4;
    int x = j % size;
    int y = j / size;
    vec4 v1 = texelFetch( batchingTexture, ivec2( x, y ), 0 );
    vec4 v2 = texelFetch( batchingTexture, ivec2( x + 1, y ), 0 );
    vec4 v3 = texelFetch( batchingTexture, ivec2( x + 2, y ), 0 );
    vec4 v4 = texelFetch( batchingTexture, ivec2( x + 3, y ), 0 );
    return mat4( v1, v2, v3, v4 );
  }
#endif
// end <batching_pars_vertex>


// start <fog_pars_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/fog_pars_vertex.glsl.js
#ifdef USE_FOG
  varying float vFogDepth;
#endif
// end <fog_pars_vertex>


// start <morphtarget_pars_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/morphtarget_pars_vertex.glsl.js
#ifdef USE_MORPHTARGETS
  #ifndef USE_INSTANCING_MORPH
    uniform float morphTargetBaseInfluence;
  #endif
  #ifdef MORPHTARGETS_TEXTURE
    #ifndef USE_INSTANCING_MORPH
      uniform float morphTargetInfluences[ MORPHTARGETS_COUNT ];
    #endif
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


// start <skinning_pars_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/skinning_pars_vertex.glsl.js
#ifdef USE_SKINNING
  uniform mat4 bindMatrix;
  uniform mat4 bindMatrixInverse;
  uniform highp sampler2D boneTexture;
  mat4 getBoneMatrix( const in float i ) {
    int size = textureSize( boneTexture, 0 ).x;
    int j = int( i ) * 4;
    int x = j % size;
    int y = j / size;
    vec4 v1 = texelFetch( boneTexture, ivec2( x, y ), 0 );
    vec4 v2 = texelFetch( boneTexture, ivec2( x + 1, y ), 0 );
    vec4 v3 = texelFetch( boneTexture, ivec2( x + 2, y ), 0 );
    vec4 v4 = texelFetch( boneTexture, ivec2( x + 3, y ), 0 );
    return mat4( v1, v2, v3, v4 );
  }
#endif
// end <skinning_pars_vertex>


// start <logdepthbuf_pars_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/logdepthbuf_pars_vertex.glsl.js
#ifdef USE_LOGDEPTHBUF
  varying float vFragDepth;
  varying float vIsPerspective;
#endif
// end <logdepthbuf_pars_vertex>


// start <shadowmap_pars_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/shadowmap_pars_vertex.glsl.js
#if 0 > 0
  uniform mat4 spotLightMatrix[ 0 ];
  varying vec4 vSpotLightCoord[ 0 ];
#endif
#ifdef USE_SHADOWMAP
  #if 0 > 0
    uniform mat4 directionalShadowMatrix[ 0 ];
    varying vec4 vDirectionalShadowCoord[ 0 ];
    struct DirectionalLightShadow {
      float shadowBias;
      float shadowNormalBias;
      float shadowRadius;
      vec2 shadowMapSize;
    };
    uniform DirectionalLightShadow directionalLightShadows[ 0 ];
  #endif
  #if 0 > 0
    struct SpotLightShadow {
      float shadowBias;
      float shadowNormalBias;
      float shadowRadius;
      vec2 shadowMapSize;
    };
    uniform SpotLightShadow spotLightShadows[ 0 ];
  #endif
  #if 0 > 0
    uniform mat4 pointShadowMatrix[ 0 ];
    varying vec4 vPointShadowCoord[ 0 ];
    struct PointLightShadow {
      float shadowBias;
      float shadowNormalBias;
      float shadowRadius;
      vec2 shadowMapSize;
      float shadowCameraNear;
      float shadowCameraFar;
    };
    uniform PointLightShadow pointLightShadows[ 0 ];
  #endif
#endif
// end <shadowmap_pars_vertex>

void main() {
  
// start <batching_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/batching_vertex.glsl.js
#ifdef USE_BATCHING
  mat4 batchingMatrix = getBatchingMatrix( batchId );
#endif
// end <batching_vertex>

  
// start <beginnormal_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/beginnormal_vertex.glsl.js
vec3 objectNormal = vec3( normal );
#ifdef USE_TANGENT
  vec3 objectTangent = vec3( tangent.xyz );
#endif
// end <beginnormal_vertex>

  
// start <morphinstance_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/morphinstance_vertex.glsl.js
#ifdef USE_INSTANCING_MORPH
  float morphTargetInfluences[MORPHTARGETS_COUNT];
  float morphTargetBaseInfluence = texelFetch( morphTexture, ivec2( 0, gl_InstanceID ), 0 ).r;
  for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
    morphTargetInfluences[i] =  texelFetch( morphTexture, ivec2( i + 1, gl_InstanceID ), 0 ).r;
  }
#endif
// end <morphinstance_vertex>

  
// start <morphnormal_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/morphnormal_vertex.glsl.js
#ifdef USE_MORPHNORMALS
  objectNormal *= morphTargetBaseInfluence;
  #ifdef MORPHTARGETS_TEXTURE
    for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
      if ( morphTargetInfluences[ i ] != 0.0 ) objectNormal += getMorph( gl_VertexID, i, 1 ).xyz * morphTargetInfluences[ i ];
    }
  #else
    objectNormal += morphNormal0 * morphTargetInfluences[ 0 ];
    objectNormal += morphNormal1 * morphTargetInfluences[ 1 ];
    objectNormal += morphNormal2 * morphTargetInfluences[ 2 ];
    objectNormal += morphNormal3 * morphTargetInfluences[ 3 ];
  #endif
#endif
// end <morphnormal_vertex>

  
// start <skinbase_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/skinbase_vertex.glsl.js
#ifdef USE_SKINNING
  mat4 boneMatX = getBoneMatrix( skinIndex.x );
  mat4 boneMatY = getBoneMatrix( skinIndex.y );
  mat4 boneMatZ = getBoneMatrix( skinIndex.z );
  mat4 boneMatW = getBoneMatrix( skinIndex.w );
#endif
// end <skinbase_vertex>

  
// start <skinnormal_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/skinnormal_vertex.glsl.js
#ifdef USE_SKINNING
  mat4 skinMatrix = mat4( 0.0 );
  skinMatrix += skinWeight.x * boneMatX;
  skinMatrix += skinWeight.y * boneMatY;
  skinMatrix += skinWeight.z * boneMatZ;
  skinMatrix += skinWeight.w * boneMatW;
  skinMatrix = bindMatrixInverse * skinMatrix * bindMatrix;
  objectNormal = vec4( skinMatrix * vec4( objectNormal, 0.0 ) ).xyz;
  #ifdef USE_TANGENT
    objectTangent = vec4( skinMatrix * vec4( objectTangent, 0.0 ) ).xyz;
  #endif
#endif
// end <skinnormal_vertex>

  
// start <defaultnormal_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/defaultnormal_vertex.glsl.js
vec3 transformedNormal = objectNormal;
#ifdef USE_TANGENT
  vec3 transformedTangent = objectTangent;
#endif
#ifdef USE_BATCHING
  mat3 bm = mat3( batchingMatrix );
  transformedNormal /= vec3( dot( bm[ 0 ], bm[ 0 ] ), dot( bm[ 1 ], bm[ 1 ] ), dot( bm[ 2 ], bm[ 2 ] ) );
  transformedNormal = bm * transformedNormal;
  #ifdef USE_TANGENT
    transformedTangent = bm * transformedTangent;
  #endif
#endif
#ifdef USE_INSTANCING
  mat3 im = mat3( instanceMatrix );
  transformedNormal /= vec3( dot( im[ 0 ], im[ 0 ] ), dot( im[ 1 ], im[ 1 ] ), dot( im[ 2 ], im[ 2 ] ) );
  transformedNormal = im * transformedNormal;
  #ifdef USE_TANGENT
    transformedTangent = im * transformedTangent;
  #endif
#endif
transformedNormal = normalMatrix * transformedNormal;
#ifdef FLIP_SIDED
  transformedNormal = - transformedNormal;
#endif
#ifdef USE_TANGENT
  transformedTangent = ( modelViewMatrix * vec4( transformedTangent, 0.0 ) ).xyz;
  #ifdef FLIP_SIDED
    transformedTangent = - transformedTangent;
  #endif
#endif
// end <defaultnormal_vertex>

  
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

  
// start <skinning_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/skinning_vertex.glsl.js
#ifdef USE_SKINNING
  vec4 skinVertex = bindMatrix * vec4( transformed, 1.0 );
  vec4 skinned = vec4( 0.0 );
  skinned += boneMatX * skinVertex * skinWeight.x;
  skinned += boneMatY * skinVertex * skinWeight.y;
  skinned += boneMatZ * skinVertex * skinWeight.z;
  skinned += boneMatW * skinVertex * skinWeight.w;
  transformed = ( bindMatrixInverse * skinned ).xyz;
#endif
// end <skinning_vertex>

  
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

  
// start <logdepthbuf_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/logdepthbuf_vertex.glsl.js
#ifdef USE_LOGDEPTHBUF
  vFragDepth = 1.0 + gl_Position.w;
  vIsPerspective = float( isPerspectiveMatrix( projectionMatrix ) );
#endif
// end <logdepthbuf_vertex>

  
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

  
// start <shadowmap_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/shadowmap_vertex.glsl.js
#if ( defined( USE_SHADOWMAP ) && ( 0 > 0 || 0 > 0 ) ) || ( 0 > 0 )
  vec3 shadowWorldNormal = inverseTransformDirection( transformedNormal, viewMatrix );
  vec4 shadowWorldPosition;
#endif
#if defined( USE_SHADOWMAP )
  #if 0 > 0
    
  #endif
  #if 0 > 0
    
  #endif
#endif
#if 0 > 0
  
#endif
// end <shadowmap_vertex>

  
// start <fog_vertex> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/fog_vertex.glsl.js
#ifdef USE_FOG
  vFogDepth = - mvPosition.z;
#endif
// end <fog_vertex>

}