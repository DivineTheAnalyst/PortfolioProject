Select *
From PortfolioProjects..CovidDeaths
where continent is not null
ORDER BY 3,4

--Select *
--From PortfolioProjects..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in Nigeria

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
Where location like '%nigeria%'
Order by 1,2



-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID 

SELECT location, date, population, total_cases,  (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location = 'Nigeria'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population


SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX ((total_cases/population))*100 AS InfectedPercentage
FROM PortfolioProjects..CovidDeaths
-- WHERE location = 'Nigeria'
GROUP by location, population
order by InfectedPercentage desc

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
-- WHERE location = 'Nigeria'
where continent is not null
GROUP by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT


 -- Showing continents with the highest death count per population

 SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
-- WHERE location = 'Nigeria'
where continent is not null
GROUP by continent --**
order by TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
--WHERE location = 'Nigeria'
where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations


Select *
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) Over (partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

----Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
----, SUM(CONVERT(INT, vac.new_vaccinations)) Over (partition by dea.location order by
----dea.location, dea.date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
----From PortfolioProjects..CovidDeaths dea
----Join PortfolioProjects..CovidVaccinations vac
----	ON dea.location = vac.location
----	and dea.date = vac.date
----where dea.continent is not null


-- USE CTE

With PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) Over (partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) Over (partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) *100
From #PercentagePopulationVaccinated


-- Creating View to Store Data for Later Visualisations

USE PortfolioProjects
GO
Create View PercentagesOfPopulationIsVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) Over (partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentagesOfPopulationIsVaccinated