/*SQL Project on India Census Data*/
--------------------------------------------------------------------------------------------------
--PART 1 - Simple and Intermediate level functions in SQL

--Returning both the sheets to get a rough idea of the data accumulated

SELECT * FROM India_Census_Project.dbo.Data1
SELECT * FROM India_Census_Project.dbo.Data2

-- Number of rows in our database

SELECT COUNT(*) FROM India_Census_Project.dbo.Data1
SELECT COUNT(*) FROM India_Census_Project..Data2

--Dataset for Jharkhand and Bihar

SELECT * FROM India_Census_Project.dbo.Data1
WHERE State in ('Jharkhand','Bihar')

--Total population from database2

SELECT * FROM India_Census_Project.dbo.Data2
SELECT SUM(Population) Count_of_Indians FROM India_Census_Project.dbo.Data2
SELECT SUM(Population) AS Count_of_Indians FROM India_Census_Project.dbo.Data2

--Both the above lines of code gives the same output irrespective of if "AS" is written or not

--Give the average growth rate of Indians and also the percentage

SELECT AVG(Growth) Growth_of_Indians FROM India_Census_Project.dbo.Data1
SELECT AVG(Growth)*100 Growth_Pecentage_of_Indians FROM India_Census_Project.dbo.Data1

--Give average growth percentage for indiviual conuntries

SELECT State,AVG(Growth)*100 AS Growth_of_Indians_Statewise
FROM India_Census_Project.dbo.Data1
GROUP BY State

--Give the average Sex-ratio statewise

SELECT State,ROUND(AVG(Sex_Ratio),0) AS Sex_ratio_of_Indians_Statewise
FROM India_Census_Project.dbo.Data1
GROUP BY State
ORDER BY Sex_ratio_of_Indians_Statewise DESC

--Give the avearage literacy rate statewise

SELECT State, ROUND(AVG(Literacy),0) AS Literacy_of_Indians_Statewise
FROM India_Census_Project.dbo.Data1
GROUP BY State
HAVING ROUND(AVG(Literacy),0)>90
ORDER BY Literacy_of_Indians_Statewise DESC

--Top 3 states showing highest growth ratio
--TOP clause is used in this query to show tje top rows of a column

SELECT TOP 3 State, AVG(Growth)*100 AS Lowest_Growth_Rate_States
FROM India_Census_Project.dbo.Data1
GROUP BY State
ORDER BY Lowest_Growth_Rate_States DESC

--LIMIT clause doesn't work in MS SQL Server rather use TOP clause as in above

--SELECT State, AVG(Growth)*100 AS Lowest_Growth_Rate_States
--FROM India_Census_Project.dbo.Data1
--GROUP BY State
--ORDER BY Lowest_Growth_Rate_States DESC
--LIMIT 3 ;

--TOP and BOTTOM 3 states in literacy rate
--A temporary table will be created 

DROP TABLE IF EXISTS #Top_States

/*This is an advanced level concept that if table exists delete it and insert new table again
which eliminates any kind of issue in working with the database
This the syntax to comment out multiple lines of code in MS SQL Server*/


CREATE TABLE #Top_States
(State nvarchar(255),
Top_States float)

INSERT INTO #Top_States
SELECT State, ROUND(AVG(literacy),0) Avg_Literacy_Ratio 
FROM India_Census_Project.dbo.Data1 
GROUP BY State ;

SELECT TOP 3 * FROM #Top_States
ORDER BY Top_States DESC ;

--Bottom 3 of the States in terms of literacy

DROP TABLE IF EXISTS #Bottom_States
CREATE TABLE #Bottom_States
(State nvarchar(255),
Bottom_States float)

INSERT INTO #Bottom_States
SELECT State, ROUND(AVG(literacy),0) Avg_Literacy_Ratio 
FROM India_Census_Project.dbo.Data1 
GROUP BY State ;

SELECT TOP 3 * FROM #Bottom_States
ORDER BY Bottom_States ;

--Combining the data from both the tables via a UNION Operator

SELECT * FROM (
SELECT TOP 3 * FROM #Top_States
ORDER BY Top_States DESC ) a
UNION
SELECT * FROM (
SELECT TOP 3 * FROM #Bottom_States
ORDER BY Bottom_States ) b;

--Select states starting from letter "a"

SELECT DISTINCT State FROM India_Census_Project.dbo.Data1
WHERE LOWER(State) LIKE 'a%'

--Select states starting from letter "a" or ending with letter "d"

SELECT DISTINCT State FROM India_Census_Project.dbo.Data1
WHERE LOWER(State) LIKE 'a%' or LOWER(State) LIKE '%d'

--Select states starting from letter "a" and ending with letter "h"

SELECT DISTINCT State FROM India_Census_Project.dbo.Data1
WHERE LOWER(State) LIKE 'a%' and LOWER(State) LIKE '%h'

--------------------------------------------------------------------------------------------------
--PART 2 - Advance level functions in SQL

--Find the number of males and females in a state

/* Join the two tables to find the males and females in a state, sex_ratio is in Table_1
and population of the state is in Table_2; 
Joining will be done on the district column */

SELECT A.District,A.State,A.Sex_Ratio,B.Population
FROM India_Census_Project..Data1 A
INNER JOIN India_Census_Project..Data2 B
ON A.District=B.District

/*Aliasing is done in joing the table and the prefix are mentioned before every column 
that is to be imported for their respective tables
Again from this joined table which is named C
Columns will be inserted applying the desired formula to calculate the males & females*/

SELECT C.District,C.State,
ROUND(C.Sex_Ratio/(1000+C.Sex_Ratio)*C.Population,0) Females,
ROUND(1000/(1000+C.Sex_Ratio)*C.Population,0) Males FROM
(SELECT A.District,A.State,A.Sex_Ratio,B.Population
FROM India_Census_Project..Data1 A
INNER JOIN India_Census_Project..Data2 B
ON A.District=B.District) C

/*FROM can't be wriiten on the line starting from that bracket of innner query,
throws error
FROM (SELECT A.District,A.State,A.Sex_Ratio,B.Population...)*/

--This above obtained data is arranged district wise, group data state wise

SELECT D.State,SUM(D.Females) Females,SUM(D.Males) Males FROM
(SELECT C.District,C.State,
ROUND(C.Sex_Ratio/(1000+C.Sex_Ratio)*C.Population,0) Females,
ROUND(1000/(1000+C.Sex_Ratio)*C.Population,0) Males FROM
(SELECT A.District,A.State,A.Sex_Ratio,B.Population
FROM India_Census_Project..Data1 A
INNER JOIN India_Census_Project..Data2 B
ON A.District=B.District) C) D
GROUP BY D.State
ORDER BY Females

/*While working with joins and deriving one table from another, 
assign the table a name, as in this case 'A','B','C' and 'D'
work with new tables and columns from previous table via aliases*/

--Give the total number of literate and illiterate people in the District

SELECT C.District,C.State,
ROUND((C.Literacy/100)*C.Population,0) AS Literate,
ROUND((1-(C.Literacy/100))*C.Population,0) AS Illiterate FROM
(SELECT A.District,A.State,A.Literacy,B.Population
FROM India_Census_Project..Data1 A
INNER JOIN India_Census_Project..Data2 B
ON A.District=B.District) C

--Give the total number of literate and illiterate people in the State

SELECT D.State, SUM(D.Literate) Literate, SUM(D.Illiterate) Illiterate FROM
(SELECT C.District,C.State,
ROUND((C.Literacy/100)*C.Population,0) AS Literate,
ROUND((1-(C.Literacy/100))*C.Population,0) AS Illiterate FROM
(SELECT A.District,A.State,A.Literacy,B.Population
FROM India_Census_Project..Data1 A
INNER JOIN India_Census_Project..Data2 B
ON A.District=B.District) C) D
GROUP BY D.State
ORDER BY Literate


--Give the data of population in the previous census
/*A.Growth is already the growth fraction of the population*/

SELECT A.District,A.State,
ROUND(B.Population/(1+A.Growth),0) AS Previous_Census_Data,
B.Population AS Current_Census_Data
FROM India_Census_Project..Data1 AS A
INNER JOIN India_Census_Project..Data2 AS B
ON A.District=B.District

--Given the above data, give the poupulation state wise

SELECT C.State, SUM(C.Previous_Census_Data) AS Prev_total_population, 
SUM(C.Current_Census_Data) AS Current_total_population FROM
(SELECT A.District,A.State,
ROUND(B.Population/(1+A.Growth),0) AS Previous_Census_Data,
B.Population AS Current_Census_Data
FROM India_Census_Project..Data1 AS A
INNER JOIN India_Census_Project..Data2 AS B
ON A.District=B.District) C
GROUP BY C.State
ORDER BY Current_total_population

--Give the total polulation based on this data for previous and current year

SELECT SUM(D.Prev_total_population) AS Previous_year_population,
SUM(D.Current_total_population) AS Current_year_population FROM
(SELECT C.State, SUM(C.Previous_Census_Data) AS Prev_total_population, 
SUM(C.Current_Census_Data) AS Current_total_population FROM
(SELECT A.District,A.State,
ROUND(B.Population/(1+A.Growth),0) AS Previous_Census_Data,
B.Population AS Current_Census_Data
FROM India_Census_Project..Data1 AS A
INNER JOIN India_Census_Project..Data2 AS B
ON A.District=B.District) C
GROUP BY C.State) D

--Find the area per unit population for both previous and current census population

SELECT I.Total_Area/I.Previous_year_population AS Previous_area_per_person,
I.Total_Area/I.Current_year_population AS Current_Area_per_person FROM
(/*#5*/ SELECT F.*,H.Total_Area FROM 
(/*#2*/ SELECT '1' AS Keyy,E.* FROM
( /*#1*/ SELECT SUM(D.Prev_total_population) AS Previous_year_population,  
SUM(D.Current_total_population) AS Current_year_population FROM
(SELECT C.State, SUM(C.Previous_Census_Data) AS Prev_total_population, 
SUM(C.Current_Census_Data) AS Current_total_population FROM
(SELECT A.District,A.State,
ROUND(B.Population/(1+A.Growth),0) AS Previous_Census_Data,
B.Population AS Current_Census_Data
FROM India_Census_Project..Data1 AS A
INNER JOIN India_Census_Project..Data2 AS B
ON A.District=B.District) C
GROUP BY C.State) D /*#1*/) E /*#2*/) F
INNER JOIN
(/*#4*/ SELECT '1' AS Keyy,G.* FROM
(/*#3*/ SELECT SUM(Area_km2) Total_Area FROM India_Census_Project.dbo.Data2 /*#3*/ ) G /*#4*/)H
ON F.Keyy=H.Keyy /*#5*/) I

/*The bracket are marked and numbered in order, 
to easily distinguish the code they are applied in between*/

--Find the top 3 districts from each state having highest literacy ratio
/*RANK Function*/

SELECT A.* FROM
(/*1*/SELECT District,State,Literacy,Rank() 
OVER(PARTITION BY State ORDER BY Literacy DESC) Rnk FROM India_Census_Project..Data1 /*1*/) A
WHERE A.Rnk in (1,2,3)
------------------------------------------------------------------------------------------------------------
