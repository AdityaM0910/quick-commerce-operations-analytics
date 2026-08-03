from db_connection import get_connection

# Hardcoded, realistic — not Faker-generated, since real companies
# operate in specific known cities, not random ones
cities_data = [
    ("Delhi", "Delhi", "Tier 1"),
    ("Mumbai", "Maharashtra", "Tier 1"),
    ("Bangalore", "Karnataka", "Tier 1"),
    ("Kolkata", "West Bengal", "Tier 1"),
    ("Chandigarh", "Chandigarh", "Tier 2"),
]

def seed_cities():
    conn = get_connection()
    cur = conn.cursor()

    for city_name, state_name, tier in cities_data:
        cur.execute(
            """
            INSERT INTO cities (city_name, state_name, tier)
            VALUES (%s, %s, %s)
            """,
            (city_name, state_name, tier)
        )

    conn.commit()  # saves the changes permanently to the database
    cur.close()
    conn.close()
    print(f"✅ Inserted {len(cities_data)} cities successfully.")

if __name__ == "__main__":
    seed_cities()