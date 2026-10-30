<script setup>
import { onMounted, onUnmounted, ref } from 'vue'
import { request, labels, date } from './api'
const items=ref([]), works=ref([]), detail=ref(null), detailMode=ref(false), q=ref(''), status=ref(''), loading=ref(true), error=ref('')
let sequence=0
async function load() {
  const current=++sequence; loading.value=true; error.value=''; detail.value=null
  const match=location.hash.match(/^#exhibition\/(\d+)$/); detailMode.value=!!match
  try {
    if(match) { const data=await request('/api/exhibitions/'+match[1]); if(current===sequence) detail.value=data }
    else { const data=await request('/api/exhibitions?'+new URLSearchParams({q:q.value,status:status.value})); if(current===sequence) items.value=data }
  } catch(e) { if(current===sequence) error.value=e.message || '数据加载失败，请重试' }
  finally { if(current===sequence) loading.value=false }
}
function route() { if(location.hash.startsWith('#exhibition/') || detailMode.value) { load(); window.scrollTo({top:0}) } }
onMounted(async()=>{window.addEventListener('hashchange',route); await load(); try { works.value=(await request('/api/home')).works } catch { works.value=[] }})
onUnmounted(()=>window.removeEventListener('hashchange',route))
</script>
<template>
  <header class="site-header shell"><a class="wordmark" href="#top">展序·厦大</a><nav aria-label="主导航"><a href="#exhibitions">发现展览</a><a href="#works">精选作品</a><a href="#about">关于展序</a></nav><span class="edition">XIAYUAN / ART & LIFE</span></header>
  <main class="shell" id="top">
    <template v-if="!detailMode"><section class="hero" aria-labelledby="hero-title"><img class="hero-image" src="/assets/厦园晨雾.png" alt="湖畔嘉庚建筑与凤凰花"><div class="hero-wash"></div><div class="hero-content"><p class="eyebrow">厦门大学 · 校园艺术与创作</p><h1 id="hero-title">在厦园，<br>让创作被看见。</h1><p class="hero-copy">把一扇窗的光、一片湖的影，<br>留在属于厦园的创作里。</p><div class="hero-actions"><a class="button button-primary" href="#exhibitions">浏览展览 →</a><a href="#works" class="button button-quiet">发现作品 ↗</a></div></div><img class="flower-sprig" src="/assets/凤凰花枝.png" alt=""></section>
      <section id="exhibitions" class="section exhibition-section"><div class="section-heading"><div><p class="section-kicker">EXHIBITIONS IN XIAYUAN</p><h2>厦园正在发生</h2></div><span class="section-note">让艺术，成为校园的日常。</span></div><form class="filters" @submit.prevent="load"><label class="sr-only" for="search">搜索展览名称</label><input id="search" v-model="q" type="search" maxlength="160" placeholder="搜索展览名称"><label class="sr-only" for="status">展览状态</label><select id="status" v-model="status" @change="load"><option value="">全部展览</option><option value="on_view">展出中</option><option value="collecting">征集中</option><option value="archived">已归档</option></select><button type="submit">搜索</button><button type="button" @click="q='';status='';load()">重置</button></form>
      <p v-if="loading" class="data-message" role="status">正在加载展览…</p><p v-else-if="error" class="data-message" role="alert">{{ error }} <button @click="load">重新加载</button></p><p v-else-if="!items.length" class="data-message">没有符合条件的公开展览，请调整搜索条件。</p>
      <div v-else class="exhibition-grid"><a v-for="(item,index) in items" :key="item.id" class="exhibition-card" :href="'#exhibition/'+item.id"><div class="exhibition-image-wrap"><img :src="item.cover || '/assets/厦园晨雾.png'" :alt="item.title"><span class="image-index">0{{ index+1 }} / EXHIBITION</span></div><div class="card-meta"><span>{{ labels[item.status] }} · {{ date(item.startsAt).slice(5,10) }} — {{ date(item.endsAt).slice(5,10) }}</span><span>↗</span></div><h3>{{ item.title }}</h3><p class="card-subtitle">{{ item.introduction }}</p></a></div></section>
      <section id="works" class="section works-section" v-if="works.length"><div class="section-heading"><h2>一幅作品，一种厦园的看法</h2><p class="section-note">从瓦影、湖面到海风<br>让不同的创作在这里相遇。</p></div><div class="works-grid"><article v-for="work in works" :key="work.id" class="work-card"><img :src="work.image" :alt="work.title"><div><h3>{{ work.title }}</h3><span>{{ work.author }} · {{ work.medium }}</span></div></article></div></section>
      <section id="about" class="callout"><div><p class="section-kicker">ABOUT ZHANXU</p><h2>把校园日常，编排成一场相遇。</h2><p>展序·厦大连接校园创作与观众，记录展览，也留存每一次观看。</p></div><a class="button button-dark" href="#exhibitions">寻找一场展览 →</a></section>
    </template>
    <section v-else class="detail-page"><a href="#exhibitions" class="text-link">← 返回展览列表</a><p v-if="loading" class="data-message">正在加载展览…</p><p v-else-if="error" role="alert" class="data-message">{{ error }} <button @click="load">重新加载</button></p><template v-else-if="detail"><div class="detail-hero"><img :src="detail.cover" :alt="detail.title"><div><p class="eyebrow">EXHIBITION / {{ labels[detail.status] }}</p><h1>{{ detail.title }}</h1><p>{{ detail.introduction }}</p><dl><dt>展览时间</dt><dd>{{ date(detail.startsAt) }}<br>至 {{ date(detail.endsAt) }}</dd><dt>展览地点</dt><dd>{{ detail.venue }}</dd></dl><span class="detail-tag">{{ labels[detail.status] }} · 线上展览档案</span></div></div><article class="statement"><p class="eyebrow">CURATORIAL STATEMENT</p><h2>策展序言</h2><p>{{ detail.statement || detail.introduction }}</p></article></template></section>
  </main><footer class="site-footer shell"><span>展序·厦大 / 自强不息，止于至善</span><span>校园艺术展览平台 · 课程演示，非真实展览信息</span></footer>
</template>
