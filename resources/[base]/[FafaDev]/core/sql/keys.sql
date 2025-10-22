CREATE TABLE IF NOT EXISTS `vehicle_keys` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `plate` varchar(8) NOT NULL,
    `owner` varchar(60) NOT NULL,
    `type` enum('personal','job','rental','temporary') NOT NULL DEFAULT 'personal',
    `job` varchar(50) DEFAULT NULL,
    `expires_at` timestamp NULL DEFAULT NULL,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_plate_owner` (`plate`, `owner`),
    KEY `plate` (`plate`),
    KEY `owner` (`owner`),
    KEY `type` (`type`),
    KEY `job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS `idx_vehicle_keys_plate_owner` ON `vehicle_keys` (`plate`, `owner`);
CREATE INDEX IF NOT EXISTS `idx_vehicle_keys_owner_type` ON `vehicle_keys` (`owner`, `type`);
CREATE INDEX IF NOT EXISTS `idx_vehicle_keys_job` ON `vehicle_keys` (`job`);
