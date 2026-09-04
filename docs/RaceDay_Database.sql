--Creates the schema, then seeds it with sample data.

IF DB_ID('RaceDayDB') IS NOT NULL
BEGIN
    ALTER DATABASE RaceDayDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDayDB;
END

CREATE DATABASE RaceDayDB;
USE RaceDayDB;

--1. Users  (Organisers and Participants share the same table, difference is showed by Role column)

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FullName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(250) NOT NULL,
    Role NVARCHAR(20) NOT NULL

CONSTRAINT CK_Users_Role 
   CHECK (Role IN ('Organiser', 'Participant')),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

-- 2. Venues

CREATE TABLE Venues (
    VenueID INT IDENTITY(1,1) PRIMARY KEY,
    VenueName NVARCHAR(150) NOT NULL,
    Address NVARCHAR(200) NULL,
    City NVARCHAR(100) NOT NULL,
    Province NVARCHAR(100) NOT NULL,
    Latitude DECIMAL(9,6)NULL,
    Longitude  DECIMAL(9,6)NULL
);

--3. Events

CREATE TABLE Events (
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID INT NOT NULL,
    VenueID INT NOT NULL,
    EventName NVARCHAR(150) NOT NULL,
    Description NVARCHAR(1000) NULL,
    EventDate DATE NOT NULL,
    EventType NVARCHAR(20) NOT NULL

    CONSTRAINT CK_Events_Type 
       CHECK (EventType IN ('Run', 'Walk', 'Cycle')),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Events_Venue FOREIGN KEY (VenueID) REFERENCES Venues(VenueID)
);

--4. Categories

CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    CategoryName NVARCHAR(50) NOT NULL,
    DistanceKm DECIMAL(5,2) NOT NULL,
    EntryFee DECIMAL(8,2) NOT NULL DEFAULT 0,
    MaxParticipants INT NOT NULL DEFAULT 100,

    CONSTRAINT FK_Categories_Event FOREIGN KEY (EventID) REFERENCES Events(EventID)
);

-- 5. Enrolments

CREATE TABLE Enrolments (
    EnrolmentID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    CategoryID INT NOT NULL,
    EnrolmentDate DATETIME NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Confirmed'

    CONSTRAINT CK_Enrolments_Status 
    CHECK (Status IN ('Confirmed', 'Cancelled')),

    CONSTRAINT FK_Enrolments_Participant FOREIGN KEY (ParticipantID) REFERENCES Users(UserID),
    CONSTRAINT FK_Enrolments_Category FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT UQ_Enrolments_ParticipantCategory UNIQUE (ParticipantID, CategoryID)
);


-- 6. Results

CREATE TABLE Results (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID INT NOT NULL UNIQUE,
    FinishTime TIME NULL,
    OverallPosition INT NULL,
    CategoryPosition INT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Finished'

    CONSTRAINT CK_Results_Status 
    CHECK (Status IN ('Finished', 'DNF', 'DQ')),

    CONSTRAINT FK_Results_Enrolment FOREIGN KEY (EnrolmentID) REFERENCES Enrolments(EnrolmentID)
);

-- Organisers (2) and Participants (2)
INSERT INTO Users (FullName, Email, PasswordHash, Role)
VALUES ('Thandiwe Mokoena', 'thandiwe.mokoena@raceday.co.za', 'HASHED_PASSWORD_1', 'Organiser'),
       ('Johan van der Merwe', 'johan.vdm@raceday.co.za', 'HASHED_PASSWORD_2', 'Organiser'),
       ('Lindiwe Dlamini', 'lindiwe.dlamini@gmail.com', 'HASHED_PASSWORD_3', 'Participant'),
       ('Craig Adams', 'craig.adams@gmail.com', 'HASHED_PASSWORD_4', 'Participant');

-- Venues
INSERT INTO Venues (VenueName, Address, City, Province, Latitude, Longitude)
VALUES ('Green Point Park', 'Fritz Sonnenberg Rd', 'Cape Town', 'Western Cape', -33.9047, 18.4058),
       ('Marks Park Sports Club',  '106 Judith Rd', 'Johannesburg', 'Gauteng', -26.1615, 28.0201),
       ('Comrades Marathon Route', 'Peter Brown Dr', 'Pietermaritzburg', 'KwaZulu-Natal', -29.6006, 30.3794);

-- Events (3), one per venue
INSERT INTO Events (OrganiserID, VenueID, EventName, Description, EventDate, EventType)
VALUES (1, 1, 'Cape Town Cycle Tour Fun Ride', 'A community cycling event around the Cape Peninsula.', '2026-11-08', 'Cycle'),
       (2, 2, 'Johannesburg Park Run Challenge','A timed 5km/10km park run series in Johannesburg.', '2026-10-17', 'Run'),
       (1, 3, 'Comrades Legacy Charity Walk', 'A community walk along part of the Comrades route.', '2026-09-20', 'Walk');


-- Categories for each event
INSERT INTO Categories (EventID, CategoryName, DistanceKm, EntryFee, MaxParticipants)
VALUES (1, '35km Short Route', 35.00, 350.00, 500),
       (1, '109km Full Route', 109.00, 650.00, 1000),
       (2, '5km Fun Run',  5.00, 80.00, 300),
       (2, '10km Timed Run', 10.00, 120.00, 300),
       (3, '10km Charity Walk', 10.00, 100.00, 200);


-- Enrolments (sample participants enrolling in categories)
INSERT INTO Enrolments (ParticipantID, CategoryID, Status) VALUES
(3, 1, 'Confirmed'),
(3, 3, 'Confirmed'), 
(4, 4, 'Confirmed'), 
(4, 5, 'Confirmed');  

-- Sample results captured for two of the enrolments
INSERT INTO Results (EnrolmentID, FinishTime, OverallPosition, CategoryPosition, Status)
VALUES (2, '00:22:14', 15, 4, 'Finished'),
       (3, '00:48:52', 32, 10, 'Finished');

