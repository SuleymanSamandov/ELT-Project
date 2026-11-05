{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key='CustomerID',
        database='Silver',
        engine='MergeTree()',
        order_by='CustomerID'
    )
}}

SELECT
    toInt64(COALESCE(id, 0)) AS "CustomerID",
    name AS "Customer Name",
    email AS "Email",
    phone AS "Phone",
    COALESCE(company, 'Unknown') AS "Company",
    created_at AS CREATED_AT,
    updated_at AS UPDATED_AT
FROM {{ ref('bronze_customer') }}

{% if is_incremental() %}
WHERE UPDATED_AT >= (SELECT MAX(UPDATED_AT) - INTERVAL 3 DAY FROM {{ this }} WHERE UPDATED_AT >= now() - INTERVAL 14 DAY
)
{% endif %}

QUALIFY ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY UPDATED_AT DESC) = 1

SETTINGS allow_suspicious_low_cardinality_types = 1