from datetime import datetime, timedelta
from generate_daily_orders import generate_orders_for_day
from db_connection import get_connection


GROWTH_RATE = 0.03


def get_latest_order_date():
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT MAX(order_placed_at)::date
        FROM orders
    """)

    latest_date = cur.fetchone()[0]

    cur.close()
    conn.close()

    return latest_date


def get_orders_for_date(order_date):
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT COUNT(*)
        FROM orders
        WHERE order_placed_at::date = %s
    """, (order_date,))

    order_count = cur.fetchone()[0]

    cur.close()
    conn.close()

    return order_count


def date_has_orders(order_date):
    return get_orders_for_date(order_date) > 0


def calculate_next_order_count(previous_order_count):
    return int(previous_order_count * (1 + GROWTH_RATE))


def run_next_day():

    print("=" * 60)
    print("QUICK COMMERCE AUTOMATED DATA PIPELINE")
    print("=" * 60)

    latest_date = get_latest_order_date()

    if latest_date is None:
        print("No existing orders found.")
        return

    latest_order_count = get_orders_for_date(latest_date)

    next_date = latest_date + timedelta(days=1)
    next_date = datetime.combine(next_date, datetime.min.time())

    next_order_count = calculate_next_order_count(
        latest_order_count
    )

    print(f"Latest database date : {latest_date}")
    print(f"Latest day orders    : {latest_order_count}")
    print(f"Next simulation date : {next_date}")
    print(f"Next day orders      : {next_order_count}")

    if date_has_orders(next_date):
        print(f"\nData already exists for {next_date}.")
        print("No new data generated.")
        return

    print(f"\nGenerating data for {next_date}...")

    generate_orders_for_day(
        next_date,
        next_order_count
    )

    print("\nAutomation step completed successfully.")


if __name__ == "__main__":
    run_next_day()