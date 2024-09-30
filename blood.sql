create database healthcare;

use healthcare;


-- Top 5 Records by Monetary Value:

SELECT * FROM Blood
ORDER BY Monetary DESC
LIMIT 5;


-- Average Monetary Value by Class:

SELECT Class, AVG(Monetary) AS Avg_Monetary
FROM Blood
GROUP BY Class;


-- Count of Records by Class:

SELECT Class, COUNT(*) AS Record_Count
FROM Blood
GROUP BY Class;


-- Total Monetary Value by Recency:

SELECT Recency, SUM(Monetary) AS Total_Monetary
FROM Blood
GROUP BY Recency;


-- Maximum and Minimum Monetary Value:

SELECT MAX(Monetary) AS Max_Monetary, MIN(Monetary) AS Min_Monetary
FROM Blood;


-- Average Monetary Value Over Time:

SELECT Time, AVG(Monetary) AS Avg_Monetary
FROM Blood
GROUP BY Time;


-- Top 3 Months with Highest Average Monetary Value:

SELECT Time, AVG(Monetary) AS Avg_Monetary
FROM Blood
GROUP BY Time
ORDER BY Avg_Monetary DESC
LIMIT 3;


-- Percentage Change in Monetary Value Month-over-Month:

SELECT t1.Time AS Current_Month, 
       t2.Time AS Previous_Month,
       ((t1.Avg_Monetary - t2.Avg_Monetary) / t2.Avg_Monetary) * 100 AS Percentage_Change
FROM (SELECT Time, AVG(Monetary) AS Avg_Monetary FROM Blood GROUP BY Time) t1
LEFT JOIN (SELECT Time, AVG(Monetary) AS Avg_Monetary FROM Blood GROUP BY Time) t2
ON t1.Time = t2.Time + 1;


-- Total Monetary Value by Class:

SELECT Class, SUM(Monetary) AS Total_Monetary
FROM Blood
GROUP BY Class;


-- Average Frequency and Monetary Value by Class:

SELECT Class, AVG(Frequency) AS Avg_Frequency, AVG(Monetary) AS Avg_Monetary
FROM Blood
GROUP BY Class;


-- Class with Highest Average Recency:

SELECT Class
FROM Blood
GROUP BY Class
ORDER BY AVG(Recency) DESC
LIMIT 1;


-- Records with Highest Frequency and Monetary Values:

SELECT * 
FROM Blood
WHERE Frequency = (SELECT MAX(Frequency) FROM Blood)
AND Monetary = (SELECT MAX(Monetary) FROM Blood);


-- Average Recency for High Frequency Records:

SELECT AVG(Recency) AS Avg_Recency
FROM Blood
WHERE Frequency > (SELECT AVG(Frequency) FROM Blood);


-- Top 10% Records by Recency and Frequency:

SELECT *
FROM (SELECT *, NTILE(10) OVER (ORDER BY Recency DESC, Frequency DESC) AS Percentile
      FROM Blood) AS Subquery
WHERE Percentile = 1;


-- Correlation Between Recency and Frequency:

SELECT
    (SUM(Recency * Frequency) - SUM(Recency) * SUM(Frequency) / COUNT(*)) /
    (SQRT(SUM(Recency * Recency) - SUM(Recency) * SUM(Recency) / COUNT(*)) *
     SQRT(SUM(Frequency * Frequency) - SUM(Frequency) * SUM(Frequency) / COUNT(*)))
    AS Correlation_Recency_Frequency
FROM Blood;



-- Recency vs. Monetary Value (Classified by Recency Buckets):

SELECT CASE 
           WHEN Recency <= 5 THEN '0-5'
           WHEN Recency BETWEEN 6 AND 10 THEN '6-10'
           ELSE '11+'
       END AS Recency_Bucket,
       AVG(Monetary) AS Avg_Monetary
FROM Blood
GROUP BY Recency_Bucket;


-- Top 5% Highest Monetary Values by Recency Bucket:

SELECT *
FROM (SELECT *, NTILE(100) OVER (PARTITION BY CASE 
                                                   WHEN Recency <= 5 THEN '0-5'
                                                   WHEN Recency BETWEEN 6 AND 10 THEN '6-10'
                                                   ELSE '11+'
                                               END ORDER BY Monetary DESC) AS Percentile
      FROM Blood) AS Subquery
WHERE Percentile <= 5;


-- Find Classes with Higher than Average Monetary Value for Their Records:


SELECT Class
FROM (SELECT Class, AVG(Monetary) AS Avg_Monetary
      FROM Blood
      GROUP BY Class) AS Subquery
WHERE Avg_Monetary > (SELECT AVG(Monetary) FROM Blood);


-- Top 10 Records by Monetary-to-Frequency Ratio:

SELECT *, (Monetary / Frequency) AS Ratio
FROM Blood
ORDER BY Ratio DESC
LIMIT 10;


-- Find Records Where Monetary is Greater than Average for Recency:

SELECT * FROM Blood t
WHERE Monetary > (SELECT AVG(Monetary) FROM Blood WHERE Recency = t.Recency);


-- Check for Duplicate Records Based on All Fields:

SELECT Recency, Frequency, Monetary, Time, Class, COUNT(*)
FROM Blood
GROUP BY Recency, Frequency, Monetary, Time, Class
HAVING COUNT(*) > 1;


-- Find Records with Missing or Null Values:

SELECT *
FROM Blood
WHERE Recency IS NULL OR Frequency IS NULL OR Monetary IS NULL OR Time IS NULL OR Class IS NULL;


-- Identify Outliers Based on Z-Score of Monetary Value:

SELECT Recency, Frequency, Monetary, Time, Class,
       (Monetary - (SELECT AVG(Monetary) FROM Blood)) / (SELECT STDDEV(Monetary) FROM Blood) AS Z_Score
FROM Blood
HAVING ABS(Z_Score) > 3;


-- Summarize Data Quality Metrics:

SELECT COUNT(*) AS Total_Records,
       SUM(CASE WHEN Recency IS NULL OR Frequency IS NULL OR Monetary IS NULL OR Time IS NULL OR Class IS NULL THEN 1 ELSE 0 END) AS Missing_Values,
       COUNT(DISTINCT Recency, Frequency, Monetary, Time, Class) AS Unique_Records
FROM Blood;


-- Identify Patterns in Frequency and Monetary Over Time:

SELECT Time, 
       AVG(Frequency) AS Avg_Frequency, 
       AVG(Monetary) AS Avg_Monetary
FROM Blood
GROUP BY Time
ORDER BY Time;


-- Correlation Between Recency and Monetary Value:

SELECT 
    (SUM((Recency - avg_recency) * (Monetary - avg_monetary)) / COUNT(*)) / 
    (SQRT(SUM(POW(Recency - avg_recency, 2)) / COUNT(*)) * 
     SQRT(SUM(POW(Monetary - avg_monetary, 2)) / COUNT(*))) AS Correlation_Recency_Monetary
FROM 
    (SELECT 
         Recency, 
         Monetary, 
         AVG(Recency) OVER () AS avg_recency, 
         AVG(Monetary) OVER () AS avg_monetary
     FROM Blood) AS subquery;



-- Percentage of Total Monetary for Each Recency Bucket:

SELECT CASE 
           WHEN Recency <= 5 THEN '0-5'
           WHEN Recency BETWEEN 6 AND 10 THEN '6-10'
           ELSE '11+'
       END AS Recency_Bucket,
       SUM(Monetary) AS Total_Monetary,
       (SUM(Monetary) / (SELECT SUM(Monetary) FROM Blood)) * 100 AS Percentage_Of_Total
FROM Blood
GROUP BY Recency_Bucket;


-- Distribution of Monetary Values Within Each Recency Category:

SELECT CASE 
           WHEN Recency <= 5 THEN '0-5'
           WHEN Recency BETWEEN 6 AND 10 THEN '6-10'
           ELSE '11+'
       END AS Recency_Category,
       COUNT(*) AS Record_Count,
       AVG(Monetary) AS Avg_Monetary
FROM Blood
GROUP BY Recency_Category;


-- Find High-Value Records Based on Multiple Criteria:

SELECT * FROM Blood
WHERE Monetary > (SELECT AVG(Monetary) FROM Blood) AND Frequency > (SELECT AVG(Frequency) FROM Blood);


                  
-- Records with Monetary Value Greater than the Average of Their Class:

SELECT *
FROM Blood t1
WHERE Monetary > (SELECT AVG(Monetary) 
                   FROM Blood t2
                   WHERE t2.Class = t1.Class);




-- Complex Aggregation with Multiple Criteria (Top 10 Recency with Highest Monetary Average):

SELECT Recency, AVG(Monetary) AS Avg_Monetary
FROM Blood
GROUP BY Recency
ORDER BY Avg_Monetary DESC
LIMIT 10;


-- Compare Recency and Monetary Values Between Two Classes:

SELECT Class, 
       AVG(Recency) AS Avg_Recency, 
       AVG(Monetary) AS Avg_Monetary
FROM Blood
GROUP BY Class
HAVING Class IN ('Class1', 'Class2');


-- Trend Analysis of Monetary Values Over Time for Different Recency Ranges:

SELECT Time, 
       CASE 
           WHEN Recency <= 5 THEN '0-5'
           WHEN Recency BETWEEN 6 AND 10 THEN '6-10'
           ELSE '11+'
       END AS Recency_Range,
       AVG(Monetary) AS Avg_Monetary
FROM Blood
GROUP BY Time, Recency_Range
ORDER BY Time, Recency_Range;


-- Find Records with Monetary Values Deviating Significantly from Class Average:

SELECT Recency, Frequency, Monetary, Time, Class
FROM Blood
WHERE ABS(Monetary - (SELECT AVG(Monetary) FROM Blood WHERE Class = Blood.Class)) > (SELECT STDDEV(Monetary) FROM Blood WHERE Class = Blood.Class);


-- Percentage of Records per Recency Bucket by Class:

SELECT Class, 
       CASE 
           WHEN Recency <= 5 THEN '0-5'
           WHEN Recency BETWEEN 6 AND 10 THEN '6-10'
           ELSE '11+'
       END AS Recency_Bucket,
       COUNT(*) AS Count,
       (COUNT(*) / (SELECT COUNT(*) FROM Blood WHERE Class = Blood.Class)) * 100 AS Percentage
FROM Blood
GROUP BY Class, Recency_Bucket;


-- Detailed Comparison of Frequency and Monetary Across Time Buckets:

SELECT Time, 
       AVG(Frequency) AS Avg_Frequency, 
       AVG(Monetary) AS Avg_Monetary,
       MAX(Frequency) AS Max_Frequency,
       MAX(Monetary) AS Max_Monetary
FROM Blood
GROUP BY Time;


-- Find Records with Highest Monetary Value per Recency Bucket (Using Window Functions):

SELECT Recency, Frequency, Monetary, Time, Class
FROM (
    SELECT *, RANK() OVER (PARTITION BY Recency ORDER BY Monetary DESC) AS `Rank`
    FROM Blood
) AS Subquery
WHERE `Rank` = 1;



-- Identify Records with Recency and Monetary Value Exceeding Historical Averages:

SELECT *
FROM Blood
WHERE Recency > (SELECT AVG(Recency) FROM Blood)
AND Monetary > (SELECT AVG(Monetary) FROM Blood);


-- Top Recency Buckets by Average Monetary Value (Using Subquery):

SELECT Recency_Bucket, 
       AVG(Monetary) AS Avg_Monetary
FROM (SELECT *, 
             CASE 
                 WHEN Recency <= 5 THEN '0-5'
                 WHEN Recency BETWEEN 6 AND 10 THEN '6-10'
                 ELSE '11+'
             END AS Recency_Bucket
      FROM Blood) AS Subquery
GROUP BY Recency_Bucket
ORDER BY Avg_Monetary DESC;


-- Aggregate Records with High Recency and Low Frequency:

SELECT Recency, Frequency, SUM(Monetary) AS Total_Monetary
FROM Blood
WHERE Recency > (SELECT AVG(Recency) FROM Blood)
AND Frequency < (SELECT AVG(Frequency) FROM Blood)
GROUP BY Recency, Frequency;


-- Monthly Trends in Monetary and Frequency Values:

SELECT Time, 
       AVG(Frequency) AS Avg_Frequency, 
       AVG(Monetary) AS Avg_Monetary,
       MAX(Frequency) AS Max_Frequency,
       MAX(Monetary) AS Max_Monetary
FROM Blood
GROUP BY Time
ORDER BY Time;


-- Perform Chi-Square Test for Independence Between Class and Recency Bucket:

-- Example assumes use of MySQL variables for chi-square calculation
SET @total_records = (SELECT COUNT(*) FROM Blood);
SET @class_recency_counts = (SELECT COUNT(*) 
                             FROM (SELECT Recency, Class, COUNT(*) AS Count 
                                   FROM Blood 
                                   GROUP BY Recency, Class) AS Counts);

                                 
                                 
-- Find Anomalies in Monetary Values Based on Z-Scores:

SELECT *, (Monetary - (SELECT AVG(Monetary) FROM Blood)) / (SELECT STDDEV(Monetary) FROM Blood) AS Z_Score
FROM Blood
HAVING ABS(Z_Score) > 3;


-- Calculate Moving Average of Monetary Values Over Time:

SELECT Time, 
       AVG(Monetary) OVER (ORDER BY Time ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Moving_Avg
FROM Blood;


-- Analyze Distribution of Monetary Values Across Recency Buckets with Histograms:

SELECT CASE 
           WHEN Recency <= 5 THEN '0-5'
           WHEN Recency BETWEEN 6 AND 10 THEN '6-10'
           ELSE '11+'
       END AS Recency_Bucket,
       COUNT(*) AS Count,
       AVG(Monetary) AS Avg_Monetary
FROM Blood
GROUP BY Recency_Bucket;