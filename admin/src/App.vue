<script setup>
import { computed, onMounted, ref } from 'vue'
import { request, labels, date } from './api'
const { demo = false } = defineProps({ demo: Boolean })
const user = ref(null), username = ref('curator'), password = ref(''), items = ref([])
const q = ref(''), status = ref(''), loading = ref(false), busy = ref(false), error = ref(''), notice = ref(''), form = ref(null)
const covers = ['/assets/厦园晨雾.png', '/assets/凤凰花季.png', '/assets/瓦影.png', '/assets/向海.png']
const filtered = computed(() => items.value.filter(x => x.title.includes(q.value) && (!status.value || x.status === status.value)))
const published = computed(() => items.value.filter(x => x.visible).length)
function fail(e) { error.value = e.message || '网络连接失败，请重试'; if (e.status === 401) { user.value = null; form.value = null } }
async function load() { loading.value = true; error.value = ''; try { items.value = await request('/api/admin/exhibitions') } catch(e) { fail(e) } finally { loading.value = false } }
async function login() { busy.value = true; error.value = ''; try { user.value = await request('/api/admin/login', { method:'POST', body:JSON.stringify({ username:username.value, password:password.value }) }); password.value = ''; await load() } catch(e) { fail(e) } finally { busy.value = false } }
async function logout() { try { await request('/api/admin/logout', { method:'POST' }); user.value = null; items.value = []; form.value = null; notice.value = '' } catch(e) { fail(e) } }
function edit(item) {
  error.value = ''; notice.value = ''
  form.value = item ? {...item, cover:item.cover || covers[0]} : { title:'', introduction:'', statement:'', venue:'校园线上展厅', cover:covers[0], status:'draft', visible:false, startsAt:'2026-11-01T09:00', endsAt:'2026-11-30T18:00' }
  window.scrollTo({ top:0 })
}
function changeStatus() { if (!['collecting','on_view','archived'].includes(form.value.status)) form.value.visible = false }
async function save() {
  busy.value = true; error.value = ''
  try {
    const f = form.value
    await request('/api/admin/exhibitions' + (f.id ? '/' + f.id : ''), { method:f.id ? 'PUT' : 'POST', body:JSON.stringify(f) })
    form.value = null; notice.value = demo ? '已保存到本浏览器，切换 Web 或移动端查看公开内容。' : '展览已保存，公开内容已同步至 Web 与移动端。'; await load()
  } catch(e) { fail(e) } finally { busy.value = false }
}
async function toggle(item) {
  if (!confirm(item.visible ? '下架后，Web 和移动端将无法查看此展览。确认下架？' : '确认公开此展览？')) return
  busy.value = true; error.value = ''; notice.value = ''
  try { await request('/api/admin/exhibitions/' + item.id, { method:'PUT', body:JSON.stringify({...item, visible:!item.visible}) }); notice.value = item.visible ? '展览已下架，记录已保留。' : '展览已公开。'; await load() } catch(e) { fail(e) } finally { busy.value = false }
}
async function remove(item) {
  if (!confirm('确认永久删除草稿“' + item.title + '”？此操作无法撤销。')) return
  busy.value = true; error.value = ''; notice.value = ''
  try { await request('/api/admin/exhibitions/' + item.id, {method:'DELETE'}); notice.value = '草稿已删除。'; await load() } catch(e) { fail(e) } finally { busy.value = false }
}
onMounted(async () => { try { user.value = await request('/api/admin/session'); await load() } catch(e) { if(e.status !== 401) fail(e) } })
</script>

<template>
  <main v-if="!user" class="login-page">
    <section class="login-art"><span class="brand">展序·厦大</span><div><p class="eyebrow">XIAYUAN · CURATOR STUDIO</p><h1>让每一场展览，<br>有序地发生。</h1><p>从一份策展构想到一次校园相遇。</p></div><small>校园艺术与创作 · 课程演示</small></section>
    <form class="login-form" @submit.prevent="login"><p class="eyebrow">CURATOR ACCESS</p><h2>{{ demo ? '进入策展演示' : '登录策展工作台' }}</h2><p class="muted">管理展览，让创作被看见。</p><label v-if="!demo">管理员账号<input v-model="username" autocomplete="username" required maxlength="80"></label><label v-if="!demo">密码<input v-model="password" type="password" autocomplete="current-password" required></label><p v-if="error" class="error" role="alert">{{ error }}</p><button class="primary" :disabled="busy">{{ busy ? '正在登录…' : (demo ? '进入演示工作台 →' : '登录工作台 →') }}</button><small>{{ demo ? '无需账号。更改仅保存在本浏览器，不会写入真实数据库。' : '使用部署时配置的管理员账号。' }}</small></form>
  </main>
  <div v-else class="admin-layout">
    <aside class="sidebar"><a class="brand" href="#" @click.prevent="form=null">展序·厦大</a><small>策展管理工作台</small><p class="nav-label">工作空间 / WORKSPACE</p><button class="nav-active" @click="form=null">▦　展览管理 <span>→</span></button><div class="sidebar-note"><span>校园艺术与创作</span><p>把厦园的日常，<br>编排成值得相遇的展览。</p></div><div class="account"><span class="avatar">策</span><div>{{ user.username }}<small>平台管理员</small></div><button class="logout" @click="logout">退出</button></div></aside>
    <main class="workspace"><header class="topbar"><span>工作空间　 /　 展览管理<span v-if="form">　 /　{{ form.id ? '编辑展览' : '创建展览' }}</span></span><span class="live-dot">展览管理服务</span></header>
      <div class="page-heading"><div><p class="eyebrow">EXHIBITION MANAGEMENT</p><h1>{{ form ? (form.id ? '编辑展览' : '创建展览') : '展览管理' }}</h1><p class="muted">{{ form ? '完善展览内容，设置展期与公开状态。' : '管理展览状态、公开信息与校园创作档案。' }}</p></div><button v-if="!form" class="primary" @click="edit(null)">＋ 创建展览</button><button v-else class="secondary" @click="form=null">← 返回列表</button></div>
      <p v-if="error" class="error" role="alert">{{ error }} <button v-if="!form" @click="load">重新加载</button></p><p v-if="notice" class="success" role="status">{{ notice }}</p>
      <template v-if="!form"><section class="stats"><article><span>全部展览</span><strong>{{ items.length.toString().padStart(2,'0') }}</strong><small>持续积累校园创作档案</small></article><article><span>公开展览</span><strong>{{ published.toString().padStart(2,'0') }}</strong><small>Web 与移动端同步展示</small></article><article><span>草稿 / 待完善</span><strong>{{ items.filter(x=>x.status==='draft').length.toString().padStart(2,'0') }}</strong><small>内容准备完成后再公开</small></article></section>
      <section class="panel"><div class="table-tools"><h2>展览档案 <small>{{ filtered.length }} 项</small></h2><div><input v-model="q" type="search" aria-label="搜索展览" placeholder="搜索展览名称" maxlength="160"><select v-model="status" aria-label="筛选展览状态"><option value="">全部状态</option><option v-for="(label,key) in labels" :key="key" :value="key">{{ label }}</option></select><button class="secondary" :disabled="loading" @click="load">刷新</button></div></div>
      <p v-if="loading" class="empty" role="status">正在加载展览…</p><div v-else class="table-scroll"><table><thead><tr><th>展览名称</th><th>展期 / 地点</th><th>业务状态</th><th>可见性</th><th>操作</th></tr></thead><tbody><tr v-for="item in filtered" :key="item.id"><td><div class="exhibit-cell"><img :src="item.cover || covers[0]" alt=""><div><strong>{{ item.title }}</strong><small>EX-{{ String(item.id).padStart(3,'0') }}</small></div></div></td><td><span>{{ date(item.startsAt).slice(0,10) }} — {{ date(item.endsAt).slice(0,10) }}</span><small>{{ item.venue }}</small></td><td><span class="badge" :class="item.status">{{ labels[item.status] }}</span></td><td><span :class="item.visible ? 'visible' : 'muted'">{{ item.visible ? '● 公开' : '○ 未公开' }}</span></td><td class="actions"><button @click="edit(item)" :disabled="busy">编辑</button><button v-if="['collecting','on_view','archived'].includes(item.status)" @click="toggle(item)" :disabled="busy">{{ item.visible ? '下架' : '公开' }}</button><button v-if="item.status==='draft' && !item.visible" @click="remove(item)" :disabled="busy">删除</button></td></tr></tbody></table><p v-if="!filtered.length" class="empty">没有符合条件的展览。调整搜索条件或创建新展览。</p></div></section>
      <section class="workflow"><span>展览生命周期</span><p>草稿 <b>→</b> 征集中 <b>→</b> 筹备中 <b>→</b> 展出中 <b>→</b> 已归档</p><small>业务阶段与公开状态独立管理；下架后保留展览记录。</small></section></template>
      <form v-else class="editor" @submit.prevent="save"><section class="panel fields"><h2>基本信息</h2><label>展览标题 *<input v-model="form.title" required maxlength="160" placeholder="为这场展览取一个名字"></label><label>展览简介 *<textarea v-model="form.introduction" required maxlength="1000" rows="3" placeholder="简要介绍展览主题与内容"></textarea></label><div class="date-fields"><label>开始时间 *<input v-model="form.startsAt" type="datetime-local" required></label><label>结束时间 *<input v-model="form.endsAt" type="datetime-local" required></label></div><label>展览地点 *<input v-model="form.venue" required maxlength="255"></label><label>策展序言<textarea v-model="form.statement" maxlength="5000" rows="5" placeholder="写下本次展览的策展思路"></textarea></label></section>
      <section class="panel publish"><h2>封面与发布</h2><img class="cover-preview" :src="form.cover" alt="当前展览封面"><div class="cover-options"><button v-for="cover in covers" :key="cover" type="button" :class="{selected:form.cover===cover}" @click="form.cover=cover" :aria-label="'选择封面 '+cover.split('/').pop()" :aria-pressed="form.cover===cover"><img :src="cover" alt=""></button></div><label>业务状态<select v-model="form.status" aria-label="业务状态" @change="changeStatus"><option v-for="(label,key) in labels" :key="key" :value="key">{{ label }}</option></select></label><label class="checkbox"><input v-model="form.visible" type="checkbox" :disabled="!['collecting','on_view','archived'].includes(form.status)">向观众公开</label><p class="muted">公开后，观众可在 Web 与移动端浏览。草稿、筹备中和已取消状态不公开。</p><button class="primary" :disabled="busy">{{ busy ? '正在保存…' : '保存展览' }}</button><button type="button" class="secondary" @click="form=null" :disabled="busy">取消编辑</button></section></form>
      <footer>展序·厦大 / 校园艺术展览平台 <span>课程演示 · 数据为虚构内容</span></footer>
    </main>
  </div>
</template>
