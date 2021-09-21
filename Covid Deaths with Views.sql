USE [Portfolio-Covid]
GO

--Total Cases vs Total Deaths in the USA
SELECT [location]
      ,[date]
      ,[population]
      ,[total_cases]
      ,[total_deaths]
	  ,(total_deaths / total_cases) * 100 As DeathPercentage
  FROM [dbo].[covid-deaths]
  WHERE location LIKE '%states%'
  ORDER BY 1,2

GO

--Total Cases vs Population in the USA
SELECT [location]
      ,[date]
      ,[population]
      ,[total_cases]
	  ,(total_cases / population) * 100 As CasePop
  FROM [dbo].[covid-deaths]
  WHERE location LIKE '%states%'
  ORDER BY 1,2 DESC

  GO

--Highest infection rates per population
SELECT [location]
      ,[population]
      ,MAX(total_cases) as HighestCaseCount
	  ,MAX((total_cases) / population) * 100 as PercentPopInfected
  FROM [dbo].[covid-deaths]
  GROUP BY location, population
  ORDER BY PercentPopInfected DESC

  GO

--Highest death counts
SELECT [location]
      ,MAX(cast(total_deaths as int)) as TotalDeathCount
  FROM [dbo].[covid-deaths]
  WHERE continent IS NOT NULL
  GROUP BY location
  ORDER BY TotalDeathCount DESC

  GO

--Broken down by continent
SELECT location
      ,MAX(cast(total_deaths as int)) as TotalDeathCount
  FROM [dbo].[covid-deaths]
  WHERE continent IS NULL
  GROUP BY location
  ORDER BY TotalDeathCount DESC

  GO

-- Global Numbers
SELECT [date]
      ,SUM(new_cases) AS TotalCases
	  ,SUM(cast(new_deaths as int)) AS TotalDeaths
	  ,(SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 As PercentDeath
  FROM [dbo].[covid-deaths]
  WHERE continent IS NOT NULL
  GROUP BY date
  ORDER BY 1, 2

  GO

  --Total population vs total vax with CTE
  WITH PopVax (continent, location, date, population, new_vaccinations, RollingVax)
  AS
  (
  SELECT dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vax.new_vaccinations
		,SUM(CONVERT(int, vax.new_vaccinations)) OVER (PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS RollingVax
	FROM [dbo].[covid-deaths] dea
	JOIN [dbo].[covid-vax] vax
		ON dea.location = vax.location
		AND dea.date = vax.date
	WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingVax / population) * 100
	FROM PopVax
GO

-- Temp Table Example

DROP Table if exists #PecentPopulationVax 
CREATE Table #PecentPopulationVax
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVax numeric
)
INSERT INTO #PecentPopulationVax
	SELECT dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vax.new_vaccinations
		,SUM(CONVERT(int, vax.new_vaccinations)) OVER (PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS RollingVax
	FROM [dbo].[covid-deaths] dea
	JOIN [dbo].[covid-vax] vax
		ON dea.location = vax.location
		AND dea.date = vax.date
	WHERE dea.continent IS NOT NULL

SELECT *, (RollingVax / Population) * 100
	FROM #PecentPopulationVax

GO

-- Create Views for visualizations

CREATE VIEW PercentPopulationVaccinated AS
  SELECT dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vax.new_vaccinations
		,SUM(CONVERT(int, vax.new_vaccinations)) OVER (PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS RollingVax
	FROM [dbo].[covid-deaths] dea
	JOIN [dbo].[covid-vax] vax
		ON dea.location = vax.location
		AND dea.date = vax.date
	WHERE dea.continent IS NOT NULL

GO