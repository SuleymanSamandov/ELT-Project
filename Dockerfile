FROM apache/airflow:2.10.5-python3.11

USER airflow

COPY api_src/requirements.txt /tmp/api_requirements.txt

RUN pip install --no-cache-dir \
    -r /tmp/api_requirements.txt \
    dbt-core \
    dbt-clickhouse