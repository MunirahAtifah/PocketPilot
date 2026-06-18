-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 17, 2026 at 11:54 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pp`
--

-- --------------------------------------------------------

--
-- Table structure for table `budget`
--

CREATE TABLE `budget` (
  `budgetID` int(10) NOT NULL,
  `budgetDate` date DEFAULT NULL,
  `budgetDesc` varchar(255) DEFAULT NULL,
  `budgetAmount` decimal(19,2) DEFAULT NULL,
  `categoryID` int(10) DEFAULT NULL,
  `studentID` int(10) DEFAULT NULL,
  `parentID` int(10) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `budget`
--

INSERT INTO `budget` (`budgetID`, `budgetDate`, `budgetDesc`, `budgetAmount`, `categoryID`, `studentID`, `parentID`) VALUES
(2, '2026-01-01', 'Food', 400.00, 2, 1, NULL),
(4, '2026-01-01', 'Fuel', 150.00, 3, 1, NULL),
(8, '2026-02-01', 'Electric', 30.00, 5, 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `categoryID` int(10) NOT NULL,
  `categoryName` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`categoryID`, `categoryName`) VALUES
(1, 'Education'),
(4, 'Entertainment'),
(2, 'Food'),
(6, 'Healthcare'),
(8, 'Other'),
(7, 'Shopping'),
(3, 'Transport'),
(5, 'Utilities');

-- --------------------------------------------------------

--
-- Table structure for table `expense`
--

CREATE TABLE `expense` (
  `expenseID` int(10) NOT NULL,
  `expenseDate` date DEFAULT NULL,
  `expenseDesc` varchar(255) DEFAULT NULL,
  `expenseAmount` decimal(19,2) DEFAULT NULL,
  `categoryID` int(10) DEFAULT NULL,
  `studentID` int(10) DEFAULT NULL,
  `parentID` int(10) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `parent`
--

CREATE TABLE `parent` (
  `parentID` int(10) NOT NULL,
  `userID` int(10) NOT NULL,
  `parentName` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `parent`
--

INSERT INTO `parent` (`parentID`, `userID`, `parentName`) VALUES
(1, 6, 'Mazlan'),
(2, 3, 'Azman'),
(3, 5, 'Ummi'),
(4, 8, 'Ali');

-- --------------------------------------------------------

--
-- Table structure for table `parentchildaccess`
--

CREATE TABLE `parentchildaccess` (
  `accessID` int(10) NOT NULL,
  `parentID` int(10) NOT NULL,
  `studentID` int(10) NOT NULL,
  `supervisionCode` varchar(8) NOT NULL,
  `connectionStatus` varchar(50) DEFAULT 'active' COMMENT 'active, inactive',
  `createdDate` timestamp NOT NULL DEFAULT current_timestamp(),
  `connectedDate` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `registration`
--

CREATE TABLE `registration` (
  `userID` int(10) NOT NULL,
  `username` varchar(255) NOT NULL,
  `phone_number` varchar(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `role` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `registration`
--

INSERT INTO `registration` (`userID`, `username`, `phone_number`, `email`, `role`, `password`) VALUES
(1, 'Muniey', '01112914982', 'irfahmazmi@gmail.com', 'Student', '123456'),
(2, 'aiman', '01234567891', 'aiman@gmail.com', 'Student', '345678'),
(3, 'azman', '0123567892', 'azman@gmail.com', 'Parent', '123qwe'),
(5, 'Ummi', '0139647354', 'ummimusallah@gmail.com', 'Parent', 'ummi1234'),
(6, 'Mazlan', '0133029282', 'mazlan@gmail.com', 'Parent', 'mazlan5159'),
(7, 'Fara', '0122576289', 'fara@gmail.com', 'Student', 'fara13'),
(8, 'Ali', '0112345624', 'ali123@gmail.com', 'Parent', '3456789');

-- --------------------------------------------------------

--
-- Table structure for table `report`
--

CREATE TABLE `report` (
  `reportID` int(10) NOT NULL,
  `firstDate` date DEFAULT NULL,
  `lastDate` date DEFAULT NULL,
  `total` decimal(19,2) DEFAULT NULL,
  `average` decimal(19,2) DEFAULT NULL,
  `surplusStatus` varchar(255) DEFAULT NULL,
  `studentID` int(10) DEFAULT NULL,
  `parentID` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student`
--

CREATE TABLE `student` (
  `studentID` int(10) NOT NULL,
  `userID` int(10) NOT NULL,
  `studentName` varchar(255) DEFAULT NULL,
  `supervisionCode` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `student`
--

INSERT INTO `student` (`studentID`, `userID`, `studentName`, `supervisionCode`) VALUES
(1, 1, 'Muniey', 'STU000001'),
(2, 7, 'Fara', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `studentcounselloraccess`
--

CREATE TABLE `studentcounselloraccess` (
  `accessID` int(10) NOT NULL,
  `studentID` int(10) NOT NULL,
  `staffID` int(10) NOT NULL,
  `accessStatus` varchar(50) DEFAULT 'pending' COMMENT 'pending, approved, disapproved',
  `createdDate` timestamp NOT NULL DEFAULT current_timestamp(),
  `approvedDate` timestamp NULL DEFAULT NULL,
  `approvedByStudent` tinyint(1) DEFAULT 0,
  `studentApprovalDate` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_counsellor`
--

CREATE TABLE `student_counsellor` (
  `staffID` int(10) NOT NULL,
  `userID` int(10) NOT NULL,
  `staffName` varchar(255) NOT NULL,
  `createdDate` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `supervisionaccess`
--

CREATE TABLE `supervisionaccess` (
  `id` int(11) NOT NULL,
  `code` varchar(6) NOT NULL,
  `approvalStatus` varchar(255) DEFAULT NULL,
  `studentID` int(10) DEFAULT NULL,
  `parentID` int(10) DEFAULT NULL,
  `relationship` varchar(50) DEFAULT NULL,
  `createdDate` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `supervisionaccess`
--

INSERT INTO `supervisionaccess` (`id`, `code`, `approvalStatus`, `studentID`, `parentID`, `relationship`, `createdDate`) VALUES
(1, 'QC0A6R', 'Approved', 1, 3, 'Mother', '2026-01-19 16:34:08');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `budget`
--
ALTER TABLE `budget`
  ADD PRIMARY KEY (`budgetID`),
  ADD KEY `idx_categoryID` (`categoryID`),
  ADD KEY `idx_studentID` (`studentID`),
  ADD KEY `idx_parentID` (`parentID`),
  ADD KEY `idx_budgetDate` (`budgetDate`);

--
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`categoryID`),
  ADD KEY `idx_categoryName` (`categoryName`);

--
-- Indexes for table `expense`
--
ALTER TABLE `expense`
  ADD PRIMARY KEY (`expenseID`),
  ADD KEY `idx_categoryID` (`categoryID`),
  ADD KEY `idx_studentID` (`studentID`),
  ADD KEY `idx_parentID` (`parentID`),
  ADD KEY `idx_expenseDate` (`expenseDate`);

--
-- Indexes for table `parent`
--
ALTER TABLE `parent`
  ADD PRIMARY KEY (`parentID`),
  ADD UNIQUE KEY `userID` (`userID`),
  ADD KEY `idx_userID` (`userID`);

--
-- Indexes for table `parentchildaccess`
--
ALTER TABLE `parentchildaccess`
  ADD PRIMARY KEY (`accessID`),
  ADD UNIQUE KEY `supervisionCode` (`supervisionCode`),
  ADD UNIQUE KEY `unique_parent_student` (`parentID`,`studentID`),
  ADD KEY `studentID` (`studentID`);

--
-- Indexes for table `registration`
--
ALTER TABLE `registration`
  ADD PRIMARY KEY (`userID`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_username` (`username`),
  ADD KEY `idx_role` (`role`);

--
-- Indexes for table `report`
--
ALTER TABLE `report`
  ADD PRIMARY KEY (`reportID`),
  ADD KEY `idx_studentID` (`studentID`),
  ADD KEY `idx_parentID` (`parentID`),
  ADD KEY `idx_firstDate` (`firstDate`),
  ADD KEY `idx_lastDate` (`lastDate`);

--
-- Indexes for table `student`
--
ALTER TABLE `student`
  ADD PRIMARY KEY (`studentID`),
  ADD UNIQUE KEY `userID` (`userID`),
  ADD UNIQUE KEY `supervisionCode` (`supervisionCode`),
  ADD KEY `idx_userID` (`userID`);

--
-- Indexes for table `studentcounselloraccess`
--
ALTER TABLE `studentcounselloraccess`
  ADD PRIMARY KEY (`accessID`),
  ADD UNIQUE KEY `unique_student_staff` (`studentID`,`staffID`),
  ADD KEY `staffID` (`staffID`);

--
-- Indexes for table `student_counsellor`
--
ALTER TABLE `student_counsellor`
  ADD PRIMARY KEY (`staffID`),
  ADD KEY `userID` (`userID`);

--
-- Indexes for table `supervisionaccess`
--
ALTER TABLE `supervisionaccess`
  ADD PRIMARY KEY (`code`),
  ADD UNIQUE KEY `id` (`id`),
  ADD KEY `idx_studentID` (`studentID`),
  ADD KEY `idx_parentID` (`parentID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `budget`
--
ALTER TABLE `budget`
  MODIFY `budgetID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `category`
--
ALTER TABLE `category`
  MODIFY `categoryID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `expense`
--
ALTER TABLE `expense`
  MODIFY `expenseID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `parent`
--
ALTER TABLE `parent`
  MODIFY `parentID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `parentchildaccess`
--
ALTER TABLE `parentchildaccess`
  MODIFY `accessID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `registration`
--
ALTER TABLE `registration`
  MODIFY `userID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `report`
--
ALTER TABLE `report`
  MODIFY `reportID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student`
--
ALTER TABLE `student`
  MODIFY `studentID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `studentcounselloraccess`
--
ALTER TABLE `studentcounselloraccess`
  MODIFY `accessID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_counsellor`
--
ALTER TABLE `student_counsellor`
  MODIFY `staffID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `supervisionaccess`
--
ALTER TABLE `supervisionaccess`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `budget`
--
ALTER TABLE `budget`
  ADD CONSTRAINT `budget_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `category` (`categoryID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `budget_ibfk_2` FOREIGN KEY (`studentID`) REFERENCES `student` (`studentID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `budget_ibfk_3` FOREIGN KEY (`parentID`) REFERENCES `parent` (`parentID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `expense`
--
ALTER TABLE `expense`
  ADD CONSTRAINT `expense_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `category` (`categoryID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `expense_ibfk_2` FOREIGN KEY (`studentID`) REFERENCES `student` (`studentID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `expense_ibfk_3` FOREIGN KEY (`parentID`) REFERENCES `parent` (`parentID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `parent`
--
ALTER TABLE `parent`
  ADD CONSTRAINT `parent_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `registration` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `parentchildaccess`
--
ALTER TABLE `parentchildaccess`
  ADD CONSTRAINT `parentchildaccess_ibfk_1` FOREIGN KEY (`parentID`) REFERENCES `parent` (`parentID`) ON DELETE CASCADE,
  ADD CONSTRAINT `parentchildaccess_ibfk_2` FOREIGN KEY (`studentID`) REFERENCES `student` (`studentID`) ON DELETE CASCADE;

--
-- Constraints for table `report`
--
ALTER TABLE `report`
  ADD CONSTRAINT `report_ibfk_1` FOREIGN KEY (`studentID`) REFERENCES `student` (`studentID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `report_ibfk_2` FOREIGN KEY (`parentID`) REFERENCES `parent` (`parentID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `student`
--
ALTER TABLE `student`
  ADD CONSTRAINT `student_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `registration` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `studentcounselloraccess`
--
ALTER TABLE `studentcounselloraccess`
  ADD CONSTRAINT `studentcounselloraccess_ibfk_1` FOREIGN KEY (`studentID`) REFERENCES `student` (`studentID`) ON DELETE CASCADE,
  ADD CONSTRAINT `studentcounselloraccess_ibfk_2` FOREIGN KEY (`staffID`) REFERENCES `student_counsellor` (`staffID`) ON DELETE CASCADE;

--
-- Constraints for table `student_counsellor`
--
ALTER TABLE `student_counsellor`
  ADD CONSTRAINT `student_counsellor_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `registration` (`userID`) ON DELETE CASCADE;

--
-- Constraints for table `supervisionaccess`
--
ALTER TABLE `supervisionaccess`
  ADD CONSTRAINT `supervisionaccess_ibfk_1` FOREIGN KEY (`studentID`) REFERENCES `student` (`studentID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `supervisionaccess_ibfk_2` FOREIGN KEY (`parentID`) REFERENCES `parent` (`parentID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
