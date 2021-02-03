DROP TABLE IF EXISTS RoomStays;
DROP TABLE IF EXISTS Rooms;

CREATE TABLE Rooms (
	ID int NOT NULL PRIMARY KEY IDENTITY(1,1),
	TavernID int NOT NULL FOREIGN KEY REFERENCES Taverns(ID),
	Status varchar(50)
);

CREATE TABLE RoomStays (
	ID int NOT NULL PRIMARY KEY IDENTITY(1,1),
	RoomID int NOT NULL FOREIGN KEY REFERENCES Rooms(ID),
	GuestID int FOREIGN KEY REFERENCES Guests(ID),
	StayDate Date,
	Rate Decimal
);

INSERT INTO Rooms (TavernID, Status) VALUES
	(1, 'Available'),
	(2, 'Not Available'),
	(3, 'Available'),
	(2, 'Available'),
	(1, 'Not Available');

INSERT INTO RoomStays (RoomID, GuestID, StayDate, Rate) VALUES
	(2, 1, '2/1/2021', 50.00),
	(5, 2, '2/2/2021', 106.00);
GO

-- Question 2
SELECT * FROM Guests WHERE BirthDate < '01/01/2000';

-- Question 3
SELECT RoomID AS ExpensiveRooms FROM RoomStays WHERE Rate > 100;

-- Question 4
SELECT DISTINCT Name FROM Guests;

-- Question 5
SELECT * FROM Guests ORDER BY Name DESC;

-- Question 6
SELECT TOP(10) Price FROM SupplySales;

-- Question 7
SELECT * FROM Service
UNION ALL SELECT * FROM ServiceStatusFlag
UNION ALL SELECT * FROM Classes
UNION ALL SELECT * FROM Statuses

-- Question 8
INSERT INTO GuestClassAndLevel VALUES
	(1, 4, 12), (2, 3, 28);

SELECT *,
	CASE
		WHEN Level <= 10 THEN '1-10'
		WHEN Level > 10 AND Level <=20 THEN '11-20'
		WHEN Level >20 THEN '20+'
	END
	AS LevelGrouping
FROM GuestClassandLevel;

-- Question 9 (Not sure if this is what was asked for)
SELECT CONCAT('INSERT INTO Rooms (Status) VALUES (''',
Name,
''');')
FROM Statuses;
