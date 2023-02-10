/*****This Query was aimed at building a date table*****/
/*****The date table  would help users filter (Slicing & Dicing) data based on the several date fields available****/
/*****For this table each new fiscal year begins from the month of Oct, this can be changed easily to suit the region*****/

USE Practice
GO

CREATE TABLE shelvy( CalendarDate DATE)


DECLARE @StartDate  DATE
DECLARE @EndDate	DATE
SET     @StartDate        = '2000-12-31'
SET     @EndDate          = GETDATE()
DECLARE @loopDate	DATE
SET     @loopDate         = @Startdate
WHILE   @loopDate         <= @EndDate
BEGIN

INSERT INTO shelvy
VALUES (@loopDate)
SET    @loopDate  = DATEADD(dd,1,@loopDate)
END;

SELECT * 
FROM shelvy

ALTER TABLE shelvy
ADD        CalendarYear INT,
		   CalendarQuarter INT,
		   CalendarMonth INT,
		   NameofMonth  TEXT,
		   DayinMonth INT,
		   DayinWeek INT,
		   NameofDay TEXT,
		   FiscalYear INT,
		   FiscalQuarter INT,
		   FiscalMonth INT;

UPDATE shelvy
SET CalendarYear        = YEAR(CalendarDate),
	CalendarQuarter     = DATEPART(QQ,CalendarDate),
	CalendarMonth       = MONTH(CalendarDate),
	NameofMonth         = DATENAME(MONTH, CalendarDate),
	DayinMonth          = DATEPART(DD,CalendarDate),
	DayinWeek           = DATEPART(WEEKDAY,CalendarDate),
	NameofDay           = DATENAME(WEEKDAY,CalendarDate),
	FiscalYear          = CASE WHEN MONTH(CalendarDate) < 10 THEN YEAR(CalendarDate) ELSE YEAR(CalendarDate) + 1 END,
	FiscalQuarter       = CASE WHEN MONTH(CalendarDate) IN (10,11,12) THEN 1
							   WHEN MONTH(CalendarDate) IN (1,2,3)    THEN 2
							   WHEN MONTH(CalendarDate) IN (4,5,6)    THEN 3
							   ELSE 4 END,
	FiscalMonth         = CASE WHEN MONTH(CalendarDate) = 10 THEN 1
							   WHEN MONTH(CalendarDate) = 11 THEN 2
							   WHEN MONTH(CalendarDate) = 12 THEN 3
							   WHEN MONTH(CalendarDate) = 1  THEN 4
							   WHEN MONTH(CalendarDate) = 2  THEN 5
							   WHEN MONTH(CalendarDate) = 3  THEN 6
							   WHEN MONTH(CalendarDate) = 4  THEN 7
							   WHEN MONTH(CalendarDate) = 5  THEN 8
							   WHEN MONTH(CalendarDate) = 6  THEN 9
							   WHEN MONTH(CalendarDate) = 7  THEN 10
							   WHEN MONTH(CalendarDate) = 8  THEN 11
							   ELSE 12 END

 


SELECT *
FROM shelvy


/*****Updated the date table to include seasons, below is the code created*****/

ALTER TABLE shelvy
  ADD Season TEXT NULL

  SELECT CalendarDate, CASE WHEN CalendarMonth BETWEEN 3 AND 5 THEN 'Spring'
						    WHEN CalendarMonth BETWEEN 6 AND 8 THEN 'Summer'
							WHEN CalendarMonth  BETWEEN 9 AND 11 THEN 'Fall(Autumn)'
							ELSE 'Winter' END AS ejo
  FROM shelvy

  UPDATE shelvy
  SET Season = CASE WHEN CalendarMonth BETWEEN 3 AND 5 THEN 'Spring'
						    WHEN CalendarMonth BETWEEN 6 AND 8 THEN 'Summer'
							WHEN CalendarMonth  BETWEEN 9 AND 11 THEN 'Fall(Autumn)'
							ELSE 'Winter' END
