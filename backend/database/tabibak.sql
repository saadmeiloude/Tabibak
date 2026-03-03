-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : jeu. 25 déc. 2025 à 13:17
-- Version du serveur : 8.2.0
-- Version de PHP : 8.2.13

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `tabibak`
--

-- --------------------------------------------------------

--
-- Structure de la table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
CREATE TABLE IF NOT EXISTS `appointments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int NOT NULL,
  `doctor_id` int NOT NULL,
  `appointment_date` date NOT NULL,
  `appointment_time` time NOT NULL,
  `duration_minutes` int DEFAULT '30',
  `status` enum('pending','confirmed','cancelled','completed','no_show') DEFAULT 'pending',
  `consultation_type` enum('online','in_person') DEFAULT 'online',
  `symptoms` text,
  `notes` text,
  `prescription` text,
  `fee_paid` decimal(10,2) DEFAULT '0.00',
  `payment_status` enum('pending','paid','refunded') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_patient` (`patient_id`),
  KEY `idx_doctor` (`doctor_id`),
  KEY `idx_date` (`appointment_date`),
  KEY `idx_status` (`status`)
) ENGINE=MyISAM AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `appointments`
--

INSERT INTO `appointments` (`id`, `patient_id`, `doctor_id`, `appointment_date`, `appointment_time`, `duration_minutes`, `status`, `consultation_type`, `symptoms`, `notes`, `prescription`, `fee_paid`, `payment_status`, `created_at`, `updated_at`) VALUES
(1, 8, 1, '2025-12-17', '08:51:00', 30, 'pending', '', 'une mal de dans dans la bouche', NULL, NULL, 0.00, 'pending', '2025-12-17 08:51:11', '2025-12-17 08:51:11'),
(2, 8, 1, '2025-12-17', '09:08:00', 30, 'pending', 'online', 'salam', NULL, NULL, 0.00, 'pending', '2025-12-17 09:08:34', '2025-12-17 09:08:34'),
(3, 8, 1, '2025-12-27', '16:00:00', 30, 'cancelled', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-17 09:29:31', '2025-12-21 11:45:01'),
(4, 8, 1, '2025-12-17', '09:31:00', 30, 'cancelled', 'online', 'je suit male au dos', NULL, NULL, 0.00, 'pending', '2025-12-17 09:31:35', '2025-12-21 15:25:56'),
(5, 11, 1, '2025-12-24', '07:30:00', 30, 'pending', 'online', 'الا الجوف', NULL, NULL, 0.00, 'pending', '2025-12-17 16:13:06', '2025-12-23 10:35:46'),
(6, 8, 1, '2025-12-18', '09:14:00', 30, 'pending', 'online', 'salam', NULL, NULL, 0.00, 'pending', '2025-12-18 09:14:13', '2025-12-18 09:14:13'),
(7, 8, 1, '2025-12-26', '16:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-18 10:05:09', '2025-12-23 10:35:46'),
(8, 8, 3, '2025-12-18', '11:05:00', 30, 'confirmed', 'online', 'cv da7moud', NULL, NULL, 0.00, 'pending', '2025-12-18 11:06:00', '2025-12-23 10:35:46'),
(9, 8, 3, '2025-12-24', '11:00:00', 30, 'confirmed', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-18 12:52:01', '2025-12-23 10:35:46'),
(10, 20, 3, '2025-12-28', '16:00:00', 30, 'confirmed', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-18 13:48:57', '2025-12-23 10:35:46'),
(11, 8, 3, '2025-12-29', '16:30:00', 30, 'cancelled', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-18 14:28:24', '2025-12-23 10:35:46'),
(12, 22, 3, '2025-12-25', '19:00:00', 30, 'confirmed', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-18 14:37:03', '2025-12-23 10:35:46'),
(13, 16, 3, '2025-12-25', '04:15:00', 30, 'pending', 'online', 'voir', NULL, NULL, 0.00, 'pending', '2025-12-19 08:31:32', '2025-12-23 10:35:46'),
(14, 15, 3, '2025-12-19', '08:45:00', 30, 'cancelled', 'online', '', NULL, NULL, 0.00, 'pending', '2025-12-19 08:32:35', '2025-12-23 10:35:46'),
(15, 8, 2, '2025-12-24', '19:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-21 11:48:43', '2025-12-23 10:35:46'),
(16, 8, 1, '2025-12-25', '16:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-21 15:20:50', '2025-12-23 10:35:46'),
(17, 8, 2, '2025-12-27', '11:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-21 15:41:51', '2025-12-23 10:35:46'),
(18, 8, 2, '2025-12-31', '14:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-21 15:43:33', '2025-12-23 10:35:46'),
(19, 8, 3, '2025-12-31', '14:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-21 15:47:44', '2025-12-23 10:35:46'),
(20, 8, 10, '2025-12-24', '10:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-22 13:50:04', '2025-12-23 10:35:46'),
(21, 8, 11, '2025-12-25', '10:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-22 14:02:34', '2025-12-23 10:35:46'),
(22, 8, 11, '2025-12-31', '10:30:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-22 14:22:45', '2025-12-23 10:35:46'),
(23, 8, 11, '2025-12-31', '10:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-22 14:35:22', '2025-12-23 10:35:46'),
(24, 8, 11, '2025-12-31', '18:30:00', 30, 'cancelled', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-22 14:38:06', '2025-12-23 10:35:46'),
(25, 8, 10, '2025-12-31', '14:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-22 15:28:21', '2025-12-23 10:35:46'),
(26, 8, 1, '2025-12-22', '15:30:00', 30, 'pending', 'online', 'slm jviotiofifi', NULL, NULL, 0.00, 'pending', '2025-12-22 15:30:02', '2025-12-22 15:30:02'),
(27, 29, 12, '2025-12-24', '10:00:00', 30, 'pending', 'online', 'UNIT_TEST_SYMPTOMS', NULL, NULL, 0.00, 'pending', '2025-12-23 08:47:37', '2025-12-23 08:47:37'),
(28, 8, 11, '2025-12-24', '10:30:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-23 08:53:29', '2025-12-23 10:35:46'),
(29, 8, 3, '2025-12-23', '14:30:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-23 08:56:27', '2025-12-23 10:35:46'),
(30, 8, 2, '2025-12-23', '16:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-23 08:57:10', '2025-12-23 10:35:46'),
(31, 8, 4, '2025-12-23', '16:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-23 08:57:45', '2025-12-23 10:35:46'),
(32, 8, 11, '2025-12-26', '19:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-23 09:11:57', '2025-12-23 10:35:46'),
(33, 8, 11, '2025-12-26', '11:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-23 09:28:55', '2025-12-23 10:35:46'),
(34, 8, 11, '2025-12-29', '16:30:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-23 09:37:22', '2025-12-23 10:35:46'),
(35, 8, 11, '2025-12-26', '19:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-23 09:53:12', '2025-12-23 09:53:12'),
(36, 8, 2, '2025-12-24', '16:00:00', 30, 'confirmed', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-23 10:18:01', '2025-12-23 10:23:07'),
(37, 8, 1, '2025-12-23', '18:00:00', 30, 'confirmed', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-23 10:29:15', '2025-12-23 10:30:43'),
(38, 30, 10, '2025-12-28', '19:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-23 11:04:38', '2025-12-23 11:04:38'),
(39, 33, 14, '2025-12-25', '11:00:00', 30, 'confirmed', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-23 21:24:08', '2025-12-23 21:55:26'),
(40, 33, 10, '2025-12-30', '18:00:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-23 21:39:18', '2025-12-23 21:39:18'),
(41, 7, 14, '2025-12-24', '14:00:00', 30, 'confirmed', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-24 11:42:31', '2025-12-24 11:45:22'),
(42, 7, 13, '2025-12-28', '16:30:00', 30, 'pending', 'online', 'Booking via Calendar', NULL, NULL, 0.00, 'pending', '2025-12-24 11:57:52', '2025-12-24 11:57:52');

-- --------------------------------------------------------

--
-- Structure de la table `commission_settings`
--

DROP TABLE IF EXISTS `commission_settings`;
CREATE TABLE IF NOT EXISTS `commission_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_type` varchar(50) NOT NULL,
  `commission_type` enum('fixed','percentage') NOT NULL,
  `commission_value` decimal(10,2) NOT NULL,
  `min_amount` decimal(12,2) DEFAULT '0.00',
  `max_amount` decimal(12,2) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_type_commission` (`transaction_type`),
  KEY `idx_active` (`is_active`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `commission_settings`
--

INSERT INTO `commission_settings` (`id`, `transaction_type`, `commission_type`, `commission_value`, `min_amount`, `max_amount`, `is_active`, `description`, `created_at`, `updated_at`) VALUES
(1, 'appointment_payment', 'percentage', 10.00, 0.00, NULL, 1, 'عمولة على دفع المواعيد - 10%', '2025-12-21 09:55:06', '2025-12-21 09:55:06'),
(2, 'withdrawal', 'fixed', 5.00, 0.00, NULL, 1, 'رسوم سحب ثابتة - 5 أوقية', '2025-12-21 09:55:06', '2025-12-21 09:55:06'),
(3, 'deposit_card', 'percentage', 2.00, 0.00, NULL, 1, 'رسوم الإيداع بالبطاقة - 2%', '2025-12-21 09:55:06', '2025-12-21 09:55:06'),
(4, 'appointment_payment', 'percentage', 10.00, 0.00, NULL, 1, 'عمولة على دفع المواعيد - 10%', '2025-12-21 10:10:32', '2025-12-21 10:10:32'),
(5, 'withdrawal', 'fixed', 5.00, 0.00, NULL, 1, 'رسوم سحب ثابتة - 5 أوقية', '2025-12-21 10:10:32', '2025-12-21 10:10:32'),
(6, 'deposit_card', 'percentage', 2.00, 0.00, NULL, 1, 'رسوم الإيداع بالبطاقة - 2%', '2025-12-21 10:10:32', '2025-12-21 10:10:32');

-- --------------------------------------------------------

--
-- Structure de la table `doctors`
--

DROP TABLE IF EXISTS `doctors`;
CREATE TABLE IF NOT EXISTS `doctors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(255) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `profile_image` varchar(500) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `user_id` int NOT NULL,
  `license_number` varchar(40) NOT NULL,
  `specialization` varchar(80) NOT NULL,
  `experience_years` int DEFAULT '0',
  `education` text,
  `certifications` text,
  `consultation_fee` decimal(10,2) DEFAULT '0.00',
  `availability_schedule` text,
  `rating` decimal(3,2) DEFAULT '0.00',
  `total_reviews` int DEFAULT '0',
  `is_available` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `license_number` (`license_number`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`),
  KEY `user_id` (`user_id`),
  KEY `idx_license` (`license_number`),
  KEY `idx_specialization` (`specialization`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `doctors`
--

INSERT INTO `doctors` (`id`, `full_name`, `email`, `phone`, `password`, `profile_image`, `is_verified`, `is_active`, `user_id`, `license_number`, `specialization`, `experience_years`, `education`, `certifications`, `consultation_fee`, `availability_schedule`, `rating`, `total_reviews`, `is_available`, `created_at`, `updated_at`) VALUES
(12, 'Test Doctor', 'test_doctor@test.com', NULL, NULL, NULL, 0, 1, 28, 'LIC123', 'cardiology', 10, NULL, NULL, 500.00, NULL, 5.00, 0, 1, '2025-12-23 08:47:37', '2025-12-23 08:47:37'),
(1, 'moussa', 'moussa@gmail.com', '37916779', '$2y$10$cMAQvKtGM3iS5dswnc/Mg.QKBQAuVhk1/N1Ybc0KGAEOkWMOGT572', NULL, 1, 1, 13, '34756', 'medcin', 19, '', 'bac + 7', 700.00, NULL, 0.00, 0, 1, '2025-12-17 13:35:15', '2025-12-22 11:09:25'),
(2, 'Saadouz', 'cloud@gmail.com', '41840267', '$2y$10$hr1mz5EdiawVIZLJQ4C1aOEhBfIdOxLC14k/3kh/iXve3sVnBcClu', NULL, 1, 1, 18, '56876', 'medcin generale', 0, NULL, NULL, 0.00, NULL, 0.00, 0, 1, '2025-12-18 10:09:08', '2025-12-22 11:09:34'),
(3, 'dr.da7moud', 'dr.da7moud@gmail.com', '48769856', '$2y$10$JKQo53mSNPz0VurbUhID6.ow0lAOZIH.7/jW9eIHffhLErjtz5z5e', 'uploads/profiles/profile_19_1766222233.png', 1, 1, 19, 'DR.Da7moud', 'Doctors en coeur', 8, 'Bac + 8', '', 2000.00, NULL, 0.00, 0, 1, '2025-12-18 11:02:02', '2025-12-22 11:09:42'),
(10, 'mohamed', 'mohamed@gmail.com', '35678134', '$2y$10$WyDV7/9ziNVTw9xbl/SGjO2a4WVhwvFMZRGS9CBFpLxPR2rGZY5zO', NULL, 1, 1, 24, '8', 'Medcine General', 18, NULL, NULL, 3000.00, NULL, 0.00, 0, 1, '2025-12-22 11:16:06', '2025-12-22 13:28:04'),
(4, 'DR.Ayya', 'dr.ayya@gmail.com', '45679809', '$2y$10$bR6uluRgIhEzpvGylLYBp.qgLQlhjUosCVOi9zaBFt/g9F388T2yq', NULL, 1, 1, 25, '7835', 'Medcin general', 9, NULL, NULL, 2000.00, NULL, 0.00, 0, 1, '2025-12-21 10:18:00', '2025-12-22 13:28:04'),
(5, 'DR.abou', 'dr.abou@gmail.com', '45675489', '$2y$10$ojEtbR8LcLvpjbJHXSrfJuVt5GsQkIEckBx192EbI4Mrs1oEOXDOG', NULL, 1, 1, 26, '4845', 'Medcine General', 10, NULL, NULL, 2000.00, NULL, 0.00, 0, 1, '2025-12-21 10:34:03', '2025-12-22 13:28:04'),
(11, 'Mariem', 'mariem@gmail.com', '40238709', '$2y$10$aoCzbuyLb1diDM8qAxRG7.ik220466nlSCLaVFyuyQFBTqQ/DWdBq', NULL, 1, 1, 27, '4039', 'Medcine Generale', 8, NULL, NULL, 8000.00, NULL, 0.00, 0, 1, '2025-12-22 14:01:26', '2025-12-22 14:01:26'),
(13, 'DR.Elhaje', 'elhaj@gmail.com', '23768905', '$2y$10$KduKgE6K//KbD0stuabKxu0AvB92N0axTCc5BimZE4ZFOCT6GrJoq', NULL, 1, 1, 34, '486', 'Docteur des yeux', 7, NULL, NULL, 2800.00, NULL, 0.00, 0, 1, '2025-12-23 21:02:34', '2025-12-23 21:02:34'),
(14, 'DR.Omar', 'omar@gmail.com', '26784312', '$2y$10$gMCv27Iw4.esPm8ILBXRqO7rb5MkDUpPUg0kywxtLuBmBHXxWpIBK', NULL, 1, 1, 35, '781', 'Docteur en peaux', 9, NULL, NULL, 2900.00, NULL, 0.00, 0, 1, '2025-12-23 21:22:29', '2025-12-23 21:22:29');

-- --------------------------------------------------------

--
-- Structure de la table `medical_records`
--

DROP TABLE IF EXISTS `medical_records`;
CREATE TABLE IF NOT EXISTS `medical_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int NOT NULL,
  `doctor_id` int NOT NULL,
  `appointment_id` int DEFAULT NULL,
  `record_type` enum('consultation','prescription','test_result','diagnosis') NOT NULL,
  `title` varchar(150) NOT NULL,
  `description` text,
  `diagnosis` text,
  `treatment` text,
  `medications` text,
  `attachments` varchar(200) DEFAULT NULL,
  `record_date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `appointment_id` (`appointment_id`),
  KEY `idx_patient_rec` (`patient_id`),
  KEY `idx_doctor_rec` (`doctor_id`),
  KEY `idx_type` (`record_type`),
  KEY `idx_date_rec` (`record_date`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `medical_records`
--

INSERT INTO `medical_records` (`id`, `patient_id`, `doctor_id`, `appointment_id`, `record_type`, `title`, `description`, `diagnosis`, `treatment`, `medications`, `attachments`, `record_date`, `created_at`, `updated_at`) VALUES
(1, 11, 13, NULL, 'prescription', 'وصفة طبية', NULL, 'وصفة طبية', NULL, 'دواء ديدان المعدة', NULL, '2025-12-18', '2025-12-18 10:38:23', '2025-12-18 10:38:23'),
(2, 11, 13, NULL, 'diagnosis', 'تحليل الدم', 'يصاحبي انت دمك خامر و فيه الامراض', 'تحليل الدم', NULL, '', NULL, '2025-12-18', '2025-12-18 10:39:30', '2025-12-18 10:39:30'),
(3, 10, 19, NULL, 'prescription', 'وصفة طبية', NULL, 'وصفة طبية', NULL, 'ديدان المعدة', NULL, '2025-12-18', '2025-12-18 14:23:02', '2025-12-18 14:23:02'),
(4, 10, 19, NULL, 'diagnosis', 'تحليل الدم', 'نظيف او سليم', 'تحليل الدم', NULL, '', NULL, '2025-12-18', '2025-12-18 14:23:34', '2025-12-18 14:23:34'),
(5, 8, 8, NULL, 'test_result', 'Presentation_GraphQL_Bibliotheque.pdf', NULL, NULL, NULL, NULL, 'uploads/medical_records/record_8_1766223578.pdf', '2025-12-20', '2025-12-20 09:39:38', '2025-12-20 09:39:38'),
(6, 8, 8, NULL, 'test_result', 'scaled_saad-photo.jpg', NULL, NULL, NULL, NULL, 'uploads/medical_records/record_8_1766223606.jpg', '2025-12-20', '2025-12-20 09:40:06', '2025-12-20 09:40:06'),
(7, 10, 6, NULL, 'prescription', 'وصفة طبية', NULL, 'وصفة طبية', NULL, 'ديدان المعدة', NULL, '2025-12-21', '2025-12-21 15:36:00', '2025-12-21 15:36:00'),
(8, 10, 6, NULL, 'diagnosis', 'تحليل السكر', 'طرح البال اراسك', 'تحليل السكر', NULL, '', NULL, '2025-12-21', '2025-12-21 15:36:52', '2025-12-21 15:36:52');

-- --------------------------------------------------------

--
-- Structure de la table `medical_research`
--

DROP TABLE IF EXISTS `medical_research`;
CREATE TABLE IF NOT EXISTS `medical_research` (
  `id` int NOT NULL AUTO_INCREMENT,
  `doctor_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `summary` text,
  `content` longtext,
  `attachment_url` varchar(255) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `tags` varchar(255) DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT '1',
  `views` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_doctor` (`doctor_id`),
  KEY `idx_category` (`category`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `messages`
--

DROP TABLE IF EXISTS `messages`;
CREATE TABLE IF NOT EXISTS `messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sender_id` int NOT NULL,
  `receiver_id` int NOT NULL,
  `appointment_id` int DEFAULT NULL,
  `message` text NOT NULL,
  `message_type` enum('text','image','file','voice') DEFAULT 'text',
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `appointment_id` (`appointment_id`),
  KEY `idx_sender` (`sender_id`),
  KEY `idx_receiver` (`receiver_id`),
  KEY `idx_read_msg` (`is_read`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(150) NOT NULL,
  `message` text NOT NULL,
  `type` enum('appointment','reminder','message','system') DEFAULT 'system',
  `is_read` tinyint(1) DEFAULT '0',
  `related_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_notif` (`user_id`),
  KEY `idx_read` (`is_read`),
  KEY `idx_type_notif` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
CREATE TABLE IF NOT EXISTS `password_resets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `token` varchar(100) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_email_reset` (`email`),
  KEY `idx_token_reset` (`token`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `payment_cards`
--

DROP TABLE IF EXISTS `payment_cards`;
CREATE TABLE IF NOT EXISTS `payment_cards` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `card_type` enum('visa','mada','mastercard','other') DEFAULT 'visa',
  `card_number_masked` varchar(20) NOT NULL,
  `holder_name` varchar(100) NOT NULL,
  `expiry_date` varchar(10) NOT NULL,
  `is_default` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `payment_cards`
--

INSERT INTO `payment_cards` (`id`, `user_id`, `card_type`, `card_number_masked`, `holder_name`, `expiry_date`, `is_default`, `created_at`, `updated_at`) VALUES
(1, 8, 'mastercard', '**** **** **** 6345', 'Saad Meiloud', '09/29', 0, '2025-12-20 11:26:22', '2025-12-20 11:31:59'),
(2, 8, 'visa', '**** **** **** 3281', '5ou5ou y5la3', '19/28', 1, '2025-12-20 11:31:04', '2025-12-20 11:31:59'),
(3, 8, 'mastercard', '**** **** **** 7697', 'Ayya', '08/29', 0, '2025-12-21 15:28:11', '2025-12-21 15:28:11'),
(4, 8, 'mada', '**** **** **** 2567', 'Mohamed', '09/29', 0, '2025-12-22 15:26:53', '2025-12-22 15:26:53');

-- --------------------------------------------------------

--
-- Structure de la table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE IF NOT EXISTS `reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int NOT NULL,
  `doctor_id` int NOT NULL,
  `appointment_id` int DEFAULT NULL,
  `rating` int NOT NULL,
  `review_text` text,
  `is_anonymous` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`),
  KEY `appointment_id` (`appointment_id`),
  KEY `idx_doctor_review` (`doctor_id`),
  KEY `idx_rating` (`rating`)
) ;

-- --------------------------------------------------------

--
-- Structure de la table `specialties`
--

DROP TABLE IF EXISTS `specialties`;
CREATE TABLE IF NOT EXISTS `specialties` (
  `id` char(36) NOT NULL,
  `specialty` varchar(100) NOT NULL,
  `specialty_name` varchar(100) NOT NULL,
  `specialty_doctor_count` varchar(10) DEFAULT '0',
  `specialty_image_path` varchar(500) DEFAULT NULL,
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `specialty` (`specialty`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `specialties`
--

INSERT INTO `specialties` (`id`, `specialty`, `specialty_name`, `specialty_doctor_count`, `specialty_image_path`, `description`, `created_at`) VALUES
('id1', 'cardiologist', 'Cardiologie', '12', 'assets/images/cardiologist.png', 'Spécialistes du cœur', '2025-12-20 09:58:45'),
('id2', 'dentist', 'Dentisterie', '8', 'assets/images/dentist.png', 'Soins dentaires', '2025-12-20 09:58:45'),
('id3', 'dermatologist', 'Dermatologie', '5', 'assets/images/dermatologist.png', 'Soins de la peau', '2025-12-20 09:58:45');

-- --------------------------------------------------------

--
-- Structure de la table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
CREATE TABLE IF NOT EXISTS `transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_ref` varchar(50) NOT NULL,
  `wallet_id` int NOT NULL,
  `transaction_type` enum('deposit','withdrawal','payment','refund','transfer','commission') NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency` varchar(3) NOT NULL DEFAULT 'MRU',
  `balance_before` decimal(12,2) NOT NULL,
  `balance_after` decimal(12,2) NOT NULL,
  `status` enum('pending','completed','failed','cancelled') DEFAULT 'pending',
  `payment_method` enum('card','bank_transfer','mobile_money','cash','wallet') DEFAULT 'wallet',
  `description` text,
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transaction_ref` (`transaction_ref`),
  KEY `wallet_id` (`wallet_id`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `transactions`
--

INSERT INTO `transactions` (`id`, `transaction_ref`, `wallet_id`, `transaction_type`, `amount`, `currency`, `balance_before`, `balance_after`, `status`, `payment_method`, `description`, `metadata`, `created_at`) VALUES
(1, 'DEP-6947D7CD8DC2B', 30, 'deposit', 78400.00, 'MRU', 0.00, 78400.00, 'completed', 'card', 'إيداع رصيد', '{\"commission\": 1600, \"net_amount\": 78400, \"gross_amount\": \"80000\", \"payment_method\": \"card\"}', '2025-12-21 11:19:41'),
(2, 'DEP-6947DAC228323', 30, 'deposit', 786.00, 'MRU', 78400.00, 79186.00, 'completed', '', 'إيداع عبر Masrvi (هاتف: 45675489)', '{\"commission\": 0, \"net_amount\": 786, \"gross_amount\": \"786\", \"phone_number\": \"45675489\", \"payment_method\": \"Masrvi\"}', '2025-12-21 11:32:18'),
(3, 'DEP-69481128DC9CB', 8, 'deposit', 1000000.00, 'MRU', 0.00, 1000000.00, 'completed', '', 'إيداع عبر Bimbank (هاتف: 32816779)', '{\"commission\": 0, \"net_amount\": 1000000, \"gross_amount\": \"1000000\", \"phone_number\": \"32816779\", \"payment_method\": \"Bimbank\"}', '2025-12-21 15:24:24'),
(4, 'DEP-6948147E6E8D7', 29, 'deposit', 56789.00, 'MRU', 0.00, 56789.00, 'completed', '', 'إيداع عبر Masrvi (هاتف: 45679809)', '{\"commission\": 0, \"net_amount\": 56789, \"gross_amount\": \"56789\", \"phone_number\": \"45679809\", \"payment_method\": \"Masrvi\"}', '2025-12-21 15:38:38'),
(5, 'DEP-6948183DECB84', 8, 'deposit', 100000000.00, 'MRU', 1000000.00, 101000000.00, 'completed', '', 'إيداع عبر Bimbank (هاتف: 32816779)', '{\"commission\": 0, \"net_amount\": 100000000, \"gross_amount\": \"100000000\", \"phone_number\": \"32816779\", \"payment_method\": \"Bimbank\"}', '2025-12-21 15:54:37'),
(6, 'DEP-694962E6AFBBD', 8, 'deposit', 3456.00, 'MRU', 101000000.00, 101003456.00, 'completed', '', 'إيداع عبر Bankily (هاتف: 32816779)', '{\"commission\": 0, \"net_amount\": 3456, \"gross_amount\": \"3456\", \"phone_number\": \"32816779\", \"payment_method\": \"Bankily\"}', '2025-12-22 15:25:26'),
(7, 'DEP-694BD57F30922', 7, 'deposit', 2000.00, 'MRU', 0.00, 2000.00, 'completed', '', 'إيداع عبر Bankily (هاتف: 32816779)', '{\"commission\": 0, \"net_amount\": 2000, \"gross_amount\": \"2000\", \"phone_number\": \"32816779\", \"payment_method\": \"Bankily\"}', '2025-12-24 11:58:55');

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(80) NOT NULL,
  `user_type` enum('patient','doctor','admin') DEFAULT 'patient',
  `profile_image` varchar(200) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('male','female') DEFAULT 'male',
  `address` text,
  `emergency_contact` varchar(30) DEFAULT NULL,
  `verification_method` enum('sms','email') DEFAULT 'sms',
  `is_verified` tinyint(1) DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_email` (`email`),
  KEY `idx_phone` (`phone`),
  KEY `idx_user_type` (`user_type`)
) ENGINE=MyISAM AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `email`, `phone`, `password`, `full_name`, `user_type`, `profile_image`, `date_of_birth`, `gender`, `address`, `emergency_contact`, `verification_method`, `is_verified`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'admin@tabibak.com', '1234567890', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Admin User', 'admin', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-16 10:42:07', '2025-12-16 10:42:07'),
(2, 'doctor@tabibak.com', '1234567891', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Dr. Ahmed Al-Rashid', 'doctor', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-16 10:42:07', '2025-12-16 10:42:07'),
(3, 'patient@tabibak.com', '1234567892', '$2y$10$8NzGnu4dAgHUAu1bTUNoBu7mRSYbrMYP5/yiueIidHO1HbO9doOWS', 'Fatima Mohamed', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-16 10:42:07', '2025-12-16 12:37:39'),
(4, 'test@example.com', '9876543210', '$2y$10$hDPd2Q4arxOB3uFB0Y1RVuV8GZ/s2T.uqhCsA2klcXolucsCZAFZm', 'Test User', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-16 15:16:58', '2025-12-16 17:42:12'),
(5, 'php.test@tabibak.com', '1122334455', '$2y$10$WR220RTvHSXqTxSmJUIZl.AnSw20cSDsplRq9dKywAMcuq51KcxEa', 'PHP Test User', 'patient', NULL, NULL, 'male', NULL, NULL, 'email', 1, 1, '2025-12-16 16:06:08', '2025-12-16 17:42:12'),
(6, 'auto.php@tabibak.com', '4445556666', '$2y$10$wBmu0y1hgUOZFZVEQ197HO4HDNhX7nndZY4xEgW4HO/gfyUwBjTsS', 'Auto Verified PHP', 'patient', NULL, NULL, 'male', NULL, NULL, 'email', 1, 1, '2025-12-16 16:09:01', '2025-12-16 16:09:01'),
(7, 'saadmeiloud40@gmail.com', '32816779', '$2y$10$qcCdgEYqnzV4kSwgMFbCHu68cZkijYIVrxb7EkvNBOuO.reoVBcDO', 'Saad Meiloud', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-16 16:11:59', '2025-12-24 11:43:47'),
(8, 'nou7@gmail.com', '32816779', '$2y$10$f9NZ.TOXXBI490St8uRLc.l5StoYP2nUqFLLjfrjO6FmQQl2VPpWm', 'Saad', 'patient', 'uploads/profiles/profile_8_1766221607.jpg', NULL, 'male', 'NKTT', NULL, 'sms', 1, 1, '2025-12-16 16:21:49', '2025-12-21 15:26:34'),
(9, 'nasser@gmail.com', '41840246', '$2y$10$2UfnO2UjIUPSPArzLdIpz.lyLuB47VcakhDVmLl4FVFvynoyCffCu', 'nasser', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-16 18:04:44', '2025-12-16 18:04:44'),
(10, 'ayya@gmail.com', '49886974', '$2y$10$YOOvLLyxpR/G6mgKM6AmrO1iw3.UAQchgZm48PESF/Xlvm1WYEVbq', 'ayya', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-17 10:26:06', '2025-12-17 10:26:06'),
(11, 'khaliva@gmail.com', '44794042', '$2y$10$Eg.KoNRNY7B1PccaKjSqMOqWSFYwji2v0ZZaECERChQXyxcUye0Gy', 'khaliva', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-17 10:32:10', '2025-12-17 10:32:10'),
(12, 'dr.sidi@gmail.com', '33897645', '$2y$10$rN0QqU1Kiu.cHcKTSUZbCehV5mgw8omgecs70Kkw65lHJ2fuMeHXO', 'sidi', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-17 10:37:37', '2025-12-17 10:37:37'),
(13, 'moussa@gmail.com', '37916779', '$2y$10$cMAQvKtGM3iS5dswnc/Mg.QKBQAuVhk1/N1Ybc0KGAEOkWMOGT572', 'moussa', 'doctor', NULL, NULL, 'male', '', NULL, 'sms', 1, 1, '2025-12-17 13:35:15', '2025-12-18 09:26:58'),
(14, 'patient_8@tabibek.local', '8', '$2y$10$ixrjIbpKo2S6y0ex1CjcVewJPZFCJ65NVgNjVCxPt4jxB8P9GmrpK', 'nouh', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-17 15:50:17', '2025-12-17 15:50:17'),
(15, 'patient_9@tabibek.local', '9', '$2y$10$ZO3jeQXOQbMsPPcg.LL8hu3gcTXHh7EvUxGDzOxBNxps/zmtSZ36S', 'hatabi', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-17 16:10:58', '2025-12-17 16:10:58'),
(16, 'patient_10@tabibek.local', '10', '$2y$10$cO8ZKFlzB51ttifHGpeP2.IWxwOoQHDSVt8mHJlGU2iWdAJyJXaMi', 'lemana', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-18 09:17:33', '2025-12-18 09:17:33'),
(17, 'patient_99137456@tabibek.local', '99137456', '$2y$10$BBbZrAN.na4UWG6bhAr6Q.Xw1jyxOyqjHXocoT17UIqs92/ApPXbm', 'Zeid Imigine', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-18 09:57:54', '2025-12-18 09:57:54'),
(18, 'cloud@gmail.com', '41840267', '$2y$10$hr1mz5EdiawVIZLJQ4C1aOEhBfIdOxLC14k/3kh/iXve3sVnBcClu', 'Saadouz', 'doctor', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-18 10:09:08', '2025-12-18 10:09:08'),
(19, 'dr.da7moud@gmail.com', '48769856', '$2y$10$JKQo53mSNPz0VurbUhID6.ow0lAOZIH.7/jW9eIHffhLErjtz5z5e', 'dr.da7moud', 'doctor', 'uploads/profiles/profile_19_1766222233.png', NULL, 'male', '', NULL, 'sms', 1, 1, '2025-12-18 11:02:02', '2025-12-20 09:17:13'),
(20, 'Minetou@gmail.com', '37098614', '$2y$10$8zzw.l0jRGpfg77/KkERXu.UkFPh7sI4Kn3lGaYGrdcOZ7RKSACNe', 'Minetou', 'patient', NULL, NULL, 'male', NULL, NULL, 'email', 1, 1, '2025-12-18 13:16:41', '2025-12-18 13:16:41'),
(21, 'demba@gmail.com', '46768798', '$2y$10$Yxh3RjoO0w2Z.1SBFCJgiev6KnW608C4jcJbr2r2fxFtECRQ84uoq', 'Demba', 'patient', NULL, NULL, 'male', NULL, NULL, 'email', 1, 1, '2025-12-18 14:09:58', '2025-12-18 14:09:58'),
(22, 'bounna@gmail.com', '36050044', '$2y$10$lQFbAwDEHVlI10tiHql2UuvQugVUAJsca184BXIPADraMMwYH7J/W', '5ouna', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-18 14:34:03', '2025-12-18 14:34:03'),
(23, 'saad@gmail.com', '39870809', '$2y$10$WuaVYE952MjsatoEyUfHDO28HMeckrPN3ejs4cp3vUDA041r167p6', 'Saad', 'patient', NULL, NULL, 'male', NULL, NULL, 'email', 1, 1, '2025-12-20 11:11:25', '2025-12-20 11:11:25'),
(24, 'mohamed@gmail.com', '35678134', '$2y$10$WyDV7/9ziNVTw9xbl/SGjO2a4WVhwvFMZRGS9CBFpLxPR2rGZY5zO', 'mohamed', 'doctor', NULL, NULL, 'male', NULL, NULL, 'email', 1, 1, '2025-12-22 13:28:04', '2025-12-22 13:28:04'),
(25, 'dr.ayya@gmail.com', '45679809', '$2y$10$bR6uluRgIhEzpvGylLYBp.qgLQlhjUosCVOi9zaBFt/g9F388T2yq', 'DR.Ayya', 'doctor', NULL, NULL, 'male', NULL, NULL, 'email', 1, 1, '2025-12-22 13:28:04', '2025-12-22 13:28:04'),
(26, 'dr.abou@gmail.com', '45675489', '$2y$10$ojEtbR8LcLvpjbJHXSrfJuVt5GsQkIEckBx192EbI4Mrs1oEOXDOG', 'DR.abou', 'doctor', NULL, NULL, 'male', NULL, NULL, 'email', 1, 1, '2025-12-22 13:28:04', '2025-12-22 13:28:04'),
(27, 'mariem@gmail.com', '40238709', '$2y$10$aoCzbuyLb1diDM8qAxRG7.ik220466nlSCLaVFyuyQFBTqQ/DWdBq', 'Mariem', 'doctor', NULL, NULL, 'male', NULL, NULL, 'email', 1, 1, '2025-12-22 14:01:26', '2025-12-22 14:01:26'),
(28, 'test_doctor@test.com', '111111', 'pass', 'Test Doctor', 'doctor', NULL, NULL, 'male', NULL, NULL, 'sms', 0, 1, '2025-12-23 08:47:37', '2025-12-23 08:47:37'),
(29, 'test_patient@test.com', '222222', 'pass', 'Test Patient', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 0, 1, '2025-12-23 08:47:37', '2025-12-23 08:47:37'),
(30, 'sala7@gmail.com', '30768945', '$2y$10$aoYx3AgwgARL/M2Fhi94JuDfm0AVPVfzgohyTQdDd6xA9GgaYevsS', 'Sala7', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-23 10:57:28', '2025-12-23 10:57:28'),
(32, 'lalla@gmail.com', '35167892', '$2y$10$1SQMccfynkiKwiz0An8Wf.8n9MvBiDQGeRqGwvHfOOea.gPn1l1ue', 'lalla', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-23 12:27:40', '2025-12-23 12:27:40'),
(33, '23060@supnum.mr', '22347868', '$2y$10$6JQ7diBUIYBiPggQx7swVexNo2cEopQz885EthhVfb5XEFeIZGK32', 'Abad', 'patient', NULL, NULL, 'male', NULL, NULL, 'sms', 1, 1, '2025-12-23 20:59:59', '2025-12-23 20:59:59'),
(34, 'elhaj@gmail.com', '23768905', '$2y$10$KduKgE6K//KbD0stuabKxu0AvB92N0axTCc5BimZE4ZFOCT6GrJoq', 'DR.Elhaje', 'doctor', NULL, NULL, 'male', NULL, NULL, 'email', 1, 1, '2025-12-23 21:02:34', '2025-12-23 21:02:34'),
(35, 'omar@gmail.com', '26784312', '$2y$10$gMCv27Iw4.esPm8ILBXRqO7rb5MkDUpPUg0kywxtLuBmBHXxWpIBK', 'DR.Omar', 'doctor', NULL, NULL, 'male', NULL, NULL, 'email', 1, 1, '2025-12-23 21:22:29', '2025-12-23 21:22:29');

-- --------------------------------------------------------

--
-- Structure de la table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
CREATE TABLE IF NOT EXISTS `user_sessions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `user_type` varchar(20) DEFAULT 'patient',
  `token` varchar(100) NOT NULL,
  `device_info` varchar(100) DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_user` (`user_id`),
  KEY `idx_token` (`token`),
  KEY `idx_expires` (`expires_at`)
) ENGINE=MyISAM AUTO_INCREMENT=165 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `user_sessions`
--

INSERT INTO `user_sessions` (`id`, `user_id`, `user_type`, `token`, `device_info`, `expires_at`, `created_at`) VALUES
(1, 3, 'patient', '82aeeab4047f7c59b1803c818df52d8f', NULL, '2026-01-15 12:51:34', '2025-12-16 12:51:34'),
(2, 3, 'patient', '1644713f18cd5b3270aa2542ffeae03f', NULL, '2026-01-15 12:56:39', '2025-12-16 12:56:39'),
(3, 6, 'patient', '183f435a7553649f43945ef79bb7d11c', NULL, '2026-01-15 16:09:42', '2025-12-16 16:09:42'),
(4, 7, 'patient', 'a9a43c1d865fb3dcc71a3cadb7d71c92', NULL, '2026-01-15 16:13:07', '2025-12-16 16:13:07'),
(5, 7, 'patient', '3b8d68fd44c6f1783c26df2cc1abcc6d', NULL, '2026-01-15 17:56:35', '2025-12-16 17:56:35'),
(6, 8, 'patient', 'b16a4082199dc05e52a218c8daac0036', NULL, '2026-01-15 18:00:40', '2025-12-16 18:00:40'),
(7, 8, 'patient', '95a38e3b2c2b12dd6717dbd8f4172ff4', NULL, '2026-01-15 18:00:50', '2025-12-16 18:00:50'),
(8, 8, 'patient', '86583169b2a517ee33811ef3cb0eacac', NULL, '2026-01-15 18:03:19', '2025-12-16 18:03:19'),
(9, 8, 'patient', '61681a91458a2fa8eff9b34aa26e4038', NULL, '2026-01-15 18:15:46', '2025-12-16 18:15:46'),
(10, 7, 'patient', '143e8cae46cb1a4079ac51c44bbfc71b', NULL, '2026-01-15 18:20:18', '2025-12-16 18:20:18'),
(11, 8, 'patient', 'c19bfdebb3f51badca2c05fada2c9853', NULL, '2026-01-15 18:33:23', '2025-12-16 18:33:23'),
(12, 8, 'patient', 'a97c824c5b4d92d9b1948d837d7bbcb4', NULL, '2026-01-16 08:50:01', '2025-12-17 08:50:01'),
(13, 8, 'patient', 'ded1b09d46f9a1a4f79b9f19598aab17', NULL, '2026-01-16 09:07:17', '2025-12-17 09:07:17'),
(14, 8, 'patient', '7df7a6df44131501ea9f1acecc626add', NULL, '2026-01-16 09:19:14', '2025-12-17 09:19:14'),
(15, 8, 'patient', '247301faff6051aad17f7ee062fd8dd1', NULL, '2026-01-16 09:27:29', '2025-12-17 09:27:29'),
(16, 8, 'patient', '72092a1b420d235c1f6c60c5b73cfa26', NULL, '2026-01-16 10:17:37', '2025-12-17 10:17:37'),
(17, 8, 'patient', 'a58bd689055ba807e7cffb5453f49283', NULL, '2026-01-16 11:51:14', '2025-12-17 11:51:14'),
(18, 8, 'patient', '878834f33f902d3109fd06dc1f083471', NULL, '2026-01-16 12:05:57', '2025-12-17 12:05:57'),
(19, 8, 'patient', '3f4373bc9443c0d2dc92109ce10d7875', NULL, '2026-01-16 12:22:45', '2025-12-17 12:22:45'),
(20, 8, 'patient', '64be21990b19a07aa5c695c39ccfb29b', NULL, '2026-01-16 12:30:54', '2025-12-17 12:30:54'),
(21, 8, 'patient', 'a721a85d636ea2350df6f376e89fa339', NULL, '2026-01-16 13:04:32', '2025-12-17 13:04:32'),
(22, 13, 'doctor', 'b725e1da01a14eeadbbc83ed757164db', NULL, '2026-01-16 13:35:30', '2025-12-17 13:35:30'),
(23, 13, 'doctor', '56afb74b2fa5b511385a2783bf6711f0', NULL, '2026-01-16 14:32:15', '2025-12-17 14:32:15'),
(24, 13, 'doctor', '8b2758193abc4378b8666a6d432dcc1e', NULL, '2026-01-16 14:51:23', '2025-12-17 14:51:23'),
(25, 13, 'doctor', 'ff2772270459d0f820fb38bcba9957c8', NULL, '2026-01-16 15:26:02', '2025-12-17 15:26:02'),
(26, 8, 'patient', '398ef38f364e837e146843229374c0e8', NULL, '2026-01-16 15:31:26', '2025-12-17 15:31:26'),
(27, 13, 'doctor', '1d66ac7acae121a96da3f17b80a2a2a9', NULL, '2026-01-16 15:49:02', '2025-12-17 15:49:02'),
(28, 13, 'doctor', '040ef232c92fa662d78f466f780f2c05', NULL, '2026-01-16 16:09:33', '2025-12-17 16:09:33'),
(29, 13, 'doctor', 'e4139d3e476ddcea27c7c7dadb524747', NULL, '2026-01-16 16:10:04', '2025-12-17 16:10:04'),
(30, 8, 'patient', '3e5f425f4f3841dde93b9d657e80cb3d', NULL, '2026-01-17 09:12:19', '2025-12-18 09:12:19'),
(31, 13, 'doctor', '355a9d437371b6b772ff61cb5b5c7e2d', NULL, '2026-01-17 09:15:39', '2025-12-18 09:15:39'),
(32, 13, 'doctor', '129d33b8b73db30e2463e359cca6ffe5', NULL, '2026-01-17 09:16:42', '2025-12-18 09:16:42'),
(33, 13, 'doctor', '6bed429822b316d6b28107ef3821346a', NULL, '2026-01-17 09:26:26', '2025-12-18 09:26:26'),
(34, 13, 'doctor', 'b0e4f11d53ea7e76dca227132d4854be', NULL, '2026-01-17 09:27:21', '2025-12-18 09:27:21'),
(35, 13, 'doctor', '9c5f46fa9b3b6911abaac0c16b3d260c', NULL, '2026-01-17 09:53:30', '2025-12-18 09:53:30'),
(37, 8, 'patient', 'dec58b0a6041b0edd58ceeed759c6069', NULL, '2026-01-17 10:04:02', '2025-12-18 10:04:02'),
(39, 18, 'doctor', '97605df87c979b436604d89cb590d0b3', NULL, '2026-01-17 10:09:21', '2025-12-18 10:09:21'),
(40, 8, 'patient', 'd9eccf8476713e64fe97de959f976e8c', NULL, '2026-01-17 10:12:36', '2025-12-18 10:12:36'),
(43, 8, 'patient', '2364c00c2df4c4af5049aef96f21edc1', NULL, '2026-01-17 10:48:31', '2025-12-18 10:48:31'),
(45, 8, 'patient', 'd0acdda61faa58ae968e179af64b73f0', NULL, '2026-01-17 11:03:16', '2025-12-18 11:03:16'),
(46, 19, 'doctor', 'b578d24be9153d514244ff8510838985', NULL, '2026-01-17 11:46:46', '2025-12-18 11:46:46'),
(47, 19, 'doctor', '59066d401801c8f5e148bd44479f76a0', NULL, '2026-01-17 12:24:55', '2025-12-18 12:24:55'),
(49, 8, 'patient', '3cb737399cf15b678342ae3a9eacf0aa', NULL, '2026-01-17 12:49:26', '2025-12-18 12:49:26'),
(50, 19, 'doctor', 'e70c781b82c8c102c7f1742c27976f55', NULL, '2026-01-17 12:53:31', '2025-12-18 12:53:31'),
(51, 19, 'doctor', '8ad7b4a67e192dd57baeb77d35642644', NULL, '2026-01-17 12:59:54', '2025-12-18 12:59:54'),
(53, 20, 'patient', '7eca2e7628cb43d471c17a6c5a651a14', NULL, '2026-01-17 13:48:07', '2025-12-18 13:48:07'),
(54, 19, 'doctor', '1ddd392c8c0fc43a73bb46c7bfc9c181', NULL, '2026-01-17 13:51:36', '2025-12-18 13:51:36'),
(55, 19, 'doctor', '3b9ed033c3cb590fecd95c92b7631502', NULL, '2026-01-17 14:18:40', '2025-12-18 14:18:40'),
(56, 19, 'doctor', '9ca3d7d8d5db45c39218a0f996ffec2c', NULL, '2026-01-17 14:20:25', '2025-12-18 14:20:25'),
(58, 8, 'patient', '8e4f28290ef4151883a323462d07fb77', NULL, '2026-01-17 14:26:24', '2025-12-18 14:26:24'),
(60, 22, 'patient', 'f7517598b32ce256e1891d731cdbe03e', NULL, '2026-01-17 14:36:08', '2025-12-18 14:36:08'),
(61, 19, 'doctor', '76f75d226cacd78986bd1a870ade3e94', NULL, '2026-01-17 14:38:23', '2025-12-18 14:38:23'),
(62, 19, 'doctor', '7f34b8437999691994c4e94aa4d78cc2', NULL, '2026-01-17 15:06:14', '2025-12-18 15:06:14'),
(63, 8, 'patient', '212162463925aaffc2563d13d265c9ff', NULL, '2026-01-18 08:25:45', '2025-12-19 08:25:45'),
(64, 19, 'doctor', '32ee54c9390ce4b1ee49923b7eefe5cd', NULL, '2026-01-18 08:27:32', '2025-12-19 08:27:32'),
(65, 19, 'doctor', '6cc0586f549fdc2e5b90429759b6dd51', NULL, '2026-01-18 09:00:33', '2025-12-19 09:00:33'),
(66, 8, 'patient', '6d2134878fb8c57d5983f78f16051569', NULL, '2026-01-19 08:38:40', '2025-12-20 08:38:40'),
(67, 19, 'doctor', '4503c9f1495e6cfaa9fa0f33eaefa967', NULL, '2026-01-19 08:42:46', '2025-12-20 08:42:46'),
(68, 8, 'patient', '6053171d6ff0406424452481dbf6f5fe', NULL, '2026-01-19 08:59:29', '2025-12-20 08:59:29'),
(69, 8, 'patient', 'bf9f3bcca358b683b40ec8121a56fbdc', NULL, '2026-01-19 09:06:19', '2025-12-20 09:06:19'),
(70, 19, 'doctor', '5f34ce491305bcdda39b109c91158192', NULL, '2026-01-19 09:07:54', '2025-12-20 09:07:54'),
(71, 19, 'doctor', 'a7338ec3b9e66dd17a0ab1d6d2f58cc2', NULL, '2026-01-19 09:16:10', '2025-12-20 09:16:10'),
(72, 8, 'patient', '70fc768a97a268c0c1863374a7ae0dc5', NULL, '2026-01-19 09:38:59', '2025-12-20 09:38:59'),
(73, 19, 'doctor', '048807edc91a8372f9b23de273ad35cd', NULL, '2026-01-19 09:45:04', '2025-12-20 09:45:04'),
(75, 19, 'doctor', 'fa3a96c65f503fe07def74d48e461d75', NULL, '2026-01-19 10:14:16', '2025-12-20 10:14:16'),
(76, 19, 'doctor', '7cca24060024e4fa4276781e94680d89', NULL, '2026-01-19 10:28:28', '2025-12-20 10:28:28'),
(78, 19, 'doctor', '89d80db52ef68b99c949b523a54e3cec', NULL, '2026-01-19 10:34:38', '2025-12-20 10:34:38'),
(79, 8, 'patient', '4d08f14eb19be5775aad274e80118722', NULL, '2026-01-19 11:06:56', '2025-12-20 11:06:56'),
(80, 23, 'patient', 'f7e429b7303f9183313096550db5328f', NULL, '2026-01-19 11:13:35', '2025-12-20 11:13:35'),
(81, 8, 'patient', '170abf6a792314faa221cd3b67e470d0', NULL, '2026-01-19 11:25:09', '2025-12-20 11:25:09'),
(83, 8, 'patient', '4c3bc20a5b440373ae2b33b146c14c46', NULL, '2026-01-20 09:59:04', '2025-12-21 09:59:04'),
(84, 8, 'patient', '88f5c490ec929d986bb131c31840ee2d', NULL, '2026-01-20 10:08:35', '2025-12-21 10:08:35'),
(88, 7, 'doctor', '95130c5b2112af4e58ce36457709af46', NULL, '2026-01-20 10:34:25', '2025-12-21 10:34:25'),
(89, 7, 'doctor', '708b38f0255f244558dee0508fd0a88c', NULL, '2026-01-20 10:49:57', '2025-12-21 10:49:57'),
(90, 8, 'patient', 'af48f316938ac95548bbcb8d960bf757', NULL, '2026-01-20 10:51:13', '2025-12-21 10:51:13'),
(92, 7, 'doctor', 'ceaa3d82b38b5c5509a200f1e414f06e', NULL, '2026-01-20 11:02:55', '2025-12-21 11:02:55'),
(93, 7, 'doctor', '7cfa2c56b617b037efdc34629d030c54', NULL, '2026-01-20 11:18:48', '2025-12-21 11:18:48'),
(95, 8, 'patient', '769961be0c41326e5f1da76a6cc4104d', NULL, '2026-01-20 11:34:29', '2025-12-21 11:34:29'),
(98, 8, 'patient', '014dac8b867b42e2d23a234318c96a61', NULL, '2026-01-20 11:46:59', '2025-12-21 11:46:59'),
(108, 8, 'patient', '83b20029bdfc09cdf73081f668f14a24', NULL, '2026-01-20 15:51:50', '2025-12-21 15:51:50'),
(113, 8, 'patient', '695aa4fd66acfe55798894bb230b8f05', NULL, '2026-01-21 11:17:19', '2025-12-22 11:17:19'),
(122, 11, 'doctor', '14c9fba1742c7255867b4e417fe00547', NULL, '2026-01-21 14:23:51', '2025-12-22 14:23:51'),
(125, 11, 'doctor', '66feb3f8891e254b9cb4fb10d35a42f4', NULL, '2026-01-21 14:39:18', '2025-12-22 14:39:18'),
(126, 8, 'patient', '3c8b790ed98e340888cd56ddfe7ed2f0', NULL, '2026-01-21 15:24:36', '2025-12-22 15:24:36'),
(133, 2, 'doctor', '15865f5976138c31a3505087fec4e943', NULL, '2026-01-22 09:00:46', '2025-12-23 09:00:46'),
(139, 11, 'doctor', 'aaebcbd9bcbde431355245a19d663519', NULL, '2026-01-22 09:38:17', '2025-12-23 09:38:17'),
(147, 10, 'doctor', '1b11a26e2b316dee06583cbac5e0d641', NULL, '2026-01-22 11:05:53', '2025-12-23 11:05:53'),
(149, 32, 'patient', '3603a80ebfe95f3af6925ee920855699', NULL, '2026-01-22 12:29:18', '2025-12-23 12:29:18'),
(150, 13, 'doctor', '49029fd3b78cc02224b0418662757741', NULL, '2026-01-22 21:02:44', '2025-12-23 21:02:44'),
(151, 13, 'doctor', '2684ffee85c989e9b9b9e6cdb6fd02ae', NULL, '2026-01-22 21:03:24', '2025-12-23 21:03:24'),
(154, 14, 'doctor', '8d1f3b2b93da8d6b1025d68d1397c91e', NULL, '2026-01-22 21:25:41', '2025-12-23 21:25:41'),
(155, 35, 'doctor', '4ac71554fb01003b2c282ad6c2665e6a', NULL, '2026-01-22 21:36:52', '2025-12-23 21:36:52'),
(157, 24, 'doctor', '64ab75a94d3810c4b1c0fe65530a4771', NULL, '2026-01-22 21:40:24', '2025-12-23 21:40:24'),
(158, 35, 'doctor', 'f404738f825d2154e0535136ff63ce23', NULL, '2026-01-22 21:54:45', '2025-12-23 21:54:45'),
(161, 35, 'doctor', '609155cb6d60be581420e48205d7da6c', NULL, '2026-01-23 11:44:15', '2025-12-24 11:44:15'),
(162, 7, 'patient', 'c1e84dfcb87d3bd8fa380c8f0618adf3', NULL, '2026-01-23 11:57:24', '2025-12-24 11:57:24'),
(163, 7, 'patient', 'a367eaff2a21a204bd4856fb4565ca20', NULL, '2026-01-23 12:14:52', '2025-12-24 12:14:52');

-- --------------------------------------------------------

--
-- Structure de la table `wallets`
--

DROP TABLE IF EXISTS `wallets`;
CREATE TABLE IF NOT EXISTS `wallets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `user_type` enum('patient','doctor','admin') DEFAULT 'patient',
  `balance` decimal(12,2) NOT NULL DEFAULT '0.00',
  `currency` varchar(3) NOT NULL DEFAULT 'MRU',
  `is_active` tinyint(1) DEFAULT '1',
  `last_transaction_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_wallet` (`user_id`,`user_type`)
) ;

--
-- Déchargement des données de la table `wallets`
--

INSERT INTO `wallets` (`id`, `user_id`, `user_type`, `balance`, `currency`, `is_active`, `last_transaction_at`, `created_at`, `updated_at`) VALUES
(1, 1, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(2, 2, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(3, 3, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(4, 4, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(5, 5, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(6, 6, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(7, 7, 'patient', 2000.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-24 11:58:55'),
(8, 8, 'patient', 101003456.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-22 15:25:26'),
(9, 9, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(10, 10, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(11, 11, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(12, 12, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(13, 13, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(14, 14, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(15, 15, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(16, 16, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(17, 17, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(18, 18, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(19, 19, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(20, 20, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(21, 21, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(22, 22, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(23, 23, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(24, 1, 'doctor', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(25, 2, 'doctor', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(26, 3, 'doctor', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(27, 4, 'doctor', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(28, 5, 'doctor', 0.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 10:54:06'),
(29, 6, 'doctor', 56789.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 15:38:38'),
(30, 7, 'doctor', 79186.00, 'MRU', 1, NULL, '2025-12-21 10:54:06', '2025-12-21 11:32:18'),
(31, 8, 'doctor', 0.00, 'MRU', 1, NULL, '2025-12-21 15:51:06', '2025-12-21 15:51:06'),
(32, 10, 'doctor', 0.00, 'MRU', 1, NULL, '2025-12-22 11:16:49', '2025-12-22 11:16:49'),
(33, 11, 'doctor', 0.00, 'MRU', 1, NULL, '2025-12-22 14:21:23', '2025-12-22 14:21:23'),
(34, 32, 'patient', 0.00, 'MRU', 1, NULL, '2025-12-23 12:29:29', '2025-12-23 12:29:29'),
(35, 13, 'doctor', 0.00, 'MRU', 1, NULL, '2025-12-23 21:02:45', '2025-12-23 21:02:45'),
(36, 14, 'doctor', 0.00, 'MRU', 1, NULL, '2025-12-23 21:22:50', '2025-12-23 21:22:50');
COMMIT;

