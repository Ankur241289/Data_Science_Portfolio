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
select location, MAX(CAST(total_deaths AS INT)) as max_deaths
from Portfolio..['CovidDeaths']
where continent is null
group by location
order by max_deaths DESC

