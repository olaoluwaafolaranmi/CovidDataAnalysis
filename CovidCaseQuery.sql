--SELECT TOP (1000) [iso_code]
--      ,[continent]
--      ,[location]
--      ,[date]
--      ,[total_cases]
--      ,[population]
--      ,[new_cases]
--      ,[new_cases_smoothed]
--      ,[total_deaths]
--      ,[new_deaths]
--      ,[new_deaths_smoothed]
--      ,[total_cases_per_million]
--      ,[new_cases_per_million]
--      ,[new_cases_smoothed_per_million]
--      ,[total_deaths_per_million]
--      ,[new_deaths_per_million]
--      ,[new_deaths_smoothed_per_million]
--      ,[reproduction_rate]
--      ,[icu_patients]
--      ,[icu_patients_per_million]
--      ,[hosp_patients]
--      ,[hosp_patients_per_million]
--      ,[weekly_icu_admissions]
--      ,[weekly_icu_admissions_per_million]
--      ,[weekly_hosp_admissions]
--      ,[weekly_hosp_admissions_per_million]
--  FROM [PortfolioProject].[dbo].[CovidDeaths]



--observing the percentage of people that died after testing positive to covid
--showing the likelihood of dying after contracting the virus

SELECT location, date, population, total_cases,total_deaths, ROUND((CAST(total_deaths as decimal)/CAST(total_cases as decimal))*100 , 2) AS DeathPercentage
From CovidDeaths
Order by 1,2


--observing Total cases vs population
--showing the percentage of the population that got covid
SELECT location, date, population, total_cases, ROUND((CAST(total_cases as decimal)/CAST(population as decimal))*100 , 7) AS InfectionRate
From CovidDeaths
Order by 1,2


-- looking at countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS MaxInfectionCount, MAX(ROUND((CAST(total_cases as decimal)/CAST(population as decimal))*100 , 7)) AS MaxInfectionRate
From CovidDeaths
Group by location, population
--HAVING population > 100000000
Order by MaxInfectionRate DESC


--showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From CovidDeaths
Where continent is not null --to observe just the countries
Group by location
Order by TotalDeathCount DESC


------showing continents/other groupings with highest death count per population with correct data
--SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
--From CovidDeaths
--Where continent is null --to observe continents
--Group by location
--Order by TotalDeathCount DESC



--showing continents with highest death count per population (for visualization sake)
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From CovidDeaths
Where continent is not null --to observe just the countries
Group by continent
Order by TotalDeathCount DESC


--Exploration on global numbers

select date, SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_death--, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

--join covid death table to the vaccination table and observe the total population vs vaccinations

--using cte so we can query on an aggregated column

with PopvsVac(continent, location, date, population, new_vaccination, CummulativeSumVaccination)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as CummulativeSumVaccination
FROM CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (CummulativeSumVaccination/population)*100
from PopvsVac


--create view for visualization

Create view PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as CummulativeSumVaccination
FROM CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

