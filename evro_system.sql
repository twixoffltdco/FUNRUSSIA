-- =====================================================
-- База данных для системы евро (SA:MP / Pawn)
-- MySQL 5.7+ / MariaDB 10.2+
-- Кодировка: utf8mb4 (поддержка эмодзи и всех символов)
-- =====================================================

CREATE DATABASE IF NOT EXISTS `samp_evro`
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE `samp_evro`;

-- =====================================================
-- Таблица игроков
-- =====================================================
CREATE TABLE IF NOT EXISTS `players` (
    `id`             INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `name`           VARCHAR(24)     NOT NULL DEFAULT '',
    `password`       VARCHAR(128)    NOT NULL DEFAULT '',

    `evro`           INT UNSIGNED    NOT NULL DEFAULT 0
                                     COMMENT 'Текущий баланс евро',
    `evro_bought`    INT UNSIGNED    NOT NULL DEFAULT 0
                                     COMMENT 'Всего куплено евро (для топа)',
    `evro_sold`      INT UNSIGNED    NOT NULL DEFAULT 0
                                     COMMENT 'Всего продано евро',
    `rub`            INT UNSIGNED    NOT NULL DEFAULT 0
                                     COMMENT 'Баланс рублей',

    `admin_level`    TINYINT UNSIGNED NOT NULL DEFAULT 0,

    `reg_date`       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_login`     DATETIME        NULL DEFAULT NULL,

    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_name` (`name`),
    KEY `idx_evro_bought` (`evro_bought` DESC),
    KEY `idx_evro` (`evro` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Логи обменов (опционально, для истории)
-- =====================================================
CREATE TABLE IF NOT EXISTS `evro_exchange_log` (
    `id`             INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `player_id`      INT UNSIGNED    NOT NULL,
    `player_name`    VARCHAR(24)     NOT NULL,
    `operation`      ENUM('buy', 'sell') NOT NULL,
    `amount`         INT UNSIGNED    NOT NULL,
    `rub_amount`     INT UNSIGNED    NOT NULL
                                     COMMENT 'Сколько рублей списано/начислено',
    `rate`           INT UNSIGNED    NOT NULL
                                     COMMENT 'Курс на момент операции',
    `balance_after`  INT UNSIGNED    NOT NULL
                                     COMMENT 'Баланс евро после операции',
    `created_at`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`id`),
    KEY `idx_player_id` (`player_id`),
    KEY `idx_created_at` (`created_at`),
    KEY `idx_operation` (`operation`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Активный курс обмена (можно менять без перезапуска)
-- =====================================================
CREATE TABLE IF NOT EXISTS `evro_settings` (
    `key`            VARCHAR(32)     NOT NULL,
    `value`          VARCHAR(128)    NOT NULL,
    `updated_at`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `evro_settings` (`key`, `value`) VALUES
    ('exchange_rate', '100'),
    ('max_per_op',    '500'),
    ('top_count',     '10')
ON DUPLICATE KEY UPDATE `value` = `value`;

-- =====================================================
-- Если таблица players уже существует, миграция:
-- =====================================================
-- ALTER TABLE `players`
--     ADD COLUMN IF NOT EXISTS `evro`        INT UNSIGNED NOT NULL DEFAULT 0,
--     ADD COLUMN IF NOT EXISTS `evro_bought` INT UNSIGNED NOT NULL DEFAULT 0,
--     ADD COLUMN IF NOT EXISTS `evro_sold`   INT UNSIGNED NOT NULL DEFAULT 0,
--     ADD COLUMN IF NOT EXISTS `rub`         INT UNSIGNED NOT NULL DEFAULT 0,
--     ADD KEY IF NOT EXISTS `idx_evro_bought` (`evro_bought` DESC),
--     ADD KEY IF NOT EXISTS `idx_evro` (`evro` DESC);

-- =====================================================
-- Тестовые данные (опционально, удалить в проде)
-- =====================================================
-- INSERT INTO `players` (`name`, `password`, `evro`, `evro_bought`, `rub`, `admin_level`) VALUES
--     ('Test_Player1', 'hash', 500, 1200, 50000, 0),
--     ('Test_Player2', 'hash', 250, 800,  30000, 0),
--     ('Test_Player3', 'hash', 999, 1500, 10000, 7),
--     ('Admin_Test',   'hash', 0,   0,    0,     7);

-- =====================================================
-- Проверка топа
-- =====================================================
-- SELECT name, evro_bought FROM `players` ORDER BY evro_bought DESC LIMIT 10;
