-- Table pour stocker les armes de l'armurerie
CREATE TABLE IF NOT EXISTS `armurerie_weapons` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `society` varchar(50) NOT NULL,
    `weapons` JSON NOT NULL,
    PRIMARY KEY (`id`),
    KEY `society` (`society`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
