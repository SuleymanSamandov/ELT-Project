{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        database='Silver',
        unique_key='Orders_ID',
        engine='MergeTree()',
        order_by='Orders_ID'
    )
}}


SELECT
toInt64(coalesce(id,0)) AS "Orders_ID", 
customer_id AS "Customer_ID", 
status AS "Status", 
discount AS "Discount", 
tax AS "Tax", 
shipping as "Shipping", 
created_at AS "CREATED_AT", 
updated_at AS "UPDATED_AT"
FROM {{ref('bronze_orders')}}
{% if is_incremental() %}
    WHERE UPDATED_AT >= (SELECT MAX(UPDATED_AT) - INTERVAL 3 DAY FROM {{this}} WHERE UPDATED_AT>= NOW()- INTERVAL 14 DAY )
{% endif %}

QUALIFY ROW_NUMBER() OVER(PARTITION BY Orders_ID ORDER BY UPDATED_AT DESC) = 1

SETTINGS allow_suspicious_low_cardinality_types = 1