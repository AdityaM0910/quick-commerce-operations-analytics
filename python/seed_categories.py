from db_connection import get_connection

# Realistic quick-commerce categories (grocery/daily essentials focused)
categories_data = [
    ("Fruits & Vegetables",),
    ("Dairy & Breakfast",),
    ("Snacks & Munchies",),
    ("Beverages",),
    ("Personal Care",),
    ("Home Care",),
    ("Bakery",),
    ("Meat & Seafood",),
]

def seed_categories():
    conn = get_connection()
    cur = conn.cursor()

    insert_query = "INSERT INTO categories (category_name) VALUES (%s)"

    cur.executemany(insert_query, categories_data)

    conn.commit()
    print(f"✅ Inserted {cur.rowcount} categories.")

    cur.close()
    conn.close()

if __name__ == "__main__":
    seed_categories()