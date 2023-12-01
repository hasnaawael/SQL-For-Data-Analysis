use testdb;
--  First question we should ask is >> what is the data == Explore?
SELECT * FROM police_incident_reports LIMIT 100;

-- Ignore unimportant columns
-- 	"SF Find Neighborhoods 2 2", 
-- 	"Current Police Districts 2 2", 
-- 	"Current Supervisor Districts 2 2", 
-- 	"Analysis Neighborhoods 2 2"
-- 	"Civic Center Harm Reduction Project Boundary 2 2", 
-- 	"Fix It Zones as of 2017-11-06 2 2", 
-- 	"Fix It Zones as of 2018-02-07 2 2", 
-- 	"CBD, BID and GBD Boundaries as of 2017 2 2", 
-- 	"Areas of Vulnerability, 2016 2 2", 
-- 	"Central Market/Tenderloin Boundary 2 2", 
-- 	"Central Market/Tenderloin Boundary Polygon - Updated 2 2", 
-- 	"HSOC Zones as of 2018-06-05 2 2", 
-- 	"OWED Public Spaces 2 2", 

-- Data we will work on :
SELECT PdId ,IncidntNum ,'Incident Code',Category ,Descript ,DayOfWeek ,Date ,Time ,PdDistrict ,Resolution ,Address ,X ,Y 
 ,location FROM police_incident_reports  LIMIT 100;
 
 -- The data range to know how many years :
 -- the YEAR function to extract the year from a date
 -- uses STR_TO_DATE to convert the date values to the MySQL date format ('%m/%d/%Y') 
SELECT YEAR(MAX(STR_TO_DATE(Date, '%m/%d/%Y'))), YEAR(MIN(STR_TO_DATE(Date, '%m/%d/%Y')))
FROM police_incident_reports;

-- Exploring data
-- 1. How many police districts are there?
SELECT COUNT(DISTINCT PdDistrict) FROM police_incident_reports;

-- How many neighborhoods are there?
SELECT COUNT('Neighborhoods 2') FROM police_incident_reports;

-- How many incidents by neighborhood?
SELECT `Neighborhoods 2`, COUNT(*) AS COUNT
FROM police_incident_reports
WHERE `Neighborhoods 2` IS NOT NULL
GROUP BY 1
ORDER BY COUNT;

-- Check the min and max number of incidents by neighborhood
-- In this case, "s" serves as a shorthand for the subquery that calculates the counts of "Neighborhoods 2" column
SELECT MAX(s.COUNT) AS MAX, MIN(s.COUNT) AS MIN, AVG(s.COUNT) AS AVG 
FROM (
    SELECT `Neighborhoods 2` AS Neighborhood, COUNT(*) AS COUNT
    FROM police_incident_reports
    WHERE `Neighborhoods 2` IS NOT NULL
    GROUP BY `Neighborhoods 2`
    ) s;
    
