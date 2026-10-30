# 展序·厦大 · Spring Boot 首页后端

给已有 Vue 首页提供展览卡片和精选作品数据。接口来自真实 MySQL 查询，不在 Java 或 Vue 中回退到静态数据。

## 工程结构

- Java 21、Spring Boot 3.5.16、Spring JDBC、MySQL Connector/J，Maven 工程。
- `HomeController`：`GET /api/home`；数据库异常返回不含 SQL 与连接信息的 503 提示。
- `HomeRepository`：用 `JdbcTemplate` 在只读事务内查询展览、征集截止日期、策展选用版本与图片。
- `HomeResponse`：公开页面数据，不返回用户邮箱、校内编号等字段。
- `database/schema.sql`：原项目完整 19 表 MySQL 设计；`seed.sql` 是课程虚构演示数据。

接口返回 `exhibitions`（3 个公开展览）和 `works`（4 件精选作品）。演示数据另有 1 个未公开展览与 1 件隐藏作品，用于隔离检查。

## 首次运行

准备 Java 21、Maven、MySQL 8.0.16 或更新版本。本机验证版本为 MySQL 8.4.11；数据库仅监听本机 `127.0.0.1:3307`，后端监听 `127.0.0.1:8080`。

1. 在本目录打开终端，向新的课程数据库实例导入结构和演示数据：

   ```bash
   mysql --protocol=TCP -h127.0.0.1 -P3307 -u root -p < database/schema.sql
   mysql --protocol=TCP -h127.0.0.1 -P3307 -u root -p < database/seed.sql
   ```

   只在首次准备时导入一次；脚本没有 DROP/TRUNCATE，不会自动清空或重置已有数据。重复导入会因已有表或主键而失败。

2. 打开 `database/create-user.example.sql`，替换占位密码，再由管理员执行，创建只读的 `zhanxu_app` 账号。

3. 复制 `.env.example` 为 `.env.local`，填入相同账号密码；若自己的 MySQL 使用 3306，修改 `DB_URL`。实际 `.env.local` 不进入提交包。

4. 加载配置、检查并启动：

   ```bash
   set -a
   source .env.local
   set +a
   mvn verify
   mvn spring-boot:run
   ```

   构建后也可运行 `java -jar target/zhanxu-backend-1.0.0.jar`。Windows 用户可在 IDE 运行配置设置 `DB_URL`、`DB_USERNAME`、`DB_PASSWORD`。

5. 在相邻 `vue-web` 目录运行 `npm install`、`npm run dev`，访问 `http://127.0.0.1:4173/`。

本机 Homebrew Java 21 的路径为 `/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home`。在本机运行 Maven 前，先执行 `export JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home`，确保使用 Java 21。

## 页面与表的对应关系

| 页面数据 | 查询或关联的表 |
| --- | --- |
| 展览标题、封面、简介、状态、展期 | `exhibitions` |
| 征集截止日期 | `calls_for_works` |
| 精选作品和策展选用版本 | `section_placements`、`exhibition_sections`、`submissions`、`artworks`、`submission_versions` |
| 精选作品图片 | `submission_version_files` |
| 作者、策展人、投稿类别的外键支撑 | `users`、`call_categories` |

公开接口要求展览 `public_visible=1`、状态为 `on_view/collecting/archived`；精选作品还要求作品已发布、投稿已入选、策展编排存在且选用版本有主图。展览状态是演示中设置的业务状态，不按系统日期自动切换。

## 检查与截图

`mvn verify` 的集成测试启动真实 Spring Boot，访问已导入演示数据的 MySQL，检查公开记录数量、顺序、日期和隐藏记录隔离。测试需要上述数据库配置。

`scripts/export_schema.py` 从 `INFORMATION_SCHEMA.COLUMNS` 与 `SHOW CREATE TABLE` 导出实际字段及约束。加载 `.env.local` 后执行：

```bash
MYSQL_BIN=mysql python3 scripts/export_schema.py ./schema-report
```

若数据库端口不是 3307，同时设置 `DB_PORT`。导出的 HTML 是可在浏览器打开并截图的表结构报告，非 Navicat 等客户端界面。

本次只实现首页公开查询；原设计中的投稿、预约、审核等表保留结构，未实现相应写入接口。框架要求参考：[Spring Boot 3.5 官方系统要求](https://docs.spring.io/spring-boot/3.5/system-requirements.html)。
