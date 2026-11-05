import pandas as pd
import logging
from datetime import date, datetime, timezone
from api_src.extract.extract_products import extract_products
import sys
from pathlib import Path
import json
from minio import Minio
from minio.error import S3Error
from io import BytesIO
from dotenv import load_dotenv
import os
import io

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
load_dotenv()

MINIO_ENDPOINT = os.getenv("MINIO_ENDPOINT")
MINIO_ACCESS_KEY = os.getenv("MINIO_ACCESS_KEY")
MINIO_SECRET_KEY = os.getenv("MINIO_SECRET_KEY")
MINIO_BUCKET = os.getenv("MINIO_BUCKET", "raw")
MINIO_SECURE = os.getenv("MINIO_SECURE", "false").lower() == "true"

if not MINIO_ENDPOINT:
    raise ValueError("MINIO_ENDPOINT is not configured")

if not MINIO_ACCESS_KEY or not MINIO_SECRET_KEY:
    raise ValueError("MinIO credentials are not configured")

minio_client = Minio(
    MINIO_ENDPOINT,
    access_key=MINIO_ACCESS_KEY,
    secret_key=MINIO_SECRET_KEY,
    secure=MINIO_SECURE,
)

def load_products(ingest_date: str | None = None):
    ingest_date = ingest_date or str(date.today())

    data = extract_products(limit=200)
    if data is None:
        raise RuntimeError("Extract failed, nothing to load")

    products = data["data"] if isinstance(data, dict) else data
    if not products:
        raise ValueError("No products to load")

    df = pd.DataFrame(products)
    df["ingest_date"] = ingest_date
    df["extract_date"] = datetime.now(timezone.utc).isoformat()
    df["record_date"] = df["id"].astype(str) + "_" + ingest_date
    df = df.drop_duplicates(subset=["record_date"], keep="last")

    buffer = io.BytesIO()
    df.to_parquet(buffer, index=False)
    buffer.seek(0)

    object_name = f"products/ingest_date={ingest_date}/products.parquet"

    if not minio_client.bucket_exists(MINIO_BUCKET):
        minio_client.make_bucket(MINIO_BUCKET)
        logger.info("Created MinIO bucket: %s", MINIO_BUCKET)

    minio_client.put_object(
        bucket_name=MINIO_BUCKET,
        object_name=object_name,
        data=buffer,
        length=buffer.getbuffer().nbytes,
        content_type="application/vnd.apache.parquet",
    )

    logger.info(
        "Uploaded %d rows to %s/%s",
        len(df),
        MINIO_BUCKET,
        object_name,
    )

    return f"{MINIO_BUCKET}/{object_name}"


if __name__ == "__main__":
    ingest_date_arg = sys.argv[1] if len(sys.argv) > 1 else None

    result = load_products(ingest_date_arg)

    print(f"Loaded successfully: {result}")