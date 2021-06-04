select * from PortfolioProject..coviddeaths
where continent is not null
order by 3,4

--select * from PortfolioProject..covidvaccinations
--order by 3,4

--Select Data that we are going to be using
select location, date, total_cases_per_million, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
order by 1,2

--Looking at total cases vs total Deaths
--shows likelihood of dying if you contract covidin canada
	select location, date, total_cases_per_million, total_deaths,(total_deaths/total_cases_per_million)*100 as Deathpercentage
	from PortfolioProject..coviddeaths
	where location like '%anad%'
	order by 1,2
--looking at the total cases vs population
--shows what percentage of population got covid
select location, date, population, total_cases_per_million, (total_cases_per_million/population)*100 as Deathpercentage
	from PortfolioProject..coviddeaths
	where location like '%anad%'
	order by 1,2

--looking at countries with highest infection rate compared to population
select location, population, max(total_cases_per_million) as HighestInfectionCount, 
             max((total_cases_per_million/population)*100) as PercentPopulationInfected
	from PortfolioProject..coviddeaths
	--where location like '%anad%'
	group by location, population
	order by PercentPopulationInfected desc
--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
	from PortfolioProject..coviddeaths
	where continent is not null
	--where location like '%anad%'
	group by location
	order by TotalDeathCount desc
--lets break things down by continents

select continent, max(cast(total_deaths as int)) as TotalDeathCount
	from PortfolioProject..coviddeaths
	where continent is not null
	--where location like '%anad%'
	group by continent
	order by TotalDeathCount desc
--showing continents with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
	from PortfolioProject..coviddeaths
	where continent is not null
	--where location like '%anad%'
	group by continent
	order by TotalDeathCount desc

-- GLOBAL NUMBERS
	select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	       sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
		from PortfolioProject..coviddeaths
		where location like '%anad%'
		and continent is not null
		--group by date
		order by 1,2
--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
	as RollingPeopleVaccinated
from PortfolioProject ..coviddeaths dea
join PortfolioProject ..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3
-- USE CTE

with PopVsVac(continent, Location,date, population, New_vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
	as RollingPeopleVaccinated
from PortfolioProject ..coviddeaths dea
join PortfolioProject ..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
	select *, (RollingPeopleVaccinated/population)*100
	from PopVsVac

-- TEMP TABLE
drop table if exists #PERCENTPOPULATIONVACCINATED
Create table #PERCENTPOPULATIONVACCINATED
(
continent nVarchar(255),
Location nVarchar(255),
date datetime, 
population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PERCENTPOPULATIONVACCINATED
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
	as RollingPeopleVaccinated
from PortfolioProject ..coviddeaths dea
join PortfolioProject ..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

	select *, (RollingPeopleVaccinated/population)*100
	from #PERCENTPOPULATIONVACCINATED

-- creating view to store data for later visualizations

	Create view PERCENTPOPULATIONVACCINATED as 
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
	as RollingPeopleVaccinated
from PortfolioProject ..coviddeaths dea
join PortfolioProject ..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

	select * 
	from PERCENTPOPULATIONVACCINATED