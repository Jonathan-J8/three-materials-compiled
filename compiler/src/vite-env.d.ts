/// <reference types="vite/client" />

declare global {
  const __APP_VERSION__: string;

  interface Window {
    h1Element: HTMLElement;
    h2Element: HTMLElement;
    btnElement: HTMLButtonElement;
    launchCompilation: () => void;
  }
}

export {};
