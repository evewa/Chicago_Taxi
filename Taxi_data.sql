/* Evelyn Watson, Chicago taxi Dataset Project; SQL cleaning file
10/13/2026
*/
USE chicago_taxi
GO
/*SELECT *
from tripdata*/

--Profile the data first
SELECT
    COUNT(*) AS total_records
From tripdata
-- checking that Date range data begins Aug 1. I noticed that my worksheet data had Row count (1,048,575) matches Excel's row limit, so the file was likely truncated before import
SELECT MIN([Trip Start Timestamp]) AS first_trip,
       MAX([Trip Start Timestamp]) AS last_trip
FROM tripdata;
-- Check for duplicate trip IDs
SELECT
    [Trip ID],
    COUNT(*) AS record_count
FROM tripdata
GROUP BY [Trip ID]
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

-- Missing-value check across key fields. Missing census tract and community area
-- values are expected (the City masks some locations for privacy); these trips were retained.
SELECT
    SUM(CASE WHEN [Trip ID] IS NULL OR LTRIM(RTRIM([Trip ID])) = '' 
    THEN 1 
    ELSE 0 
    END) AS missing_trip_id,
    SUM(CASE WHEN [Taxi ID] IS NULL OR LTRIM(RTRIM([Taxi ID])) = '' 
    THEN 1 ELSE 0 END) AS missing_taxi_id,
    SUM(CASE WHEN [Trip Start Timestamp] IS NULL THEN 1 
    ELSE 0 
    END) AS missing_start,
    SUM(CASE WHEN [Trip End Timestamp] IS NULL 
    THEN 1 
    ELSE 0 
    END) AS missing_end,
    SUM(CASE WHEN [Trip Seconds] IS NULL 
    THEN 1 
    ELSE 0 
    END) AS missing_seconds,
    SUM(CASE WHEN [Trip Miles] IS NULL 
    THEN 1 
    ELSE 0 
    END) AS missing_miles,
    SUM(CASE WHEN [Pickup Census Tract] IS NULL 
    THEN 1 
    ELSE 0 
    END) AS missing_pickup_tract,
    SUM(CASE WHEN [Dropoff Census Tract] IS NULL 
    THEN 1 
    ELSE 0 
    END) AS missing_dropoff_tract,
    SUM(CASE WHEN [Pickup Community Area] IS NULL 
    THEN 1 
    ELSE 0 
    END) AS missing_pickup_area,
    SUM(CASE WHEN [Dropoff Community Area] IS NULL 
    THEN 1 
    ELSE 0 
    END) 
    AS missing_dropoff_area,
    SUM(CASE WHEN [Fare] IS NULL 
    THEN 1
    ELSE 0 
    END) AS missing_fare,
    SUM(CASE WHEN [Trip Total] IS NULL 
    THEN 1 
    ELSE 0 
    END) AS missing_trip_total,
    SUM(CASE WHEN [Payment Type] IS NULL OR LTRIM(RTRIM([Payment Type])) = '' 
    THEN 1 
    ELSE 0 
    END) AS missing_payment_type,
    SUM(CASE WHEN [Company] IS NULL OR LTRIM(RTRIM([Company])) = '' 
    THEN 1 
    ELSE 0 
    END) AS missing_company
FROM tripdata;

-- Are timestamps on 15-minute marks? are they rounded?
SELECT DATEPART(MINUTE, [Trip Start Timestamp]) AS minute_mark, COUNT(*) AS trips
FROM tripdata
GROUP BY DATEPART(MINUTE, [Trip Start Timestamp])
ORDER BY minute_mark;

SELECT
    SUM(CASE WHEN [Trip Seconds] % 60 = 0 THEN 1 ELSE 0 END) AS whole_minutes,
    SUM(CASE WHEN [Trip Seconds] % 60 <> 0 THEN 1 ELSE 0 END) AS not_whole_minutes
FROM tripdata;

-- check our times, negative values, huge outliers, durations set to "0" of duration
SELECT
    MIN([Trip Seconds]) 
    AS minimum_seconds, 
    MAX([Trip Seconds]) 
    AS maximum_seconds, --85235 seconds max = 1420.53 minutes or 23.67  hours..
    AVG(CAST([Trip Seconds] AS FLOAT)) 
    AS average_seconds
FROM tripdata;

SELECT *
FROM tripdata
WHERE [Trip Seconds] < 0; -- Negative value check

-- looking at the info on the zero-duration trips and the almost day long trip
SELECT *
FROM tripdata
WHERE [Trip Seconds] = 0 AND [Trip Miles] <> 0;

SELECT
    MIN([Trip Miles]) AS minimum_miles,
    MAX([Trip Miles]) AS maximum_miles, -- 725 mile maximum.. need to check distribution
    AVG(CAST([Trip Miles] AS FLOAT)) AS average_miles
FROM tripdata;

-- checking outlier distribution to see how far out those Max values were
SELECT DISTINCT
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY [Trip Miles]) OVER () AS median_miles,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY [Trip Miles]) OVER () AS p99_miles,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY [Trip Seconds]) OVER () AS median_secs,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY [Trip Seconds]) OVER () AS p99_secs
FROM tripdata;
/* Flagging outliers and handle through calculated fields in tableau to avoid having to reset connections
so trip counts and revenue reconcile to the source table. Rules:
Bad Distance: > 100 miles; > 80 mph on trips of 3+ minutes; or zero seconds and zero miles
Bad Duration: > 14,400 seconds (4 hours); or zero seconds and zero miles
Flagged trips stay in counts and revenue, and are excluded only from averages and per-mile rates. */
--checking timestamps for negatives again
SELECT COUNT(*) AS invalid_timestamp_order
FROM tripdata
WHERE [Trip End Timestamp] < [Trip Start Timestamp];

SELECT TOP 100
    [Trip ID],
    [Trip Start Timestamp],
    [Trip End Timestamp],
    [Trip Seconds],
    DATEDIFF(SECOND, [Trip Start Timestamp], [Trip End Timestamp]) AS calculated_seconds
FROM tripdata
ORDER BY calculated_seconds DESC;

-- Check if there are differences in duration, validate that the duration recorded actually matches the calculation
SELECT COUNT(*) AS duration_mismatches
FROM tripdata
WHERE ABS(
    DATEDIFF(SECOND, [Trip Start Timestamp], [Trip End Timestamp])
    - [Trip Seconds]
) > 900;


-- View for the Geographic Activity dashboard: one row per community area, company, and
-- direction (pickup/dropoff). Additive measures (sums) let Tableau compute weighted rates.

/*
GO
 CREATE VIEW vw_area_flow AS 
 SELECT
    'Pickup' AS direction,
    [Pickup Community Area] AS community_area,
    company,
    COUNT(*) AS trips,
    SUM([Trip Total]) AS revenue
FROM tripdata
WHERE [Pickup Community Area] IS NOT NULL
GROUP BY [Pickup Community Area], company

UNION ALL

SELECT
    'Dropoff',
    [Dropoff Community Area],
    company,
    COUNT(*),
    SUM([Trip Total])
FROM tripdata
WHERE [Dropoff Community Area] IS NOT NULL
GROUP BY [Dropoff Community Area], company; */

-- extend the view with some aggregated columns and then calculate rates in tableau
GO

CREATE OR ALTER VIEW vw_area_flow AS
SELECT
    'Pickup' AS direction,
    [Pickup Community Area] AS community_area,
    company,
    COUNT(*) AS trips,
    SUM(Fare) AS fare_sum,
    SUM(tips) AS tips_sum,
    SUM([Trip Total]) AS revenue,
    SUM([Trip Miles]) AS miles_sum,
    SUM([Trip Seconds]) AS seconds_sum
FROM tripdata
WHERE [Pickup Community Area] IS NOT NULL
GROUP BY [Pickup Community Area], company


UNION ALL

SELECT
    'Dropoff',
    [Dropoff Community Area],
    company,
    COUNT(*),
    SUM(fare),
    SUM(tips),
    SUM([Trip Total]),
    SUM([Trip Miles]),
    SUM([Trip Seconds])
FROM tripdata
WHERE [Dropoff Community Area] IS NOT NULL
GROUP BY [Dropoff Community Area], company;

-- The fare pie chart seemed off with "unknown" payment types
SELECT Company,
       COUNT(*) AS trips,
       AVG([Trip Miles]) AS avg_miles,
       AVG(CAST([Trip Seconds] AS float)) AS avg_secs
FROM tripdata
WHERE [Trip Total] = 0 AND [Payment Type] = 'Unknown'
GROUP BY Company
ORDER BY trips DESC;

-- “Unknown-payment trips with zero totals don’t match the 0.21% on the dashboard; lets check the full payment breakdown

SELECT [Payment Type],
       COUNT(*) AS trips,
       SUM(CASE WHEN [Trip Total] = 0 THEN 1 ELSE 0 END) AS zero_total_trips,
       CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS decimal(6,3)) AS pct_of_trips
FROM tripdata
GROUP BY [Payment Type]
ORDER BY trips DESC;