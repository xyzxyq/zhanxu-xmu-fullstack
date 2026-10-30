# 展序·厦大 · Spring Boot 后端

完整说明见 [根目录 readme.md](../readme.md)。先执行根目录 `database/schema.sql`、`seed.sql` 和修改后的 `create-user.example.sql`，再复制 `.env.example` 为 `.env.local` 并设置数据库与管理员密码。

```bash
set -a
source .env.local
set +a
mvn verify
java -jar target/zhanxu-backend-1.0.0.jar
```

默认监听 `127.0.0.1:8081`。使用 Java 21；Windows 环境变量配置和完整 API 见根目录说明。自动测试需要真实 MySQL 和初始化数据。

`ExhibitionRepository` 复用原表结构实现展览增删改查；`AdminAccess` 与 `AdminSessionController` 管理登录会话；`ApiErrors` 返回可读错误。`HomeRepository` 保留公开首页查询。管理员由环境变量配置，写入关联演示策展人 `users.id=1`。
