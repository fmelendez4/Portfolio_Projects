SELECT *
FROM Portfolio_Project.dbo.CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM Portfolio_Project.dbo.CovidVaccinations
--order by 3,4

--#selected data to be used next

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows liklihood of death if contracted covid in particular country

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
FROM Portfolio_Project..CovidDeaths
WHERE location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
-- The following shows what percentage of population got covid

SELECT location, date, population, total_cases,(total_cases/population)*100 as Death_Percentage
FROM Portfolio_Project..CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
FROM Portfolio_Project..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
order by Percent_Population_Infected desc

-- Showing countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Portfolio_Project..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
order by Total_Death_Count desc

--Breaking things down by continent

SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Portfolio_Project..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
order by Total_Death_Count desc

-- GLOBAL NUMBERS
-- Sum of new cases every day throughout the world

SELECT date, SUM(new_cases) --, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2

-- Sum of new cases and deaths every day throughout the world

SELECT date, SUM(new_cases), SUM(new_deaths) --, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2

-- Encourterd issue with the code becaause the new_deaths data type is a nvarchar, so I'm casting it as an integer

SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)) --, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2

-- Adding percentage column to the same query and naming columns

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2

-- Total numbers from start of Covid from January 2020 to April 30, 2021

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
order by 1,2

-- Joining Covid Deaths and Covid Vaccinations tables

SELECT *
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Looking at Total Population vs Total Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
	order by 2, 3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_people_Vaccinated
--, (Rolling_people_Vaccinated/population)*100
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
	order by 2, 3

-- Using a CTE (common table expression)

With Pop_vs_Vac (Continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_people_Vaccinated
--, (Rolling_people_Vaccinated/population)*100
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
	--order by 2, 3
)
SELECT *
FROM Pop_vs_Vac

-- Finding percentage of rolling population vaccinated

With Pop_vs_Vac (Continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_people_Vaccinated
--, (Rolling_people_Vaccinated/population)*100
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
	--order by 2, 3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM Pop_vs_Vac

-- Creating View to store data for visulizations

CREATE VIEW Percent_Population_Vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_people_Vaccinated
--, (Rolling_people_Vaccinated/population)*100
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
	--order by 2, 3
