-- 首页联调演示数据；均为课程虚构内容。只导入新建的课程数据库一次。
USE zhanxu_xmu;
START TRANSACTION;
INSERT INTO users (id, display_name) VALUES (1,'课程策展员'),(2,'临舟'),(3,'云序'),(4,'知夏'),(5,'南汐');
INSERT INTO exhibitions (id,title,slug,cover_url,introduction,venue_label,status,public_visible,starts_at,ends_at,created_by) VALUES
    (1,'厦园有光','xiayuan-light','/assets/厦园晨雾.png','山海之间的青年创作展','校园线上展厅','on_view',TRUE,'2026-10-20 09:00:00','2026-11-06 18:00:00',1),
    (2,'凤凰花开的季节','phoenix-season','/assets/凤凰花季.png','校园植物与日常的视觉记录','校园线上展厅','collecting',TRUE,'2026-11-20 09:00:00','2026-12-06 18:00:00',1),
    (3,'瓦影与窗','windows-and-tiles','/assets/瓦影.png','嘉庚建筑视觉设计展','校园线上展厅','archived',TRUE,'2026-09-20 09:00:00','2026-10-10 18:00:00',1),
    (4,'未公开展览（隔离检查）','private-fixture',NULL,'不应出现在公开接口','内部','on_view',FALSE,'2026-10-20 09:00:00','2026-11-06 18:00:00',1);
INSERT INTO calls_for_works (id,exhibition_id,title,description,starts_at,deadline_at,allowed_formats,terms_text,status) VALUES
    (1,1,'厦园有光作品征集','课程演示征集','2026-09-01 00:00:00','2026-09-20 23:59:59',JSON_ARRAY('image/png'),'仅限课程演示','closed'),
    (2,2,'凤凰花季作品征集','校园植物与日常的视觉记录','2026-10-01 00:00:00','2026-11-15 23:59:59',JSON_ARRAY('image/png'),'仅限课程演示','open');
INSERT INTO call_categories (id,call_id,exhibition_id,name) VALUES (1,1,1,'视觉创作');
INSERT INTO exhibition_sections (id,exhibition_id,title,sort_order) VALUES (1,1,'精选作品',1);
INSERT INTO artworks (id,author_id,title,medium,creation_year,description,public_credit,status) VALUES (1,2,'窗的秩序','视觉创作',2026,'这是一份课程演示作品，以厦园的建筑、湖面、花木和海风为灵感，用视觉创作记录校园日常。作品和作者名用于课堂原型展示，不代表真实展览或投稿记录。','临舟','published');
INSERT INTO submissions (id,artwork_id,exhibition_id,call_category_id,status,display_author_name,display_author_consent_at,submitted_at) VALUES (1,1,1,1,'selected','临舟',CURRENT_TIMESTAMP(3),CURRENT_TIMESTAMP(3));
INSERT INTO submission_versions (submission_id,version_no,title,medium,creation_year,description,public_credit,display_author_consent_at) VALUES (1,1,'窗的秩序','视觉创作',2026,'这是一份课程演示作品，以厦园的建筑、湖面、花木和海风为灵感，用视觉创作记录校园日常。作品和作者名用于课堂原型展示，不代表真实展览或投稿记录。','临舟',CURRENT_TIMESTAMP(3));
INSERT INTO submission_version_files (id,submission_id,version_no,file_url,original_filename,mime_type,file_size_bytes,is_primary) VALUES (1,1,1,'/assets/瓦影.png','瓦影.png','image/png',3503643,TRUE);
INSERT INTO section_placements (id,section_id,submission_id,exhibition_id,version_no,sort_order) VALUES (1,1,1,1,1,1);
INSERT INTO artworks (id,author_id,title,medium,creation_year,description,public_credit,status) VALUES (2,3,'红瓦的几何','视觉创作',2026,'这是一份课程演示作品，以厦园的建筑、湖面、花木和海风为灵感，用视觉创作记录校园日常。作品和作者名用于课堂原型展示，不代表真实展览或投稿记录。','云序','published');
INSERT INTO submissions (id,artwork_id,exhibition_id,call_category_id,status,display_author_name,display_author_consent_at,submitted_at) VALUES (2,2,1,1,'selected','云序',CURRENT_TIMESTAMP(3),CURRENT_TIMESTAMP(3));
INSERT INTO submission_versions (submission_id,version_no,title,medium,creation_year,description,public_credit,display_author_consent_at) VALUES (2,1,'红瓦的几何','视觉创作',2026,'这是一份课程演示作品，以厦园的建筑、湖面、花木和海风为灵感，用视觉创作记录校园日常。作品和作者名用于课堂原型展示，不代表真实展览或投稿记录。','云序',CURRENT_TIMESTAMP(3));
INSERT INTO submission_version_files (id,submission_id,version_no,file_url,original_filename,mime_type,file_size_bytes,is_primary) VALUES (2,2,1,'/assets/凤凰花季.png','凤凰花季.png','image/png',3197264,TRUE);
INSERT INTO section_placements (id,section_id,submission_id,exhibition_id,version_no,sort_order) VALUES (2,1,2,1,1,2);
INSERT INTO artworks (id,author_id,title,medium,creation_year,description,public_credit,status) VALUES (3,4,'湖面留白','视觉创作',2026,'这是一份课程演示作品，以厦园的建筑、湖面、花木和海风为灵感，用视觉创作记录校园日常。作品和作者名用于课堂原型展示，不代表真实展览或投稿记录。','知夏','published');
INSERT INTO submissions (id,artwork_id,exhibition_id,call_category_id,status,display_author_name,display_author_consent_at,submitted_at) VALUES (3,3,1,1,'selected','知夏',CURRENT_TIMESTAMP(3),CURRENT_TIMESTAMP(3));
INSERT INTO submission_versions (submission_id,version_no,title,medium,creation_year,description,public_credit,display_author_consent_at) VALUES (3,1,'湖面留白','视觉创作',2026,'这是一份课程演示作品，以厦园的建筑、湖面、花木和海风为灵感，用视觉创作记录校园日常。作品和作者名用于课堂原型展示，不代表真实展览或投稿记录。','知夏',CURRENT_TIMESTAMP(3));
INSERT INTO submission_version_files (id,submission_id,version_no,file_url,original_filename,mime_type,file_size_bytes,is_primary) VALUES (3,3,1,'/assets/厦园晨雾.png','厦园晨雾.png','image/png',3100093,TRUE);
INSERT INTO section_placements (id,section_id,submission_id,exhibition_id,version_no,sort_order) VALUES (3,1,3,1,1,3);
INSERT INTO artworks (id,author_id,title,medium,creation_year,description,public_credit,status) VALUES (4,5,'海风的形状','视觉创作',2026,'这是一份课程演示作品，以厦园的建筑、湖面、花木和海风为灵感，用视觉创作记录校园日常。作品和作者名用于课堂原型展示，不代表真实展览或投稿记录。','南汐','published');
INSERT INTO submissions (id,artwork_id,exhibition_id,call_category_id,status,display_author_name,display_author_consent_at,submitted_at) VALUES (4,4,1,1,'selected','南汐',CURRENT_TIMESTAMP(3),CURRENT_TIMESTAMP(3));
INSERT INTO submission_versions (submission_id,version_no,title,medium,creation_year,description,public_credit,display_author_consent_at) VALUES (4,1,'海风的形状','视觉创作',2026,'这是一份课程演示作品，以厦园的建筑、湖面、花木和海风为灵感，用视觉创作记录校园日常。作品和作者名用于课堂原型展示，不代表真实展览或投稿记录。','南汐',CURRENT_TIMESTAMP(3));
INSERT INTO submission_version_files (id,submission_id,version_no,file_url,original_filename,mime_type,file_size_bytes,is_primary) VALUES (4,4,1,'/assets/向海.png','向海.png','image/png',3213368,TRUE);
INSERT INTO section_placements (id,section_id,submission_id,exhibition_id,version_no,sort_order) VALUES (4,1,4,1,1,4);
INSERT INTO artworks (id,author_id,title,medium,creation_year,description,public_credit,status) VALUES (5,2,'隐藏作品（隔离检查）','视觉创作',2026,'这是一份课程演示作品，以厦园的建筑、湖面、花木和海风为灵感，用视觉创作记录校园日常。作品和作者名用于课堂原型展示，不代表真实展览或投稿记录。','临舟','hidden');
INSERT INTO submissions (id,artwork_id,exhibition_id,call_category_id,status,display_author_name,display_author_consent_at,submitted_at) VALUES (5,5,1,1,'selected','临舟',CURRENT_TIMESTAMP(3),CURRENT_TIMESTAMP(3));
INSERT INTO submission_versions (submission_id,version_no,title,medium,creation_year,description,public_credit,display_author_consent_at) VALUES (5,1,'隐藏作品（隔离检查）','视觉创作',2026,'这是一份课程演示作品，以厦园的建筑、湖面、花木和海风为灵感，用视觉创作记录校园日常。作品和作者名用于课堂原型展示，不代表真实展览或投稿记录。','临舟',CURRENT_TIMESTAMP(3));
INSERT INTO submission_version_files (id,submission_id,version_no,file_url,original_filename,mime_type,file_size_bytes,is_primary) VALUES (5,5,1,'/assets/瓦影.png','瓦影.png','image/png',3503643,TRUE);
INSERT INTO section_placements (id,section_id,submission_id,exhibition_id,version_no,sort_order) VALUES (5,1,5,1,1,0);
COMMIT;
