Select*
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--Select*
--From PortfolioProject..CovidVaccinations$
--Where continent is not null
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2


-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contracted covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%kingdom%' and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows percentage of population that contracted covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%kingdom%' and continent is not null
order by 1,2
 

 --Looking at countries with Highest Infection Rate in comparason to Population

Select Location, Population, 
MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%kingdom%' and continent is not null
Group by Location, Population
order by PercentPopulationInfected desc



--Showing Countries with the Highest Death Count per Population

Select Location, 
MAX(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%kingdom%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT

--Showing the Continents with the Highest Death count per population
Select continent, 
MAX(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%kingdom%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
--Group by date
order by 1,2



--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)
Select*, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated  
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
order by 2, 3

Select*, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated  
From #PercentPopulationVaccinated


-- Creating View to store data for later

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3