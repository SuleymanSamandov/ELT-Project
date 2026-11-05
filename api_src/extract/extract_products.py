import pandas as pd
import requests
import time
import logging

url = 'https://api.sondahub.com/v1/store/products'
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def extract_products(limit: int = 200, max_retries: int = 3, timeout: int = 5):
    all_products = []
    offset = 0

    while True:
        params = {"limit": limit, "offset": offset}
        success = False
        data = None

        for attempt in range(1, max_retries + 1):
            try:
                r = requests.get(url=url, params=params, timeout=timeout)
                r.raise_for_status()
                data = r.json()

                if "data" not in data:
                    logging.warning("Unexpected response format: %s", data)
                    return None
                
                success = True
                break
            
            except requests.exceptions.Timeout:
                logging.warning("Timeout (attempt %d/%d)", attempt, max_retries)

            except requests.exceptions.HTTPError as e:
                logger.info("HTTP error: %s", e)
                if r.status_code in (401, 403):
                    return None

            except requests.exceptions.RequestException as e:
                logger.info("Request error (attempt %d/%d): %s", attempt, max_retries)

            if attempt < max_retries:
                time.sleep(3)

        if not success:
            logger.error("All attempts failed at offset %d", offset)
            break

        products = data.get("data", [])
        
        if not products:
            break

        all_products.extend(products)
        logger.info("Fetched %d products at offset %d.", len(products), offset)

        offset += limit

    logger.info("Successfully fetched %d products in total.", len(all_products))
    return {"data": all_products}