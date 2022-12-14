SELECT *
FROM PortfolioProject..CovidDeath
ORDER BY 3;

--SELECT *
--FROM PortfolioProject..CovidVaccine;

--Query showing likelihood from dieing from  covid in respective countries
SELECT location, date, total_cases, new_cases, total_deaths, population, ROUND(((total_deaths/total_cases)*100),2) AS percentage_deathrate
FROM PortfolioProject..CovidDeath
WHERE location = 'Nigeria'
ORDER BY 1, 2;

--Query showing rate of infection against total population
SELECT location, date, total_cases, new_cases, population, ROUND(((total_cases/population)*100),2) AS percentage_infectionrate
FROM PortfolioProject..CovidDeath
--WHERE location = 'Nigeria'
ORDER BY 1, 2;

--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS Highest_CASES, MAX(ROUND(((total_cases/population)*100),2)) AS percentage_infectionrate
FROM PortfolioProject..CovidDeath
--WHERE location = 'Nigeria'
GROUP BY location, population
ORDER BY percentage_infectionrate DESC;

-- Highest Deaths Per Population
SELECT location, population, MAX(cast(total_deaths as bigint)) AS highest_death, MAX(ROUND(((cast(total_deaths as bigint)/population)*100),2)) AS max_death_per_population
FROM PortfolioProject..CovidDeath
WHERE continent <> 'NULL'
GROUP BY location, population
ORDER BY highest_death DESC;

--QUERYING THE DATASET BY CONTINENT
SELECT location, MAX(cast(total_deaths as bigint)) AS highest_death, MAX(ROUND(((cast(total_deaths as bigint)/population)*100),2)) AS max_death_per_population
FROM PortfolioProject..CovidDeath
WHERE continent IS NULL
GROUP BY location
ORDER BY highest_death DESC


--QUERYING THE DATASET BY CONTINENT
SELECT location, MAX(cast(total_deaths as bigint)) AS highest_death
FROM PortfolioProject..CovidDeath
WHERE continent IS NULL
AND location <> 'Upper middle income'
AND location <> 'High income'
AND location <> 'Lower middle income'
AND location <> 'European Union'
AND location <> 'Low income'
AND location <> 'World'
AND location <> 'International'
GROUP BY location
ORDER BY location;


--GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
				ROUND((SUM(CAST(new_deaths AS INT))/ SUM(new_cases))*100,2) AS percentagedead
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
AND location <> 'Upper middle income'
AND location <> 'High income'
AND location <> 'Lower middle income'
AND location <> 'European Union'
AND location <> 'Low income'
AND location <> 'World'
AND location <> 'International'
GROUP BY CUBE(date)
ORDER BY date;

--Cumulative Sums of Vaccinations per country
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CAST(CV.new_Vaccinations AS bigint)) OVER(PARTITION BY CD.location ORDER BY CD.date,CD.location) AS cumsum_newvaccinations
		FROM PortfolioProject..CovidDeath AS CD
		INNER JOIN PortfolioProject..CovidVaccine AS CV
		ON CD.location = CV.location
		AND CD.date = CV.date
		WHERE CD.continent IS NOT NULL
		ORDER BY 2,3;

-- Using a CTE to get the percentage of population vaccinated

WITH vaccinations_per_Country AS(SELECT CD.continent, CD.location, CD.date, CD.population AS country_population, CV.new_vaccinations, SUM(CAST(CV.new_Vaccinations AS bigint)) OVER(PARTITION BY CD.location ORDER BY CD.date,CD.location) AS cumsum_newvaccinations
		FROM PortfolioProject..CovidDeath AS CD
		INNER JOIN PortfolioProject..CovidVaccine AS CV
		ON CD.location = CV.location
		AND CD.date = CV.date
		WHERE CD.continent IS NOT NULL)

	SELECT *, ROUND(((cumsum_newvaccinations/country_population) *100),2) AS percentage_Vaccinated
	FROM vaccinations_per_Country

	-- Getting distinct countries and population vaccinated (Need to work on this)
--WITH vaccinations_per_Country AS(SELECT CD.continent, CD.location AS country, CD.date, CD.population AS country_population, CV.new_vaccinations, SUM(CAST(CV.new_Vaccinations AS bigint)) OVER(PARTITION BY CD.location ORDER BY CD.date,CD.location) AS cumsum_newvaccinations
--		FROM PortfolioProject..CovidDeath AS CD
--		INNER JOIN PortfolioProject..CovidVaccine AS CV
--		ON CD.location = CV.location
--		AND CD.date = CV.date
--		WHERE CD.continent IS NOT NULL)

--	SELECT country, MAX(cumsum_newvaccinations) 
--	FROM vaccinations_per_Country;

-- Creating a view

USE PortfolioProject
GO
CREATE VIEW VaccPer AS
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CAST(CV.new_Vaccinations AS bigint)) OVER(PARTITION BY CD.location ORDER BY CD.date,CD.location) AS cumsum_newvaccinations
		FROM PortfolioProject..CovidDeath AS CD
		INNER JOIN PortfolioProject..CovidVaccine AS CV
		ON CD.location = CV.location
		AND CD.date = CV.date
		WHERE CD.continent IS NOT NULL
		--ORDER BY 2,3

		SELECT DISTINCT CD.location, CD.continent, CD.Population, RANK() OVER(PARTITION BY CD.continent ORDER BY CD.Population DESC) AS country_rank
		FROM PortfolioProject..CovidDeath AS CD
		WHERE CD.continent IS NOT NULL
		ORDER BY CD.location