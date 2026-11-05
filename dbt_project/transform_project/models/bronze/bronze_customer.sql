{{
    config(
        materialized='table',
        engine='MergeTree()',
        order_by='tuple()'
    )
}}

SELECT
    id,
    name,
    email,
    phone,
    company,
    toDate(parseDateTimeBestEffort(created_at)) AS created_at,
    toDate(parseDateTimeBestEffort(updated_at)) AS updated_at,
    ingest_date
FROM {{ ref('src_customer') }}
SETTINGS
    use_hive_partitioning = 1,
    allow_suspicious_low_cardinality_types = 1