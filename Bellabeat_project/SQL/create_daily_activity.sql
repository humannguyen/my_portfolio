-- Create merged table for daily activity
CREATE TABLE `capstoneproject-429913.fitabase.DailyActivity` AS
	-- 'dailyActivity_merged.csv' table from ”Fitabase Data 3.12.16-4.11.16” folder
	SELECT * FROM `capstoneproject-429913.fitbit_data.dailyActivity_1203-1104`
UNION ALL 
	-- 'dailyActivity_merged.csv' table from “Fitabase Data 4.12.16-5.12.16” folder
	SELECT * FROM `capstoneproject-429913.fitbit_data.dailyActivity_1204-1205`
ORDER BY Id, ActivityDate;

-- Checking for duplicate primary key
SELECT
    Id,
    ActivityDate,
    COUNT(*) AS count
FROM `capstoneproject-429913.fitabase.DailyActivity`
GROUP BY
    Id,
    ActivityDate
HAVING
    COUNT(*) > 1