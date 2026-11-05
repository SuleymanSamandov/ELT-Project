{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        database='Silver',
        unique_key='Product_ID',
        engine='MergeTree()',
        order_by='Product_ID'
    )
}}

SELECT 
	toInt64(COALESCE(p.id,0)) as "Product_ID",
    p.category_id as "CATEGORY_ID",
	p.name as "Porduct Name",
	p.brand as "Brand",
	p.price as "Price",
	p.created_at AS CREATED_AT,
    p.updated_at AS UPDATED_AT
FROM {{ref('bronze_products')}} p
{% if is_incremental() %}
    WHERE UPDATED_AT>=(SELECT MAX(UPDATED_AT) - INTERVAL 3 DAY FROM {{this}} WHERE UPDATED_AT>=NOW() - INTERVAL 14 DAY)
{% endif %}
QUALIFY ROW_NUMBER() OVER(PARTITION BY Product_ID ORDER BY UPDATED_AT DESC)=1

SETTINGS allow_suspicious_low_cardinality_types = 1
 