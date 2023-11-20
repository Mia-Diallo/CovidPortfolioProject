select*
from CovidPortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

select Location, date, total_cases, new_cases, total_deaths, population
from CovidPortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your Country--
select Location, date, total_cases, total_deaths, 
(convert(float, total_deaths) /nullif(convert(float,total_cases),0))*100 as Deathpercentage
from CovidPortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1, 2


--Total cases vs Population
--Shows what percentage of population infected got Covid--

select Location, date, population, total_cases, 
(convert(float, total_cases) /nullif(convert(float,population),0))*100 as PercentPopulatedInfected
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
order by 1, 2


--Countries with highest infection rate compared to population--

select Location, population, max(cast(total_cases as int)) as HighestInfectionCount, 
max((convert(float, total_cases) /nullif(convert(float,population),0)))*100 as PercentPopulatedInfected
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulatedInfected desc

--Countries with highest death count per population--

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT--

--Showing continents with the highest death count per population--

select continent, max(cast(total_deaths as int)) as TotalDeathCount 
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers--

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Total Population vs Vaccinations--
--Shows Percentage of Population that has received at least on Covid Vaccine--

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 