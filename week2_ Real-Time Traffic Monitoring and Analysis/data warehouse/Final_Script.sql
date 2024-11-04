CREATE DATABASE star_schema_TrafficUK;

CREATE TABLE Dim_Roads (
    Road_ID INT PRIMARY KEY,
    First_Road_Class INT,
    First_Road_Number INT,
    Road_Type VARCHAR(100),
    Speed_limit INT,
    Junction_Control VARCHAR(100),
    Second_Road_Class INT,
    Second_Road_Number INT
);

CREATE TABLE Dim_Conditions (
    Condition_ID INT PRIMARY KEY,
    Pedestrian_Crossing_Human_Control VARCHAR(100),
    Pedestrian_Crossing_Physical_Facilities VARCHAR(100),
    Light_Conditions VARCHAR(100),
    Weather_Conditions VARCHAR(100),
    Road_Surface_Conditions VARCHAR(100),
    Special_Conditions_at_Site VARCHAR(100),
    Carriageway_Hazards VARCHAR(100),
    Urban_or_Rural_Area INT
);

CREATE TABLE Dim_Authorities (
    Authority_ID INT PRIMARY KEY,
    Local_Authority_District INT,
    Local_Authority_Highway VARCHAR(100)
);

CREATE TABLE Dim_Time (
    Time_ID INT PRIMARY KEY IDENTITY(1,1),
    Date DATE,
    Day_of_Week INT,
    Time TIME,
    Year INT
);


CREATE TABLE Fact_Accidents (
    Accident_Index INT PRIMARY KEY,  
    Road_ID INT,  
    Condition_ID INT,  
    Authority_ID INT,  
    Time_ID INT,  
    Number_of_Vehicles INT,
    Number_of_Casualties INT,
    Accident_Severity INT,
    Longitude FLOAT,
    Latitude FLOAT,
    Casualties_Per_Vehicle FLOAT,
    Accidents_Under_Light_Condition INT,
    Most_Common_Accident_Hour INT,
    Is_High_Risk_Area BIT,
	FOREIGN KEY (Time_ID) REFERENCES Dim_Time(Time_ID),
    FOREIGN KEY (Road_ID) REFERENCES Dim_Roads(Road_ID),
    FOREIGN KEY (Condition_ID) REFERENCES Dim_Conditions(Condition_ID),
    FOREIGN KEY (Authority_ID) REFERENCES Dim_Authorities(Authority_ID)
);

----- load measure data -------------------------------------
UPDATE Fact_Accidents
SET Casualties_Per_Vehicle = CASE
    WHEN Number_of_Vehicles = 0 THEN NULL
    ELSE Number_of_Casualties / Number_of_Vehicles
END;


WITH LightConditionAccidents AS (
    SELECT f.Road_ID, COUNT(*) AS AccidentsCount
    FROM Fact_Accidents f
    JOIN Dim_Conditions c ON f.Condition_ID = c.Condition_ID
    WHERE c.Light_Conditions IN ('Daylight: Street light present', 'Darkness: Street lighting unknown','Darkness: Street lights present and lit')
    GROUP BY f.Road_ID
)
UPDATE fa
SET fa.Accidents_Under_Light_Condition = lca.AccidentsCount
FROM Fact_Accidents fa
JOIN LightConditionAccidents lca ON fa.Road_ID = lca.Road_ID;


WITH CommonAccidentHour AS (
    SELECT f.Road_ID, DATEPART(HOUR, t.Time) AS Accident_Hour, COUNT(*) AS Frequency
    FROM Fact_Accidents f
    JOIN Dim_Time t ON f.Time_ID = t.Time_ID
    GROUP BY f.Road_ID, DATEPART(HOUR, t.Time)
)
UPDATE fa
SET fa.Most_Common_Accident_Hour = ca.Accident_Hour
FROM Fact_Accidents fa
JOIN CommonAccidentHour ca ON fa.Road_ID = ca.Road_ID
WHERE ca.Frequency = (SELECT MAX(Frequency) FROM CommonAccidentHour WHERE Road_ID = fa.Road_ID);


WITH HighRiskAreas AS (
    SELECT Road_ID
    FROM Fact_Accidents
    GROUP BY Road_ID
    HAVING COUNT(*) > 100
)
UPDATE fa
SET fa.Is_High_Risk_Area = CASE 
    WHEN fa.Road_ID IN (SELECT Road_ID FROM HighRiskAreas) THEN 1 
    ELSE 0 
END
FROM Fact_Accidents fa;

SELECT * FROM Fact_Accidents;



select * from [dbo].[Fact_Accidents]
select * from[dbo].[Dim_Authorities]
select * from[dbo].[Dim_Conditions]
select * from[dbo].[Dim_Roads]
select * from[dbo].[Dim_Time]