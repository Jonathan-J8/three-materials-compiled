import { defineConfig } from "vite";
export default defineConfig({
  server: {
    hmr: true,
    open: "/index.html",
  },
  define: {
    __APP_VERSION__: JSON.stringify(process.env.npm_package_version),
  },
});
