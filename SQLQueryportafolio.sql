--select * 
--from PortfolioProject.dbo.coviddeaths$
--order by 3,4

--select *
--from PortfolioProject.dbo.Covidvaccinatios$
--order by 3,4

--Select the data that we are going to be using 


SELECT Location, date, Total_cases, new_cases, total_deaths, population
FROM PortfolioProject..coviddeaths$
order by 1,2 

-- Looking at total cases vs total death 
-- shows likelihood of dying if you contract covid in your country


--SELECT Location, date, Total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as Death_percentage
--FROM PortfolioProject..coviddeaths$
--Where location	like '%colombia%'
--order by 1,2

-- looling at the totals cases vs the population 

--SELECT Location, date, Total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as Infected_percentege
--FROM PortfolioProject..coviddeaths$
----Where location	like '%colombia%'
--order by 1,2

-- Looking at countries with highest infection rate compared to population

--SELECT Location, population, max(Total_cases) as Highest_infection_count , max(cast(total_cases as float)/cast(population as float))*100 as Infected_percentege
--FROM PortfolioProject..coviddeaths$
----Where location	like '%colombia%'
--group by location, population
--order by Infected_percentege desc

--Countries with the highest death count per population

--LET'S BREAKS THINGS DOWN BY CONTINENT 

--SELECT continent, max(cast(total_deaths as float)) as TotalDeathCount
--FROM PortfolioProject..coviddeaths$
----Where location	like '%colombia%'
--where continent is not  null
--group by continent
--order by TotalDeathCount desc

--Showing the continents with the highest death count by population 

--SELECT continent, max(cast(total_deaths as float)) as TotalDeathCount
--FROM PortfolioProject..coviddeaths$
----Where location	like '%colombia%'
--where continent is not  null
--group by continent
--order by TotalDeathCount desc

--Breaking global numbers

SELECT date, sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths, (sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as deathpercentage
FROM PortfolioProject..coviddeaths$
--Where location like '%colombia%'
Where cast(new_cases as float) > 0 and continent is not null
Group by date
order by 1,2

--loking total population vs vacination


--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--	SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, 
--	dea.date) as RollingPeopleVaccinated
--From PortfolioProject..coviddeaths$ dea
--Join PortfolioProject..Covidvaccinatios$ vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

With popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths$ dea
Join PortfolioProject..Covidvaccinatios$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100
from popvsvac
--USE CTE


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths$ dea
Join PortfolioProject..Covidvaccinatios$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *,(rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated

--create view for storage data for later visualization

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths$ dea
Join PortfolioProject..Covidvaccinatios$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 