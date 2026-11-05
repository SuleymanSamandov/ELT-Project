{{
    config(
        materialized='table',
        engine='MergeTree()',
        order_by='tuple()'
    )
}}

SELECT
    id,
    customer_id ,
    status,
    discount,	 
    tax,
    shipping,
    toDate(parseDateTimeBestEffort(created_at)) AS created_at,
    toDate(parseDateTimeBestEffort(updated_at)) AS updated_at,
    toDate(parseDateTimeBestEffort(placed_at)) as placed_at,
    ingest_date AS ingest_date
FROM {{ ref('src_orders') }}
SETTINGS
    use_hive_partitioning = 1,
    allow_suspicious_low_cardinality_types = 1