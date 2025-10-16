CREATE TABLE IF NOT EXISTS `cloakroom` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `society_name` varchar(50) NOT NULL,
  `info_outfit` longtext NOT NULL,
  `outfit` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE IF NOT EXISTS `cloakroom_outfits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cloakroom_uid` varchar(50) NOT NULL,
  `outfit_uid` varchar(50) NOT NULL,
  `label` varchar(100) NOT NULL,
  `job` varchar(50) NOT NULL,
  `grade_required` int(11) DEFAULT 0,
  `skin_male` longtext DEFAULT NULL,
  `skin_female` longtext DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `outfit_uid` (`outfit_uid`),
  KEY `cloakroom_uid` (`cloakroom_uid`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;