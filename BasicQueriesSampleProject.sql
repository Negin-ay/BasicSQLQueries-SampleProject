-- 1) Summary of statistics across World
SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths AS SIGNED INT)) as Total_deaths,
       SUM(cast(new_deaths AS SIGNED INT))/SUM(new_Cases)*100 as Death_Percentage
From CovidDeaths.coviddeaths
WHERE continent IS NOT NULL;

-- 2) Summary of statistics across Canada
SELECT SUM(new_cases) AS Canada_total_cases, SUM(cast(new_deaths AS SIGNED INT)) as Canada_total_deaths,
       SUM(cast(new_deaths AS SIGNED INT))/SUM(new_Cases)*100 as Canada_death_Percentage
From CovidDeaths.coviddeaths
WHERE location="Canada";

-- 3) Continents with total death count
SELECT Continent, SUM(cast(new_deaths AS SIGNED INT)) AS TotalDeathCount
FROM CovidDeaths.coviddeaths
WHERE continent <> ""
GROUP BY Continent
ORDER BY TotalDeathCount DESC;
 
-- 4) Counries with the highest death count per population
SELECT Location, MAX((CAST(total_deaths AS SIGNED INT)/population)*100) AS Death_percentage
FROM CovidDeaths.coviddeaths
WHERE continent REGEXP("America") OR continent IN ("Asia", "Africa", "Europe", "Oceania")
GROUP BY Location
ORDER BY Death_percentage DESC;

 -- 5) Counries with total cases per population
SELECT Date, Location, (total_cases/population)*100 AS Infection_percentage
FROM CovidDeaths.coviddeaths
WHERE continent <> "" AND location IN ("Canada", "United States", "China", "India", "United Kingdom", "Iran");

-- 6) Monthly share of vaccinated population
SELECT  CONCAT(monthname(date)," , ",YEAR(date)) AS Month_of_Year, location, 
CASE
 WHEN SUM(CONVERT(new_vaccinations, SIGNED INT))/population >= 0.1 THEN "Fast"
 WHEN SUM(CONVERT(new_vaccinations, SIGNED INT))/population BETWEEN 0.08 AND 0.1 THEN "Moderate"
 WHEN SUM(CONVERT(new_vaccinations, SIGNED INT))/population BETWEEN 0.08 AND 0.04 THEN "Slow"
 ELSE "Very Slow"
END AS Vaccination_Rate
FROM CovidVaccinations.covidvaccinations
WHERE continent <> ""
GROUP BY YEAR(date), month(date), location;

-- 7) % of population fully vaccinated 
SELECT location, 
IF(MAX(CONVERT(people_fully_vaccinated, SIGNED INT))/population >= 0.5, "Safe to Travel", "Not safe to Travel") AS Status
FROM CovidVaccinations.covidvaccinations
WHERE continent <> ""
GROUP BY location;

-- 8) Continents with the highest death count
SELECT continent, MAX(CAST(total_deaths AS SIGNED INT)) AS Maximum_death_count
FROM CovidDeaths.coviddeaths
WHERE continent <> ""
GROUP BY continent
HAVING Maximum_death_count > 100000;

-- 9) Global monthly statistics
SELECT date, SUM(new_cases) AS Global_total_cases, 
       SUM(CAST(new_deaths AS SIGNED INT)) AS Global_total_deaths,
       SUM(CAST(new_deaths AS SIGNED INT))/SUM(new_cases) AS Global_death_percentage
FROM CovidDeaths.coviddeaths
WHERE continent <> ""
GROUP BY date;

-- 10) Counries with cumulative total vaccination
SELECT D.continent, D.location, D.date, V.new_vaccinations,
       SUM(CONVERT(V.new_vaccinations , SIGNED INT)) OVER 
       (PARTITION BY V.location ORDER BY D.location, D.date) AS Cumulative_vaccinations
FROM CovidDeaths.coviddeaths D
JOIN CovidVaccinations.covidvaccinations V
USING (date,location)
WHERE D.continent <> ""
ORDER BY D.continent AND D.location;


-- 11) Contries with vaccinations per population
WITH Pop_per_VAC (Continent, Location, Date, Population, New_vaccination, Cumulative_vaccinations)
AS
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
       SUM(CONVERT(V.new_vaccinations , SIGNED INT)) OVER 
       (PARTITION BY V.location ORDER BY D.location, D.date) AS Cumulative_vaccinations
FROM CovidDeaths.coviddeaths D
JOIN CovidVaccinations.covidvaccinations V
ON D.date=V.date AND D.location=V.location
WHERE D.continent <> ""
ORDER BY D.continent AND D.location
)
SELECT *, (Cumulative_vaccinations/Population)*100 AS Vaccination_percentage
FROM Pop_per_VAC;

-- 12) Copy a Table from  CovidVaccinations_db to CovidDeaths_db
CREATE TABLE CovidDeaths.covidvaccinations 
LIKE CovidVaccinations.covidvaccinations;
INSERT CovidDeaths.covidvaccinations
SELECT *
FROM CovidVaccinations.covidvaccinations;

-- 13) Create view total vaccination
CREATE VIEW TotalVaccination AS
SELECT D.continent, D.location, D.date, V.new_vaccinations,
       SUM(CONVERT(V.new_vaccinations , SIGNED INT)) OVER 
       (PARTITION BY V.location ORDER BY D.location, D.date) AS Cumulative_vaccinations
FROM CovidDeaths.coviddeaths D
JOIN CovidVaccinations.covidvaccinations V
ON D.date=V.date AND D.location=V.location
WHERE D.continent <> ""






















