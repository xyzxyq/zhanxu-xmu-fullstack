-- 先替换占位密码，再以 MySQL 管理员身份执行；不要重复执行或用于已有同名账号。
CREATE USER 'zhanxu_fullstack_app'@'127.0.0.1' IDENTIFIED BY 'replace-with-your-database-password';
GRANT SELECT ON zhanxu_fullstack.* TO 'zhanxu_fullstack_app'@'127.0.0.1';
GRANT INSERT, UPDATE, DELETE ON zhanxu_fullstack.exhibitions TO 'zhanxu_fullstack_app'@'127.0.0.1';
