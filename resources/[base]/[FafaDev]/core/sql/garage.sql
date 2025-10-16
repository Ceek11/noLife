-- Table pour stocker les véhicules des joueurs (si elle n'existe pas déjà)
CREATE TABLE IF NOT EXISTS `owned_vehicles` (
  `owner` varchar(60) NOT NULL,
  `plate` varchar(12) NOT NULL,
  `vehicle` longtext DEFAULT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'car',
  `job` varchar(20) DEFAULT NULL,
  `job2` varchar(20) DEFAULT NULL,
  `stored` int(11) NOT NULL DEFAULT 0,
  `label` varchar(100) DEFAULT NULL,
  `pound` int(11) NOT NULL DEFAULT 0,
  `parking` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`plate`),
  KEY `owner` (`owner`),
  KEY `type` (`type`),
  KEY `job` (`job`),
  KEY `job2` (`job2`),
  KEY `stored` (`stored`),
  KEY `pound` (`pound`),
  KEY `parking` (`parking`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Table pour stocker les clés des véhicules (si elle n'existe pas déjà)
CREATE TABLE IF NOT EXISTS `open_car` (
  `identifier` varchar(60) NOT NULL,
  `label` varchar(100) NOT NULL,
  `value` varchar(12) NOT NULL,
  `got` varchar(10) NOT NULL DEFAULT 'false',
  `NB` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`identifier`, `value`),
  KEY `value` (`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Index pour optimiser les performances
CREATE INDEX IF NOT EXISTS `idx_owned_vehicles_owner_type` ON `owned_vehicles` (`owner`, `type`);
CREATE INDEX IF NOT EXISTS `idx_owned_vehicles_parking_stored` ON `owned_vehicles` (`parking`, `stored`);
CREATE INDEX IF NOT EXISTS `idx_owned_vehicles_pound` ON `owned_vehicles` (`pound`);
