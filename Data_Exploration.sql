/*
Covid 19 Data Exploration 
Skills used: Basic select, Windows Functions, Aggregate Functions, Joins, CTE's, Temp Tables, Creating Views, Converting Data Types.
*/


select * 
from PortfolioProject..CovidVaccinations
order by 3,4


-- BREAKING THINGS DOWN BY LOCATION

select *
from PortfolioProject..CovidDeaths
where continent is not null

select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1

--Total cases vs total deaths
--chance of dying if contracts covid in india 
select Location,date,total_cases,new_cases,total_deaths,round((total_deaths/total_cases)*100,2) as deathpercentage
from PortfolioProject..CovidDeaths
where location like '%India%' and continent is not null

--Total cases vs population
--what % of population got covid
select Location,total_cases,population,round((total_cases/population)*100,2) as covidpercentage
from PortfolioProject..CovidDeaths
where continent is not null

--Infection rate per location compared to population
select Location,Population,max(total_cases) as Highinfection_count,round(max((total_cases/population))*100,2) as infectedpercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by Location,population
order by infectedpercentage desc

--Location with highest death rate per population
select Location,population,max(total_deaths) as HighDeath_count,round(max((total_deaths/population))*100,2) as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by deathpercentage desc

--Location with highest death count per population
select Location,max(total_deaths) as totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc


-- BREAKING THINGS DOWN BY CONTINENT
select continent,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc

--total continents : 6

--global numbers
--new cases
--casting new_deaths into int because it is of varchar datatype in dataset.
select date,sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date

--gives total numbers
select sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null

--Joining both the tables
select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date

--checking total population vs vaccinations
--total no of people in world that got vaccinated
--we can't use a newly created column in the query with in select 
--so using cte or we can use a temp table
with PopvsVac (continent,location,date,population,new_vaccinations,people_vaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,dea.new_vaccinations)) over(PARTITION by dea.location order by dea.location,dea.date) as people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,round((people_vaccinated/population)*100,4) as perofppvaccinated
from PopvsVac

--creating a view to store data for visualizations

create VIEW PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,dea.new_vaccinations)) over(PARTITION by dea.location order by dea.location,dea.date) as people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

--drop VIEW PercentPopulationVaccinated

select *
from PercentPopulationVaccinated
