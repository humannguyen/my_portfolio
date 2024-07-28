-- Create a summarize table 'users_summarize'
CREATE TABLE `capstoneproject-429913.fitabase.users_summarize` AS
SELECT
	-- Select all columns from the Activity subquery
  Activity.*,
  -- If SleepType is null, set it to 'Unclassified'
  COALESCE(Sleep.SleepType,'Unclassified') AS SleepType,
FROM 
  -- Subquery to aggregate metrics from daily activity data
  (
    WITH
      -- CTE to calculate average metrics by user 
      AvgByUser AS
        (
          SELECT
            Id,
            COUNT(ActivityDate) AS TotalUsedDays,
            AVG(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes) AS AvgMinsUsed,
            AVG(TotalSteps) AS AvgSteps,
            AVG(Calories) AS AvgCalories,
            AVG(VeryActiveMinutes) AS AvgVery,
            AVG(FairlyActiveMinutes) AS AvgFairly,
            AVG(LightlyActiveMinutes) AS AvgLightly,
            AVG(SedentaryMinutes) AS AvgSedentary,
          FROM `capstoneproject-429913.fitabase.daily_activity` 
          GROUP BY Id
        ),
      -- CTE to calculate the differences between individual and overall averages
      Diff AS
        (
          SELECT
            Id,
            ((AvgVery - TotalVery)/TotalVery) AS DiffVery,
            ((AvgFairly - TotalFairly)/TotalFairly) AS DiffFairly,
            ((AvgLightly - TotalLightly)/TotalLightly) AS DiffLightly,
            ((AvgSedentary - TotalSedentary)/TotalSedentary) AS DiffSedentary,
          FROM
            -- Cross join AvgByUser CTE with overall averages
            AvgByUser,
            (
              -- Subquery to calculate overall averages
              SELECT
                AVG(AvgVery) AS TotalVery,
                AVG(AvgFairly) AS TotalFairly,
                AVG(AvgLightly) AS TotalLightly,
                AVG(AvgSedentary) AS TotalSedentary
              FROM AvgByUser
            )
        )
    -- Select the final results from the Diff CTE and join it with the AvgByUser CTE
    SELECT
      AvgByUser.Id,
      TotalUsedDays,
      ROUND(AvgMinsUsed,1) AS AvgMinsUsed,
      ROUND(AvgSteps,1) AS AvgSteps,
      ROUND(AvgCalories,1) AS AvgCalories,
      ROUND(AvgVery,1) AS AvgVeryActive,
      ROUND(AvgFairly,1) AS AvgFairlyActive,
      ROUND(AvgLightly,1) AS AvgLightlyActive,
      ROUND(AvgSedentary,1) AS AvgSedentary,
      -- Determine the activity type with the greatest relavtive difference from overall averages
      CASE 
        WHEN GREATEST(DiffVery, DiffFairly, DiffLightly, DiffSedentary) = DiffVery THEN 'Very Active'
        WHEN GREATEST(DiffVery, DiffFairly, DiffLightly, DiffSedentary) = DiffFairly THEN 'Fairly Active'
        WHEN GREATEST(DiffVery, DiffFairly, DiffLightly, DiffSedentary) = DiffLightly THEN 'Lightly Active'
        WHEN GREATEST(DiffVery, DiffFairly, DiffLightly, DiffSedentary) = DiffSedentary THEN 'Sedentary'
        ELSE 'Unclassified'
      END AS ActivityType
    FROM Diff JOIN AvgByUser ON Diff.Id = AvgByUser.Id
    ORDER BY Id
  ) AS Activity
LEFT JOIN 
	-- Subquery to determine sleep types
  (
    SELECT
      Id,
      -- Determine the sleep type with the highest percentage
      CASE
        WHEN GREATEST(SleeplessPercent, OversleepPercent, NormalSleepPercent) = SleeplessPercent THEN 'Sleepless'
        WHEN GREATEST(SleeplessPercent, OversleepPercent, NormalSleepPercent) = OversleepPercent THEN 'Oversleep'
        WHEN GREATEST(SleeplessPercent, OversleepPercent, NormalSleepPercent) = NormalSleepPercent THEN 'NormalSleep'
      END AS SleepType
    FROM
	    -- Subquery to calculate sleep type percentage 
      (
        SELECT
          Id,
          COUNT(*) AS TotalRecords,
          COUNT(CASE WHEN TotalMinutesAsleep < 360 THEN 1 END)/COUNT(*) AS SleeplessPercent,
          COUNT(CASE WHEN TotalMinutesAsleep > 480 THEN 1 END)/COUNT(*) AS OversleepPercent,
          COUNT(CASE WHEN TotalMinutesAsleep BETWEEN 360 AND 480 THEN 1 END)/COUNT(*) AS NormalSleepPercent
        FROM
        `capstoneproject-429913.fitabase.daily_sleep`
        GROUP BY Id
         -- Include only users with at least 10 sleep records
        HAVING COUNT(*) >= 10
      )
  ) AS Sleep 
ON Activity.Id = Sleep.Id