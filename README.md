# three-materials-compiled

Are you tired of constantly searching for the meanings of different chunks in three.js shaders?

In [./materials](./materials/), you'll find all the codes organized as follows:

- materialName.frag.compiled.glsl
- materialName.frag.pre.compiled.glsl
- materialName.uniforms.glsl
- materialName.vert.compiled.glsl
- materialName.vert.pre.compiled.glsl

## Scripts

If you need to recompile the related codes from materials, follow these steps:

```bash
cd ./compiler
npm install
npm start
```

Caution: It will automatically download all the shader codes for you in your default download folder.  
If you need to modify the source code, navigate to [./scripts/src](./scripts/src/) as [./scripts/src/main.ts](./scripts/src/main.ts) is the entry point.
