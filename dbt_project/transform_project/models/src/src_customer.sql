select
   * EXCEPT (ingest_date),
    toDate(extract(_path, 'ingest_date=([0-9-]+)')) as ingest_date
from s3(
    '{{ var("minio_url") }}/customer/ingest_date=*/customer.parquet',
    '{{ var("minio_key") }}',
    '{{ var("minio_secret") }}',
    'Parquet'
)