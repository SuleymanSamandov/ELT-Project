import pandas as pd
import requests
import time
import logging
#
url='https://api.sondahub.com/v1/store/categories'
logging.basicConfig(level=logging.INFO)
logger=logging.getLogger(__name__)

def extract_category(limit: int=1, max_retries: int=3, timeout: int=5):
    params={"limit":limit}

    for attempt in range(1,max_retries+1):
        try:
            r=requests.get(url=url,params=params,timeout=timeout)
            r.raise_for_status()
            data=r.json()

            if "data" not in data:
                logging.warning("Unexpected response format: %s",data)
                return None
            
            logger.info("The API call was successful.")
            return data
        
        except requests.exceptions.Timeout:
            logging.warning("Timeout (attempt %d/%d)",attempt,max_retries)


        except requests.exceptions.HTTPError as e:
            logger.info("HTTP error: %s",e)
            if r.status_code in (401,403):
                break

        except requests.exceptions.RequestException as e:
            logger.info("Request error (attempt %d/%d): %s",attempt,max_retries)

        if attempt<max_retries:
            time.sleep(3)

    logger.error("All Attempts Error")
    return None