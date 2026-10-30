<script setup>
import { onMounted, ref } from 'vue'

const exhibitions = ref([])
const works = ref([])
const loading = ref(true)
const loadError = ref('')

async function loadHome() {
  loading.value = true
  loadError.value = ''
  try {
    const response = await fetch('/api/home', { signal: AbortSignal.timeout(10000) })
    if (!response.ok) throw new Error('首页接口请求失败')
    const data = await response.json()
    if (!Array.isArray(data.exhibitions) || !Array.isArray(data.works)) {
      throw new Error('首页数据格式错误')
    }
    exhibitions.value = data.exhibitions
    works.value = data.works
  } catch {
    loadError.value = '展览与作品暂时无法加载，请稍后重试。'
  } finally {
    loading.value = false
  }
}

onMounted(loadHome)
</script>

<template>
  <header class="site-header shell">
    <a class="wordmark" href="#top" aria-label="展序·厦大首页">展序·厦大</a>
    <nav aria-label="主导航">
      <a href="#exhibitions">展览</a>
      <a href="#works">作品</a>
      <a href="#call">征集</a>
      <a href="#archive">厦园档案</a>
      <a class="nav-accent" href="#call">我的展序 ↗</a>
    </nav>
    <a class="mobile-menu" href="#exhibitions" aria-label="浏览展览">☰</a>
  </header>

  <main id="top" class="shell">
    <section class="hero" aria-labelledby="hero-title">
      <img class="hero-image" src="/assets/厦园晨雾.png" alt="芙蓉湖畔的嘉庚建筑与凤凰花" />
      <div class="hero-wash"></div>
      <div class="hero-content">
        <p class="eyebrow">厦门大学 · 校园艺术与创作</p>
        <h1 id="hero-title">在厦园，<br />让创作被看见。</h1>
        <p class="hero-copy">把一扇窗的光、一片湖的影，<br />留在属于厦园的创作里。</p>
        <div class="hero-actions">
          <a class="button button-primary" href="#exhibitions">浏览展览 <span>→</span></a>
          <a class="button button-quiet" href="#call">参与征集 <span class="drawn-arrow">⤴</span></a>
        </div>
      </div>
      <img class="flower-sprig" src="/assets/凤凰花枝.png" alt="" aria-hidden="true" />
    </section>

    <section id="exhibitions" class="section exhibition-section">
      <div class="section-heading">
        <div>
          <p class="section-kicker">NOW IN XIAYUAN</p>
          <h2>厦园正在发生</h2>
        </div>
        <a class="text-link" href="#archive">全部展览 ↗</a>
      </div>
      <p v-if="loading" class="data-message" role="status">正在加载展览与作品…</p>
      <div v-else-if="loadError" class="data-message" role="alert">
        {{ loadError }} <button type="button" @click="loadHome">重新加载</button>
      </div>
      <p v-else-if="exhibitions.length === 0" class="data-message">暂无公开展览。</p>
      <div v-else class="exhibition-grid">
        <a v-for="(item, index) in exhibitions" :key="item.id" class="exhibition-card" :href="item.state === 'collecting' ? '#call' : '#works'">
          <div class="exhibition-image-wrap" :class="item.tone">
            <img :src="item.image" :alt="item.alt" />
            <span class="image-index">0{{ index + 1 }} / EXHIBITION</span>
          </div>
          <div class="card-meta"><span>{{ item.status }}</span><span>↗</span></div>
          <h3>{{ item.title }}</h3>
          <p class="card-subtitle">{{ item.subtitle }}</p>
        </a>
      </div>
    </section>

    <section id="works" class="section works-section">
      <div class="section-heading">
        <div>
          <p class="section-kicker">SELECTED WORKS</p>
          <h2>一幅作品，一种厦园的看法</h2>
        </div>
        <p class="section-note">从瓦影、湖面到海风<br />让不同的创作在这里相遇。</p>
      </div>
      <p v-if="!loading && !loadError && works.length === 0" class="data-message">暂无精选作品。</p>
      <div class="works-grid">
        <article v-for="work in works" :key="work.id" class="work-card">
          <img :src="work.image" :alt="work.title" />
          <div><h3>{{ work.title }}</h3><span>{{ work.author }} · {{ work.medium }}</span></div>
        </article>
      </div>
    </section>

    <section id="call" class="callout">
      <img src="/assets/凤凰花枝.png" alt="" aria-hidden="true" />
      <div>
        <p class="section-kicker">OPEN CALL · 2026</p>
        <h2>把你的厦园，带进下一场展览。</h2>
        <p>摄影、插画、视觉设计——从一份草稿开始你的创作档案。</p>
      </div>
      <a class="button button-dark" href="#call">查看征集 <span>→</span></a>
    </section>
  </main>

  <footer id="archive" class="site-footer shell">
    <span>展序·厦大　/　自强不息，止于至善</span>
    <span>校园艺术展览平台 · 课程原型</span>
  </footer>
</template>
