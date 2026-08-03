from db_connection import get_connection
from faker import Faker
import random

fake = Faker()

def get_cities():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT city_id FROM cities")
    cities = cur.fetchall()
    cur.close()
    conn.close()
    return cities

def seed_customers(num_customers=2000):
    cities = get_cities()
    conn = get_connection()
    cur = conn.cursor()

    customers_data = []
    for _ in range(num_customers):
        city_id = random.choice(cities)[0]
        name = fake.name()
        email = fake.unique.email()
        phone = fake.unique.msisdn()[:10]
        customers_data.append((name, email, phone, city_id))

    insert_query = """
        INSERT INTO customers (full_name, email, phone_number, city_id)
        VALUES (%s, %s, %s, %s)
    """
    cur.executemany(insert_query, customers_data)
    conn.commit()
    print(f"✅ Inserted {cur.rowcount} customers.")
    cur.close()
    conn.close()

if __name__ == "__main__":
    seed_customers(2000)