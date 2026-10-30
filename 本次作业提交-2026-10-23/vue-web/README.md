# 展序·厦大 Web 首页（Vue）

课程作业页面复刻自 Figma 原型中的 **W01 / 首页**，仅包含 Web 首页。展览卡片和精选作品已通过 `GET /api/home` 读取 Spring Boot 和 MySQL；图片素材保存在 `public/assets/`。

原型文件：[展序·厦大｜Figma](https://www.figma.com/design/jfLt6B1elspRvgGAt3ff7P)，页面节点 `W01 / 首页`（`5:2`）。

## 运行

先按相邻 `springboot-backend/README.md` 准备数据库并启动后端，再用 Vite 启动本页；不要直接双击根目录的 `index.html`。

```bash
npm install
npm run dev
```

打开 `http://127.0.0.1:4173/`，Vite 将 `/api` 代理到 `http://127.0.0.1:8080`。接口无法访问时显示错误与“重新加载”，不会回退到硬编码列表。

打包运行 `npm run build`，输出位于 `dist/`；本地预览运行 `npm run preview`，同样需要后端。导航与按钮在本页内跳转，未实现其他页面和投稿、预约表单。

## 提交材料

本次联调截图统一位于作业提交包的 `前端截图/` 目录；源码目录原有的 `提交材料/` 为上一次纯前端作业的历史材料，不放入本次源码副本。

本项目使用 Vue 3 和 Vite；图片素材保存在 `public/assets/`。
