from db_connection import get_connection
import random

def get_stores():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT store_id FROM stores")
    stores = cur.fetchall()
    cur.close()
    conn.close()
    return stores

def get_products():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT product_id FROM products")
    products = cur.fetchall()
    cur.close()
    conn.close()
    return products

def seed_inventory():
    stores = get_stores()
    products = get_products()
    conn = get_connection()
    cur = conn.cursor()

    inventory_data = []
    for (store_id,) in stores:
        for (product_id,) in products:
            # Every store stocks every product, with varying quantity
            # Occasionally simulate out-of-stock (quantity = 0) — needed for
            # your "Out of Stock Products" KPI later
            qty = random.choices(
                [0, random.randint(1, 20), random.randint(21, 200)],
                weights=[0.05, 0.15, 0.80]  # 5% out-of-stock, 15% low, 80% healthy
            )[0]
            inventory_data.append((store_id, product_id, qty))

    insert_query = """
        INSERT INTO inventory (store_id, product_id, quantity_available)
        VALUES (%s, %s, %s)
    """
    cur.executemany(insert_query, inventory_data)
    conn.commit()
    print(f"✅ Inserted {cur.rowcount} inventory rows.")
    cur.close()
    conn.close()

if __name__ == "__main__":
    seed_inventory()