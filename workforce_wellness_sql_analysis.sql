/* =========================================
   Workforce Wellness Analytics Project
   SQL Server Analytical Workflow
   Author: Basilis Tsourapis
========================================= */

USE WorkforceWellnessAnalytics;
GO

/* =========================================
   Data Validation & Row Count Checks
========================================= */

SELECT 'HR_Cleaned' AS Table_Name, COUNT(*) AS Rows_Count FROM HR_Cleaned
UNION ALL
SELECT 'Sleep_Cleaned', COUNT(*) FROM Sleep_Cleaned
UNION ALL
SELECT 'Activity_Cleaned', COUNT(*) FROM Activity_Cleaned
UNION ALL
SELECT 'Nutrition_Cleaned', COUNT(*) FROM Nutrition_Cleaned;

/* =========================================
   Sleep Analytics View
========================================= */
CREATE VIEW vw_sleep_analysis AS
SELECT
    Gender,
    Age,
    Occupation,
    Sleep_Duration,
    Quality_of_sleep,
    Stress_Level,
    Daily_Steps,

    CASE
        WHEN Sleep_Duration < 6 THEN 'Poor Sleep'
        WHEN Sleep_Duration BETWEEN 6 AND 7 THEN 'Average Sleep'
        ELSE 'Healthy Sleep'
    END AS Sleep_Group

FROM Sleep_Cleaned;

SELECT TOP 20 *
FROM vw_sleep_analysis;



ALTER VIEW vw_sleep_analysis AS
SELECT
    Gender,
    Age,
    Occupation,

    CASE
        WHEN Sleep_Duration > 10
            THEN CAST(Sleep_Duration / 10.0 AS DECIMAL(3,1))
        ELSE CAST(Sleep_Duration AS DECIMAL(3,1))
    END AS Sleep_Duration,

    Quality_of_sleep,
    Stress_Level,
    Daily_Steps,

    CASE
        WHEN
            CASE
                WHEN Sleep_Duration > 10
                    THEN Sleep_Duration / 10.0
                ELSE Sleep_Duration
            END < 6
        THEN 'Poor Sleep'

        WHEN
            CASE
                WHEN Sleep_Duration > 10
                    THEN Sleep_Duration / 10.0
                ELSE Sleep_Duration
            END BETWEEN 6 AND 7
        THEN 'Average Sleep'

        ELSE 'Healthy Sleep'
    END AS Sleep_Group

FROM Sleep_Cleaned;

SELECT TOP 20 *
FROM vw_sleep_analysis;

/* =========================================
   Burnout Risk Analysis View
========================================= */

CREATE VIEW vw_burnout_risk AS
SELECT
    Department,
    Job_Role,
    Job_Satisfaction,
    WorkLife_Balance,
    Over_Time,
    Performance_Rating,

    CASE
        WHEN Over_Time = 1
             AND WorkLife_Balance <= 2
             AND Job_Satisfaction <= 2
        THEN 'High Burnout Risk'

        WHEN Over_Time = 1
             OR WorkLife_Balance <= 2
        THEN 'Medium Burnout Risk'

        ELSE 'Low Burnout Risk'
    END AS Burnout_Risk

FROM HR_Cleaned;

SELECT TOP 20 *
FROM vw_burnout_risk;

/* =========================================
   Activity & Lifestyle Analysis View
========================================= */

CREATE VIEW vw_activity_analysis AS
SELECT
    Total_Steps,
    Very_Active_Minutes,
    Fairly_Active_Minutes,
    Lightly_Active_Minutes,
    Sedentary_Minutes,
    Calories,

    CASE
        WHEN Total_Steps < 5000
        THEN 'Sedentary'

        WHEN Total_Steps BETWEEN 5000 AND 9000
        THEN 'Moderately Active'

        ELSE 'Highly Active'
    END AS Activity_Level

FROM Activity_Cleaned;

SELECT TOP 20 *
FROM vw_activity_analysis;

/* =========================================
   Nutrition Behavior Analysis View
========================================= */

CREATE VIEW vw_nutrition_analysis AS
SELECT
    Alcohol_Consumption,
    High_Calorie_Food,
    Vegetable_Consumption,
    Meals_Per_Day,
    Smoking,
    Physical_Activity_Frequency,
    Technology_Usage,
    Snacking_Habit,
    Obesity_Category,

    CASE
        WHEN High_Calorie_Food = 1
             OR Snacking_Habit IN ('Frequently', 'Always')
        THEN 'Poor Nutrition'

        WHEN Vegetable_Consumption >= 3
             AND High_Calorie_Food = 0
        THEN 'Healthy Nutrition'

        ELSE 'Average Nutrition'
    END AS Nutrition_Group

FROM Nutrition_Cleaned;

SELECT TOP 20 *
FROM vw_nutrition_analysis;


SELECT
    Burnout_Risk,
    COUNT(*) AS Employees
FROM vw_burnout_risk
GROUP BY Burnout_Risk
ORDER BY Employees DESC;

SELECT
    Sleep_Group,
    AVG(Sleep_Duration) AS Avg_Sleep,
    AVG(Stress_Level) AS Avg_Stress,
    AVG(Daily_Steps) AS Avg_Steps
FROM vw_sleep_analysis
GROUP BY Sleep_Group;

SELECT
    Activity_Level,
    AVG(Calories) AS Avg_Calories,
    AVG(Sedentary_Minutes) AS Avg_Sedentary_Minutes,
    AVG(Very_Active_Minutes) AS Avg_Active_Minutes
FROM vw_activity_analysis
GROUP BY Activity_Level;

SELECT
    Nutrition_Group,
    COUNT(*) AS People_Count
FROM vw_nutrition_analysis
GROUP BY Nutrition_Group
ORDER BY People_Count DESC;