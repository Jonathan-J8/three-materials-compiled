import { defineConfig } from "vite";
export default defineConfig({
  server: {
    port: 8080,
    hmr: true,
    open: "/index.html",
  },
  define: {
    __APP_VERSION__: JSON.stringify(process.env.npm_package_version),
  },
});
