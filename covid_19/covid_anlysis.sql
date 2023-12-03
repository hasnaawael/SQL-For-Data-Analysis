USE covid;

-- Let's see all the data
Select *
From coviddeathss;
Select *
From covidvaccinationss;

-- Select Data that we are going to be starting with
Select location, date, total_cases, new_cases, total_deaths, population
 From coviddeathss 
 Where continent is not null ;

-- Let's see Total Cases vs Total Deaths
Select location, date, total_cases,total_deaths, 
    (total_deaths/total_cases)*100 as DeathPercentage
From coviddeathss
Where continent is not null;

-- Shows what percentage of population infected with Covid
Select location, date, Population, total_cases, 
    (total_cases/population)*100 as PercentPopulationInfected
From coviddeathss;

-- Countries with Highest Infection Rate compared to Population
Select 
	location, 
    Population, 
    MAX(total_cases) as HighestInfectionCount,
    Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeathss 
Group by Location, Population 
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population
Select 
    location,
    MAX(total_deaths) as TotalDeathCount
From coviddeathss
Where continent is not null 
Group by Location
order by TotalDeathCount desc; 

-- Showing contintents with the highest death count per population
Select
	continent,
    MAX(Total_deaths) as TotalDeathCount
From coviddeathss
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS
SELECT
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths,
    SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases) * 100 AS DeathPercentage
FROM
    coviddeathss
WHERE
    continent IS NOT NULL;

-- Shows information about COVID-19 deaths and vaccinations from two tables
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS SIGNED))
-- The "OVER" clause is used to specify the window or partition over which the sum is calculated
OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From coviddeathss dea
Join covidvaccinationss vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;





