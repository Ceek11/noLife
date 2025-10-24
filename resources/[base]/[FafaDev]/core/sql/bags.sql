CREATE TABLE IF NOT EXISTS `dropped_bags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bag_name` varchar(100) NOT NULL,
  `bag_type` varchar(50) NOT NULL,
  `owner_identifier` varchar(60) NOT NULL,
  `x` decimal(10,6) NOT NULL,
  `y` decimal(10,6) NOT NULL,
  `z` decimal(10,6) NOT NULL,
  `heading` decimal(10,6) NOT NULL DEFAULT 0.0,
  `items` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_accessed` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `owner_identifier` (`owner_identifier`),
  KEY `bag_name` (`bag_name`),
  KEY `coordinates` (`x`, `y`, `z`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
