select * from Portfolio..['CovidDeaths']
WHERE continent is not null
order by location, date


--select * from Portfolio..['CovidVaccinations']
--order by location, date


-- Select the data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from Portfolio..['CovidDeaths']
order by location, date


-- Looking at total cases vs total deaths 
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as cases_to_death_percentage
from Portfolio..['CovidDeaths']
order by location, date


-- Lets take a look at total cases Vs total deaths in case of India
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as cases_to_death_percentage
from Portfolio..['CovidDeaths']
Where location LIKE '%India%'
order by location, date
	
	-- 1. We can see that India recorded its first ever Covid case on 30/01/2020
	-- 2. The first death related to Covid was recorded almost 40 days after recording its first case on 11/03/2020.




-- Looking at the data of total cases vs total deaths in case of India
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as cases_to_death_percentage
from Portfolio..['CovidDeaths']
Where location = 'India'
order by location, date


 -- Looking at the data of total cases vs population in case of India
 -- Shows what percentage of population contracted Covid-19
select location, date, population, total_cases, round((total_cases/population)*100, 2) as cases_to_population
from Portfolio..['CovidDeaths']
Where location = 'India'
order by location, date


-- Looking at countries with highest infection rate as compared to population
select location, population, MAX(total_cases) as maximum_cases, MAX(round((total_cases/population)*100, 2)) as cases_to_population
from Portfolio..['CovidDeaths']
Group by population, location
order by cases_to_population DESC



-- Highest Death count as per population
select location, MAX(CAST(total_deaths AS INT)) as max_deaths
from Portfolio..['CovidDeaths']
where continent is not null
group by location
order by max_deaths DESC



-------- LET'S BREAK THIGS DOWN BY CONTINENT---------------

-- Highest Death count as per population continent wise
select continent, MAX(CAST(total_deaths AS INT)) as max_deaths
from Portfolio..['CovidDeaths']
where continent is not null 
group by continent
order by max_deaths DESC



-- Looking at number of covid cases to total population continent wise as on the last day of reported data i.e 27/02/2023----

------ Here we will see the continents ranked by highest percentage of Covid_cases to Total_Population as per the latest data
select continent, sum(population) as total_population, MAX(total_cases) as total_cases, MAX(round((total_cases/population)*100, 2)) as cases_to_population
from Portfolio..['CovidDeaths']
where continent is not null 
and date = '2023-02-27 00:00:00.000'
group by continent
order by cases_to_population DESC



---- GLOBAL NUMBERS----

---Looking at day to day global cases to death percentage data, sorted date wise---
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as INT)) as total_deaths, round(sum(cast(new_deaths as INT))/sum(new_cases) * 100,2) as death_percentage
from Portfolio..['CovidDeaths']
where continent is not null
group by date
order by date



---- looking at total global cases to death percentage data----
select sum(new_cases) as total_cases, sum(cast(new_deaths as INT)) as total_deaths, round(sum(cast(new_deaths as INT))/sum(new_cases) * 100,2) as death_percentage
from Portfolio..['CovidDeaths']
where continent is not null




---- LETS TAKE A LOOK AT OUR SECOND DATASET----
select * 
from Portfolio..['CovidVaccinations']
order by date


---- NOW WE WILL JOIN BOTH DATASETS ON LOCATION AND DATE COLUMNS AND TAKE A LOOK AT JOINED DATA-----
select * 
from Portfolio..['CovidDeaths'] death
join Portfolio..['CovidVaccinations'] vaccinations
	on death.location = vaccinations.location
	and death.date = vaccinations.date
order by 2,3



---- Looking at Population to New Vaccinations----
select death.continent, death.location, death.date, death.population, vaccinations.new_vaccinations
from Portfolio..['CovidDeaths'] death
join Portfolio..['CovidVaccinations'] vaccinations
	on death.location = vaccinations.location
	and death.date = vaccinations.date
where death.continent is not null
order by 2,3



---- Looking at Population to New Vaccinations data where new vaccinations gets added to total vaccinations after with each new vaccination----
----------The total vaccinations counter will set itself to zero as soon as it encounters a new country-------

select death.continent, death.location, death.date, death.population, vaccinations.new_vaccinations
, SUM(cast(vaccinations.new_vaccinations as bigint)) OVER (Partition by  death.location Order by death.location,death.date) as Daily_Total_vaccinations
from Portfolio..['CovidDeaths'] death
join Portfolio..['CovidVaccinations'] vaccinations
	on death.location = vaccinations.location
	and death.date = vaccinations.date
where death.continent is not null
order by 2,3




------ Now lets check the latest situation (as on 27-02-2023) of percentage of people vaccinated against total population of each country---------
With popuVSvacc (Continent, Location, Date, Population, New_Vaccinations, Total_Vaccinations)
as
(
select death.continent, death.location, death.date, death.population, vaccinations.new_vaccinations
, SUM(cast(vaccinations.new_vaccinations as bigint)) OVER (Partition by  death.location Order by death.location,death.date) as Total_vaccinations
from Portfolio..['CovidDeaths'] death
join Portfolio..['CovidVaccinations'] vaccinations
	on death.location = vaccinations.location
	and death.date = vaccinations.date
where death.continent is not null
)
select *, ROUND(Total_Vaccinations/Population*100,2) as Current_Vaccination_Pctg
from popuVSvacc
Where Date = '2023-02-27'
order by Location




------Creating a Temp Table to see the same details as above mentioned query-----
---------Here we have sought the same information of Current Situation of Vaccination percentage against population but using a different query using TEMP Table------
DROP Table if exists #PercentPopulationVaccinated
Create Table  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Total_Vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
select death.continent, death.location, death.date, death.population, vaccinations.new_vaccinations
, SUM(cast(vaccinations.new_vaccinations as bigint)) OVER (Partition by  death.location Order by death.location,death.date) as Total_vaccinations
from Portfolio..['CovidDeaths'] death
join Portfolio..['CovidVaccinations'] vaccinations
	on death.location = vaccinations.location
	and death.date = vaccinations.date
where death.continent is not null

select *, ROUND(Total_Vaccinations/Population*100,2) as Current_Vaccination_Pctg
from #PercentPopulationVaccinated
Where Date = '2023-02-27'
order by Location




------- NOW LETS CREATE SOME VIEWS TO STORE DATA FOR LATER VISUALIZATION----

--- 1. Creating View for to see daily vaccination performance of countries with vaccination percentage----
Create View
PopulationVaccinatedPercentage as
With popuVSvacc (Continent, Location, Date, Population, New_Vaccinations, Total_Vaccinations)
as
(
select death.continent, death.location, death.date, death.population, vaccinations.new_vaccinations
, SUM(cast(vaccinations.new_vaccinations as bigint)) OVER (Partition by  death.location Order by death.location,death.date) as Total_vaccinations
from Portfolio..['CovidDeaths'] death
join Portfolio..['CovidVaccinations'] vaccinations
	on death.location = vaccinations.location
	and death.date = vaccinations.date
where death.continent is not null
)
select *, ROUND(Total_Vaccinations/Population*100,2) as Current_Vaccination_Pctg
from popuVSvacc





-----2. Creating View to see Vaccination status of countries as on 27-02-2023-----
Create View
PopulationVaccinatedPercentage27Feb2023 as
With popuVSvacc (Continent, Location, Date, Population, New_Vaccinations, Total_Vaccinations)
as
(
select death.continent, death.location, death.date, death.population, vaccinations.new_vaccinations
, SUM(cast(vaccinations.new_vaccinations as bigint)) OVER (Partition by  death.location Order by death.location,death.date) as Total_vaccinations
from Portfolio..['CovidDeaths'] death
join Portfolio..['CovidVaccinations'] vaccinations
	on death.location = vaccinations.location
	and death.date = vaccinations.date
where death.continent is not null
)
select *, ROUND(Total_Vaccinations/Population*100,2) as Current_Vaccination_Pctg
from popuVSvacc
Where Date = '2023-02-27'


select * from PopulationVaccinatedPercentage
order by location, date



----- 3. Creating a view to see countries where Vaccinations exceed 200% as on 27-02-2023----
Create View
TopCountriesInVaccinations as
select * from PopulationVaccinatedPercentage27Feb2023
where Current_Vaccination_Pctg >= 200

