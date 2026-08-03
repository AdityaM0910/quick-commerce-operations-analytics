from db_connection import get_connection
from faker import Faker
import random

fake = Faker()

def get_cities():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT city_id, city_name FROM cities")
    cities = cur.fetchall()
    cur.close()
    conn.close()
    return cities

def seed_stores():
    cities = get_cities()
    conn = get_connection()
    cur = conn.cursor()

    stores_data = []
    for city_id, city_name in cities:
        # 2-3 dark stores per city — realistic for a mid-sized quick-commerce footprint
        num_stores = random.randint(2, 3)
        for i in range(num_stores):
            store_name = f"{city_name} Dark Store {i+1}"
            manager_name = fake.name()
            stores_data.append((store_name, city_id, manager_name))

    insert_query = """
        INSERT INTO stores (store_name, city_id, store_manager)
        VALUES (%s, %s, %s)
    """
    cur.executemany(insert_query, stores_data)
    conn.commit()
    print(f"✅ Inserted {cur.rowcount} stores.")

    cur.close()
    conn.close()

if __name__ == "__main__":
    seed_stores()