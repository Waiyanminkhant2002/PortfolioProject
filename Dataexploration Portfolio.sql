--Covid-19 Data Exploration--
--Skill used= joins,CTE, Temptables, WindowFunctions , Aggregate functions , Creating views , Converting data types

Select*from Portfolioproject..CovidDeaths
where continent is not null
order by 3,4

--selecting data I will start with
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

--Total cases vs total deaths(Death_percentage_in_cases) In Myanmar
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Myanmar%'
and continent is not null 
order by 1,2

--Total deaths vs population(Deaths_percentage_in_population) In Myanmar
Select Location, date,population, total_deaths, (total_deaths/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Myanmar%'
and continent is not null 
order by 1,2

--Total cases vs population(Cases_percentage_in_population) In Myanmar
Select Location, date,population, total_cases, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Myanmar%'
and continent is not null 
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select location,population,Max(total_cases) as High_infection_count ,Max((total_cases/population))*100 as High_infection_Percentage
from Portfolioproject..CovidDeaths
group by location,population
order by High_infection_Percentage desc 


--look for the country which has infection rate per population
select location,population,Max(total_cases) as High_infection_count ,Max((total_cases/population))*100 as High_infection_Percentage
from Portfolioproject..CovidDeaths
Where location like '%Myanmar%'
group by location,population
order by High_infection_Percentage desc , Max(total_cases) desc , Max(population) desc

-- Countries with Highest Death Count per Population

Select Location,population, MAX(cast(Total_deaths as int)) as TotalDeaths , (Max(cast(Total_deaths as int))/population)*100 as Death_percentage_per_population
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location, population
order by TotalDeaths desc  , Death_percentage_per_population desc


-- Showing Regions(contintent) with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeaths
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeaths desc

-- GLOBAL NUMBERS

Select Sum(population) as Worldpopulation,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine in Regions

Select dea.continent,  dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Shows Population that has recieved at least one Covid Vaccine in countries

Select dea.location,  dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Total_Vaccinated_People
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where vac.new_vaccinations is not null


-- Using CTE to perform Calculation on Partition By in previous query

With PopulationVsVaccinations ( Location,Continent, Date, Population, New_Vaccinations, Total_Vaccinated_People)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Total_Vaccinated_People
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and vac.new_vaccinations is not null
)
Select *, (Total_Vaccinated_People/Population)*100 as Vaccinated_persantage_of_population
From PopulationVsVaccinations



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_Vaccinated_People numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Total_Vaccinated_People
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (Total_Vaccinated_People/Population)*100 as Vaccinated_persantage_of_population
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
