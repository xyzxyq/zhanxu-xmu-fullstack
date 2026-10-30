# 公网前端原型

在线地址：<https://zhanxu-xmu-prototype.vercel.app/>  
管理演示：<https://zhanxu-xmu-prototype.vercel.app/admin/>  
移动 H5：<https://zhanxu-xmu-prototype.vercel.app/mobile/>

使用已确认的 Vercel Hobby 免费账号部署。仅包含静态文件，无后端、无真实账户、无数据库连接。示例内容为虚构演示数据；编辑只保存在当前浏览器中，同源的三端页面可读取，其他设备与访问者看不到这些编辑。已打开的页面需要刷新。演示数据可通过顶部“重置演示”恢复；浏览器清理站点数据也会清除编辑。

## 本地预览与构建

保留本文件夹和同级 `admin/`、`web/`、`mobile/`；Node.js 建议 22.12 或更新的受支持版本。在本目录执行：

```bash
npm ci
npm test
npm run dev
# 或构建后预览
npm run build
npm run preview -- --host 127.0.0.1 --port 4187
```

`main.js` 按路径加载原有 Vue 页面；`vite.config.js` 仅在这个原型构建中把页面的 `./api` 解析为 `demo-api.js`。原有三端目录独立启动时继续请求真实后端。管理页的 `demo` 属性默认关闭，正式模式仍需要原有账号密码。

## 文件用途

| 文件 | 作用 |
| --- | --- |
| `main.js`、`index.html` | 三端入口、演示说明、导航和重置按钮 |
| `demo-api.js`、`seed.js` | 浏览器演示数据、校验、查询与本地保存 |
| `demo.test.js` | 公开隔离、写入校验、CRUD、损坏数据与重置的自动检查 |
| `vite.config.js`、`package*.json` | 复用三端源文件与静态素材，生成部署文件 |
| `vercel.json` | `/admin/`、`/mobile/` 的静态入口重写 |

## 发布方式与复现

本次将 `dist/` 内容和 `vercel.json` 放在独立的私有 GitHub 仓库 `xyzxyq/zhanxu-xmu-prototype`，Vercel 从 `main` 发布。仓库只保存编译后的前端，不含后端或私有配置。Vercel 项目：`zhanxu-xmu-prototype`；框架 Other，无安装命令、无构建命令，输出目录 `.`。更新源文件后需重新构建并替换该仓库中的静态文件，再提交发布。完整源码位于本仓库根目录，前端构建结果单独用于部署。

生产版本提交：`503bdd4e66566901c413dcad122f1c3cc9871a69`。部署状态 READY，验收日期 2026-10-30。匿名浏览器实测记录见 [公网验收结果](../tests/prototype-browser-result.json)。

复现浏览器验收：先启动上面的 4187 预览，在 `../tests` 中执行 `npm ci`、`npx playwright install chromium`、`npm run test:prototype`。要验证公网，设置环境变量 `DEMO_URL=https://zhanxu-xmu-prototype.vercel.app`；可用 `CHROME_BIN` 指向本机 Chrome。此测试只改写新建浏览器会话中的演示数据。

未部署 Spring Boot 与 MySQL；演示会话不构成真实权限控制。免费托管受 [Vercel Hobby 使用限制](https://vercel.com/docs/plans/hobby) 约束，不保证所有地区和网络的可达性。未测试真实手机或 Safari。
