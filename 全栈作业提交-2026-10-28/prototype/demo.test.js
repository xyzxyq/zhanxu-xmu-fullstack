import test from 'node:test'
import assert from 'node:assert/strict'
import { request, resetDemo } from './demo-api.js'
const storage = () => { const data = new Map(); return {getItem:k=>data.get(k) ?? null, setItem:(k,v)=>data.set(k,v), removeItem:k=>data.delete(k)} }
globalThis.localStorage = storage(); globalThis.sessionStorage = storage()
test('演示创建、公开、隐藏、删除、输入校验和重置', async () => {
  assert.equal((await request('/api/exhibitions')).length, 3)
  await assert.rejects(request('/api/admin/exhibitions'), {status:401})
  await assert.rejects(request('/api/exhibitions/4'), {status:404})
  await request('/api/admin/login', {method:'POST'})
  const draft = (await request('/api/admin/exhibitions')).find(x=>x.id===5)
  const save = body => request('/api/admin/exhibitions', {method:'POST', body:JSON.stringify(body)})
  await assert.rejects(save({...draft,visible:true}), {status:400})
  await assert.rejects(save({...draft,endsAt:draft.startsAt}), {status:400})
  await assert.rejects(save({...draft,cover:'https://example.com/private.png'}), {status:400})
  const item = await save({...draft,title:'测试展览',status:'on_view',visible:true})
  assert.equal((await request('/api/exhibitions?q=测试&status=on_view'))[0].id, item.id)
  await request(`/api/admin/exhibitions/${item.id}`, {method:'PUT',body:JSON.stringify({...item,visible:false,status:'draft'})})
  await assert.rejects(request(`/api/exhibitions/${item.id}`), {status:404})
  await request(`/api/admin/exhibitions/${item.id}`, {method:'DELETE'})
  assert.equal((await request('/api/admin/exhibitions')).length, 5)
  localStorage.setItem('zhanxu-public-prototype-v1','broken')
  await assert.rejects(request('/api/exhibitions'), {status:503})
  resetDemo(); assert.equal((await request('/api/exhibitions')).length, 3)
  await request('/api/admin/logout',{method:'POST'})
  await assert.rejects(request('/api/admin/session'),{status:401})
})
