{% snapshot dim_products %}

{{
    config(
        target_database='Gold',
        target_schema='Gold',
        unique_key='Product_ID',
        strategy='check',
        check_cols=['Product_Name', 'Brand', 'Price'],
        invalidate_hard_deletes=True,
        engine='MergeTree()',
        order_by='Product_ID'
    )
}}

SELECT
    Product_ID,
    CATEGORY_ID,
    "Porduct Name" AS Product_Name,
    Brand,
    Price,
    UPDATED_AT
FROM {{ ref('silver_products') }}
{% if is_incremental() %}
    WHERE UPDATED_AT >= (SELECT MAX(UPDATED_AT) - INTERVAL 3 DAY FROM {{this}} WHERE UPDATED_AT>= NOW()- INTERVAL 14 DAY )
{% endif %}

{% endsnapshot %}