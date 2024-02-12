-- Create the Database 
CREATE DATABASE HotelBookingDB;

-- Use HotelBookingDB database
USE HotelBookingDB;

-- Create the User table with UUID as primary key
CREATE TABLE User (
   userID VARCHAR(36) PRIMARY KEY,
   name VARCHAR(100) NOT NULL,
   email VARCHAR(100) UNIQUE NOT NULL,
   bookingInfo TEXT
);

-- Create the Admin table with UUID as primary key
CREATE TABLE Admin (
   adminID VARCHAR(36) PRIMARY KEY,
   name VARCHAR(100) NOT NULL,
   email VARCHAR(100) UNIQUE NOT NULL,
   password VARCHAR(255) NOT NULL
);

-- Create the Booking table with UUID as primary key
CREATE TABLE Booking (
   bookingID VARCHAR(36) PRIMARY KEY,
   roomID INT,
   checkInDate DATE NOT NULL,
   checkOutDate DATE NOT NULL,
   customerID VARCHAR(36),
   bookingInfo TEXT,
   FOREIGN KEY (customerID) REFERENCES User(userID) ON DELETE CASCADE,
   FOREIGN KEY (roomID) REFERENCES Room(roomID) ON DELETE CASCADE
);

-- Create the Reports table with UUID as primary key
CREATE TABLE Reports (
   reportID VARCHAR(36) PRIMARY KEY,
   title VARCHAR(255),
   reportType VARCHAR(100),
   content TEXT,
   creationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   bookingID VARCHAR(36),
   FOREIGN KEY (bookingID) REFERENCES Booking(bookingID) ON DELETE CASCADE
);

-- Create the Staff table with UUID as primary key
CREATE TABLE Staff (
   staffID VARCHAR(36) PRIMARY KEY,
   name VARCHAR(100) NOT NULL,
   email VARCHAR(100) UNIQUE NOT NULL,
   password VARCHAR(255) NOT NULL
);

-- Create the Room table with auto-increment primary key and hotelID foreign key
CREATE TABLE Room (
   roomID INT AUTO_INCREMENT PRIMARY KEY,
   roomType VARCHAR(100) NOT NULL,
   rate DECIMAL(10, 2) NOT NULL,
   availability BOOLEAN NOT NULL DEFAULT TRUE,
   hotelID INT,
   FOREIGN KEY (hotelID) REFERENCES Hotel(hotelID) ON DELETE CASCADE
);

-- Create the Hotel table with auto-increment primary key
CREATE TABLE Hotel (
   hotelID INT AUTO_INCREMENT PRIMARY KEY,
   name VARCHAR(100) NOT NULL,
   address VARCHAR(255) NOT NULL,
   contact VARCHAR(100) NOT NULL
);

-- Insert data into User table, Admin table, Booking table, Reports table, Staff table, and Hotel table
INSERT INTO User (userID, name, email, bookingInfo) VALUES 
(UUID(), 'John Doe', 'johndoe@example.com', 'Booking for a deluxe room from 2024-02-15 to 2024-02-20'),
(UUID(), 'Alice Smith', 'alice@example.com', 'Booking for a standard room from 2024-03-01 to 2024-03-05');

INSERT INTO Admin (adminID, name, email, password) VALUES 
(UUID(), 'Admin User', 'admin@example.com', 'adminpassword');
-- not sure 
INSERT INTO Booking (bookingID, roomID, checkInDate, checkOutDate, customerID, bookingInfo) VALUES 
(UUID(), 1, '2024-02-15', '2024-02-20', (SELECT userID FROM User WHERE email = 'johndoe@example.com'), 'Booking for a deluxe room'),
(UUID(), 2, '2024-03-01', '2024-03-05', (SELECT userID FROM User WHERE email = 'alice@example.com'), 'Booking for a standard room');

-- Insert data into Booking table
INSERT INTO Booking (bookingID, roomID, checkInDate, checkOutDate, customerID, bookingInfo) VALUES 
(UUID(), (SELECT roomID FROM Room WHERE roomType = 'Deluxe'), '2024-02-15', '2024-02-20', (SELECT userID FROM User WHERE email = 'johndoe@example.com'), 'Booking for a deluxe room'),
(UUID(), (SELECT roomID FROM Room WHERE roomType = 'Standard'), '2024-03-01', '2024-03-05', (SELECT userID FROM User WHERE email = 'alice@example.com'), 'Booking for a standard room');

INSERT INTO Reports (reportID, title, reportType, content, bookingID) VALUES 
(UUID(), 'Monthly Report', 'Sales', 'This report contains sales data for the month of February.', (SELECT bookingID FROM Booking WHERE bookingID = (SELECT bookingID FROM User WHERE email = 'johndoe@example.com')));

INSERT INTO Staff (staffID, name, email, password) VALUES 
(UUID(), 'Staff Member', 'staff@example.com', 'staffpassword');

INSERT INTO Hotel (name, address, contact) VALUES 
('Hotel A', '123 Main St, City', '123-456-7890'),
('Hotel B', '456 Park Ave, Town', '987-654-3210');

-- Retrieve all users, admins, bookings, reports, staff, hotels
SELECT * FROM User;
SELECT * FROM Admin;
SELECT * FROM Booking;
SELECT * FROM Reports;
SELECT * FROM Staff;
SELECT * FROM Hotel;

-- Retrieve all bookings with corresponding user information
SELECT Booking.bookingID, Booking.roomID, Booking.checkInDate, Booking.checkOutDate, Booking.bookingInfo, User.name AS customerName, User.email AS customerEmail
FROM Booking
INNER JOIN User ON Booking.customerID = User.userID;

-- Retrieve all reports with corresponding booking information
SELECT Reports.reportID, Reports.title, Reports.reportType, Reports.content, Reports.creationDate, Booking.roomID, Booking.checkInDate, Booking.checkOutDate, Booking.bookingInfo
FROM Reports
INNER JOIN Booking ON Reports.bookingID = Booking.bookingID;

-- Retrieve all bookings made by a specific user
SELECT * FROM Booking WHERE customerID = (SELECT userID FROM User WHERE email = 'johndoe@example.com');

-- Reports by Month and Year
SELECT YEAR(creationDate) AS Year, MONTH(creationDate) AS Month, COUNT(*) AS TotalReports
FROM Reports
GROUP BY YEAR(creationDate), MONTH(creationDate);

-- Top 3 Customers (by number of bookings)
SELECT User.userID, User.name AS CustomerName, COUNT(Booking.bookingID) AS TotalBookings
FROM User
JOIN Booking ON User.userID = Booking.customerID
GROUP BY User.userID, User.name
ORDER BY TotalBookings DESC
LIMIT 3;

-- Least Booked Room
SELECT roomID, COUNT(*) AS TotalBookings
FROM Booking
GROUP BY roomID
ORDER BY TotalBookings ASC
LIMIT 1;

-- Most Booked Room
SELECT roomID, COUNT(*) AS TotalBookings
FROM Booking
GROUP BY roomID
ORDER BY TotalBookings DESC
LIMIT 1;

-- Summary of Rooms Categorized
SELECT Room.categoryID, COUNT(*) AS TotalRooms
FROM Room
GROUP BY Room.categoryID;

-- List of Rooms Categorized
SELECT Room.roomID, Room.roomType, Room.rate, Room.categoryID
FROM Room
ORDER BY Room.categoryID;

-- Additional Data Analysis

-- Average Booking Duration
SELECT AVG(DATEDIFF(checkOutDate, checkInDate)) AS AvgBookingDuration
FROM Booking;

-- Average Room Rate
SELECT AVG(rate) AS AvgRoomRate
FROM Room;

-- Total Revenue Generated
SELECT SUM(rate * DATEDIFF(checkOutDate, checkInDate)) AS TotalRevenue
FROM Booking
JOIN Room ON Booking.roomID = Room.roomID;


