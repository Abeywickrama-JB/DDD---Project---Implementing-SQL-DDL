-- Drop tables if exist (safe for re-run)
IF OBJECT_ID('dbo.BookingSeat','U') IS NOT NULL DROP TABLE dbo.BookingSeat;
IF OBJECT_ID('dbo.Booking','U') IS NOT NULL DROP TABLE dbo.Booking;
IF OBJECT_ID('dbo.Payment','U') IS NOT NULL DROP TABLE dbo.Payment;
IF OBJECT_ID('dbo.DigitalTicket','U') IS NOT NULL DROP TABLE dbo.DigitalTicket;
IF OBJECT_ID('dbo.Seat','U') IS NOT NULL DROP TABLE dbo.Seat;
IF OBJECT_ID('dbo.Schedule','U') IS NOT NULL DROP TABLE dbo.Schedule;
IF OBJECT_ID('dbo.Route','U') IS NOT NULL DROP TABLE dbo.Route;
IF OBJECT_ID('dbo.Train','U') IS NOT NULL DROP TABLE dbo.Train;
IF OBJECT_ID('dbo.Station','U') IS NOT NULL DROP TABLE dbo.Station;
IF OBJECT_ID('dbo.Admin','U') IS NOT NULL DROP TABLE dbo.Admin;
IF OBJECT_ID('dbo.Passenger','U') IS NOT NULL DROP TABLE dbo.Passenger;
IF OBJECT_ID('dbo.UserPhone','U') IS NOT NULL DROP TABLE dbo.UserPhone;
IF OBJECT_ID('dbo.UserEmail','U') IS NOT NULL DROP TABLE dbo.UserEmail;
IF OBJECT_ID('dbo.Users','U') IS NOT NULL DROP TABLE dbo.Users;


-- Users table
CREATE TABLE dbo.Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL, -- store hash in real apps
    Status NVARCHAR(20) NOT NULL DEFAULT('Active'),
    CreatedAt DATE NOT NULL DEFAULT(CONVERT(date, GETDATE())),
    UpdatedAt DATE NULL
);

-- UserEmail (one-to-many)
CREATE TABLE dbo.UserEmail (
    EmailID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_UserEmail_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID)
);

-- UserPhone (one-to-many)
CREATE TABLE dbo.UserPhone (
    PhoneID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    PhoneNumber NVARCHAR(15) NOT NULL,
    CONSTRAINT FK_UserPhone_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID)
);

-- Passenger (specialization of Users: PassengerID = UserID)
CREATE TABLE dbo.Passenger (
    PassengerID INT PRIMARY KEY, -- will reference Users(UserID)
    NIC NVARCHAR(12) UNIQUE NOT NULL,
    DateOfBirth DATE NULL,
    Address NVARCHAR(255) NULL,
    Gender NVARCHAR(10) NULL,
    EmergencyContact NVARCHAR(15) NULL,
    CONSTRAINT FK_Passenger_Users FOREIGN KEY (PassengerID) REFERENCES dbo.Users(UserID)
);

-- Admin (specialization of Users: AdminID = UserID)
CREATE TABLE dbo.Admin (
    AdminID INT PRIMARY KEY, -- will reference Users(UserID)
    EmployeeID NVARCHAR(10) UNIQUE NOT NULL,
    Department NVARCHAR(50) NULL,
    JoinDate DATE NULL,
    Permission NVARCHAR(50) NULL,
    AccessLevel NVARCHAR(30) NULL,
    CONSTRAINT FK_Admin_Users FOREIGN KEY (AdminID) REFERENCES dbo.Users(UserID)
);

-- Station
CREATE TABLE dbo.Station (
    StationID INT IDENTITY(1,1) PRIMARY KEY,
    StationName NVARCHAR(100) NOT NULL,
    City NVARCHAR(50) NULL,
    ContactNumber NVARCHAR(15) NULL,
    PlatformCount INT NULL,
    Facilities NVARCHAR(255) NULL
);

-- Train
CREATE TABLE dbo.Train (
    TrainID INT IDENTITY(1,1) PRIMARY KEY,
    TrainName NVARCHAR(100) NOT NULL,
    TrainType NVARCHAR(50) NULL,
    TotalSeats INT NULL,
    Description NVARCHAR(255) NULL,
    Manufacturer NVARCHAR(100) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT('Active')
);

-- Route (references stations)
CREATE TABLE dbo.Route (
    RouteID INT IDENTITY(1,1) PRIMARY KEY,
    RouteName NVARCHAR(100) NOT NULL,
    StartingStationID INT NOT NULL,
    EndStationID INT NOT NULL,
    Distance DECIMAL(10,2) NULL,
    Duration NVARCHAR(20) NULL,
    Description NVARCHAR(255) NULL,
    Status NVARCHAR(20) NULL,
    CONSTRAINT FK_Route_StartStation FOREIGN KEY (StartingStationID) REFERENCES dbo.Station(StationID),
    CONSTRAINT FK_Route_EndStation FOREIGN KEY (EndStationID) REFERENCES dbo.Station(StationID)
);

-- Schedule (train on route at date/time)
CREATE TABLE dbo.Schedule (
    ScheduleID INT IDENTITY(1,1) PRIMARY KEY,
    TrainID INT NOT NULL,
    RouteID INT NOT NULL,
    ScheduleDate DATE NULL,
    DepartureTime TIME NULL,
    ArrivalTime TIME NULL,
    Attribute NVARCHAR(100) NULL,
    Status NVARCHAR(20) NULL,
    CONSTRAINT FK_Schedule_Train FOREIGN KEY (TrainID) REFERENCES dbo.Train(TrainID),
    CONSTRAINT FK_Schedule_Route FOREIGN KEY (RouteID) REFERENCES dbo.Route(RouteID)
);

-- Seat (belongs to a train)
CREATE TABLE dbo.Seat (
    SeatID INT IDENTITY(1,1) PRIMARY KEY,
    SeatClass NVARCHAR(20) NULL,
    TrainID INT NOT NULL,
    SeatNumber NVARCHAR(10) NULL,
    CONSTRAINT FK_Seat_Train FOREIGN KEY (TrainID) REFERENCES dbo.Train(TrainID)
);

-- Booking
CREATE TABLE dbo.Booking (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    PassengerID INT NOT NULL,
    BookingDate DATE NULL,                 -- renamed Date -> BookingDate
    TotalAmount DECIMAL(10,2) NULL,
    BookedSeatsCount INT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT('Pending'),
    CONSTRAINT FK_Booking_Passenger FOREIGN KEY (PassengerID) REFERENCES dbo.Passenger(PassengerID)
);

-- BookingSeat (association Booking <-> Seat)
CREATE TABLE dbo.BookingSeat (
    BookingSeatID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL,
    SeatID INT NOT NULL,
    SeatNumber NVARCHAR(10) NULL,
    SeatClass NVARCHAR(20) NULL,
    SeatPrice DECIMAL(10,2) NULL,
    Status NVARCHAR(20) NULL,
    CONSTRAINT FK_BookingSeat_Booking FOREIGN KEY (BookingID) REFERENCES dbo.Booking(BookingID),
    CONSTRAINT FK_BookingSeat_Seat FOREIGN KEY (SeatID) REFERENCES dbo.Seat(SeatID)
);

-- Payment (one or more per booking)
CREATE TABLE dbo.Payment (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL,
    PaymentDate DATE NULL,
    PaymentTime TIME NULL,
    Amount DECIMAL(10,2) NULL,
    Details NVARCHAR(255) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT('Pending'),
    CONSTRAINT FK_Payment_Booking FOREIGN KEY (BookingID) REFERENCES dbo.Booking(BookingID)
);

-- DigitalTicket
CREATE TABLE dbo.DigitalTicket (
    TicketID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL,
    TicketNumber NVARCHAR(50) UNIQUE NOT NULL,
    IssueDate DATE NULL,
    IssueTime TIME NULL,
    Status NVARCHAR(20) NULL,
    CONSTRAINT FK_Ticket_Booking FOREIGN KEY (BookingID) REFERENCES dbo.Booking(BookingID)
);


-- =========================
-- Sample INSERTS (specify columns)
-- =========================

INSERT INTO dbo.Users (Name, PasswordHash, Status, CreatedAt, UpdatedAt)
VALUES
('Alice Perera','pass123','Active','2025-01-01','2025-10-01'),
('Bimal Silva','pass456','Active','2025-02-15','2025-10-05'),
('Chathu Fernando','pass789','Active','2025-03-10','2025-10-07'),
('Dilani Jayasinghe','pass321','Active','2025-04-12','2025-10-08'),
('Eshan Wijesinghe','pass654','Active','2025-05-20','2025-10-09');

-- Emails
INSERT INTO dbo.UserEmail (UserID, Email) VALUES
(1,'alice@gmail.com'),
(2,'bimal@yahoo.com'),
(3,'chathu@hotmail.com'),
(4,'dilani@gmail.com'),
(5,'eshan@gmail.com');

-- Phones
INSERT INTO dbo.UserPhone (UserID, PhoneNumber) VALUES
(1,'0711234567'),
(2,'0722345678'),
(3,'0773456789'),
(4,'0754567890'),
(5,'0765678901');

-- Passengers (PassengerID must match Users.UserID)
INSERT INTO dbo.Passenger (PassengerID, NIC, DateOfBirth, Address, Gender, EmergencyContact) VALUES
(1,'990011223V','1995-01-15','Colombo','Female','0719876543'),
(2,'880022334V','1992-05-20','Kandy','Male','0729876543'),
(3,'770033445V','1990-08-10','Galle','Male','0779876543'),
(4,'660044556V','1998-12-05','Negombo','Female','0759876543'),
(5,'550055667V','1997-03-25','Matara','Male','0769876543');

-- Admins (AdminID must match Users.UserID)
INSERT INTO dbo.Admin (AdminID, EmployeeID, Department, JoinDate, Permission, AccessLevel) VALUES
(1,'EMP001','Operations','2023-01-01','Full','Level 1'),
(2,'EMP002','Booking','2023-02-01','Partial','Level 2'),
(3,'EMP003','Maintenance','2023-03-01','Full','Level 1'),
(4,'EMP004','Customer Service','2023-04-01','Partial','Level 2'),
(5,'EMP005','Scheduling','2023-05-01','Full','Level 1');

-- Stations
INSERT INTO dbo.Station (StationName, City, ContactNumber, PlatformCount, Facilities) VALUES
('Colombo Fort','Colombo','0112345678',5,'Waiting area, Restrooms'),
('Kandy','Kandy','0812345678',3,'Parking, Restrooms'),
('Galle','Galle','0912345678',4,'Food court, Waiting area'),
('Negombo','Negombo','0312345678',2,'Restrooms, Parking'),
('Matara','Matara','0412345678',3,'Waiting area, Ticket counter');

-- Trains
INSERT INTO dbo.Train (TrainName, TrainType, TotalSeats, Description, Manufacturer, Status) VALUES
('Intercity Express','Express',200,'Fast train Colombo-Kandy','Hitachi','Active'),
('Coastal Line','Local',150,'Scenic route Galle-Matara','Bombardier','Active'),
('Night Rider','Night',100,'Overnight service Colombo-Galle','Alstom','Active'),
('City Connector','Express',180,'Colombo to Negombo','Siemens','Active'),
('Heritage Express','Tourist',120,'Special sightseeing train','Hitachi','Active');

-- Routes (use station ids 1..5 from above)
INSERT INTO dbo.Route (RouteName, StartingStationID, EndStationID, Distance, Duration, Description, Status) VALUES
('Colombo-Kandy Route',1,2,120.50,'3h','Main intercity route','Active'),
('Galle-Matara Route',3,5,65.00,'1h30m','Scenic coastal route','Active'),
('Colombo-Galle Route',1,3,120.00,'2h30m','Express coastal train','Active'),
('Colombo-Negombo Route',1,4,38.00,'45m','Commuter route','Active'),
('Heritage Tour',2,5,200.00,'5h','Tourist scenic route','Active');

-- Schedules
INSERT INTO dbo.Schedule (TrainID, RouteID, ScheduleDate, DepartureTime, ArrivalTime, Attribute, Status) VALUES
(1,1,'2025-10-15','06:00:00','09:00:00','Express','Active'),
(2,2,'2025-10-16','08:30:00','10:00:00','Local','Active'),
(3,3,'2025-10-15','22:00:00','00:30:00','Night','Active'),
(4,4,'2025-10-17','07:00:00','07:45:00','Commuter','Active'),
(5,5,'2025-10-18','09:00:00','14:00:00','Tourist','Active');

-- Seats (SeatNumber left NULL where not provided)
INSERT INTO dbo.Seat (SeatClass, TrainID, SeatNumber) VALUES
('First Class',1,'A1'),
('Second Class',1,'B1'),
('Third Class',2,'C1'),
('First Class',3,'A2'),
('Second Class',4,'B2'),
('Third Class',5,'C2'),
('First Class',5,'A3'),
('Second Class',3,'B3'),
('Third Class',2,'C2-2'),
('Second Class',4,'B4');

-- Bookings
INSERT INTO dbo.Booking (PassengerID, BookingDate, TotalAmount, BookedSeatsCount, Status) VALUES
(1,'2025-10-05',5000.00,2,'Confirmed'),
(2,'2025-10-06',3000.00,1,'Pending'),
(3,'2025-10-07',4500.00,2,'Confirmed'),
(4,'2025-10-08',2500.00,1,'Pending'),
(5,'2025-10-09',6000.00,3,'Confirmed');

-- BookingSeat (make sure BookingID and SeatID exist)
INSERT INTO dbo.BookingSeat (BookingID, SeatID, SeatNumber, SeatClass, SeatPrice, Status) VALUES
(1,1,'A1','First Class',2500.00,'Booked'),
(1,2,'B1','Second Class',2500.00,'Booked'),
(2,3,'C1','Third Class',3000.00,'Pending'),
(3,4,'A2','First Class',2250.00,'Booked'),
(3,8,'B3','Second Class',2250.00,'Booked');

-- Payments
INSERT INTO dbo.Payment (BookingID, PaymentDate, PaymentTime, Amount, Details, Status) VALUES
(1,'2025-10-05','10:00:00',5000.00,'Credit Card','Paid'),
(2,'2025-10-06','11:30:00',3000.00,'Cash','Pending'),
(3,'2025-10-07','09:45:00',4500.00,'Bank Transfer','Paid'),
(4,'2025-10-08','14:00:00',2500.00,'Cash','Pending'),
(5,'2025-10-09','15:30:00',6000.00,'Credit Card','Paid');

-- Digital Tickets
INSERT INTO dbo.DigitalTicket (BookingID, TicketNumber, IssueDate, IssueTime, Status) VALUES
(1,'TCK1001','2025-10-05','10:05:00','Active'),
(2,'TCK1002','2025-10-06','11:35:00','Pending'),
(3,'TCK1003','2025-10-07','09:50:00','Active'),
(4,'TCK1004','2025-10-08','14:05:00','Pending'),
(5,'TCK1005','2025-10-09','15:35:00','Active');


-- =========================
-- Queries (fixed)
-- =========================

-- Active trains
SELECT TrainID, TrainName, TrainType, TotalSeats, Status
FROM dbo.Train
WHERE Status = 'Active';

-- Booking list with passenger name
SELECT B.BookingID, U.Name, B.TotalAmount, B.Status
FROM dbo.Booking B
JOIN dbo.Passenger P ON B.PassengerID = P.PassengerID
JOIN dbo.Users U ON P.PassengerID = U.UserID;

-- Total seats booked per train (sum of BookingSeat counts per train)
SELECT T.TrainName, SUM(BS.SeatPrice) AS TotalSeatsBookedPrice, COUNT(BS.BookingSeatID) AS SeatsBookedCount
FROM dbo.BookingSeat BS
JOIN dbo.Seat S ON BS.SeatID = S.SeatID
JOIN dbo.Train T ON S.TrainID = T.TrainID
JOIN dbo.Booking B ON BS.BookingID = B.BookingID
GROUP BY T.TrainName;

-- Trains with more than 1 booking (count distinct bookings per train)
SELECT T.TrainName, COUNT(DISTINCT B.BookingID) AS BookingCount
FROM dbo.Booking B
JOIN dbo.BookingSeat BS ON B.BookingID = BS.BookingID
JOIN dbo.Seat S ON BS.SeatID = S.SeatID
JOIN dbo.Train T ON S.TrainID = T.TrainID
GROUP BY T.TrainName
HAVING COUNT(DISTINCT B.BookingID) > 1;

-- Users who made bookings with total amount > 4000
SELECT U.Name, U.UserID
FROM dbo.Users U
WHERE U.UserID IN (
    SELECT P.PassengerID
    FROM dbo.Booking B
    JOIN dbo.Passenger P ON B.PassengerID = P.PassengerID
    WHERE B.TotalAmount > 4000
);


-- =========================
-- Scalar function: compute total of BookingSeat for a booking
-- (SQL Server scalar function)
-- =========================
IF OBJECT_ID('dbo.GetBookingTotal','FN') IS NOT NULL
    DROP FUNCTION dbo.GetBookingTotal;
GO

CREATE FUNCTION dbo.GetBookingTotal (@BookingID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalAmount DECIMAL(10,2);

    SELECT @TotalAmount = SUM(ISNULL(SeatPrice,0))
    FROM dbo.BookingSeat
    WHERE BookingID = @BookingID;

    RETURN ISNULL(@TotalAmount, 0);
END;
GO

-- example usage
SELECT dbo.GetBookingTotal(1) AS TotalAmountForBooking1;


-- =========================
-- Trigger: After insert into Payment update Booking.Status = 'Confirmed'
-- Only confirm when payment.Status = 'Paid'
-- =========================
IF OBJECT_ID('dbo.trg_AfterPaymentInsert','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_AfterPaymentInsert;
GO

CREATE TRIGGER dbo.trg_AfterPaymentInsert
ON dbo.Payment
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update booking status to Confirmed only when payment row(s) have Status = 'Paid'
    UPDATE B
    SET B.Status = 'Confirmed'
    FROM dbo.Booking B
    INNER JOIN inserted I ON B.BookingID = I.BookingID
    WHERE I.Status = 'Paid';
END;
GO

-- Test trigger: insert a payment with Paid status (uncomment to test)
-- INSERT INTO dbo.Payment (BookingID, PaymentDate, PaymentTime, Amount, Details, Status)
-- VALUES (2, GETDATE(), CONVERT(time, GETDATE()), 3000.00, 'Test Paid', 'Paid');

-- End of script
