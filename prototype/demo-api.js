import { exhibitions, works } from './seed.js'
export { labels, date } from '../web/src/api.js'
const key = 'zhanxu-public-prototype-v1', sessionKey = 'zhanxu-demo-session'
const publicStatuses = ['collecting', 'on_view', 'archived']
const statuses = ['draft', 'preparing', 'cancelled', ...publicStatuses]
const covers = [...new Set(exhibitions.map(item => item.cover))]
const publicItem = item => item.visible && publicStatuses.includes(item.status)
function fail(message, status = 400) { throw Object.assign(new Error(message), { status }) }
function read() {
  let raw
  try { raw = localStorage.getItem(key) } catch { fail('浏览器禁止本地存储，请允许此站点保存演示数据。', 503) }
  if (raw === null) return structuredClone(exhibitions)
  try {
    const data = JSON.parse(raw)
    if (!Array.isArray(data) || data.some(item => !Number.isSafeInteger(item.id) || !statuses.includes(item.status) || typeof item.title !== 'string')) throw new Error()
    return data
  } catch { fail('本地演示数据无法读取，请使用顶部“重置演示”恢复。', 503) }
}
function write(items) {
  try { localStorage.setItem(key, JSON.stringify(items)) } catch { fail('演示数据保存失败，请检查浏览器存储权限或剩余空间。', 503) }
}
export function resetDemo() {
  try { localStorage.removeItem(key) } catch { fail('无法重置，请检查浏览器存储权限。', 503) }
}
function validate(data) {
  if (!data || typeof data !== 'object') fail('展览数据格式错误。')
  const result = {}
  for (const [field, limit] of Object.entries({title:160, introduction:1000, venue:255, statement:5000})) {
    if (typeof data[field] !== 'string' || data[field].length > limit || (field !== 'statement' && !data[field].trim())) fail('请填写完整的展览信息，并检查文字长度。')
    result[field] = data[field]
  }
  if (!statuses.includes(data.status) || typeof data.visible !== 'boolean') fail('展览状态无效。')
  if (data.visible && !publicStatuses.includes(data.status)) fail('只有征集中、展出中和已归档展览可以公开。')
  if (!covers.includes(data.cover)) fail('请选择已有的课程封面。')
  for (const field of ['startsAt', 'endsAt']) {
    if (typeof data[field] !== 'string' || !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2})?$/.test(data[field]) || !Number.isFinite(Date.parse(data[field]))) fail('展览时间无效。')
  }
  if (Date.parse(data.endsAt) <= Date.parse(data.startsAt)) fail('结束时间必须晚于开始时间。')
  return {...result, status:data.status, visible:data.visible, cover:data.cover, startsAt:data.startsAt, endsAt:data.endsAt}
}
// shortcut: 此会话仅用于课堂界面演示，真实权限与多用户共享必须使用原 Spring Boot 后端。
export async function request(path, options = {}) {
  const url = new URL(path, 'https://prototype.invalid'), method = options.method || 'GET'
  if (url.pathname === '/api/admin/login' && method === 'POST') {
    try { sessionStorage.setItem(sessionKey, 'demo') } catch { fail('请允许浏览器会话存储后进入演示。', 503) }
    return { username:'演示策展员' }
  }
  if (url.pathname.startsWith('/api/admin/')) {
    let loggedIn
    try { loggedIn = sessionStorage.getItem(sessionKey) } catch { fail('无法读取演示会话，请允许浏览器存储。', 503) }
    if (!loggedIn) fail('请先进入演示工作台。', 401)
    if (url.pathname === '/api/admin/session' && method === 'GET') return { username:'演示策展员' }
    if (url.pathname === '/api/admin/logout' && method === 'POST') { sessionStorage.removeItem(sessionKey); return null }
  }
  const items = read()
  if (url.pathname === '/api/home' && method === 'GET') return { works:items.some(item => item.id === 1 && publicItem(item)) ? structuredClone(works) : [] }
  if (url.pathname === '/api/exhibitions' && method === 'GET') {
    const q = (url.searchParams.get('q') || '').trim(), status = url.searchParams.get('status')
    return items.filter(item => publicItem(item) && item.title.includes(q) && (!status || item.status === status))
  }
  if (url.pathname === '/api/admin/exhibitions' && method === 'GET') return items
  const match = url.pathname.match(/^\/api\/(admin\/)?exhibitions\/(\d+)$/)
  if (match && method === 'GET' && !match[1]) {
    const item = items.find(item => item.id === Number(match[2]) && publicItem(item))
    if (!item) fail('展览不存在或尚未公开。', 404)
    return item
  }
  if (url.pathname === '/api/admin/exhibitions' && method === 'POST' || match?.[1] && method === 'PUT') {
    let body
    try { body = JSON.parse(options.body) } catch { fail('展览数据格式错误。') }
    const record = validate(body)
    if (method === 'POST') { record.id = Math.max(0, ...items.map(item => item.id)) + 1; items.push(record) }
    else {
      const index = items.findIndex(item => item.id === Number(match[2]))
      if (index < 0) fail('展览不存在。', 404)
      record.id = items[index].id; items[index] = record
    }
    write(items); return record
  }
  if (match?.[1] && method === 'DELETE') {
    const item = items.find(item => item.id === Number(match[2]))
    if (!item) fail('展览不存在。', 404)
    if (item.visible || item.status !== 'draft' || item.id <= 2) fail('仅可删除未公开、无关联内容的草稿。', 409)
    write(items.filter(record => record.id !== item.id)); return null
  }
  fail('此原型未实现该操作。', 404)
}
