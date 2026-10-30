<script setup>
import { onMounted, onUnmounted, ref } from 'vue'
import { request, labels, date } from './api'
const items=ref([]), detail=ref(null), detailMode=ref(false), q=ref(''), status=ref(''), loading=ref(true), error=ref('')
let sequence=0
async function load() {
  const current=++sequence; loading.value=true; error.value=''; detail.value=null
  const match=location.hash.match(/^#exhibition\/(\d+)$/); detailMode.value=!!match
  try {
    const data=await request(match ? '/api/exhibitions/'+match[1] : '/api/exhibitions?'+new URLSearchParams({q:q.value,status:status.value}))
    if(current===sequence) { if(match) detail.value=data; else items.value=data }
  } catch(e) { if(current===sequence) error.value=e.message || '网络连接失败，请重试' }
  finally { if(current===sequence) loading.value=false }
}
function route() {load();window.scrollTo({top:0})}
function filter(value) {status.value=value;load()}
onMounted(()=>{load();window.addEventListener('hashchange',route)})
onUnmounted(()=>window.removeEventListener('hashchange',route))
</script>
<template>
  <div class="mobile-app"><header><a href="#" class="brand">展序·厦大</a><span>校园艺术与创作</span></header>
    <main><template v-if="!detailMode"><section class="intro"><p class="eyebrow">DISCOVER XIAYUAN</p><h1>在厦园，<br>与一场展览相遇。</h1><p>山海之间，发现校园创作的另一面。</p><img src="/assets/厦园晨雾.png" alt="厦园湖畔与嘉庚建筑"></section>
      <form class="search" @submit.prevent="load"><label class="sr-only" for="search">搜索展览名称</label><input id="search" v-model="q" type="search" placeholder="搜索展览名称" maxlength="160"><button>搜索</button></form>
      <div class="tabs" aria-label="展览状态筛选"><button v-for="(label,key) in {'':'全部展览',on_view:'展出中',collecting:'征集中',archived:'已归档'}" :key="key" :class="{active:status===key}" :aria-pressed="status===key" @click="filter(key)">{{ label }}</button></div>
      <div class="section-heading"><h2>发现展览</h2><button @click="load" :disabled="loading">刷新 ↻</button></div>
    </template><a v-else href="#" class="back">← 返回发现展览</a>
    <p v-if="loading" class="message" role="status">正在加载展览…</p><div v-else-if="error" class="message" role="alert">{{ error }}<button @click="load">重新加载</button></div>
    <template v-else-if="detailMode && detail"><article class="detail"><img :src="detail.cover" :alt="detail.title"><span class="badge">{{ labels[detail.status] }}</span><h1>{{ detail.title }}</h1><p class="summary">{{ detail.introduction }}</p><dl><dt>展览时间</dt><dd>{{ date(detail.startsAt) }}<br>至 {{ date(detail.endsAt) }}</dd><dt>展览地点</dt><dd>{{ detail.venue }}</dd></dl><section class="statement"><p class="eyebrow">CURATORIAL STATEMENT</p><h2>策展序言</h2><p>{{ detail.statement || detail.introduction }}</p></section></article></template>
    <template v-else-if="!detailMode"><p v-if="!items.length" class="message">暂无符合条件的展览。<button @click="q='';filter('')">查看全部展览</button></p><a v-for="item in items" :key="item.id" :href="'#exhibition/'+item.id" class="card"><div class="card-image"><img :src="item.cover || '/assets/厦园晨雾.png'" :alt="item.title"><span class="badge">{{ labels[item.status] }}</span></div><div class="card-body"><span class="date">{{ date(item.startsAt).slice(5,10) }} — {{ date(item.endsAt).slice(5,10) }} / {{ item.venue }}</span><h2>{{ item.title }} <span>↗</span></h2><p>{{ item.introduction }}</p></div></a></template>
    <footer>校园艺术展览平台 · 课程演示<br>展览与作者均为虚构演示内容</footer></main>
    <nav class="bottom-nav" aria-label="底部导航"><a href="#" :class="{active:!detailMode}"><span>▦</span>发现展览</a><button @click="load"><span>↻</span>更新内容</button></nav>
  </div>
</template>
