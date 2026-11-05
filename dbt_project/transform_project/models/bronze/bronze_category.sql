{{
    config(
        materialized='table',
        engine='MergeTree()',
        order_by='tuple()'
    )
}}

select 
    id,
    name,
    slug,
    description,
    toDate(parseDateTimeBestEffort(created_at)) AS created_at,
    toDate(parseDateTimeBestEffort(updated_at)) AS updated_at,
    ingest_date
from  {{ ref('src_category') }}
settings
    use_hive_partitioning = 1,
    allow_suspicious_low_cardinality_types = 1
