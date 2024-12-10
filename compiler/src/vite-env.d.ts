/// <reference types="vite/client" />

import type * as THREE from "three";
declare global {
  const __APP_VERSION__: string;
  const THREE: THREE;

  interface Window {
    h1Element: HTMLElement;
    h2Element: HTMLElement;
    launchCompilation: () => void;
  }
}

export {};
