{% snapshot dim_customers %}

{{
    config(
        database='Gold',
        unique_key='Customer_ID',
        strategy='check',
        check_cols=['Customer_Name', 'Email', 'Phone', 'Company'],
        invalidate_hard_deletes=True,
        engine='MergeTree()',
        order_by='Customer_ID'
    )
}}

SELECT
`CustomerID` AS Customer_ID,
`Customer Name` AS Customer_Name,
Email,
Phone,
Company,
UPDATED_AT
FROM {{ ref('silver_customer') }}
{% if is_incremental() %}
    WHERE UPDATED_AT >= (SELECT MAX(UPDATED_AT) - INTERVAL 3 DAY FROM {{this}} WHERE UPDATED_AT>= NOW()- INTERVAL 14 DAY )
{% endif %}


{% endsnapshot %}