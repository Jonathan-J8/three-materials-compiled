// TODO : find a better solution for typescript shenanigans
import * as TTT from "https://cdn.jsdelivr.net/npm/three@latest/build/three.module.js";
import type * as THREE from "three";

const ModuleNamespace: typeof THREE = TTT;

export default ModuleNamespace;
