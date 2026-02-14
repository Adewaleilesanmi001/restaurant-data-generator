import psycopg2
from dotenv import load_dotenv
import os
import logging
load_dotenv(override = True)


logging.basicConfig(
    filename='app.log',
    level=logging.INFO,
    format='%(asctime)s | %(levelname)s | %(name)s | %(message)s'
)

logger = logging.getLogger(__name__)


host = os.getenv("hostname")
dbname = os.getenv("database")
user = os.getenv("username")
password = os.getenv("password")
port =  os.getenv("port")

from faker import Faker
from faker.exceptions import UniquenessException
import pandas as pd
fake = Faker(['en_GB'])



data = []

Faker.seed(0)
for x in range(3):
    try:
         # this help so the data generated do not change 

         data.append(
             {
                'customer_id' : x+1,
                'first_name' : fake.first_name(),
                'last_name' : fake.last_name(),
                'email' : fake.unique.email(),
                'phone_number' : fake.unique.phone_number(),
                'created_at' : fake.date_time_this_year()
             }
         )



        

    except UniquenessException:
        print ('Uniqness fail')

conn = None
cur = None


try:
    conn = psycopg2.connect(
            host = host,
            dbname = dbname,
            user = user,
            password = password,
            port = port
    )

    cur = conn.cursor()

    # creat_table = '''
    #                     CREATE TABLE ingredients (
	#                     ingredient_id SERIAL PRIMARY KEY
	#                     ,name VARCHAR(100) NOT NULL
	#                     ,unit VARCHAR(20) NOT NULL)
    #     
    #             '''
    for row in data:
        cur.execute(
            "INSERT INTO ingredients (name, unit) VALUES (%s, %s)",
            (row["first_name"], row["last_name"])
        )
    conn.commit()

    # logger.info('Updade') #Input INFO to be logged

    
except Exception as error:
    logger.error(error)
    

finally:
    if cur is not None:
        cur.close()
    if conn is not None:
        conn.close()
    