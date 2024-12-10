#version 300 es
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
#define SHADER_TYPE MeshMatcapMaterial
#define SHADER_NAME 
#define MATCAP 
uniform mat4 viewMatrix;
uniform vec3 cameraPosition;
uniform bool isOrthographic;
#define OPAQUE
vec4 LinearTransferOETF( in vec4 value ) {
  return value;
}
vec4 sRGBTransferEOTF( in vec4 value ) {
  return vec4( mix( pow( value.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), value.rgb * 0.0773993808, vec3( lessThanEqual( value.rgb, vec3( 0.04045 ) ) ) ), value.a );
}
vec4 sRGBTransferOETF( in vec4 value ) {
  return vec4( mix( pow( value.rgb, vec3( 0.41666 ) ) * 1.055 - vec3( 0.055 ), value.rgb * 12.92, vec3( lessThanEqual( value.rgb, vec3( 0.0031308 ) ) ) ), value.a );
}
vec4 linearToOutputTexel( vec4 value ) {
  return sRGBTransferOETF( vec4( value.rgb * mat3( 1.0000,-0.0000,-0.0000,-0.0000,1.0000,0.0000,0.0000,0.0000,1.0000 ), value.a ) );
}
float luminance( const in vec3 rgb ) {
  const vec3 weights = vec3( 0.2126, 0.7152, 0.0722 );
  return dot( weights, rgb );
}

#define MATCAP
uniform vec3 diffuse;
uniform float opacity;
uniform sampler2D matcap;
varying vec3 vViewPosition;

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


// start <normal_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/normal_pars_fragment.glsl.js
#ifndef FLAT_SHADED
  varying vec3 vNormal;
  #ifdef USE_TANGENT
    varying vec3 vTangent;
    varying vec3 vBitangent;
  #endif
#endif
// end <normal_pars_fragment>


// start <bumpmap_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/bumpmap_pars_fragment.glsl.js
#ifdef USE_BUMPMAP
  uniform sampler2D bumpMap;
  uniform float bumpScale;
  vec2 dHdxy_fwd() {
    vec2 dSTdx = dFdx( vBumpMapUv );
    vec2 dSTdy = dFdy( vBumpMapUv );
    float Hll = bumpScale * texture2D( bumpMap, vBumpMapUv ).x;
    float dBx = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdx ).x - Hll;
    float dBy = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdy ).x - Hll;
    return vec2( dBx, dBy );
  }
  vec3 perturbNormalArb( vec3 surf_pos, vec3 surf_norm, vec2 dHdxy, float faceDirection ) {
    vec3 vSigmaX = normalize( dFdx( surf_pos.xyz ) );
    vec3 vSigmaY = normalize( dFdy( surf_pos.xyz ) );
    vec3 vN = surf_norm;
    vec3 R1 = cross( vSigmaY, vN );
    vec3 R2 = cross( vN, vSigmaX );
    float fDet = dot( vSigmaX, R1 ) * faceDirection;
    vec3 vGrad = sign( fDet ) * ( dHdxy.x * R1 + dHdxy.y * R2 );
    return normalize( abs( fDet ) * surf_norm - vGrad );
  }
#endif
// end <bumpmap_pars_fragment>


// start <normalmap_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/normalmap_pars_fragment.glsl.js
#ifdef USE_NORMALMAP
  uniform sampler2D normalMap;
  uniform vec2 normalScale;
#endif
#ifdef USE_NORMALMAP_OBJECTSPACE
  uniform mat3 normalMatrix;
#endif
#if ! defined ( USE_TANGENT ) && ( defined ( USE_NORMALMAP_TANGENTSPACE ) || defined ( USE_CLEARCOAT_NORMALMAP ) || defined( USE_ANISOTROPY ) )
  mat3 getTangentFrame( vec3 eye_pos, vec3 surf_norm, vec2 uv ) {
    vec3 q0 = dFdx( eye_pos.xyz );
    vec3 q1 = dFdy( eye_pos.xyz );
    vec2 st0 = dFdx( uv.st );
    vec2 st1 = dFdy( uv.st );
    vec3 N = surf_norm;
    vec3 q1perp = cross( q1, N );
    vec3 q0perp = cross( N, q0 );
    vec3 T = q1perp * st0.x + q0perp * st1.x;
    vec3 B = q1perp * st0.y + q0perp * st1.y;
    float det = max( dot( T, T ), dot( B, B ) );
    float scale = ( det == 0.0 ) ? 0.0 : inversesqrt( det );
    return mat3( T * scale, B * scale, N );
  }
#endif
// end <normalmap_pars_fragment>


// start <logdepthbuf_pars_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/logdepthbuf_pars_fragment.glsl.js
#if defined( USE_LOGDEPTHBUF )
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
#if defined( USE_LOGDEPTHBUF )
  gl_FragDepth = vIsPerspective == 0.0 ? gl_FragCoord.z : log2( vFragDepth ) * logDepthBufFC * 0.5;
#endif
// end <logdepthbuf_fragment>

  
// start <map_fragment> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/map_fragment.glsl.js
#ifdef USE_MAP
  vec4 sampledDiffuseColor = texture2D( map, vMapUv );
  #ifdef DECODE_VIDEO_TEXTURE
    sampledDiffuseColor = sRGBTransferEOTF( sampledDiffuseColor );
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

  
// start <normal_fragment_begin> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/normal_fragment_begin.glsl.js
float faceDirection = gl_FrontFacing ? 1.0 : - 1.0;
#ifdef FLAT_SHADED
  vec3 fdx = dFdx( vViewPosition );
  vec3 fdy = dFdy( vViewPosition );
  vec3 normal = normalize( cross( fdx, fdy ) );
#else
  vec3 normal = normalize( vNormal );
  #ifdef DOUBLE_SIDED
    normal *= faceDirection;
  #endif
#endif
#if defined( USE_NORMALMAP_TANGENTSPACE ) || defined( USE_CLEARCOAT_NORMALMAP ) || defined( USE_ANISOTROPY )
  #ifdef USE_TANGENT
    mat3 tbn = mat3( normalize( vTangent ), normalize( vBitangent ), normal );
  #else
    mat3 tbn = getTangentFrame( - vViewPosition, normal,
    #if defined( USE_NORMALMAP )
      vNormalMapUv
    #elif defined( USE_CLEARCOAT_NORMALMAP )
      vClearcoatNormalMapUv
    #else
      vUv
    #endif
    );
  #endif
  #if defined( DOUBLE_SIDED ) && ! defined( FLAT_SHADED )
    tbn[0] *= faceDirection;
    tbn[1] *= faceDirection;
  #endif
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
  #ifdef USE_TANGENT
    mat3 tbn2 = mat3( normalize( vTangent ), normalize( vBitangent ), normal );
  #else
    mat3 tbn2 = getTangentFrame( - vViewPosition, normal, vClearcoatNormalMapUv );
  #endif
  #if defined( DOUBLE_SIDED ) && ! defined( FLAT_SHADED )
    tbn2[0] *= faceDirection;
    tbn2[1] *= faceDirection;
  #endif
#endif
vec3 nonPerturbedNormal = normal;
// end <normal_fragment_begin>

  
// start <normal_fragment_maps> https://github.com/mrdoob/three.js/blob/master/src/renderers/shaders/ShaderChunk/normal_fragment_maps.glsl.js
#ifdef USE_NORMALMAP_OBJECTSPACE
  normal = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;
  #ifdef FLIP_SIDED
    normal = - normal;
  #endif
  #ifdef DOUBLE_SIDED
    normal = normal * faceDirection;
  #endif
  normal = normalize( normalMatrix * normal );
#elif defined( USE_NORMALMAP_TANGENTSPACE )
  vec3 mapN = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;
  mapN.xy *= normalScale;
  normal = normalize( tbn * mapN );
#elif defined( USE_BUMPMAP )
  normal = perturbNormalArb( - vViewPosition, normal, dHdxy_fwd(), faceDirection );
#endif
// end <normal_fragment_maps>

  vec3 viewDir = normalize( vViewPosition );
  vec3 x = normalize( vec3( viewDir.z, 0.0, - viewDir.x ) );
  vec3 y = cross( viewDir, x );
  vec2 uv = vec2( dot( x, normal ), dot( y, normal ) ) * 0.495 + 0.5;
  #ifdef USE_MATCAP
    vec4 matcapColor = texture2D( matcap, uv );
  #else
    vec4 matcapColor = vec4( vec3( mix( 0.2, 0.8, uv.y ) ), 1.0 );
  #endif
  vec3 outgoingLight = diffuseColor.rgb * matcapColor.rgb;
  
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