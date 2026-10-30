-- 使用管理员连接执行；先替换占位密码，不把实际密码写进提交包。
CREATE USER 'zhanxu_app'@'localhost' IDENTIFIED BY 'REPLACE_WITH_YOUR_OWN_PASSWORD';
GRANT SELECT ON zhanxu_xmu.* TO 'zhanxu_app'@'localhost';
