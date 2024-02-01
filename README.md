# three-materials-compiled

Are you tired of constantly searching for the meanings of different chunks in three.js shaders?

In [./materials](./materials/), you'll find all the codes organized as follows:

- material.frag.compiled.glsl
- material.vert.compiled.glsl
- material.frag.pre.compiled.glsl
- material.vert.pre.compiled.glsl
- material.uniforms.glsl

## Scripts

If you need to recompile the related codes from materials, follow these steps:

```bash
cd ./compiler
npm install
npm start
```

Caution: It will automatically download all the shader codes for you in your default download folder.  
If you need to modify the source code, navigate to [./scripts/src](./scripts/src/) as [./scripts/src/main.ts](./scripts/src/main.ts) is the entry point.
