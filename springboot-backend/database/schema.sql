-- 展序·厦大 校园展览平台数据库结构
-- 目标数据库：MySQL 8.0.16+
-- 时间由应用按 Asia/Shanghai 解释并写入；文件内容保存在对象存储，本库仅保存引用。
CREATE DATABASE IF NOT EXISTS `zhanxu_xmu`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE `zhanxu_xmu`;
SET NAMES utf8mb4;

CREATE TABLE `users` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `campus_no` VARCHAR(32) NULL COMMENT '校内身份编号，仅内部使用，不公开',
  `email` VARCHAR(255) NULL,
  `display_name` VARCHAR(80) NOT NULL,
  `status` VARCHAR(16) NOT NULL DEFAULT 'active',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_campus_no` (`campus_no`),
  UNIQUE KEY `uq_users_email` (`email`),
  CONSTRAINT `chk_users_status` CHECK (`status` IN ('active', 'suspended', 'deleted'))
) ENGINE=InnoDB;

CREATE TABLE `roles` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(32) NOT NULL,
  `name` VARCHAR(80) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_roles_code` (`code`)
) ENGINE=InnoDB;

INSERT INTO `roles` (`code`, `name`) VALUES
  ('audience', '观众'),
  ('creator', '创作者'),
  ('curator', '策展人员'),
  ('verifier', '核验人员'),
  ('admin', '平台管理员');

CREATE TABLE `exhibitions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(160) NOT NULL,
  `slug` VARCHAR(180) NOT NULL,
  `cover_url` VARCHAR(1024) NULL,
  `introduction` TEXT NULL,
  `curatorial_statement` TEXT NULL,
  `venue_label` VARCHAR(255) NULL,
  `status` VARCHAR(16) NOT NULL DEFAULT 'draft',
  `public_visible` BOOLEAN NOT NULL DEFAULT FALSE,
  `starts_at` DATETIME(3) NULL,
  `ends_at` DATETIME(3) NULL,
  `archived_at` DATETIME(3) NULL,
  `created_by` BIGINT UNSIGNED NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_exhibitions_slug` (`slug`),
  KEY `idx_exhibitions_public_status_dates` (`public_visible`, `status`, `starts_at`, `ends_at`),
  CONSTRAINT `fk_exhibitions_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_exhibitions_status` CHECK (`status` IN ('draft', 'collecting', 'preparing', 'on_view', 'archived', 'cancelled')),
  CONSTRAINT `chk_exhibitions_dates` CHECK (`ends_at` IS NULL OR `starts_at` IS NULL OR `ends_at` > `starts_at`)
) ENGINE=InnoDB;

CREATE TABLE `role_assignments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `role_id` BIGINT UNSIGNED NOT NULL,
  `exhibition_id` BIGINT UNSIGNED NULL COMMENT '为空表示全平台范围',
  `scope_key` BIGINT UNSIGNED GENERATED ALWAYS AS (IFNULL(`exhibition_id`, 0)) STORED,
  `assigned_by` BIGINT UNSIGNED NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_role_assignments_scope` (`user_id`, `role_id`, `scope_key`),
  KEY `idx_role_assignments_exhibition` (`exhibition_id`, `role_id`),
  CONSTRAINT `fk_role_assignments_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_role_assignments_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  CONSTRAINT `fk_role_assignments_exhibition` FOREIGN KEY (`exhibition_id`) REFERENCES `exhibitions` (`id`),
  CONSTRAINT `fk_role_assignments_assigned_by` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `calls_for_works` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `exhibition_id` BIGINT UNSIGNED NOT NULL,
  `title` VARCHAR(160) NOT NULL,
  `description` TEXT NOT NULL,
  `starts_at` DATETIME(3) NOT NULL,
  `deadline_at` DATETIME(3) NOT NULL,
  `allowed_formats` JSON NOT NULL,
  `max_file_size_bytes` BIGINT UNSIGNED NOT NULL DEFAULT 20971520,
  `max_detail_images` TINYINT UNSIGNED NOT NULL DEFAULT 4,
  `terms_text` TEXT NOT NULL,
  `status` VARCHAR(16) NOT NULL DEFAULT 'draft',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_calls_for_works_id_exhibition` (`id`, `exhibition_id`),
  UNIQUE KEY `uq_calls_for_works_exhibition` (`exhibition_id`),
  CONSTRAINT `fk_calls_for_works_exhibition` FOREIGN KEY (`exhibition_id`) REFERENCES `exhibitions` (`id`),
  CONSTRAINT `chk_calls_for_works_dates` CHECK (`deadline_at` > `starts_at`),
  CONSTRAINT `chk_calls_for_works_status` CHECK (`status` IN ('draft', 'open', 'closed'))
) ENGINE=InnoDB;

CREATE TABLE `call_categories` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `call_id` BIGINT UNSIGNED NOT NULL,
  `exhibition_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(80) NOT NULL,
  `description` VARCHAR(500) NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_call_categories_id_exhibition` (`id`, `exhibition_id`),
  UNIQUE KEY `uq_call_categories_name` (`call_id`, `name`),
  CONSTRAINT `fk_call_categories_call_exhibition` FOREIGN KEY (`call_id`, `exhibition_id`) REFERENCES `calls_for_works` (`id`, `exhibition_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_call_categories_name` CHECK (CHAR_LENGTH(`name`) > 0)
) ENGINE=InnoDB;

CREATE TABLE `artworks` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `author_id` BIGINT UNSIGNED NOT NULL,
  `title` VARCHAR(120) NOT NULL,
  `medium` VARCHAR(120) NOT NULL,
  `creation_year` YEAR NULL,
  `description` TEXT NOT NULL,
  `public_credit` VARCHAR(120) NOT NULL,
  `status` VARCHAR(16) NOT NULL DEFAULT 'draft',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_artworks_author_status` (`author_id`, `status`),
  CONSTRAINT `fk_artworks_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_artworks_status` CHECK (`status` IN ('draft', 'published', 'hidden', 'removed'))
) ENGINE=InnoDB;

CREATE TABLE `submissions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `artwork_id` BIGINT UNSIGNED NOT NULL,
  `exhibition_id` BIGINT UNSIGNED NOT NULL,
  `call_category_id` BIGINT UNSIGNED NOT NULL,
  `current_version_no` INT UNSIGNED NOT NULL DEFAULT 1,
  `status` VARCHAR(20) NOT NULL DEFAULT 'draft',
  `display_author_name` VARCHAR(120) NOT NULL,
  `display_author_consent_at` DATETIME(3) NOT NULL,
  `revision_deadline` DATETIME(3) NULL,
  `submitted_at` DATETIME(3) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_submissions_artwork_exhibition` (`artwork_id`, `exhibition_id`),
  UNIQUE KEY `uq_submissions_id_exhibition` (`id`, `exhibition_id`),
  KEY `idx_submissions_exhibition_status` (`exhibition_id`, `status`, `submitted_at`),
  CONSTRAINT `fk_submissions_artwork` FOREIGN KEY (`artwork_id`) REFERENCES `artworks` (`id`),
  CONSTRAINT `fk_submissions_exhibition` FOREIGN KEY (`exhibition_id`) REFERENCES `exhibitions` (`id`),
  CONSTRAINT `fk_submissions_category` FOREIGN KEY (`call_category_id`, `exhibition_id`) REFERENCES `call_categories` (`id`, `exhibition_id`),
  CONSTRAINT `chk_submissions_status` CHECK (`status` IN ('draft', 'pending_review', 'selected', 'revision_requested', 'rejected', 'withdrawn'))
) ENGINE=InnoDB;

CREATE TABLE `submission_versions` (
  `submission_id` BIGINT UNSIGNED NOT NULL,
  `version_no` INT UNSIGNED NOT NULL,
  `title` VARCHAR(120) NOT NULL,
  `medium` VARCHAR(120) NOT NULL,
  `creation_year` YEAR NULL,
  `description` TEXT NOT NULL,
  `public_credit` VARCHAR(120) NOT NULL,
  `display_author_consent_at` DATETIME(3) NOT NULL,
  `submitted_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`submission_id`, `version_no`),
  CONSTRAINT `fk_submission_versions_submission` FOREIGN KEY (`submission_id`) REFERENCES `submissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_submission_versions_title_length` CHECK (CHAR_LENGTH(`title`) BETWEEN 2 AND 40),
  CONSTRAINT `chk_submission_versions_description_length` CHECK (CHAR_LENGTH(`description`) BETWEEN 50 AND 500)
) ENGINE=InnoDB;

CREATE TABLE `submission_version_files` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `submission_id` BIGINT UNSIGNED NOT NULL,
  `version_no` INT UNSIGNED NOT NULL,
  `file_url` VARCHAR(1024) NOT NULL,
  `original_filename` VARCHAR(255) NOT NULL,
  `mime_type` VARCHAR(100) NOT NULL,
  `file_size_bytes` BIGINT UNSIGNED NOT NULL,
  `sort_order` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `is_primary` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_submission_files_order` (`submission_id`, `version_no`, `sort_order`),
  KEY `idx_submission_files_version` (`submission_id`, `version_no`),
  CONSTRAINT `fk_submission_files_version` FOREIGN KEY (`submission_id`, `version_no`) REFERENCES `submission_versions` (`submission_id`, `version_no`) ON DELETE CASCADE,
  CONSTRAINT `chk_submission_file_size` CHECK (`file_size_bytes` > 0),
  CONSTRAINT `chk_submission_file_order` CHECK (`sort_order` <= 4)
) ENGINE=InnoDB;

CREATE TABLE `review_records` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `submission_id` BIGINT UNSIGNED NOT NULL,
  `version_no` INT UNSIGNED NOT NULL,
  `reviewer_id` BIGINT UNSIGNED NOT NULL,
  `decision` VARCHAR(24) NOT NULL,
  `comment` TEXT NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_review_records_submission_time` (`submission_id`, `created_at`),
  KEY `idx_review_records_reviewer_time` (`reviewer_id`, `created_at`),
  CONSTRAINT `fk_review_records_version` FOREIGN KEY (`submission_id`, `version_no`) REFERENCES `submission_versions` (`submission_id`, `version_no`),
  CONSTRAINT `fk_review_records_reviewer` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_review_records_decision` CHECK (`decision` IN ('selected', 'revision_requested', 'rejected'))
) ENGINE=InnoDB;

CREATE TABLE `exhibition_sections` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `exhibition_id` BIGINT UNSIGNED NOT NULL,
  `title` VARCHAR(120) NOT NULL,
  `description` TEXT NULL,
  `sort_order` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_exhibition_sections_id_exhibition` (`id`, `exhibition_id`),
  UNIQUE KEY `uq_exhibition_sections_order` (`exhibition_id`, `sort_order`),
  CONSTRAINT `fk_exhibition_sections_exhibition` FOREIGN KEY (`exhibition_id`) REFERENCES `exhibitions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `section_placements` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `section_id` BIGINT UNSIGNED NOT NULL,
  `submission_id` BIGINT UNSIGNED NOT NULL,
  `exhibition_id` BIGINT UNSIGNED NOT NULL,
  `version_no` INT UNSIGNED NOT NULL,
  `sort_order` INT UNSIGNED NOT NULL DEFAULT 0,
  `wall_label` TEXT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_section_placements_submission` (`section_id`, `submission_id`),
  UNIQUE KEY `uq_section_placements_order` (`section_id`, `sort_order`),
  CONSTRAINT `fk_section_placements_section` FOREIGN KEY (`section_id`, `exhibition_id`) REFERENCES `exhibition_sections` (`id`, `exhibition_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_section_placements_submission` FOREIGN KEY (`submission_id`, `exhibition_id`) REFERENCES `submissions` (`id`, `exhibition_id`),
  CONSTRAINT `fk_section_placements_version` FOREIGN KEY (`submission_id`, `version_no`) REFERENCES `submission_versions` (`submission_id`, `version_no`)
) ENGINE=InnoDB;

CREATE TABLE `exhibition_sessions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `exhibition_id` BIGINT UNSIGNED NOT NULL,
  `starts_at` DATETIME(3) NOT NULL,
  `ends_at` DATETIME(3) NOT NULL,
  `capacity` INT UNSIGNED NOT NULL,
  `status` VARCHAR(16) NOT NULL DEFAULT 'open',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_exhibition_sessions_exhibition_time` (`exhibition_id`, `starts_at`),
  CONSTRAINT `fk_exhibition_sessions_exhibition` FOREIGN KEY (`exhibition_id`) REFERENCES `exhibitions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_exhibition_sessions_dates` CHECK (`ends_at` > `starts_at`),
  CONSTRAINT `chk_exhibition_sessions_capacity` CHECK (`capacity` > 0),
  CONSTRAINT `chk_exhibition_sessions_status` CHECK (`status` IN ('open', 'closed', 'cancelled'))
) ENGINE=InnoDB;

CREATE TABLE `reservations` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `session_id` BIGINT UNSIGNED NOT NULL,
  `credential_token_hash` BINARY(32) NOT NULL COMMENT '随机凭证令牌的 SHA-256，不存明文',
  `status` VARCHAR(16) NOT NULL DEFAULT 'reserved',
  `reserved_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `cancelled_at` DATETIME(3) NULL,
  `checked_in_at` DATETIME(3) NULL,
  `checked_in_by` BIGINT UNSIGNED NULL,
  `active_user_id` BIGINT UNSIGNED GENERATED ALWAYS AS (CASE WHEN `status` IN ('reserved', 'checked_in') THEN `user_id` ELSE NULL END) STORED,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_reservations_credential_hash` (`credential_token_hash`),
  UNIQUE KEY `uq_reservations_one_active_per_session` (`session_id`, `active_user_id`),
  KEY `idx_reservations_user_status` (`user_id`, `status`, `reserved_at`),
  CONSTRAINT `fk_reservations_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_reservations_session` FOREIGN KEY (`session_id`) REFERENCES `exhibition_sessions` (`id`),
  CONSTRAINT `fk_reservations_checker` FOREIGN KEY (`checked_in_by`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_reservations_status` CHECK (`status` IN ('reserved', 'checked_in', 'cancelled', 'expired')),
  CONSTRAINT `chk_reservations_checkin_fields` CHECK ((`status` = 'checked_in' AND `checked_in_at` IS NOT NULL AND `checked_in_by` IS NOT NULL) OR (`status` <> 'checked_in'))
) ENGINE=InnoDB;

CREATE TABLE `favorites` (
  `user_id` BIGINT UNSIGNED NOT NULL,
  `artwork_id` BIGINT UNSIGNED NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`user_id`, `artwork_id`),
  CONSTRAINT `fk_favorites_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_favorites_artwork` FOREIGN KEY (`artwork_id`) REFERENCES `artworks` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `feedback` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `exhibition_id` BIGINT UNSIGNED NOT NULL,
  `rating` TINYINT UNSIGNED NULL,
  `content` TEXT NULL,
  `is_public` BOOLEAN NOT NULL DEFAULT FALSE,
  `status` VARCHAR(16) NOT NULL DEFAULT 'submitted',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_feedback_exhibition_status` (`exhibition_id`, `status`, `created_at`),
  CONSTRAINT `fk_feedback_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_feedback_exhibition` FOREIGN KEY (`exhibition_id`) REFERENCES `exhibitions` (`id`),
  CONSTRAINT `chk_feedback_rating` CHECK (`rating` IS NULL OR `rating` BETWEEN 1 AND 5),
  CONSTRAINT `chk_feedback_status` CHECK (`status` IN ('submitted', 'reviewed', 'hidden'))
) ENGINE=InnoDB;

CREATE TABLE `user_messages` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `exhibition_id` BIGINT UNSIGNED NULL,
  `title` VARCHAR(160) NOT NULL,
  `body` TEXT NOT NULL,
  `read_at` DATETIME(3) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_user_messages_inbox` (`user_id`, `read_at`, `created_at`),
  CONSTRAINT `fk_user_messages_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_messages_exhibition` FOREIGN KEY (`exhibition_id`) REFERENCES `exhibitions` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `audit_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `actor_id` BIGINT UNSIGNED NULL,
  `exhibition_id` BIGINT UNSIGNED NULL,
  `action` VARCHAR(80) NOT NULL,
  `entity_type` VARCHAR(80) NOT NULL,
  `entity_id` BIGINT UNSIGNED NOT NULL,
  `details` JSON NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_audit_logs_entity` (`entity_type`, `entity_id`, `created_at`),
  KEY `idx_audit_logs_actor_time` (`actor_id`, `created_at`),
  CONSTRAINT `fk_audit_logs_actor` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_audit_logs_exhibition` FOREIGN KEY (`exhibition_id`) REFERENCES `exhibitions` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;
