from db_connection import get_connection
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()

def get_customers_with_city():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT customer_id, city_id FROM customers")
    data = cur.fetchall()
    cur.close(); conn.close()
    return data

def get_stores_by_city():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT store_id, city_id FROM stores")
    rows = cur.fetchall()
    cur.close(); conn.close()
    city_to_stores = {}
    for store_id, city_id in rows:
        city_to_stores.setdefault(city_id, []).append(store_id)
    return city_to_stores

def get_products():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT product_id, price FROM products")
    data = cur.fetchall()
    cur.close(); conn.close()
    return data

def get_partners_by_city():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT partner_id, city_id FROM delivery_partners")
    rows = cur.fetchall()
    cur.close(); conn.close()
    city_to_partners = {}
    for partner_id, city_id in rows:
        city_to_partners.setdefault(city_id, []).append(partner_id)
    return city_to_partners

def generate_orders_for_day(order_date, num_orders):
    customers = get_customers_with_city()
    city_to_stores = get_stores_by_city()
    products = get_products()
    city_to_partners = get_partners_by_city()

    conn = get_connection()
    cur = conn.cursor()

    orders_created = 0

    for _ in range(num_orders):
        customer_id, city_id = random.choice(customers)

        # Business rule: order must be fulfilled by a store in the customer's city
        available_stores = city_to_stores.get(city_id, [])
        if not available_stores:
            continue
        store_id = random.choice(available_stores)

        # Random order timestamp within the given day (spread across hours)
        placed_at = order_date + timedelta(
            hours=random.randint(7, 23), minutes=random.randint(0, 59)
        )

        # 8% cancellation rate — realistic, not exaggerated
        is_cancelled = random.random() < 0.08

        # Build order_items first (1-5 products per order)
        num_items = random.randint(1, 5)
        chosen_products = random.sample(products, min(num_items, len(products)))
        order_items = []
        total_amount = 0
        for product_id, price in chosen_products:
            qty = random.randint(1, 3)
            item_total = float(price) * qty
            total_amount += item_total
            order_items.append((product_id, qty, price))

        # Insert order (status/timestamps depend on cancelled vs delivered path)
        if is_cancelled:
            # Cancellation happens at a random earlier stage (per your rule:
            # allowed only before "Out for Delivery")
            cancel_stage = random.choice(["Placed", "Confirmed", "Packed"])
            confirmed_at = placed_at + timedelta(minutes=2) if cancel_stage != "Placed" else None
            packed_at = confirmed_at + timedelta(minutes=5) if cancel_stage == "Packed" else None
            cancelled_at = (packed_at or confirmed_at or placed_at) + timedelta(minutes=3)

            cur.execute("""
                INSERT INTO orders (customer_id, store_id, order_status,
                    order_placed_at, order_confirmed_at, order_packed_at,
                    cancelled_at, total_amount)
                VALUES (%s,%s,'Cancelled',%s,%s,%s,%s,%s) RETURNING order_id
            """, (customer_id, store_id, placed_at, confirmed_at, packed_at,
                  cancelled_at, round(total_amount, 2)))
        else:
            confirmed_at = placed_at + timedelta(minutes=2)
            packed_at = confirmed_at + timedelta(minutes=5)
            assigned_at = packed_at + timedelta(minutes=2)
            out_for_delivery_at = assigned_at + timedelta(minutes=3)
            delivered_at = out_for_delivery_at + timedelta(minutes=random.randint(8, 25))

            cur.execute("""
                INSERT INTO orders (customer_id, store_id, order_status,
                    order_placed_at, order_confirmed_at, order_packed_at,
                    partner_assigned_at, out_for_delivery_at, delivered_at, total_amount)
                VALUES (%s,%s,'Delivered',%s,%s,%s,%s,%s,%s,%s) RETURNING order_id
            """, (customer_id, store_id, placed_at, confirmed_at, packed_at,
                  assigned_at, out_for_delivery_at, delivered_at, round(total_amount, 2)))

        order_id = cur.fetchone()[0]

        # Insert order_items
        for product_id, qty, price in order_items:
            cur.execute("""
                INSERT INTO order_items (order_id, product_id, quantity, price_at_order)
                VALUES (%s,%s,%s,%s)
            """, (order_id, product_id, qty, price))

        # Insert delivery + payment only for non-cancelled orders
        if not is_cancelled:
            partners = city_to_partners.get(city_id, [])
            if partners:
                partner_id = random.choice(partners)
                delivery_minutes = (delivered_at - out_for_delivery_at).seconds / 60
                is_late = delivery_minutes > 20  # SLA threshold: 20 min
                rating = round(random.uniform(3.5, 5.0), 1)
                cur.execute("""
                    INSERT INTO deliveries (order_id, partner_id, delivery_rating, is_late)
                    VALUES (%s,%s,%s,%s)
                """, (order_id, partner_id, rating, is_late))

            payment_method = random.choice(["UPI", "Card", "Cash", "Wallet"])
            cur.execute("""
                INSERT INTO payments (order_id, payment_method, payment_status, amount_paid)
                VALUES (%s,%s,'Success',%s)
            """, (order_id, payment_method, round(total_amount, 2)))

        orders_created += 1

    conn.commit()
    print(f"✅ {order_date.date()}: {orders_created} orders created.")
    cur.close()
    conn.close()

if __name__ == "__main__":
    # Day 1 simulation — matches your brief's starting volume
    generate_orders_for_day(datetime(2026, 1, 1), num_orders=1000)