---------------------------------------------------
---- 1_Total number and Average_Severity  of accidents by road type -----
---------------------------------------------------
SELECT 
    ROAD_TYPE, COUNT(*) AS Total_Accidents,AVG(Accident_Severity) AS Average_Severity
FROM 
    Accidents JOIN  Roads 
	ON Accidents.Road_ID = Roads.Road_ID
GROUP BY ROAD_TYPE
ORDER BY Total_Accidents DESC;
---------------------------------------------------
-- 2_Weather conditions that lead to accidents ----
---------------------------------------------------
SELECT 
	Weather_Conditions, COUNT(*) AS Total_Accidents
FROM 
	Conditions JOIN Accidents 
	ON Conditions.Condition_ID = Accidents.Condition_ID
GROUP BY Weather_Conditions
ORDER BY Total_Accidents DESC;
------------------------------------------------------------------------
-- 3_number of accidents by local authority district could be useful ---
------------------------------------------------------------------------
SELECT 
	Local_Authority_District, COUNT(*) AS Total_Accidents
FROM 
	Authorities JOIN [dbo].[Accident_Authority]
	ON Authorities.Authority_ID = Accident_Authority.Authority_ID 
		JOIN [dbo].[Accidents] 
		ON Accidents.Accident_Index = Accident_Authority.Accident_Index
GROUP BY 
	Local_Authority_District
ORDER BY 
	Total_Accidents DESC;
------------------------------------------------
--- 4_Number of accidents by day of the week ---
------------------------------------------------
SELECT 
    CASE 
        WHEN Day_of_Week = 1 THEN 'Sunday'
        WHEN Day_of_Week = 2 THEN 'Monday'
        WHEN Day_of_Week = 3 THEN 'Tuesday'
        WHEN Day_of_Week = 4 THEN 'Wednesday'
        WHEN Day_of_Week = 5 THEN 'Thursday'
        WHEN Day_of_Week = 6 THEN 'Friday'
        WHEN Day_of_Week = 7 THEN 'Saturday'
    END AS Day_Name,
    COUNT(Accident_Index) AS Total_Accidents
FROM Accidents
GROUP BY Day_of_Week
ORDER BY Day_of_Week;
-------------------------------------------------------------------------
----5_average number of vehicles involved in accidents by road type,----
-------------------------------------------------------------------------
SELECT 
    R.Road_Type, AVG(A.Number_of_Vehicles) AS Average_Vehicles_Involved
FROM Accidents A JOIN Roads R 
	ON A.Road_ID = R.Road_ID
GROUP BY R.Road_Type
ORDER BY Average_Vehicles_Involved DESC;
------------------------------------------------------------
----6_how accident severity varies with light conditions----
------------------------------------------------------------
SELECT 
	C.Light_Conditions, A.Accident_Severity, COUNT(A.Accident_Index) AS Total_Accidents
FROM Accidents A JOIN Conditions C 
	ON A.Condition_ID = C.Condition_ID
GROUP BY C.Light_Conditions, A.Accident_Severity
ORDER BY C.Light_Conditions, A.Accident_Severity;
------------------------------------------------------------------------------------------------------
--- 7_Average Number of Vehicles in Fatal and Serious Accidents from January 1 to January 11, 2005 ---
------------------------------------------------------------------------------------------------------
SELECT 
    Accident_Index,ROUND(AVG(Number_of_Vehicles), 2) AS Avg_Vehicles,
	CASE 
        WHEN Accident_Severity = 1 THEN 'Fatal'
        WHEN Accident_Severity = 2 THEN 'Serious'
    END AS Severity_Description
FROM Accidents
WHERE Accident_Severity IN (1, 2)  
AND Date BETWEEN '2005-01-01' AND '2005-01-11'
GROUP BY Accident_Index, Accident_Severity
ORDER BY Avg_Vehicles DESC;

--------------------------------------------------------------------------
--- 8_Top 10 Recent Accidents Exceeding Average Casualties by Severity ---
--------------------------------------------------------------------------
SELECT Accident_Index, Date, Accident_Severity,Number_of_Casualties, Total_Casualties_On_Severity
FROM (
	  SELECT Accident_Index, Date, Accident_Severity,Number_of_Casualties, COUNT(*) OVER(PARTITION BY Accident_Severity) AS Total_Casualties_On_Severity
      FROM Accidents
      WHERE Number_of_Casualties > (SELECT AVG(Number_of_Casualties) FROM Accidents)
) AS Sub
ORDER BY Date DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;
------------------------------------------------------------------------
--- 9_Function to Get the Total Number of Accidents in a Given Month ---
------------------------------------------------------------------------
CREATE FUNCTION dbo.GetTotalAccidentsByMonth( @Year INT,@Month INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalAccidents INT;
    SELECT @TotalAccidents = COUNT(*)
    FROM Accidents
    WHERE Year = @Year AND MONTH(Date) = @Month;
    RETURN @TotalAccidents;
END;
--use 
SELECT dbo.GetTotalAccidentsByMonth(2005, 2) AS TotalAccidentsInSeptember2023;
------------------------------------------------------------------------
--- 10. Accidents by Severity and Time of Day ---
------------------------------------------------------------------------
WITH AccidentTimes AS (
    SELECT 
        a.Accident_Index,
        a.Accident_Severity,
        CASE 
            WHEN CAST(a.Time AS TIME) BETWEEN '00:00:00' AND '05:59:59' THEN 'Night'
            WHEN CAST(a.Time AS TIME) BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
            WHEN CAST(a.Time AS TIME) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
            WHEN CAST(a.Time AS TIME) BETWEEN '18:00:00' AND '23:59:59' THEN 'Evening'
        END AS Time_Of_Day
    FROM Accidents a
)
SELECT 
    Time_Of_Day,
    Accident_Severity, 
    COUNT(Accident_Index) AS Total_Accidents
FROM AccidentTimes
GROUP BY Time_Of_Day, Accident_Severity
ORDER BY Time_Of_Day, Accident_Severity;
------------------------------------------------------------------------
--- 11. Accidents by Police Force ---
------------------------------------------------------------------------
SELECT 
    Police_Force, 
    COUNT(Accident_Index) AS Total_Accidents
FROM 
    Accidents
GROUP BY 
    Police_Force
ORDER BY 
  Total_Accidents DESC

------------------------------------------------------------------------
--- 12. Casualties per Accident by Light Condition ---
------------------------------------------------------------------------
SELECT 
    c.Light_Conditions, 
    ROUND(AVG(a.Number_of_Casualties), 2) AS Avg_Casualties
FROM 
    Accidents a
JOIN 
    Conditions c ON a.Condition_ID = c.Condition_ID
GROUP BY 
    c.Light_Conditions
ORDER BY 
    Avg_Casualties DESC;
------------------------------------------------------------------------
--- 13. Urban vs. Rural Accidents ---
------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN c.Urban_or_Rural_Area = 1 THEN 'Urban'
        WHEN c.Urban_or_Rural_Area = 0 THEN 'Rural'
    END AS Area_Type,
    COUNT(*) AS Total_Accidents
FROM 
    Accidents a 
JOIN 
    Conditions c ON a.Condition_ID = c.Condition_ID
GROUP BY 
    CASE 
        WHEN c.Urban_or_Rural_Area = 1 THEN 'Urban'
        WHEN c.Urban_or_Rural_Area = 0 THEN 'Rural'
    END;

	

------------------------------------------------------------------------
--- 14.Top 5 Most Dangerous Roads by Number of Accidents ---
------------------------------------------------------------------------

SELECT TOP 5 
    r.First_Road_Class, 
    r.First_Road_Number, 
    COUNT(a.Accident_Index) AS Total_Accidents
FROM 
    Roads r
JOIN 
    Accidents a ON r.Road_ID = a.Road_ID
GROUP BY 
    r.First_Road_Class, r.First_Road_Number
ORDER BY 
    Total_Accidents DESC;

------------------------------------------------------------------------
--- 15.Accidents by Hour of the Day. ---
------------------------------------------------------------------------
SELECT 
    DATEPART(HOUR, Time) AS Accident_Hour, 
    COUNT(*) AS Total_Accidents
FROM 
    Accidents
GROUP BY 
    DATEPART(HOUR, Time)
ORDER BY 
    Accident_Hour;
------------------------------------------------------------------------
--- 16.Average Number of Accidents on Weekends vs. Weekdays ---
------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN DATEPART(WEEKDAY, Date) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    COUNT(Accident_Index) AS Total_Accidents
FROM 
    Accidents
GROUP BY 
    CASE 
        WHEN DATEPART(WEEKDAY, Date) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END;


------------------------------------------------------------------------
--- 17.Accidents Within a Specific Date Range ---
------------------------------------------------------------------------
SELECT 
    COUNT(*) AS Total_Accidents
FROM 
    Accidents
WHERE 
    Date BETWEEN '2005-01-01' AND '2005-12-31';

------------------------------------------------------------------------
--- 18.Monthly Trend of Accidents Over Years ---
------------------------------------------------------------------------
SELECT 
    YEAR(Date) AS Accident_Year,
    MONTH(Date) AS Accident_Month,
    COUNT(*) AS Total_Accidents
FROM 
    Accidents
GROUP BY 
    YEAR(Date), MONTH(Date)
ORDER BY 
    Accident_Year, Accident_Month;
