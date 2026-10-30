# 展序·厦大 · 管理后台前端

完整产品介绍、接口与数据库准备见 [根目录 readme.md](../readme.md)。

先启动后端，再在本目录执行：

```bash
npm ci
npm run dev
```

访问 http://127.0.0.1:5174/ 。生产构建使用 `npm run build`，本地预览使用 `npm run preview`。代理后端默认为 `http://127.0.0.1:8081`，可通过 `API_TARGET` 环境变量调整。

本目录可独立构建；`src/App.vue` 实现界面和交互，`src/api.js` 处理接口请求，`src/style.css` 为页面样式，`public/assets/` 保存本地图片。移动 H5 使用手机浏览器或开发者工具设备模式预览。
