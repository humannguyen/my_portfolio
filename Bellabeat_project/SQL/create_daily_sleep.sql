-- Create a new table called `daily_sleep` in the main dataset 
CREATE TABLE `capstoneproject-429913.fitabase.daily_sleep` AS
	-- Aggregate sleep data by day from March 12, 2016 - April 11, 2016
	SELECT
	  Id,
	  -- Extract the date from a datetime
	  EXTRACT(DATE FROM date_time) AS SleepDate,
	  -- Count the number of value [1] to create TotalMinutesAsleep column
	  COUNT(CASE WHEN value = 1 THEN 1 END) AS TotalMinutesAsleep,
	  -- Count the total number of values to create TotalTimeInBed column
	  COUNT(value) AS TotalTimeInBed
	FROM 
	  -- Subquery to select and parse date values
	  (
	    SELECT DISTINCT
		    Id,
        PARSE_DATETIME('%m/%d/%Y %I:%M:%S %p', date) AS date_time,
        value
	    -- "minuteSleep_merged" table from "Fitabase Data 3.12.16-4.11.16" folder
	    FROM `capstoneproject-429913.fitbit_data.minuteSleep_1203-1204`
	    -- Exclude rows where the parsed date is '2016-04-12'
	    WHERE EXTRACT(DATE FROM PARSE_DATETIME('%m/%d/%Y %I:%M:%S %p', date)) != '2016-4-12'
	  )
	-- Group the count function by Id and SleepDate
	GROUP BY Id, SleepDate
UNION ALL
	-- Aggregate sleep data by day from April 12, 2016 - May 12, 2016
	SELECT
	  Id,
	  -- Extract the date from a datetime
	  EXTRACT(DATE FROM DateTime) AS SleepDate,
	  -- Count the number of value [1] to create TotalMinutesAsleep column
	  COUNT(CASE WHEN value = 1 THEN 1 END) AS TotalMinutesAsleep,
	  -- Count the total number of values to create TotalTimeInBed column
	  COUNT(value) AS TotalTimeInBed
	FROM
		-- Subquery to select and parse date values
	  (
		  -- SELECT DISTINCT to avoid duplicates
		  SELECT DISTINCT
		    Id,
		    -- Converts 'date' column from STRING to a DATETIME format
		    PARSE_DATETIME('%m/%d/%Y %I:%M:%S %p', date) AS DateTime,
		    value
		  -- "minuteSleep_merged" table from "Fitabase Data 4.12.16-5.12.16" folder
		  FROM `capstoneproject-429913.fitbit_data.minuteSleep_1204-1205`
		  -- Exclude rows where the parsed date is '2016-04-11'
		  WHERE EXTRACT(DATE FROM PARSE_DATETIME('%m/%d/%Y %I:%M:%S %p', date)) != '2016-4-11'
	  )
	-- Group the count function by Id and SleepDate
	GROUP BY Id, SleepDate
ORDER BY Id, SleepDate