SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Order BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in United States country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage  
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1, 2


--Looking at the Total Cases vs Population
--Shows what percentage of population got COVID

SELECT location, date,  population, total_cases, (total_cases/population)*100 as PercentPopulationInfected  
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'AND continent IS NOT NULL
ORDER BY 1, 2


--Looking at Countries with Highest infections Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected  
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC


--Showing Countries with Highest Deaths Count per Population

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathsCount  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY TotalDeathsCount DESC 


--Let's break things down by continent
--Showing Continents with Highest Deaths Count

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathsCount  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathsCount DESC 


--Global Numbers

SELECT SUM(new_cases)as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths,
 SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2


--Looking at the Total Population vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location ORDER BY 
dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


--USE CTE

WITH "CTE-PopvsVac" (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)  
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location ORDER BY 
dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM "CTE-PopvsVac"


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location ORDER BY 
dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated 


--Creating Views to store data for later visualization
-- View PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location ORDER BY 
dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


--View DeathPercentageInUnitedStates

CREATE VIEW DeathPercentageInUnitedStates AS 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage  
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL



--View PercentPopulationInfectedInUnitedStates

CREATE VIEW PercentPopulationInfectedInUnitedStates AS
SELECT location, date,  population, total_cases, (total_cases/population)*100 as PercentPopulationInfected  
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'AND continent IS NOT NULL


--View HighestPercentPopulationInfected  

CREATE VIEW PercentPopulationInfected AS 
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected  
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population 


--View TotalDeathsCount  
CREATE VIEW TotalDeathsCount AS 
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathsCount  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location 


--View TotalDeathsCountPerContinent

CREATE VIEW TotalDeathsCountPerContinent AS
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathsCount  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 


--View GlobalNumbers 

CREATE VIEW GlobalNumbers AS  
SELECT SUM(new_cases)as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths,
 SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL




