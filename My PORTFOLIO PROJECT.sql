USE [My Portfolio Project]; 

SELECT*FROM covid_DEATHS
WHERE continent IS NOT NULL AND population IS NOT NULL 
ORDER BY 3,4 ;

SELECT*FROM covid_VACCIN
WHERE continent IS NOT NULL 
ORDER BY 3,4;


SELECT DISTINCT De.location,De.continent, De.date,De.population,De.total_cases,De.new_cases,
De.total_deaths,Va.people_fully_vaccinated,(Va.people_fully_vaccinated/De.population)*100 AS Percentage_Population_Fully_Vaccinated
FROM covid_DEATHS De  JOIN covid_VACCIN Va
ON De.location=Va.location AND De.date=Va.date
WHERE De.continent IS NOT NULL  AND De.population is not null 
--AND De.location like 'India'
ORDER BY 1 ASC,3 DESC;

--percentage of population fully vaccinated --

SELECT DISTINCT De.location,De.population,max(Va.people_fully_vaccinated) AS Fully_Vaccinatated,max((Va.people_fully_vaccinated/De.population))*100 AS Percentage_Population_Fully_Vaccinated
FROM covid_DEATHS De  JOIN covid_VACCIN Va
ON De.location=Va.location AND De.date=Va.date
WHERE De.continent IS NOT NULL  AND De.population is not null 
--AND De.location like 'India'
group by De.location,De.population
ORDER BY 4 desc;

--Likelihood of dying due to covid in our country--
SELECT location,date,population,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Total_death_percentage
FROM covid_DEATHS WHERE location LIKE 'India' AND continent IS NOT NULL AND population IS NOT NULL
ORDER BY 2 DESC,6 DESC;

--Percentage of population got covid--
SELECT location,date,population,total_cases,(total_cases/population)*100 AS Total_COVIDaffected_percentage
FROM covid_DEATHS
WHERE continent IS NOT NULL AND population IS NOT NULL
--AND location LIKE 'India' 
ORDER BY 2 DESC,5 DESC;

--Infection rate compared to population--
SELECT location,population,max(total_cases) AS Max_cases,max((total_cases/population))*100 AS Infection_Rate
FROM covid_DEATHS
WHERE continent IS NOT NULL AND population IS NOT NULL
--AND location LIKE 'India' 
GROUP BY location,population
ORDER BY 4 DESC;

--Countries with higest death count in population--
SELECT location,population,MAX(CAST(total_deaths AS INT)) AS Total_death
FROM covid_DEATHS WHERE continent IS NOT NULL AND population IS NOT NULL 
GROUP BY location,population
ORDER BY Total_death DESC;

--Continent wise total covid death--
SELECT location,population,MAX((CAST(total_deaths AS INT))) AS Total_death_continent
FROM covid_DEATHS WHERE continent IS NULL AND population IS NOT NULL 
GROUP BY location,population
ORDER BY Total_death_continent DESC;

--Overall new death percentage in World --
SELECT location,sum(new_cases) AS sum_new_cases,(SUM(CONVERT(INT,new_deaths))/SUM(new_cases))*100 AS New_Death_percentage
FROM covid_DEATHS
WHERE continent IS NULL AND population IS NOT NULL AND location NOT IN ('World','European Union') 
GROUP BY location
ORDER BY 3 DESC;


SELECT DISTINCT De.location,De.continent, De.date,De.population,De.total_cases,De.new_cases,
De.total_deaths,Va.people_fully_vaccinated,Va.positive_rate,Va.human_development_index
FROM covid_DEATHS De  JOIN covid_VACCIN Va
ON De.location=Va.location AND De.date=Va.date
WHERE De.continent IS NOT NULL  AND De.population is not null 
--AND De.location like 'India'
ORDER BY 3 DESC,10 DESC;

--Population got vaccinated--
SELECT De.location,De.date,Va.new_vaccinations,SUM(CONVERT(INT,Va.new_vaccinations)) OVER (PARTITION BY De.location ORDER BY De.location,De.date) AS Total_new_vaccinations
FROM covid_DEATHS De  JOIN covid_VACCIN Va
ON De.location=Va.location AND De.date=Va.date
WHERE De.continent IS NOT NULL  AND De.population is not null 
AND De.location like 'India'
ORDER BY 1,2 desc;

--Percentage of population got vaccinated--CTE----

WITH Vacc_Update(location,date,population,new_vaccinations,Total_new_vaccinations) AS(
SELECT De.location,De.date,De.population,Va.new_vaccinations,SUM(CONVERT(INT,Va.new_vaccinations)) OVER (PARTITION BY De.location ORDER BY De.location,De.date) AS Total_new_vaccinations
FROM covid_DEATHS De  JOIN covid_VACCIN Va
ON De.location=Va.location AND De.date=Va.date
WHERE De.continent IS NOT NULL  AND De.population is not null )
--AND De.location like 'India'
SELECT*,( Total_new_vaccinations/population)*100 AS population_Vaccinted_percentage from Vacc_Update
ORDER BY 1,2 DESC,6 DESC;
 
 --Percentage of population got vaccinate--NEW TABLE--

 --DROP TABLE IF EXISTS Updates_vaccination; 
CREATE TABLE Updates_vaccinations
(location NVARCHAR(255),
date DATE,
population NUMERIC,
new_vaccinations NUMERIC,
Total_new_vaccinations NUMERIC)
INSERT INTO Updates_vaccinations
SELECT De.location,De.date,De.population,Va.new_vaccinations,SUM(CONVERT(INT,Va.new_vaccinations)) OVER (PARTITION BY De.location ORDER BY De.location,De.date) AS Total_new_vaccinations
FROM covid_DEATHS De  JOIN covid_VACCIN Va
ON De.location=Va.location AND De.date=Va.date
WHERE De.continent IS NOT NULL  AND De.population is not null 
--AND De.location like 'India'
SELECT*,( Total_new_vaccinations/population)*100 AS population_Vaccinted_percentage from Updates_vaccinations
ORDER BY 1,2 DESC,6 DESC;

--Creating View--
CREATE VIEW Vaccination_percentage AS
SELECT  De.location,De.date,De.population,Va.new_vaccinations,SUM(CONVERT(INT,Va.new_vaccinations)) OVER (PARTITION BY De.location ORDER BY De.location,De.date) AS Total_new_vaccinations
FROM covid_DEATHS De  JOIN covid_VACCIN Va
ON De.location=Va.location AND De.date=Va.date
WHERE De.continent IS NOT NULL  AND De.population is not null ;
SELECT * FROM Vaccination_percentage;
--DROP VIEW Vaccination_percentage;

--Checking 5% Positivity rate--
SELECT DISTINCT De.location,De.continent, De.date,De.population,De.total_cases,De.new_cases,
De.total_deaths,Va.people_fully_vaccinated,Va.cardiovasc_death_rate,Va.diabetes_prevalence,Va.handwashing_facilities,Va.positive_rate,
CASE
WHEN Va.positive_rate >= .05 THEN 'Not_Safe_Zone'
WHEN Va.positive_rate < .05 THEN 'Safe_Zone'
ELSE 'Not_Defined'
END AS Zone
FROM covid_DEATHS De  JOIN covid_VACCIN Va
ON De.location=Va.location AND De.date=Va.date
WHERE De.continent IS NOT NULL AND De.population is not null 
--AND De.location like 'India' 
--AND Va.date='2021/07/15'
ORDER BY 1 ASC,3 DESC;

--Maximum covid19 Cases in 2021--
SELECT location,date, MAX(new_cases) AS Max_Cases FROM covid_DEATHS
WHERE continent IS NOT NULL AND population IS NOT NULL AND year(date)='2021' 
--AND location LIKE 'ind%'
GROUP BY location, date 
ORDER BY 3 DESC;
