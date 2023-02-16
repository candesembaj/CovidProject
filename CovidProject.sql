SELECT * FROM ProfileProject ..CovidDeath
order by 3,4

SELECT * FROM ProfileProject ..CovidVaccination
order by 3,4

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM ProfileProject ..CovidDeath
Order by 1,2

-- Looking at Total cases vs Total deaths 
-- Shows likelihood of dying if you contract Covid in your country
SELECT Location, Date, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 AS DeathPercentage
FROM ProfileProject ..CovidDeath
Order by 1,2

--Looking at Total cases vs Population
-- Shows whats percentage of population got covid
SELECT Location, Date, population, total_cases, (cast(total_cases as float)/population)*100 AS PercentPopulationInfected
FROM ProfileProject ..CovidDeath
WHERE continent IS NOT NULL 
Order by 1,2

--Looking at countries with highest infection rate compared to populaion
SELECT Location, population, MAX(total_cases) AS HighestInfection, MAX((cast(total_cases as float)/cast(population as float)))*100 AS PercentPopulationInfected
FROM ProfileProject ..CovidDeath
GROUP BY Location, population
Order by PercentPopulationInfected DESC

--Showing countries with highest death count per population
SELECT Location, MAX(CAST(total_deaths as decimal(10, 2))) AS TotalDeathCount
FROM ProfileProject ..CovidDeath
WHERE continent IS NOT NULL 
GROUP BY Location
Order by TotalDeathCount DESC

--Global numbers
SELECT SUM(CAST(new_cases as float)) AS total_cases, 
  SUM(CAST(new_deaths as float)) AS total_deaths, 
  SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float))*100 AS DeathPercentage
FROM ProfileProject ..CovidDeath
WHERE continent IS NOT NULL
Order by 1,2
--Global numbers comparing World Population vs total deaths
SELECT SUM(CAST(population as float)) AS WorldPopulation, SUM(CAST(new_cases as float)) AS total_cases, 
  SUM(CAST(new_deaths as float)) AS total_deaths, 
  SUM(CAST(total_deaths as float))/SUM(CAST(population as float))*100 AS DeathPercentage
FROM ProfileProject ..CovidDeath
WHERE continent IS NOT NULL
Order by 1,2

--Looking at total population vs vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(float, cv.new_vaccinations))  
OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM ProfileProject ..CovidDeath cd
JOIN ProfileProject ..CovidVaccination cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

--Creating Table

CREATE TABLE #PercentPopulationVaccinated
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(float, cv.new_vaccinations))  
OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM ProfileProject ..CovidDeath cd
JOIN ProfileProject ..CovidVaccination cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

--Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(float, cv.new_vaccinations))  
OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM ProfileProject ..CovidDeath cd
JOIN ProfileProject ..CovidVaccination cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3