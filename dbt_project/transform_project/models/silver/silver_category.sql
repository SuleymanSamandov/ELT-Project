{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        database='Silver',
        unique_key='CategoryID',
        engine='MergeTree()',
        order_by='CategoryID'
    )
}}

SELECT 
	toInt64(COALESCE(id,0)) as "CategoryID",
	name as "Category Name",
	description  as "Description",
	p.created_at AS CREATED_AT,
    p.updated_at AS UPDATED_AT
FROM {{ref('bronze_category')}} p
{% if is_incremental() %}
    WHERE UPDATED_AT>=(SELECT MAX(UPDATED_AT) - INTERVAL 3 DAY FROM {{this}} WHERE UPDATED_AT>=NOW() - INTERVAL 14 DAY)
{% endif %}
QUALIFY ROW_NUMBER() OVER(PARTITION BY CategoryID ORDER BY UPDATED_AT DESC)=1

SETTINGS allow_suspicious_low_cardinality_types = 1