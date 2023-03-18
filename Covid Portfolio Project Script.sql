SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
Order by 3, 4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order by 3, 4 

-- Select Data that we are going to using.

SELECT location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1, 2


-- Looking at Total Cased vs Total Deaths
-- Shows likelihood of dying if you contract Coivd in your country

Select location, date, total_cases, total_deaths, (cast(total_deaths as decimal)/total_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths
where location like '%india%' and continent is not null
order by 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population god Covid

Select location, date, population, total_cases, (cast(total_cases as decimal)/population)*100 as percentofpopulationinfected
FROM PortfolioProject..CovidDeaths
--where location like '%india%'
order by 1, 2


-- Looking at countries with highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionRate, 
(max(cast(total_cases as decimal)/population))*100 as percentofpopulationinfected
FROM PortfolioProject..CovidDeaths
--where location like '%india%'
group by location, population
order by percentofpopulationinfected desc


-- Showing countries with Highest Death Count per Population

Select location, max(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc


-- Let's Break Things Down By Continent

-- Showing continents with highest death count per population

Select continent, max(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Creating View

Create View DeathCountPerContinent as
Select continent, max(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
--order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as decimal))/SUM(new_cases)*100 as DeathPercentage --, total_deaths, (cast(total_deaths as decimal)/total_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths
--where location like '%india%' and 
where continent is not null
--Group By date
order by 1, 2


-- Looking at Total Population vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) 
OVER (Partition By d.location Order By d.location, d.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/d.population)*100 
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location and d.date = v.date
where d.continent is not null
order by 2, 3


-- Use CTE

With PopsvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) 
OVER (Partition By d.location Order By d.location, d.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/d.population)*100 
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/cast(population as decimal))*100
From PopsvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) 
OVER (Partition By d.location Order By d.location, d.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/d.population)*100 
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location and d.date = v.date
where d.continent is not null
order by 2, 3

Select *, (RollingPeopleVaccinated/cast(population as decimal))*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) 
OVER (Partition By d.location Order By d.location, d.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/d.population)*100 
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2, 3

SELECT *
FROM PercentPopulationVaccinated