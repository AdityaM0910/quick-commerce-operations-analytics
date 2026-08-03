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

def seed_delivery_partners():
    cities = get_cities()
    conn = get_connection()
    cur = conn.cursor()

    partners_data = []
    for (city_id,) in cities:
        # 15-20 delivery partners per city — enough to simulate realistic load
        num_partners = random.randint(15, 20)
        for _ in range(num_partners):
            name = fake.name()
            phone = fake.msisdn()[:10]  # 10-digit phone number
            partners_data.append((name, phone, city_id))

    insert_query = """
        INSERT INTO delivery_partners (full_name, phone_number, city_id)
        VALUES (%s, %s, %s)
    """
    cur.executemany(insert_query, partners_data)
    conn.commit()
    print(f"✅ Inserted {cur.rowcount} delivery partners.")

    cur.close()
    conn.close()

if __name__ == "__main__":
    seed_delivery_partners()