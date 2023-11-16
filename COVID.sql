-- Select Data that we are going to be starting with

Select *
From CovidDeaths

Select * 
From CovidVaccinations


-- Total Deaths Percentage in Egypt

Select Location, date, total_cases,total_deaths, Round((total_deaths/total_cases)*100,2) as Death_Percentage
From CovidDeaths
Where location = 'Egypt'
order by  date


-- Total Population Infected Percentage in Egypt

Select Location, date, Population, total_cases, Round((total_cases/population)*100,2) as Population_Infected_Percentage
From PortfolioProject..CovidDeaths
Where location = 'Egypt'
order by  date


-- Countries with Highest Infection Rate

Select location , population , MAX(total_cases) AS Highest_Infection_Count , Round(Max((total_cases/population))*100,2) AS Percentage_Population_Infected
From CovidDeaths
GROUP BY location , population 
ORDER BY Percentage_Population_Infected DESC


-- Continents with Highest Infection Rate

Select continent , MAX(total_cases) AS Highest_Infection_Count , Round(Max((total_cases/population))*100,2) AS Percentage_Population_Infected
From CovidDeaths
GROUP BY continent  
Having continent is not null
ORDER BY Percentage_Population_Infected DESC


-- Countries with Highest Death Rate

Select location , population , MAX(cast(Total_deaths as int)) AS Total_Death_Rate 
From CovidDeaths
where continent is not null
GROUP BY location , population
ORDER BY Total_Death_Rate DESC 


-- Continent with Highest Death Rate

Select continent , MAX(cast(Total_deaths as int)) AS Total_Death_Rate , ROUND(MAX(total_deaths / population)*100,2) AS Percentage_Population_Death 
From CovidDeaths
GROUP BY continent  
Having continent is not null
ORDER BY Percentage_Population_Death DESC


-- Global Number

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, round(SUM(cast(new_deaths as int))/SUM(New_Cases)*100,2) as Death_Percentage
From CovidDeaths
where continent is not null  
--and location = 'Egypt'
--Group By date
--order by date


-- Total Population vs vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations AS int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths AS dea
Join CovidVaccinations AS vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by dea.location, dea.date


--Temp Table to perform Calculation Percentage of Population that haveing Vaccine

Create Table #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations AS int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From CovidDeaths AS dea
Join CovidVaccinations AS vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100 AS Percentage_Population_Vaccinated
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View Percent_Pop_Vac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations AS int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

