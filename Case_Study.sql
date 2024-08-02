
--renamed original column 'location' in dataset as 'country'

select country,date,total_cases,new_cases,total_deaths,population
from Project..CovidDeaths
where continent is not null
order by 1

-- 1.BREAKING THINGS DOWN BY country

-- Total distinct countries
select COUNT(distinct country) as no_of_countries
from Project..CovidDeaths


--Total cases vs total deaths | chance of dying if covid contracts in a country.

select country,date,total_cases,new_cases,total_deaths,round((total_deaths/total_cases)*100,2) as death_percentage
from Project..CovidDeaths
where country like '%India%' and continent is not null


--Total cases vs population | % of population who got covid

select country,date,total_cases,population,round((total_cases/population)*100,2) as covid_percentage
from Project..CovidDeaths
where continent is not null


--average no of new cases in a country per day

select country,date,avg(cast(new_cases as int)) as average_cases
from Project..CovidDeaths
where continent is not null
group by country,date
order by country,average_cases desc


--countries with highest Infection rate compared to population

select country,Population,max(total_cases) as Highinfection_count,round(max(total_cases)/population*100,2) as infected_percentage
from Project..CovidDeaths
where continent is not null --and country like '%India%'
group by country,population
order by infected_percentage desc


--countries with highest death rate compared to population

select country,population,max(total_deaths) as HighDeath_count,round(max(total_deaths)/population*100,2) as death_percentage
from Project..CovidDeaths
where continent is not null
group by country,population
order by death_percentage desc


--country with highest death count compared to population

select country,max(total_deaths) as total_deathcount
from Project..CovidDeaths
where continent is not null
group by country
order by total_deathcount desc


-- 2.BREAKING THINGS DOWN BY CONTINENT

--total distinct continents
select COUNT(distinct continent) as no_of_continents
from Project..CovidDeaths


--continent with highest death count

select continent,max(cast(total_deaths as int)) as total_deathcount
from Project..CovidDeaths
where continent is not null
group by continent
order by total_deathcount desc


--New cases vs New deaths | death percentage for each date with new cases and new deaths.

select date,sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths,round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as death_percentage
from Project..CovidDeaths
where continent is not null
group by date


--world wide death percentage

select sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths,round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as death_percentage
from Project..CovidDeaths
where continent is not null


/*select country,ISNULL(round(sum(new_cases_per_million),2),0) as new_cases_per_million
from Project..CovidDeaths
group by country
order by new_cases_per_million desc*/


--Joining both the tables
select * 
from Project..CovidDeaths dea
join Project..CovidVaccinations vac
on dea.country=vac.country
and dea.date=vac.date


--Total population vs vaccinations | total no of people in world that got vaccinated

with PopvsVac (continent,country,date,population,new_vaccinations,people_vaccinated)
as 
(
select dea.continent,dea.country,dea.date,dea.population,ISNULL(vac.new_vaccinations,0) as new_vaccination,
ISNULL(sum(convert(int,dea.new_vaccinations)) over(PARTITION by dea.country order by dea.country,dea.date),0) as people_vaccinated
from Project..CovidDeaths dea
join Project..CovidVaccinations vac
on dea.country=vac.country
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,round((people_vaccinated/population)*100,4) as percent_of_people_vaccinated
from PopvsVac


--ranking countries in a continent wrt total cases
--country with highest no of cases in a continent

with ranking_cte as
(
select continent,country,ISNULL(SUM(total_cases),0) as cases,
ROW_NUMBER() over(Partition by continent order by SUM(total_cases) desc) as rnk
from Project..CovidDeaths
where continent is not null
group by continent,country
)
select continent,country,cases
from ranking_cte
where rnk=1
