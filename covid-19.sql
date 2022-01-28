--select all the data
SELECT *
FROM dbo.[covid-deaths]


SELECT *
FROM dbo.[covid-vaccination]

--total deaths vs total cases

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percentage
FROM dbo.[covid-deaths]
where location like '%desh%'
order by date

--total cases vs populations

SELECT location,date,total_cases,population,(total_cases/population)*100 as affected_percentange
from dbo.[covid-deaths]
where location like '%desh%'
order by date


--Highest infections rate compare to populatons
SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as affected_percentange
from dbo.[covid-deaths]
Group by location,population
order by affected_percentange desc

--Highest deaths rate per populations
SELECT location,MAX(cast(total_deaths as int)) as HighestDeathCount--,MAX((total_deaths/population))*100 as deaths_percentange
from dbo.[covid-deaths]
where continent is not null
Group by location
order by HighestDeathCount desc

--Highest death rate per continent
select continent, MAX(CAST(total_deaths as int)) as HighestDeathCount
from dbo.[covid-deaths]
where continent is not null
group by continent
order by HighestDeathCount  desc

--global number

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from dbo.[covid-deaths]
where continent is not null

--corona update in bangladesh
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death,
SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
from dbo.[covid-deaths]
where location like '%desh%'

--join two table
--total vaccinated in the world, --USe CTE
With vaccVSpop (continent,locaton,date,population,new_vaccinations,regular_vaccinations)
as(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint))  OVER (PARTITION BY dea.location Order By dea.location, dea.date) as regular_vaccinations
from dbo.[covid-deaths] dea
join dbo.[covid-vaccination] vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null)
SELECT *,(regular_vaccinations/population)*100 as vacc_percentange
from vaccVSpop


--TEMP table
Drop table if exists VaccinationsPercentange
CREATE table VaccinationsPercentange
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
regular_vaccinations numeric
)

Insert into VaccinationsPercentange
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint))  OVER (PARTITION BY dea.location Order By dea.location, dea.date) as regular_vaccinations
from dbo.[covid-deaths] dea
join dbo.[covid-vaccination] vac
	on dea.location= vac.location
	and dea.date = vac.date
--where dea.continent is not null

SELECT *,(regular_vaccinations/population)*100 as vacc_percentange
from VaccinationsPercentange

--creating view
Create View vaccPercentange as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint))  OVER (PARTITION BY dea.location Order By dea.location, dea.date) as regular_vaccinations
from dbo.[covid-deaths] dea
join dbo.[covid-vaccination] vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
