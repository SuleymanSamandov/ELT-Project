{{
    config(
        materialized='table',
        target_database='Gold',
        database='Gold',
        target_schema='Gold',
        engine='MergeTree()',
        order_by='ID'
    )
}}

SELECT
    sod.`Order_Details_ID` AS ID,
    sod.`Order_ID`,
    dp.`Product_ID` AS Product_ID,
    dp.`CATEGORY_ID` AS Category_ID,
    c.`Customer_ID` AS Customer_ID,
    toUInt32(toYYYYMMDD(sod.CREATED_AT)) AS DataKey,
    sod.`Quantity`,
    sod.`Unit_Price`,
    sod.`CREATED_AT` AS CREATED_AT,
    sod.`UPDATED_AT` AS UPDATED_AT
FROM {{ ref('silver_orders') }} AS so
LEFT JOIN {{ ref('silver_orders_details') }} AS sod ON so.`Orders_ID` = sod.`Order_ID`
LEFT JOIN {{ ref('dim_products') }} AS dp ON dp.`Product_ID` = sod.`Product_ID`
LEFT JOIN {{ ref('dim_category') }} AS dc ON dp.`CATEGORY_ID` = dc.`Category_ID`
LEFT JOIN {{ ref('dim_customers') }} AS c ON so.`Customer_ID` = c.`Customer_ID`
{% if is_incremental() %}
    WHERE UPDATED_AT>=(SELECT MAX(UPDATED_AT) - INTERVAL 3 DAY FROM {{this}} WHERE UPDATED_AT>=NOW() - INTERVAL 14 DAY)
{% endif %}