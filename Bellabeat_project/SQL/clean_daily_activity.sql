-- Create the table `daily_activity` without the error records
CREATE TABLE `capstoneproject-429913.fitabase.daily_activity` AS
-- Select needed columns (except rn column) where rn = 1
SELECT
    Id,
    ActivityDate,
    TotalSteps,
    TotalDistance,
    TrackerDistance,
    LoggedActivitiesDistance,
    VeryActiveDistance,
    ModeratelyActiveDistance,
    LightActiveDistance,
    SedentaryActiveDistance,
    VeryActiveMinutes,
    FairlyActiveMinutes,
    LightlyActiveMinutes,
    SedentaryMinutes,
    Calories,
FROM
	-- Subquery to handle duplicates
	(
		SELECT
			*,
			-- Assign a unique number to each row in each primary key group 
			ROW_NUMBER() OVER (PARTITION BY Id, ActivityDate ORDER BY ActivityDate DESC) AS rn
		-- Merged table which contain duplicates
    FROM `capstoneproject-429913.fitabase.DailyActivity`
	) AS Duplicates
-- Filter to keep only rows with number 1
WHERE rn = 1
ORDER BY Id, ActivityDate