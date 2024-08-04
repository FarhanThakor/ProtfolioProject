SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2




--Looking at Total Cases vs Total Deaths
SELECT 
    location, 
    date, 
    total_cases,  
    total_deaths, 
    CASE 
        WHEN total_cases > 0 THEN (total_deaths / total_cases) * 100 
        ELSE 0 
    END AS DeathPercentage
FROM 
    PortfolioProject..CovidDeaths
WHERE location = 'india'
ORDER BY 
    1,2

--Looking at Total cases vs Population

SELECT 
    location, 
    date,
	population,
    total_cases,  
	(total_cases / population)  * 100 as  DeathPercentage
FROM 
    PortfolioProject..CovidDeaths
WHERE location = 'india'
ORDER BY 
    1,2

-- Looking at contries with highest infection rate compared to population
SELECT 
    location, 
	population,
    max(total_cases) as HighestInfectionCount,  
	max((total_cases / population))  * 100 as  PercentagePopulationInfacted
FROM 
    PortfolioProject..CovidDeaths
--WHERE location = 'india'
GROUP BY 
	location, 
	population
ORDER BY 
    PercentagePopulationInfacted DESC

--Showing contries with the highest deaths per population

SELECT 
    location, 
    max(total_deaths) as TotalDeathCount  
FROM
	 PortfolioProject..CovidDeaths
WHERE
	continent is not null
GROUP BY	
	location
ORDER BY 
	TotalDeathCount	DESC


--By continent
SELECT 
    continent, 
    max(total_deaths) as TotalDeathCount  
FROM
	 PortfolioProject..CovidDeaths
WHERE
	continent is not null
GROUP BY	
	continent
ORDER BY 
	TotalDeathCount	DESC


--Looking at total population vs vactination

SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVatinations
	--,(RollingVatinations/population)*100
FROM 
	PortfolioProject..CovidDeaths dea
JOIN
	PortfolioProject..CovidVactinations vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null
ORDER BY
	2,3




--Use CTE
with PopsvsVac(continent,
	location,
	date, 
	population,
	new_vaccinations,
	RollingVaccinations)
as
(
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVatinations
	--,(RollingVaccinations/population)*100
FROM 
	PortfolioProject..CovidDeaths dea
JOIN
	PortfolioProject..CovidVactinations vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null
--ORDER BY
--	2,3
)
select * 
from PopsvsVac



--TEMP TABLE

CREATE TABLE #PercentntPopulationVaccinated
	(Continenet nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinations numeric)	


INSERT INTO #PercentntPopulationVaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinations
	--,(RollingPeopleVaccinations/population)*100
FROM 
	PortfolioProject..CovidDeaths dea
JOIN
	PortfolioProject..CovidVactinations vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent is not null
--ORDER BY
--	2,3

select * , (RollingPeopleVaccinations/population)*100
from #PercentntPopulationVaccinated


-- Drop the existing view if it exists
IF OBJECT_ID('PercentntPopulationVaccinated', 'V') IS NOT NULL
DROP VIEW PercentntPopulationVaccinated;
GO

-- Create the new view
CREATE VIEW PercentntPopulationVaccinated AS 
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinations,
    (SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / dea.population) * 100 AS PercentPopulationVaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN
    PortfolioProject..CovidVactinations vac
ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;
