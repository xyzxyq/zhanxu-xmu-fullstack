import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath } from 'node:url'
export default defineConfig({
  plugins: [vue(), { name: 'prototype-api', enforce: 'pre', resolveId(source, importer) {
    if (source === './api' && importer?.endsWith('/src/App.vue')) return fileURLToPath(new URL('./demo-api.js', import.meta.url))
  } }],
  resolve: { alias: { vue: fileURLToPath(new URL('./node_modules/vue/dist/vue.runtime.esm-bundler.js', import.meta.url)) } },
  publicDir: '../web/public',
  server: { host: '127.0.0.1' },
})
