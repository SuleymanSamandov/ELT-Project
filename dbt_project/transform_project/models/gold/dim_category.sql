{{
    config(
        materialized='table',
        database='Gold',
        engine='MergeTree()',
        order_by='Category_ID'
    )
}}

WITH DIM_CATEGORY AS
(
    SELECT
        CategoryID as "Category_ID",
        `Category Name` AS Category_Name,
        Description
    FROM {{ ref('silver_category') }}
)

SELECT
{{ dbt_utils.generate_surrogate_key(['Category_ID','Category_Name','Description']) }} AS Category_SK,
Category_ID,
Category_Name,
Description
FROM DIM_CATEGORY