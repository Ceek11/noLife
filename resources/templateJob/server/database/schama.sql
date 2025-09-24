INSERT INTO `jobs` (`name`, `label`) VALUES
('template', 'Template Job');

INSERT INTO `jobs_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('template', 0, 'employee', 'Employé', 200, '{}', '{}'),
('template', 1, 'senior', 'Senior', 300, '{}', '{}'),
('template', 2, 'supervisor', 'Superviseur', 400, '{}', '{}'),
('template', 3, 'manager', 'Manager', 500, '{}', '{}'),
('template', 4, 'boss', 'Patron', 600, '{}', '{}');

-- Table pour le système de coffre (format compact avec JSON)
CREATE TABLE IF NOT EXISTS `fafa_chest` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `job_name` varchar(50) NOT NULL,
    `items` longtext NOT NULL DEFAULT '{}',
    `max_weight` decimal(10,2) NOT NULL DEFAULT 100.00,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_job` (`job_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;