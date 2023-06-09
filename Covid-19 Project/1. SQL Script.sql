USE covid_data;
SELECT * FROM covid_deaths;
SELECT * FROM covid_vaccinations;

--Correcting imported datatypes
ALTER TABLE covid_deaths
ALTER COLUMN total_cases FLOAT;

ALTER TABLE covid_deaths
ALTER COLUMN total_deaths FLOAT;

ALTER TABLE covid_vaccinations
ALTER COLUMN new_vaccinations FLOAT;

ALTER TABLE covid_vaccinations
ALTER COLUMN total_vaccinations FLOAT;

ALTER TABLE covid_vaccinations
ALTER COLUMN people_vaccinated FLOAT;

ALTER TABLE covid_vaccinations
ALTER COLUMN people_fully_vaccinated FLOAT;

--The data that will be explored
SELECT continent, location, date, population, new_cases, total_cases, new_deaths, total_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2,3;

SELECT continent, location, date, new_vaccinations, total_vaccinations, people_vaccinated, people_fully_vaccinated
FROM covid_vaccinations
WHERE continent IS NOT NULL
ORDER BY 1,2,3;

--Total cases, total deaths, infection rate, death rate, fatality rate, per location
SELECT continent, location, date, population, total_cases, total_deaths,
	   (total_cases/population)*100 AS infection_rate,
	   (total_deaths/population)*100 AS death_rate,
	   (total_deaths/total_cases)*100 AS fatality_rate
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2,3;

--Continents with most cases and deaths
SELECT continent, MAX(total_cases) AS TotalCases, MAX(total_deaths) AS TotalDeaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 3 DESC;

--Countries with most cases and deaths
SELECT location, MAX(total_cases) AS TotalCases, MAX(total_deaths) AS TotalDeaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 3 DESC;

----Countries with the most infection rate
SELECT location, MAX((total_cases/population)*100) AS infection_rate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

--Countries with most death rate per population
SELECT location, MAX((total_deaths/population)*100) AS death_rate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

--Countries with most fatality rate
SELECT location, MAX((total_deaths/total_cases)*100) AS fatality_rate
FROM covid_deaths
WHERE continent IS NOT NULL AND total_cases >= 1000
GROUP BY location
ORDER BY 2 DESC

-- Daily Global Numbers
SELECT date, SUM(new_cases) AS global_new_cases, SUM(new_deaths) AS global_new_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;


-- Adding Vaccinations to the data
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	   cv.total_vaccinations, cv.people_vaccinated, cv.people_fully_vaccinated
FROM covid_deaths cd
JOIN covid_vaccinations cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 1,2,3;

-- Vaccination Rates per population
SELECT cv.continent, cv.location, cv.date, cd.population, cv.new_vaccinations, cv.total_vaccinations, 
	   cv.people_vaccinated, cv.people_fully_vaccinated,
	   (people_vaccinated/population)*100 AS vaccination_percent,
	   (people_fully_vaccinated/population)*100 AS full_vaccination_percent,
	   (people_fully_vaccinated/people_vaccinated)*100 AS vac_completion_percent
FROM covid_vaccinations cv
JOIN covid_deaths cd
ON cv.location = cd.location AND cv.date=cd.date
WHERE cv.continent IS NOT NULL
ORDER BY 1,2;

--The rolling sum of new vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_total_vac
FROM covid_deaths cd
JOIN covid_vaccinations cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 1,2,3;


--Getting the total rolling vaccinations rate per population
--Using a CTE
WITH popvac(continent, location, date, population, new_vaccinations, rolling_total_vac) AS (
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_total_vac
FROM covid_deaths cd
JOIN covid_vaccinations cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent IS NOT NULL)
SELECT *,(rolling_total_vac/population)*100  AS vaccination_rate FROM popvac


--Using Temp Table
DROP TABLE IF EXISTS #popvac
CREATE TABLE #popvac (
continent VARCHAR(255),
location VARCHAR(255),
date DATETIME,
population numeric,
new_vaccinations numeric,
rolling_total_vac numeric)

INSERT INTO #popvac
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location order by cd.location, cd.date) AS rolling_total_vac
FROM covid_deaths cd
JOIN covid_vaccinations cv
	ON cd.location = cv.location AND cd.date=cv.date
	WHERE cd.continent IS NOT NULL

SELECT *, (rolling_total_vac/population)*100 AS vaccination_rate
FROM #popvac;

--VIEWS
CREATE VIEW covid_data_visual AS
SELECT cd.continent, cd.location, cd.date, cd.population, cd.new_cases, cd.total_cases,
		cd.new_deaths, cd.total_deaths, cv.new_vaccinations,
		SUM(cv.new_vaccinations) OVER(PARTITION BY cd.location order by cd.location, cd.date) AS rolling_total_vac,
		cv.total_vaccinations, cv.people_vaccinated, cv.people_fully_vaccinated 
FROM covid_deaths cd
JOIN covid_vaccinations cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent IS NOT NULL;


CREATE VIEW covid_rates AS
SELECT cd.location, MAX((cd.total_cases/cd.population)*100) AS infection_rate,
				 MAX((cd.total_deaths/cd.population)*100) AS death_rate,
				 MAX((cd.total_deaths/cd.total_cases)*100) AS fatality_rate,
				 MAX((cv.people_vaccinated/cd.population)*100) AS vaccination_rate
FROM covid_deaths cd JOIN covid_vaccinations cv ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent IS NOT NULL AND cd.total_cases >100000
GROUP BY cd.location;

/*
SELECT date, SUM(new_cases) AS global_new_cases, SUM(new_deaths) AS global_new_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;*/
