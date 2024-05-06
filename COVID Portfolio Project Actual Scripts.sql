--select * from CovidDeaths order by 2 desc
--select count(*) from CovidVaccinations

-- Select Data that we're going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population  
FROM CovidDeaths
ORDER BY 1, 2 

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths*100/total_cases) AS DeathPercentage
FROM CovidDeaths WHERE location LIKE '%saudi%'
ORDER BY 1, 2 DESC

-- Looking at total cases vs population
-- Shows what % of population got covid
SELECT location, date, total_cases, population, (total_cases*100/population) AS PercentPopulationInfected
FROM CovidDeaths WHERE location LIKE '%Lebanon'
ORDER BY 1, 2 DESC

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX(total_cases*100/population) AS PercentPopulationInfected
FROM CovidDeaths 
--WHERE location LIKE '%states'
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC

-- Showing countries with highest death count per population
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount, 
ROUND(MAX(CAST(total_deaths AS INT)*100/population), 2) AS PercentPopulationDied
FROM CovidDeaths 
--WHERE location LIKE '%states'
GROUP BY population, location
ORDER BY 3 DESC, PercentPopulationDied DESC

-- Showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Break things down by continent
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

SELECT location, FORMAT(TDC, '#,##0') AS TotalDeathCount 
FROM (
	SELECT location, MAX(CAST(total_deaths AS INT)) AS TDC
	FROM CovidDeaths 
	WHERE continent IS NULL
	GROUP BY location
) AS SubQuery
ORDER BY TDC DESC

-- Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
SUM(CAST(new_deaths AS INT))*100/SUM(new_cases) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

SELECT FORMAT(SUM(new_cases), '#,##0') AS total_cases, 
FORMAT(SUM(CAST(new_deaths AS INT)), '#,##0') AS total_deaths, 
SUM(CAST(new_deaths AS INT))*100/SUM(new_cases) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1


-- Looking at total population vs vaccination

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
FROM CovidVaccinations cv JOIN CovidDeaths cd
ON cv.location = cd.location AND cv.date = cd.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3

SELECT CAST(MAX(new_vaccinations) AS INT) AS mnv , cv.location FROM 
CovidVaccinations cv JOIN CovidDeaths cd 
ON cd.date = cv.date AND cv.location = cd.location
WHERE cd.continent IS NOT NULL
GROUP BY cv.location
ORDER BY mnv DESC

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
FORMAT(
SUM(
CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cv.location ORDER BY cv.location, cv.date),
'#,##0') AS RollingTotalVax
FROM CovidVaccinations cv JOIN CovidDeaths cd
ON cv.location = cd.location AND cv.date = cd.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3

-- USE CTE
WITH PopVsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(INT, cv.new_vaccinations)) 
OVER(PARTITION BY cv.location ORDER BY cv.location, cv.date) AS RollingPeopleVaccinated 
FROM CovidDeaths cd JOIN CovidVaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentVaccinated FROM PopVsVac


-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(INT, cv.new_vaccinations)) 
OVER(PARTITION BY cv.location ORDER BY cv.location, cv.date) AS RollingPeopleVaccinated 
FROM CovidDeaths cd JOIN CovidVaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentVaccinated FROM #PercentPopulationVaccinated


-- VIEWS
CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(INT, cv.new_vaccinations)) 
OVER(PARTITION BY cv.location ORDER BY cv.location, cv.date) AS RollingPeopleVaccinated 
FROM CovidDeaths cd JOIN CovidVaccinations cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
--ORDER BY 2, 3

SELECT * FROM PercentPopulationVaccinated