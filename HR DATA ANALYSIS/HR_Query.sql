USE Hr_database;

-- Let's see all the data
Select *
From dbo.[HR Data]

-- explore table structure
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Hr Data';

--------------------------------------------------------------------------------------------------------------------------
-- Data Cleaning 
--------------------------------------------------------------------------------------------------------------------------
-- 1. termdate column 

-- Fix column "termdate" formatting
SELECT termdate 
FROM dbo.[HR Data]
ORDER BY termdate DESC ;

UPDATE [HR Data]
SET termdate = FORMAT(CONVERT(DATETIME, LEFT(termdate, 19), 120), 'yyyy-MM-dd');

-- Update from nvachar to date
ALTER TABLE [HR Data]
ADD new_termdate DATE;

-- Update the new date column with the converted values
UPDATE [HR Data]
SET new_termdate = IIF(ISDATE(termdate) = 1, CAST(termdate AS DATETIME), NULL)
WHERE termdate IS NOT NULL;

-- let's see what we do 
SELECT new_termdate 
FROM [HR Data]
ORDER BY new_termdate DESC;

-- 2. Get Age From Birthdate 

-- create new column "age"
ALTER TABLE [Hr Data]
ADD age nvarchar(50)

-- Populate new column with age
UPDATE [HR Data]
SET age = DATEDIFF(YEAR, birthdate, GETDATE());

-- Select birthdate and age, ordering by age
SELECT birthdate, age
FROM [HR Data]

--------------------------------------------------------------------------------------------------------------------------
-- QUESTIONS TO ANSWER FROM THE DATA
--------------------------------------------------------------------------------------------------------------------------
-- 1) What's the age distribution in the company?
SELECT 
 MIN(age) AS Youngest, 
 MAX(age) AS Oldest
FROM [HR Data];

-- Age Distribution 
SELECT
  age_group,
  COUNT(*) AS count
FROM (
  SELECT
    CASE
      WHEN age BETWEEN 21 AND 30 THEN '21 to 30'
      WHEN age BETWEEN 31 AND 40 THEN '31 to 40'
      WHEN age BETWEEN 41 AND 50 THEN '41-50'
      ELSE '50+'
    END AS age_group
  FROM [HR Data]
  WHERE new_termdate IS NULL
) AS Subquery
GROUP BY age_group
ORDER BY age_group;

--Age by gender 
SELECT
  age_group,
  gender,
  COUNT(*) AS count
FROM (
  SELECT
    CASE
      WHEN age BETWEEN 21 AND 30 THEN '21 to 30'
      WHEN age BETWEEN 31 AND 40 THEN '31 to 40'
      WHEN age BETWEEN 41 AND 50 THEN '41-50'
      ELSE '50+'
    END AS age_group,
    gender
  FROM [HR Data]
  WHERE new_termdate IS NULL
) AS Subquery
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 2) What's the gender breakdown in the company?
SELECT
  gender,
  COUNT(gender) AS count
FROM [HR Data]
GROUP BY gender
ORDER BY gender ASC;

-- 3) How does gender vary across departments and job titles?
SELECT 
  department, jobtitle, gender, COUNT(gender) AS count
FROM [HR Data]
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, gender ASC;

-- 4) What's the race distribution in the company?
SELECT race, COUNT(*) AS count
FROM [HR Data]
GROUP BY race
ORDER BY count DESC;

-- 5) What's the average length of employment in the company?
SELECT
  AVG(DATEDIFF(YEAR, hire_date, new_termdate)) AS tenure
FROM [HR Data]
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE();

-- 6) Which department has the highest turnover rate? >>  turnover rate : is a metric that measures the proportion of employees who leave a company over a specific period
SELECT
  department,
  total_count,
  terminated_count,
  ROUND(CAST(terminated_count AS FLOAT) / total_count, 2) AS turnover_rate
FROM 
  (SELECT
    department,
    COUNT(*) AS total_count,
    SUM(
      CASE
        WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE()
        THEN 1
        ELSE 0
      END
    ) AS terminated_count
  FROM [HR Data]
  GROUP BY department
  ) AS Subquery
ORDER BY turnover_rate DESC;

-- 7) What is the tenure distribution for each department?
-- Average 
SELECT 
    department,
    AVG(DATEDIFF(YEAR, hire_date, new_termdate)) AS tenure
FROM [HR Data]
WHERE 
    new_termdate IS NOT NULL 
    AND new_termdate <= GETDATE()
GROUP BY department;

-- Overall Tenure
SELECT 
    department, 
    DATEDIFF(YEAR, MIN(hire_date), MAX(new_termdate)) AS tenure
FROM [HR Data]
WHERE  
    new_termdate IS NOT NULL 
    AND new_termdate <= GETDATE()
GROUP BY department
ORDER BY tenure DESC;

-- 8) How many employees work remotely for each department?
SELECT
  location,
  COUNT(*) AS count
FROM [HR Data]
GROUP BY location;

-- 9) What's the distribution of employees across different states?
SELECT
  location_state,
  COUNT(*) AS count
FROM [HR Data]
GROUP BY location_state
ORDER BY count DESC;

-- 10) How are job titles distributed in the company?
SELECT 
	jobtitle ,
	COUNT(*) AS count
FROM [HR Data]
GROUP BY jobtitle
ORDER BY count DESC;

-- 11) How have employee hire counts varied over time?
-- analyze how employee hire counts have varied over time, taking into account terminations and calculating the net change and percentage change
SELECT
  hire_yr,
  hires,
  terminations,
  hires - terminations AS net_change,
  (ROUND(CAST(hires - terminations AS FLOAT) / NULLIF(hires, 0), 2)) * 100 AS percent_hire_change
FROM  
  (SELECT
    YEAR(hire_date) AS hire_yr,
    COUNT(*) AS hires,
    SUM(CASE WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0 END) AS terminations
  FROM [HR Data]
  GROUP BY YEAR(hire_date)
  ) AS subquery
ORDER BY hire_yr ASC;

