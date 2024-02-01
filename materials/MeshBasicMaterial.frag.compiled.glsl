#version 300 es
precision mediump sampler2DArray;
#define varying in
layout(location = 0) out highp vec4 pc_fragColor;
#define gl_FragColor pc_fragColor
#define gl_FragDepthEXT gl_FragDepth
#define texture2D texture
#define textureCube texture
#define texture2DProj textureProj
#define texture2DLodEXT textureLod
#define texture2DProjLodEXT textureProjLod
#define textureCubeLodEXT textureLod
#define texture2DGradEXT textureGrad
#define texture2DProjGradEXT textureProjGrad
#define textureCubeGradEXT textureGrad
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
#define SHADER_TYPE MeshBasicMaterial
#define SHADER_NAME 
uniform mat4 viewMatrix;
uniform vec3 cameraPosition;
uniform bool isOrthographic;
#define OPAQUE

const mat3 LINEAR_SRGB_TO_LINEAR_DISPLAY_P3 = mat3(
  vec3( 0.8224621, 0.177538, 0.0 ),
  vec3( 0.0331941, 0.9668058, 0.0 ),
  vec3( 0.0170827, 0.0723974, 0.9105199 )
);
const mat3 LINEAR_DISPLAY_P3_TO_LINEAR_SRGB = mat3(
  vec3( 1.2249401, - 0.2249404, 0.0 ),
  vec3( - 0.0420569, 1.0420571, 0.0 ),
  vec3( - 0.0196376, - 0.0786361, 1.0982735 )
);
vec4 LinearSRGBToLinearDisplayP3( in vec4 value ) {
  return vec4( value.rgb * LINEAR_SRGB_TO_LINEAR_DISPLAY_P3, value.a );
}
vec4 LinearDisplayP3ToLinearSRGB( in vec4 value ) {
  return vec4( value.rgb * LINEAR_DISPLAY_P3_TO_LINEAR_SRGB, value.a );
}
vec4 LinearTransferOETF( in vec4 value ) {
  return value;
}
vec4 sRGBTransferOETF( in vec4 value ) {
  return vec4( mix( pow( value.rgb, vec3( 0.41666 ) ) * 1.055 - vec3( 0.055 ), value.rgb * 12.92, vec3( lessThanEqual( value.rgb, vec3( 0.0031308 ) ) ) ), value.a );
}
vec4 LinearToLinear( in vec4 value ) {
  return value;
}
vec4 LinearTosRGB( in vec4 value ) {
  return sRGBTransferOETF( value );
}
vec4 linearToOutputTexel( vec4 value ) { return ( sRGBTransferOETF( value ) ); }

uniform vec3 diffuse;
uniform float opacity;
#ifndef FLAT_SHADED
  varying vec3 vNormal;
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


// start <dithering_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/dithering_pars_fragment.glsl.js
#ifdef DITHERING
  vec3 dithering( vec3 color ) {
    float grid_position = rand( gl_FragCoord.xy );
    vec3 dither_shift_RGB = vec3( 0.25 / 255.0, -0.25 / 255.0, 0.25 / 255.0 );
    dither_shift_RGB = mix( 2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position );
    return color + dither_shift_RGB;
  }
#endif
// end <dithering_pars_fragment>


// start <color_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/color_pars_fragment.glsl.js
#if defined( USE_COLOR_ALPHA )
  varying vec4 vColor;
#elif defined( USE_COLOR )
  varying vec3 vColor;
#endif
// end <color_pars_fragment>


// start <uv_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/uv_pars_fragment.glsl.js
#if defined( USE_UV ) || defined( USE_ANISOTROPY )
  varying vec2 vUv;
#endif
#ifdef USE_MAP
  varying vec2 vMapUv;
#endif
#ifdef USE_ALPHAMAP
  varying vec2 vAlphaMapUv;
#endif
#ifdef USE_LIGHTMAP
  varying vec2 vLightMapUv;
#endif
#ifdef USE_AOMAP
  varying vec2 vAoMapUv;
#endif
#ifdef USE_BUMPMAP
  varying vec2 vBumpMapUv;
#endif
#ifdef USE_NORMALMAP
  varying vec2 vNormalMapUv;
#endif
#ifdef USE_EMISSIVEMAP
  varying vec2 vEmissiveMapUv;
#endif
#ifdef USE_METALNESSMAP
  varying vec2 vMetalnessMapUv;
#endif
#ifdef USE_ROUGHNESSMAP
  varying vec2 vRoughnessMapUv;
#endif
#ifdef USE_ANISOTROPYMAP
  varying vec2 vAnisotropyMapUv;
#endif
#ifdef USE_CLEARCOATMAP
  varying vec2 vClearcoatMapUv;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
  varying vec2 vClearcoatNormalMapUv;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
  varying vec2 vClearcoatRoughnessMapUv;
#endif
#ifdef USE_IRIDESCENCEMAP
  varying vec2 vIridescenceMapUv;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
  varying vec2 vIridescenceThicknessMapUv;
#endif
#ifdef USE_SHEEN_COLORMAP
  varying vec2 vSheenColorMapUv;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
  varying vec2 vSheenRoughnessMapUv;
#endif
#ifdef USE_SPECULARMAP
  varying vec2 vSpecularMapUv;
#endif
#ifdef USE_SPECULAR_COLORMAP
  varying vec2 vSpecularColorMapUv;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
  varying vec2 vSpecularIntensityMapUv;
#endif
#ifdef USE_TRANSMISSIONMAP
  uniform mat3 transmissionMapTransform;
  varying vec2 vTransmissionMapUv;
#endif
#ifdef USE_THICKNESSMAP
  uniform mat3 thicknessMapTransform;
  varying vec2 vThicknessMapUv;
#endif
// end <uv_pars_fragment>


// start <map_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/map_pars_fragment.glsl.js
#ifdef USE_MAP
  uniform sampler2D map;
#endif
// end <map_pars_fragment>


// start <alphamap_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/alphamap_pars_fragment.glsl.js
#ifdef USE_ALPHAMAP
  uniform sampler2D alphaMap;
#endif
// end <alphamap_pars_fragment>


// start <alphatest_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/alphatest_pars_fragment.glsl.js
#ifdef USE_ALPHATEST
  uniform float alphaTest;
#endif
// end <alphatest_pars_fragment>


// start <alphahash_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/alphahash_pars_fragment.glsl.js
#ifdef USE_ALPHAHASH
  const float ALPHA_HASH_SCALE = 0.05;
  float hash2D( vec2 value ) {
    return fract( 1.0e4 * sin( 17.0 * value.x + 0.1 * value.y ) * ( 0.1 + abs( sin( 13.0 * value.y + value.x ) ) ) );
  }
  float hash3D( vec3 value ) {
    return hash2D( vec2( hash2D( value.xy ), value.z ) );
  }
  float getAlphaHashThreshold( vec3 position ) {
    float maxDeriv = max(
      length( dFdx( position.xyz ) ),
      length( dFdy( position.xyz ) )
    );
    float pixScale = 1.0 / ( ALPHA_HASH_SCALE * maxDeriv );
    vec2 pixScales = vec2(
      exp2( floor( log2( pixScale ) ) ),
      exp2( ceil( log2( pixScale ) ) )
    );
    vec2 alpha = vec2(
      hash3D( floor( pixScales.x * position.xyz ) ),
      hash3D( floor( pixScales.y * position.xyz ) )
    );
    float lerpFactor = fract( log2( pixScale ) );
    float x = ( 1.0 - lerpFactor ) * alpha.x + lerpFactor * alpha.y;
    float a = min( lerpFactor, 1.0 - lerpFactor );
    vec3 cases = vec3(
      x * x / ( 2.0 * a * ( 1.0 - a ) ),
      ( x - 0.5 * a ) / ( 1.0 - a ),
      1.0 - ( ( 1.0 - x ) * ( 1.0 - x ) / ( 2.0 * a * ( 1.0 - a ) ) )
    );
    float threshold = ( x < ( 1.0 - a ) )
      ? ( ( x < a ) ? cases.x : cases.y )
      : cases.z;
    return clamp( threshold , 1.0e-6, 1.0 );
  }
#endif
// end <alphahash_pars_fragment>


// start <aomap_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/aomap_pars_fragment.glsl.js
#ifdef USE_AOMAP
  uniform sampler2D aoMap;
  uniform float aoMapIntensity;
#endif
// end <aomap_pars_fragment>


// start <lightmap_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/lightmap_pars_fragment.glsl.js
#ifdef USE_LIGHTMAP
  uniform sampler2D lightMap;
  uniform float lightMapIntensity;
#endif
// end <lightmap_pars_fragment>


// start <envmap_common_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/envmap_common_pars_fragment.glsl.js
#ifdef USE_ENVMAP
  uniform float envMapIntensity;
  uniform float flipEnvMap;
  #ifdef ENVMAP_TYPE_CUBE
    uniform samplerCube envMap;
  #else
    uniform sampler2D envMap;
  #endif
  
#endif
// end <envmap_common_pars_fragment>


// start <envmap_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/envmap_pars_fragment.glsl.js
#ifdef USE_ENVMAP
  uniform float reflectivity;
  #if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )
    #define ENV_WORLDPOS
  #endif
  #ifdef ENV_WORLDPOS
    varying vec3 vWorldPosition;
    uniform float refractionRatio;
  #else
    varying vec3 vReflect;
  #endif
#endif
// end <envmap_pars_fragment>


// start <fog_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/fog_pars_fragment.glsl.js
#ifdef USE_FOG
  uniform vec3 fogColor;
  varying float vFogDepth;
  #ifdef FOG_EXP2
    uniform float fogDensity;
  #else
    uniform float fogNear;
    uniform float fogFar;
  #endif
#endif
// end <fog_pars_fragment>


// start <specularmap_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/specularmap_pars_fragment.glsl.js
#ifdef USE_SPECULARMAP
  uniform sampler2D specularMap;
#endif
// end <specularmap_pars_fragment>


// start <logdepthbuf_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/logdepthbuf_pars_fragment.glsl.js
#if defined( USE_LOGDEPTHBUF ) && defined( USE_LOGDEPTHBUF_EXT )
  uniform float logDepthBufFC;
  varying float vFragDepth;
  varying float vIsPerspective;
#endif
// end <logdepthbuf_pars_fragment>


// start <clipping_planes_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/clipping_planes_pars_fragment.glsl.js
#if 0 > 0
  varying vec3 vClipPosition;
  uniform vec4 clippingPlanes[ 0 ];
#endif
// end <clipping_planes_pars_fragment>

void main() {
  vec4 diffuseColor = vec4( diffuse, opacity );
  
// start <clipping_planes_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/clipping_planes_fragment.glsl.js
#if 0 > 0
  vec4 plane;
  #ifdef ALPHA_TO_COVERAGE
    float distanceToPlane, distanceGradient;
    float clipOpacity = 1.0;
    
    #if 0 < 0
      float unionClipOpacity = 1.0;
      
      clipOpacity *= 1.0 - unionClipOpacity;
    #endif
    diffuseColor.a *= clipOpacity;
    if ( diffuseColor.a == 0.0 ) discard;
  #else
    
    #if 0 < 0
      bool clipped = true;
      
      if ( clipped ) discard;
    #endif
  #endif
#endif
// end <clipping_planes_fragment>

  
// start <logdepthbuf_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/logdepthbuf_fragment.glsl.js
#if defined( USE_LOGDEPTHBUF ) && defined( USE_LOGDEPTHBUF_EXT )
  gl_FragDepthEXT = vIsPerspective == 0.0 ? gl_FragCoord.z : log2( vFragDepth ) * logDepthBufFC * 0.5;
#endif
// end <logdepthbuf_fragment>

  
// start <map_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/map_fragment.glsl.js
#ifdef USE_MAP
  vec4 sampledDiffuseColor = texture2D( map, vMapUv );
  #ifdef DECODE_VIDEO_TEXTURE
    sampledDiffuseColor = vec4( mix( pow( sampledDiffuseColor.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), sampledDiffuseColor.rgb * 0.0773993808, vec3( lessThanEqual( sampledDiffuseColor.rgb, vec3( 0.04045 ) ) ) ), sampledDiffuseColor.w );
  
  #endif
  diffuseColor *= sampledDiffuseColor;
#endif
// end <map_fragment>

  
// start <color_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/color_fragment.glsl.js
#if defined( USE_COLOR_ALPHA )
  diffuseColor *= vColor;
#elif defined( USE_COLOR )
  diffuseColor.rgb *= vColor;
#endif
// end <color_fragment>

  
// start <alphamap_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/alphamap_fragment.glsl.js
#ifdef USE_ALPHAMAP
  diffuseColor.a *= texture2D( alphaMap, vAlphaMapUv ).g;
#endif
// end <alphamap_fragment>

  
// start <alphatest_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/alphatest_fragment.glsl.js
#ifdef USE_ALPHATEST
  #ifdef ALPHA_TO_COVERAGE
  diffuseColor.a = smoothstep( alphaTest, alphaTest + fwidth( diffuseColor.a ), diffuseColor.a );
  if ( diffuseColor.a == 0.0 ) discard;
  #else
  if ( diffuseColor.a < alphaTest ) discard;
  #endif
#endif
// end <alphatest_fragment>

  
// start <alphahash_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/alphahash_fragment.glsl.js
#ifdef USE_ALPHAHASH
  if ( diffuseColor.a < getAlphaHashThreshold( vPosition ) ) discard;
#endif
// end <alphahash_fragment>

  
// start <specularmap_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/specularmap_fragment.glsl.js
float specularStrength;
#ifdef USE_SPECULARMAP
  vec4 texelSpecular = texture2D( specularMap, vSpecularMapUv );
  specularStrength = texelSpecular.r;
#else
  specularStrength = 1.0;
#endif
// end <specularmap_fragment>

  ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
  #ifdef USE_LIGHTMAP
    vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
    reflectedLight.indirectDiffuse += lightMapTexel.rgb * lightMapIntensity * RECIPROCAL_PI;
  #else
    reflectedLight.indirectDiffuse += vec3( 1.0 );
  #endif
  
// start <aomap_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/aomap_fragment.glsl.js
#ifdef USE_AOMAP
  float ambientOcclusion = ( texture2D( aoMap, vAoMapUv ).r - 1.0 ) * aoMapIntensity + 1.0;
  reflectedLight.indirectDiffuse *= ambientOcclusion;
  #if defined( USE_CLEARCOAT ) 
    clearcoatSpecularIndirect *= ambientOcclusion;
  #endif
  #if defined( USE_SHEEN ) 
    sheenSpecularIndirect *= ambientOcclusion;
  #endif
  #if defined( USE_ENVMAP ) && defined( STANDARD )
    float dotNV = saturate( dot( geometryNormal, geometryViewDir ) );
    reflectedLight.indirectSpecular *= computeSpecularOcclusion( dotNV, ambientOcclusion, material.roughness );
  #endif
#endif
// end <aomap_fragment>

  reflectedLight.indirectDiffuse *= diffuseColor.rgb;
  vec3 outgoingLight = reflectedLight.indirectDiffuse;
  
// start <envmap_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/envmap_fragment.glsl.js
#ifdef USE_ENVMAP
  #ifdef ENV_WORLDPOS
    vec3 cameraToFrag;
    if ( isOrthographic ) {
      cameraToFrag = normalize( vec3( - viewMatrix[ 0 ][ 2 ], - viewMatrix[ 1 ][ 2 ], - viewMatrix[ 2 ][ 2 ] ) );
    } else {
      cameraToFrag = normalize( vWorldPosition - cameraPosition );
    }
    vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );
    #ifdef ENVMAP_MODE_REFLECTION
      vec3 reflectVec = reflect( cameraToFrag, worldNormal );
    #else
      vec3 reflectVec = refract( cameraToFrag, worldNormal, refractionRatio );
    #endif
  #else
    vec3 reflectVec = vReflect;
  #endif
  #ifdef ENVMAP_TYPE_CUBE
    vec4 envColor = textureCube( envMap, vec3( flipEnvMap * reflectVec.x, reflectVec.yz ) );
  #else
    vec4 envColor = vec4( 0.0 );
  #endif
  #ifdef ENVMAP_BLENDING_MULTIPLY
    outgoingLight = mix( outgoingLight, outgoingLight * envColor.xyz, specularStrength * reflectivity );
  #elif defined( ENVMAP_BLENDING_MIX )
    outgoingLight = mix( outgoingLight, envColor.xyz, specularStrength * reflectivity );
  #elif defined( ENVMAP_BLENDING_ADD )
    outgoingLight += envColor.xyz * specularStrength * reflectivity;
  #endif
#endif
// end <envmap_fragment>

  
// start <opaque_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/opaque_fragment.glsl.js
#ifdef OPAQUE
diffuseColor.a = 1.0;
#endif
#ifdef USE_TRANSMISSION
diffuseColor.a *= material.transmissionAlpha;
#endif
gl_FragColor = vec4( outgoingLight, diffuseColor.a );
// end <opaque_fragment>

  
// start <tonemapping_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/tonemapping_fragment.glsl.js
#if defined( TONE_MAPPING )
  gl_FragColor.rgb = toneMapping( gl_FragColor.rgb );
#endif
// end <tonemapping_fragment>

  
// start <colorspace_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/colorspace_fragment.glsl.js
gl_FragColor = linearToOutputTexel( gl_FragColor );
// end <colorspace_fragment>

  
// start <fog_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/fog_fragment.glsl.js
#ifdef USE_FOG
  #ifdef FOG_EXP2
    float fogFactor = 1.0 - exp( - fogDensity * fogDensity * vFogDepth * vFogDepth );
  #else
    float fogFactor = smoothstep( fogNear, fogFar, vFogDepth );
  #endif
  gl_FragColor.rgb = mix( gl_FragColor.rgb, fogColor, fogFactor );
#endif
// end <fog_fragment>

  
// start <premultiplied_alpha_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/premultiplied_alpha_fragment.glsl.js
#ifdef PREMULTIPLIED_ALPHA
  gl_FragColor.rgb *= gl_FragColor.a;
#endif
// end <premultiplied_alpha_fragment>

  
// start <dithering_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/dithering_fragment.glsl.js
#ifdef DITHERING
  gl_FragColor.rgb = dithering( gl_FragColor.rgb );
#endif
// end <dithering_fragment>

}