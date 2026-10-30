"""Export actual MySQL column definitions and constraints as screenshot-ready HTML."""
import datetime
import html
import json
import os
from pathlib import Path
import subprocess
import sys
import xml.etree.ElementTree as ET

TABLES = [
    ('exhibitions', '展览表', '首页三张展览卡片的数据来源；仅查询 public_visible=1 的公开状态。'),
    ('artworks', '作品表', '作品基础信息与发布状态；隐藏作品不通过首页接口公开。'),
    ('users', '用户表', '策展人和作者的身份关联；首页不返回校内编号、邮箱等字段。'),
    ('calls_for_works', '征集表', '记录展览征集期限，首页征集卡片显示 deadline_at。'),
    ('call_categories', '征集类别表', '通过复合外键保证投稿类别与所属展览一致。'),
    ('submissions', '投稿表', '连接作品与展览；精选作品仅来自 selected 状态的投稿。'),
    ('submission_versions', '投稿版本表', '保存投稿快照，首页展示的是策展选用版本的标题与公开署名。'),
    ('submission_version_files', '投稿版本文件表', '保存图片引用；首页读取策展版本的主图 is_primary=1。'),
    ('exhibition_sections', '展区表', '定义展览内的展区和显示顺序。'),
    ('section_placements', '策展编排表', '指定展区、投稿、选用版本与顺序，决定首页精选作品。'),
]

def query(sql):
    env = os.environ.copy()
    env['MYSQL_PWD'] = env['DB_PASSWORD']
    result = subprocess.run([
        env.get('MYSQL_BIN', 'mysql'), '--protocol=TCP', '-h127.0.0.1',
        '-P' + env.get('DB_PORT', '3307'), '-u' + env.get('DB_USERNAME', 'zhanxu_app'),
        '--default-character-set=utf8mb4', '--xml', '-e', sql,
    ], check=True, capture_output=True, env=env)
    return [{field.attrib['name']: (None if field.attrib.get('{http://www.w3.org/2001/XMLSchema-instance}nil') == 'true'
                                   else field.text or '') for field in row.findall('field')}
            for row in ET.fromstring(result.stdout).findall('row')]

def escaped(value):
    return html.escape('—' if value is None else str(value))

def main(output):
    output.mkdir(parents=True, exist_ok=True)
    version = query('SELECT VERSION() AS version')[0]['version']
    captured = datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=8))).isoformat(timespec='seconds')
    snapshot = {'database': 'zhanxu_xmu', 'version': version, 'captured_at': captured, 'tables': []}
    layout = []
    for index, (table, label, description) in enumerate(TABLES, 1):
        columns = query(f"SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY, COLUMN_DEFAULT, EXTRA, COLUMN_COMMENT FROM information_schema.columns WHERE table_schema='zhanxu_xmu' AND table_name='{table}' ORDER BY ORDINAL_POSITION")
        ddl = query(f'SHOW CREATE TABLE zhanxu_xmu.{table}')[0]['Create Table']
        row_count = query(f'SELECT COUNT(*) AS n FROM zhanxu_xmu.{table}')[0]['n']
        assert columns and 'CREATE TABLE' in ddl, table
        constraints = '\n'.join(line.strip().rstrip(',') for line in ddl.splitlines()
                                if any(key in line for key in ('PRIMARY KEY', 'UNIQUE KEY', ' KEY ', 'CONSTRAINT')))
        rows = ''.join('<tr>' + ''.join('<td>' + escaped(value) + '</td>' for value in row.values()) + '</tr>' for row in columns)
        page = f'''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><title>{table} · 数据库表设计</title>
<style>
*{{box-sizing:border-box}} body{{margin:0;padding:38px 48px;background:#f3f5f7;color:#233b45;font:15px/1.55 -apple-system,BlinkMacSystemFont,"PingFang SC",sans-serif}}
header{{border-bottom:2px solid #284f5b;padding-bottom:20px;margin-bottom:24px}} .eyebrow{{font-size:12px;letter-spacing:2px;color:#78858c}} h1{{font-size:30px;margin:12px 0 7px}} h1 code{{font-size:24px;color:#a95541}} p{{margin:6px 0;color:#5d7079}} .badges{{display:flex;gap:12px;margin:15px 0}} .badges span{{padding:6px 12px;background:white;border:1px solid #dce4e8;border-radius:6px;font-size:13px}}
table{{width:100%;border-collapse:collapse;background:white;font-size:14px}} th{{padding:12px;text-align:left;background:#284f5b;color:white;font-weight:500}} td{{padding:10px 12px;border-bottom:1px solid #e5ebef;vertical-align:top}} tr:nth-child(even) td{{background:#f8fafb}} td:first-child{{font-family:ui-monospace,monospace;font-weight:600}} h2{{font-size:18px;margin:24px 0 10px}} pre{{white-space:pre-wrap;overflow-wrap:anywhere;margin:0;padding:18px;background:#e8eef1;border-radius:6px;font:13px/1.7 ui-monospace,monospace}} footer{{margin-top:18px;color:#6a7d86;font-size:12px}}
</style><header><div class="eyebrow">展序·厦大 / 数据库设计 / WEB 首页</div><h1>{label} <code>{table}</code></h1><p>{description}</p><div class="badges"><span>MySQL {escaped(version)}</span><span>数据库 zhanxu_xmu</span><span>{len(columns)} 个字段</span><span>{row_count} 行课程演示数据</span></div></header>
<table><thead><tr><th>字段名</th><th>数据类型</th><th>允许空值</th><th>键标记</th><th>默认值</th><th>附加属性</th><th>数据库注释</th></tr></thead><tbody>{rows}</tbody></table>
<h2>主键、索引与约束（SHOW CREATE TABLE）</h2><pre>{html.escape(constraints)}</pre>
<footer>来源：真实 MySQL INFORMATION_SCHEMA.COLUMNS 与 SHOW CREATE TABLE 查询结果。采集时间：{captured}。<br>PRI=主键，UNI=唯一键，MUL=非唯一索引；“—”表示 SQL NULL，“”空白表示数据库未设置相应属性。此页为表结构报告，非数据库客户端界面。</footer></html>'''
        name = f'{index:02d}-{table}'
        (output / (name + '.html')).write_text(page, encoding='utf-8')
        height = max(900, 410 + 45 * len(columns) + 27 * len(constraints.splitlines()))
        layout.append({'name': name, 'width': 1600, 'height': height})
        snapshot['tables'].append({'table': table, 'label': label, 'row_count': int(row_count), 'columns': columns, 'create_table': ddl})
    (output / 'schema_snapshot.json').write_text(json.dumps(snapshot, ensure_ascii=False, indent=2), encoding='utf-8')
    (output / 'capture-layout.json').write_text(json.dumps(layout, indent=2), encoding='utf-8')
    print(f'Exported {len(TABLES)} live table definitions to {output}')

if __name__ == '__main__':
    main(Path(sys.argv[1]))
