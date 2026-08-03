from db_connection import get_connection
from faker import Faker
import random

fake = Faker()

# Realistic product name templates per category (Faker alone can't generate
# believable grocery product names, so we combine real product words with Faker)
product_templates = {
    "Fruits & Vegetables": ["Banana", "Apple", "Tomato", "Onion", "Potato", "Spinach", "Carrot"],
    "Dairy & Breakfast": ["Milk 500ml", "Curd 400g", "Paneer 200g", "Cornflakes", "Bread"],
    "Snacks & Munchies": ["Potato Chips", "Namkeen Mix", "Biscuits", "Popcorn"],
    "Beverages": ["Cola 750ml", "Orange Juice", "Mineral Water 1L", "Energy Drink"],
    "Personal Care": ["Shampoo 200ml", "Soap Bar", "Toothpaste", "Face Wash"],
    "Home Care": ["Dish Soap", "Floor Cleaner", "Detergent Powder", "Room Freshener"],
    "Bakery": ["Brown Bread", "Muffins Pack", "Cookies", "Cake Slice"],
    "Meat & Seafood": ["Chicken Breast 500g", "Fish Fillet", "Eggs Pack of 12"],
}

def get_categories():
    """Fetch category_id + category_name pairs from DB — never hardcode FK ids."""
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT category_id, category_name FROM categories")
    categories = cur.fetchall()  # list of tuples: [(1, 'Fruits & Vegetables'), ...]
    cur.close()
    conn.close()
    return categories

def seed_products():
    categories = get_categories()
    conn = get_connection()
    cur = conn.cursor()

    products_data = []
    for category_id, category_name in categories:
        base_products = product_templates.get(category_name, [])
        for product_name in base_products:
            price = round(random.uniform(20, 500), 2)  # realistic ₹20-500 range
            products_data.append((product_name, category_id, price))

    insert_query = """
        INSERT INTO products (product_name, category_id, price)
        VALUES (%s, %s, %s)
    """
    cur.executemany(insert_query, products_data)
    conn.commit()
    print(f"✅ Inserted {cur.rowcount} products.")

    cur.close()
    conn.close()

if __name__ == "__main__":
    seed_products()