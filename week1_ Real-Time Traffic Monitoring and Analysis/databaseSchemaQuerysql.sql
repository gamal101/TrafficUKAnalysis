CREATE TABLE Roads (
    Road_ID INT PRIMARY KEY IDENTITY(1,1),
    First_Road_Class INT,
    First_Road_Number INT,
    Road_Type VARCHAR(100),
    Speed_limit INT,
    Junction_Control VARCHAR(100),
    Second_Road_Class INT,
    Second_Road_Number INT
);


CREATE TABLE Conditions (
    Condition_ID INT PRIMARY KEY IDENTITY(1,1),
    Pedestrian_Crossing_Human_Control VARCHAR(100),
    Pedestrian_Crossing_Physical_Facilities VARCHAR(100),
    Light_Conditions VARCHAR(100),
    Weather_Conditions VARCHAR(100),
    Road_Surface_Conditions VARCHAR(100),
    Special_Conditions_at_Site VARCHAR(100),
    Carriageway_Hazards VARCHAR(100),
    Urban_or_Rural_Area INT
);

CREATE TABLE Authorities (
    Authority_ID INT PRIMARY KEY IDENTITY(1,1),
    Local_Authority_District INT,
    Local_Authority_Highway VARCHAR(100)
);

CREATE TABLE Accidents (
    Accident_Index INT PRIMARY KEY IDENTITY(1,1),
    Location_Easting_OSGR INT,
    Location_Northing_OSGR INT,
    Longitude FLOAT,
    Latitude FLOAT,
    Police_Force INT,
    Accident_Severity INT,
    Number_of_Vehicles INT,
    Number_of_Casualties INT,
    Date DATE,
    Day_of_Week INT,
    Time TIME,
    Year INT,
    Did_Police_Officer_Attend_Scene_of_Accident INT,
    Road_ID INT,  -- Foreign key connecting to Roads
    Condition_ID INT,  -- Foreign key connecting to Conditions
    FOREIGN KEY (Road_ID) REFERENCES Roads(Road_ID),
    FOREIGN KEY (Condition_ID) REFERENCES Conditions(Condition_ID)
);


CREATE TABLE Accident_Authority (
    Accident_Index INT,
    Authority_ID INT,
    PRIMARY KEY (Accident_Index, Authority_ID),
    FOREIGN KEY (Accident_Index) REFERENCES Accidents(Accident_Index),
    FOREIGN KEY (Authority_ID) REFERENCES Authorities(Authority_ID)
);
drop table Accident_Authority, Accidents,Authorities,Roads,Conditions
create database trafficuk
