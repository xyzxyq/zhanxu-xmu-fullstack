import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
const settings = { host: '127.0.0.1', port: 5174, strictPort: true, proxy: { '/api': process.env.API_TARGET || 'http://127.0.0.1:8081' } }
export default defineConfig({ plugins: [vue()], server: settings, preview: settings })
