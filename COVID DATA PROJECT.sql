SELECT * FROM PortfolioProject..[COVID DEATHS]
WHERE continent IS NOT NULL
ORDER BY location, date

--SELECT * FROM [COVID VACCINATIONS]
--ORDER BY location, date

--Selecting data I am using.

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..[COVID DEATHS]
WHERE continent IS NOT NULL
ORDER BY location, date

--Looing at Total Cases vs Population in USA
--Shows what percentage of population got covid

SELECT location, date, Population, total_cases, (total_cases/Population)*100 AS DeathPercentage
FROM PortfolioProject..[COVID DEATHS]
WHERE location LIKE 'United States' AND continent IS NOT NULL
ORDER BY location, date

--Countries with Highest Infection Rate compared to Population

SELECT location, Population, MAX(total_cases) AS HighestInfection_Count, MAX((total_cases/Population))*100 AS PercentPopulationInfected
FROM PortfolioProject..[COVID DEATHS]
--WHERE location LIKE 'United States'
GROUP BY location, Population
ORDER BY PercentPopulationInfected DESC

--Showing countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeaths_Count
FROM PortfolioProject..[COVID DEATHS]
--WHERE location LIKE 'United States'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeaths_Count DESC



--LET'S BREAK THINGS DOWN BY CONTINENT
--Continents with Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeaths_Count
FROM PortfolioProject..[COVID DEATHS]
--WHERE location LIKE 'United States'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths_Count DESC


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS TOTAL_CASES , SUM(CAST(new_deaths AS INT)) AS TOTAL_DEATHS, SUM(CAST(new_deaths AS INT))/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject..[COVID DEATHS]
--WHERE location LIKE 'United States' 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..[COVID DEATHS] dea 
JOIN PortfolioProject..[COVID VACCINATIONS] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS  NOT NULL
ORDER BY 1,2,3


-- USE CTE
WITH POPvsVAC (continent, date,location, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..[COVID DEATHS] dea 
JOIN PortfolioProject..[COVID VACCINATIONS] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS  NOT NULL
--ORDER BY 1,2,3
)
SELECT * ,(RollingPeopleVaccinated/population)*100 AS
FROM POPvsVAC


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR (255),
location NVARCHAR (255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..[COVID DEATHS] dea 
JOIN PortfolioProject..[COVID VACCINATIONS] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS  NOT NULL
--ORDER BY 1,2,3

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated


--Create view to store data for data visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..[COVID DEATHS] dea 
JOIN PortfolioProject..[COVID VACCINATIONS] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS  NOT NULL
--ORDER BY 1,2,3

SELECT * FROM PercentPeopleVaccinated




