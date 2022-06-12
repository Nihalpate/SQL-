

USE nihal

SELECT * 
FROM coviddeaths
WHERE location LIKE "%income%"

-- listing number of entries with respect to country code and name 
SELECT location,iso_code, COUNT(*)
FROM coviddeaths 
GROUP BY iso_code


-- Looking at total covid cases vs population of the country with respect to percentage of the death 

SELECT 
	location,
    date,
	total_cases, 
    total_deaths, 
    (total_deaths/total_cases*100) AS "Death Percentage"
FROM coviddeaths
WHERE location = "india" 
ORDER BY 1,2

-- Looking at Total cases vs Population of the country

SELECT 
	location,
    date,
	total_cases), 
    population,
    (total_cases/population) * 100 AS "Percent of the popultion got infected"
FROM coviddeaths
WHERE location = "india"
ORDER BY 1,2

-- List of the countries by the infaction rate

SELECT
	location AS "Country",
    MAX(total_cases) AS "Highest Infaction Count",
    population,
    MAX(total_cases/population)*100 AS "Chances of the Infaction in %"
FROM coviddeaths

GROUP BY 1
ORDER BY 4 DESC 

-- Looking at the countries with the highest deaths rates 
location
SELECT 
	location,
    total_cases,
    total_deaths,
    population
FROM coviddeaths
WHERE total_deaths IS MAX
GROUP BY location




-- Looking at the total infection count and total deaths
SELECT 
	location AS "countries / continent",
    MAX(total_cases) AS "Total Infection Count",
    MAX(total_deaths) AS "Total Death Count",
    MAX(total_deaths/total_cases) * 100 AS "Percentage of the death"
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 3 DESC




-- Changing the empty string (" ") with NULL in order to process it later on 
UPDATE coviddeaths
SET continent = NULLIF(continent, '') 




-- Looking at the total infaction count and total deaths for each continent 
-- The list is orderd by the death count 

SELECT 
	location AS "countries / continent",
    MAX(total_cases) AS "Total Infection Count",
    MAX(total_deaths) AS "Total Death Count",
    MAX(total_deaths/total_cases) * 100 AS "Percentage of the death"
FROM coviddeaths
WHERE continent IS NULL AND
	  Location NOT LIKE "%income%"
GROUP BY 1
ORDER BY 3 DESC

-- Data arond the world 

SELECT date,
       SUM(new_cases) AS "Daily Infcation Count",
       SUM(new_deaths) AS "Daily Death Count",
       ROUND(SUM(new_deaths)/SUM(new_cases)*100,2) AS "Daily Death Rate", 
       SUM(total_cases) AS "Total Infacions",
       SUM(total_deaths) AS "Total Deaths",
       ROUND(SUM(total_deaths)/SUM(total_cases)*100,2) AS "Overall Death Rate"
FROM coviddeaths
GROUP BY date
ORDER BY date

-- Calling everything from the covid vaccination table 

SELECT 
	*
FROM covidvaccination


-- FROM NOW ONWARDS WE WILL USE DATA FROM BOTH OF THIS TABLE SIMULTANEOUSLY
-- First let's join both of these table 

SELECT
	dea.location,
    dea.date,
    vac.new_vaccinations,
    total_vaccinations
FROM 
	coviddeaths AS dea
    JOIN covidvaccination AS vac 
    ON dea.location = vac.location AND 
	   dea.date = vac.date
       
       
-- Adding some of the calculaitons in the query 
-- Looking at the running sum of the total vaccination for each countries 

SELECT
	dea.location,
    dea.date,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) 
		OVER (PARTITION BY dea.location 
			  ORDER BY dea.location, dea.date)
		AS "Daily Count of Total Vaccination"
FROM 
	coviddeaths AS dea
    JOIN covidvaccination AS vac 
    ON dea.location = vac.location AND 
	   dea.date = vac.date
ORDER BY 1,2


-- USE OF CTE 

WITH new_covtable(location, date, population, new_vaccinations, Daily_updated_Total_Vaccination)
AS(
    SELECT
	dea.location,
    dea.date,
    population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) 
		OVER (PARTITION BY dea.location 
			  ORDER BY dea.location, dea.date)
		AS "Daily_updated_Total_Vaccination"
	FROM 
		coviddeaths AS dea
		JOIN covidvaccination AS vac 
		ON dea.location = vac.location AND 
		   dea.date = vac.date
	-- ORDER BY 1,2
)
SELECT
	*,
    (Daily_updated_Total_Vaccination / population) * 100 AS "Rate of vaccination"
FROM new_covtable


-- Temp Table 
-- first we have to create the table as we do in normal procedure for creating table 
-- than we need to insert the datas into newly created table \

DROP TABLE IF EXISTS newcovtable
CREATE TABLE newcovtable (
	location VARCHAR(225), 
    date DATETIME, 
    population NUMERIC, 
    new_vaccinations NUMERIC, 
    Daily_updated_Total_Vaccination NUMERIC
)

INSERT INTO newcovtable
    SELECT
	dea.location,
    dea.date,
    population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) 
		OVER (PARTITION BY dea.location 
			  ORDER BY dea.location, dea.date)
		AS "Daily_updated_Total_Vaccination"
	FROM 
		coviddeaths AS dea
		JOIN covidvaccination AS vac 
		ON dea.location = vac.location AND 
		   dea.date = vac.date
	-- ORDER BY 1

SELECT COUNT(*) 
FROM newcovtable






