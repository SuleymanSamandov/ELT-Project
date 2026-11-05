{{
    config(
        materialized='table',
        engine='MergeTree()',
        order_by='tuple()'
    )
}}

SELECT
    id,
    order_id,
    product_id,
    quantity,
    unit_price,
    toDate(parseDateTimeBestEffort(created_at)) AS created_at,
    toDate(parseDateTimeBestEffort(updated_at)) AS updated_at,
    ingest_date
FROM {{ ref('src_order_details') }}
SETTINGS
    use_hive_partitioning = 1,
    allow_suspicious_low_cardinality_types = 1