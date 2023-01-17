/****** Script for SelectTopNRows command from SSMS  ******/
SELECT Location, date, total_cases, new_cases,
total_deaths, population
FROM
	PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of a person diying they contact covid

SELECT Location, date, total_cases, 
total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 as DearthPercentage
FROM
	PortfolioProject..CovidDeaths
where Location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Population
-- % That got COvid
SELECT Location, date,population, total_cases, 
 (CAST(total_cases AS float)/CAST(population AS float))*100 as InfectionPercentage
FROM
	PortfolioProject..CovidDeaths
where Location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2
-- countries with highest rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, 
 MAX((CAST(total_cases AS float)/CAST(population AS float)))*100 as PercentagePopulationInfected
FROM
	PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY 
	location, population
ORDER BY PercentagePopulationInfected DESC

-- sHOWING COUNTRIES WITH HIGHEST DEATH COUT PER POPULATION


SELECT 
	Location,  MAX(total_deaths) as TotalDeathCount
FROM
	PortfolioProject..CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	location
ORDER BY TotalDeathCount DESC

-- BREAKING BY CONTINET
-- Showing continents with highest death count per population 
SELECT 
	continent,  MAX(total_deaths) as TotalDeathCount
FROM
	PortfolioProject..CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS
-- Death percentage groupe by date
SELECT 
	date, SUM(new_cases) AS total_cases, SUM(new_deaths) as total_deaths,
	SUM(new_deaths)/SUM(CAST(new_cases AS float))*100 as DeathPercentage
FROM
	PortfolioProject..CovidDeaths
where  continent IS NOT NULL
GROUP BY
	date
ORDER BY 1,2
--- Total death percentage
SELECT 
	SUM(new_cases) AS total_cases, SUM(new_deaths) as total_deaths,
	SUM(new_deaths)/SUM(CAST(new_cases AS float))*100 as DeathPercentage
FROM
	PortfolioProject..CovidDeaths
where  continent IS NOT NULL

ORDER BY 1,2

--- Looking at Total Population vs Vaccinations
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT  
	dea.continent, dea.location, 
	dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) 
	OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM 
	PortfolioProject..CovidDeaths dea
JOIN 
	PortfolioProject..covidVaccinations vac
ON
	dea.location = vac.location
	and dea.date =vac.date
where  continent IS NOT NULL
)
SELECT *,(convert(FLOAT,
RollingPeopleVaccinated)/Population)*100 FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	continent nvarchar(255),
	Location nvarchar(255),
	Date date,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT  
	dea.continent, dea.location, 
	dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) 
	OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM 
	PortfolioProject..CovidDeaths dea
JOIN 
	PortfolioProject..covidVaccinations vac
ON
	dea.location = vac.location
	and dea.date =vac.date
where  continent IS NOT NULL
SELECT *,(convert(FLOAT,
RollingPeopleVaccinated)/Population)*100 FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualisation
CREATE VIEW PercentPopulationVaccinated AS
SELECT  
	dea.continent, dea.location, 
	dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) 
	OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM 
	PortfolioProject..CovidDeaths dea
JOIN 
	PortfolioProject..covidVaccinations vac
ON
	dea.location = vac.location
	and dea.date =vac.date
where  continent IS NOT NULL

 