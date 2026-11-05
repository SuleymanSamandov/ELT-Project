{{
    config(
        materialized='table',
        database='Gold',
        engine='MergeTree()',
        unique_key='datekey'
    )
}}


WITH RECURSIVE dates  as (
SELECT toDate('2025-01-01') as date

UNION ALL

SELECT date + interval 1 DAY 
FROM dates 
WHERE date < toDate('2040-01-01')
)
SELECT
toUInt32(toYYYYMMDD(date)) as datekey,
date,
toYear(date) as year,
toMonth(date) as month,
toDayOfMonth(date) as day
FROM dates  
SETTINGS max_recursive_cte_evaluation_depth = 6000