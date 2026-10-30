import { createApp } from 'vue'
import { resetDemo } from './demo-api.js'
const view = location.pathname.startsWith('/admin') ? 'admin' : location.pathname.startsWith('/mobile') ? 'mobile' : 'web'
const pages = {
  web: () => Promise.all([import('../web/src/App.vue'), import('../web/src/style.css')]),
  admin: () => Promise.all([import('../admin/src/App.vue'), import('../admin/src/style.css')]),
  mobile: () => Promise.all([import('../mobile/src/App.vue'), import('../mobile/src/style.css')]),
}
const toolbar = document.querySelector('#demo-toolbar').attachShadow({ mode: 'open' })
toolbar.innerHTML = `<style>
:host{display:block;position:relative;z-index:10}*{box-sizing:border-box}nav{font:13px/1.5 system-ui,sans-serif;color:#edf1e9;background:#203f49;padding:12px 20px;display:flex;gap:16px;align-items:center;flex-wrap:wrap}strong{font-size:13px}span{flex:1;color:#d3dfda}a{color:inherit;text-decoration:none;padding:4px 7px;border-radius:5px}a[aria-current=page]{background:#ffffff24}button{font:inherit;color:inherit;border:1px solid #ffffff55;background:none;border-radius:5px;padding:4px 9px;cursor:pointer}@media(max-width:600px){nav{gap:5px;padding:9px 12px}span{flex-basis:100%;font-size:11px;order:2}strong{margin-right:auto}}
</style><nav aria-label="原型演示导航"><strong>前端演示</strong><span>虚构数据 · 仅保存于本浏览器 · 切换页面查看更改</span><a href="/" ${view === 'web' ? 'aria-current="page"' : ''}>Web</a><a href="/admin/" ${view === 'admin' ? 'aria-current="page"' : ''}>管理端</a><a href="/mobile/" ${view === 'mobile' ? 'aria-current="page"' : ''}>移动端</a><button type="button">重置演示</button></nav>`
toolbar.querySelector('button').addEventListener('click', () => {
  if (!confirm('恢复初始演示数据？这会清除本浏览器中创建和修改的演示展览。')) return
  try { resetDemo(); location.reload() } catch (e) { alert(e.message) }
})
const [module] = await pages[view]()
createApp(module.default, { demo: true }).mount('#app')
if (view === 'admin') {
  const style = document.createElement('style')
  style.textContent = '.admin-layout .sidebar{top:var(--demo-toolbar-height)}'
  document.head.append(style)
  new ResizeObserver(([entry]) => document.documentElement.style.setProperty('--demo-toolbar-height', `${entry.contentRect.height}px`)).observe(document.querySelector('#demo-toolbar'))
}
