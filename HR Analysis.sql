USE Hotel
GO

SELECT *
FROM Human_Resources


--Renaming id column to employee_id 
EXEC sp_rename 'Human_Resources.id', 'employee_id', 'COLUMN'


--Changing the date datatype and format

ALTER TABLE Human_Resources
ALTER COLUMN birthdate DATE

ALTER TABLE Human_Resources
ALTER COLUMN hire_date DATE


--Intorducing an age column for analysis and computing it
ALTER TABLE Human_Resources
ADD age INT

UPDATE Human_Resources
SET age = DATEDIFF(YEAR,birthdate,GETDATE())

-- Analytical Questions to answer from the dataset
-- Gender breakdown of employees in the company

SELECT gender, COUNT (*) AS Gender_BreakDown
FROM Human_Resources
GROUP BY gender
ORDER BY Gender_BreakDown DESC

--Race/Ethnicity breakdown of the company
SELECT race, COUNT(*) AS Race_Breakdown
FROM Human_Resources 
GROUP BY Race
Order BY Race_Breakdown DESC

--Age distribution of the employees (Determine the upper and lower Limits first)

SELECT a. age_distribution, gender, COUNT(*) AS Total_No
FROM (SELECT CASE
		WHEN age between 18 AND 24 THEN '18-24'
		WHEN age between 25 AND 34 THEN '25-34'
		WHEN age between 35 AND  44 THEN '35-44'
		WHEN age between 45 AND  54 THEN '45-54'
		WHEN age between 55 AND  64 THEN '55-64'
		ELSE '65+' END AS age_distribution, gender
FROM Human_Resources) AS a
GROUP BY a.age_distribution, a.gender
ORDER BY a.age_distribution DESC


-- Determine the distribution of the employees according to location
SELECT Location, COUNT(*) AS Total_Count
FROM Human_Resources
GROUP BY location
ORDER BY Total_Count DESC

-- Determine the distribution of the employees according to departments
SELECT department, gender, COUNT(*) AS Total_No_of_Employees
FROM Human_Resources
GROUP BY department, gender
ORDER BY department

--Distribution of Job_Titles across the comoany
SELECT jobtitle, department, COUNT (*) AS Total_Count_of_Jobtilte
FROM Human_Resources
GROUP BY jobtitle, department
ORDER BY Total_Count_of_Jobtilte DESC

--Distribution of Employees across location_city, Location State
SELECT location_state, gender, COUNT(*) AS Total_Count
FROM Human_Resources
GROUP BY location_state, gender
ORDER BY location_state DESC

