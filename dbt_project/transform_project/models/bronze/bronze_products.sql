{{
    config(
        materialized='table',
        engine='MergeTree()',
        order_by='tuple()'
    )
}}

select 
    id,
    sku,
    name,
    slug,
    description,
    category_id,
    brand,
    price,
    compare_at_price,
    currency,
    color,
    weight_g,
    toDate(parseDateTimeBestEffort(created_at)) AS created_at,
    toDate(parseDateTimeBestEffort(updated_at)) AS updated_at,
    ingest_date AS ingest_date
from {{ ref('src_products') }}
settings
    use_hive_partitioning = 1,
    allow_suspicious_low_cardinality_types = 1
