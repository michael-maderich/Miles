--1. Write a query to return a “report” of all users and their roles
SELECT Users.Name as [User], BirthDate, Roles.Name as Role, Description FROM
	Users FULL JOIN Roles ON Users.RoleID = Roles.ID;


--2. Write a query to return all classes and the count of guests that hold those classes
SELECT c.Name as [Class], COUNT(g.ID) as [Count] FROM
	Classes c JOIN GuestClassAndLevel gc ON c.ID = gc.ClassID
	JOIN Guests g ON gc.GuestID = g.ID
	GROUP BY c.Name;


/*3. Write a query that returns all guests ordered by name (ascending) and their classes
and corresponding levels. Add a column that labels them beginner (lvl 1-5), intermediate (5-10)
and expert (10+) for their classes (Don’t alter the table for this)*/
SELECT u.Name AS GuestName, c.Name AS [Class], gc.Level, 
	CASE
		WHEN 0 < Level AND Level <=5 THEN 'Beginner'
		WHEN 5 < Level AND Level <=10 THEN 'Intermediate'
		WHEN 10 < Level THEN 'Expert'
		ELSE 'Unskilled'
	END
	AS Experience
FROM Users u JOIN Guests g ON u.ID = g.UserID
	JOIN GuestClassAndLevel gc ON g.ID = gc.GuestID
	JOIN Classes c ON gc.GuestID = c.ID
	ORDER BY u.Name ASC;


--4. Write a function that takes a level and returns a “grouping” from question 3 (e.g. 1-5, 5-10, 10+, etc)
-- Drop Function if exists
IF OBJECT_ID(N'dbo.LevelGrouping', N'FN') IS NOT NULL
	DROP FUNCTION LevelGrouping;
GO

-- Create Scalar Function to return level grouping with level number input
CREATE FUNCTION dbo.LevelGrouping(@gID int, @cID int)
RETURNS varchar(20)
AS
BEGIN
	DECLARE @GroupingName varchar(20);
	SELECT @GroupingName =
	CASE
		WHEN 0 < Level AND Level <=5 THEN 'Beginner'
		WHEN 5 < Level AND Level <=10 THEN 'Intermediate'
		WHEN 10 < Level THEN 'Expert'
		ELSE 'Unskilled'
	END
	FROM GuestClassAndLevel gc
		WHERE gc.GuestID = @gID AND gc.ClassID = @cID;
	RETURN @GroupingName;
END;
GO

-- Test Function
SELECT u.Name AS GuestName, c.Name AS [Class], gc.Level, dbo.LevelGrouping(gc.GuestID, gc.ClassID) AS Experience
FROM Users u JOIN Guests g ON u.ID = g.UserID
	JOIN GuestClassAndLevel gc ON g.ID = gc.GuestID
	JOIN Classes c ON gc.GuestID = c.ID
ORDER BY u.Name ASC;


--5. Write a function that returns a report of all open rooms (not used) on a particular day (input) and which tavern they belong to
-- Drop Function if exists
IF OBJECT_ID(N'dbo.OpenRoomsByDate', N'IF') IS NOT NULL
	DROP FUNCTION OpenRoomsByDate;
GO

-- Create Table Function to return table of available rooms on passed date
CREATE FUNCTION dbo.OpenRoomsByDate(@DateQuery Date)
RETURNS TABLE
AS
RETURN
(
	SELECT Taverns.Name AS TavernName, Rooms.ID AS RoomID, Rooms.Status, /*RoomStays.StayDate,*/ @DateQuery as [Date]
	FROM (Taverns JOIN Rooms ON Taverns.ID = Rooms.TavernID
		LEFT JOIN RoomStays ON Rooms.ID = RoomStays.RoomID)
	WHERE RoomStays.StayDate IS NULL OR RoomStays.StayDate != @DateQuery-- AND Rooms.Status = 'Available' 
);
GO

-- Test Function
--SELECT * FROM Rooms;
--SELECT * FROM RoomStays;
SELECT * FROM dbo.OpenRoomsByDate('2021-02-01');
SELECT * FROM dbo.OpenRoomsByDate('1/2/2021');


/*6. Modify the same function from 5 to instead return a report of prices in a 
range (min and max prices) - Return Rooms and their taverns based on price inputs*/
IF OBJECT_ID(N'dbo.RoomsByPrice', N'IF') IS NOT NULL
	DROP FUNCTION RoomsByPrice;
GO

-- Create Table Function to return table of rooms based on passed price range
CREATE FUNCTION dbo.RoomsByPrice(@LowPrice Decimal(5,2), @HighPrice Decimal(5,2))
RETURNS TABLE
AS
RETURN
(
	SELECT Taverns.Name AS TavernName, Rooms.ID AS RoomID, Rooms.Status, RoomStays.Rate
	FROM (Taverns JOIN Rooms ON Taverns.ID = Rooms.TavernID
		LEFT JOIN RoomStays ON Rooms.ID = RoomStays.RoomID)
	WHERE RoomStays.Rate BETWEEN @LowPrice AND @HighPrice
);
GO

-- Test Function
--SELECT * FROM Rooms;
SELECT * FROM RoomStays;
SELECT * FROM dbo.RoomsByPrice(25,50);
SELECT * FROM dbo.RoomsByPrice(60,70);
SELECT * FROM dbo.RoomsByPrice(1,150);


/*7. Write a command that uses the result from 6 to Create a Room in 
another tavern that undercuts (is less than) the cheapest room by a 
penny - thereby making the new room the cheapest one*/
INSERT INTO Rooms (TavernID, Status) VALUES (1, 'Available');
DECLARE @NewRoomID int;
SELECT @NewRoomID = MAX(ID) FROM Rooms;
DECLARE @MinRoomPrice Decimal(5,2);
SELECT @MinRoomPrice = MIN(Rate) FROM dbo.RoomsByPrice(0,60);
SELECT @MinRoomPrice = @MinRoomPrice - 0.01;

INSERT INTO RoomStays (RoomID, Rate) VALUES (@NewRoomID,@MinRoomPrice);

-- Test results
SELECT * FROM dbo.RoomsByPrice(0,60);
SELECT * FROM Rooms;
SELECT * from RoomStays;
