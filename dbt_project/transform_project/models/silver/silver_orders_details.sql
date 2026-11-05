{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        database='Silver',
        unique_key='Order_Details_ID',
        engine='MergeTree()',
        order_by='Order_ID'
    )
}}

SELECT
    toInt64(coalesce(id, 0)) AS "Order_Details_ID",
    toInt64(coalesce(order_id, 0)) AS "Order_ID",
    toInt64(coalesce(product_id, 0)) AS "Product_ID",
    toInt64(coalesce(quantity, 0)) AS "Quantity",
    toFloat64(coalesce(unit_price, 0)) AS "Unit_Price",
    created_at AS "CREATED_AT",
    updated_at AS "UPDATED_AT"
FROM {{ref('bronze_order_details')}}
{% if is_incremental() %}
    WHERE UPDATED_AT >= (SELECT MAX(UPDATED_AT) - INTERVAL 3 DAY FROM {{this}} WHERE UPDATED_AT>= NOW()- INTERVAL 14 DAY )
{% endif %}

QUALIFY ROW_NUMBER() OVER(PARTITION BY Order_Details_ID ORDER BY UPDATED_AT DESC) = 1

SETTINGS allow_suspicious_low_cardinality_types = 1