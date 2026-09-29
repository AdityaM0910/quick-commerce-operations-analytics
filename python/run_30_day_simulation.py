from generate_daily_orders import generate_orders_for_day
from db_connection import get_connection
from datetime import datetime, timedelta

def date_has_orders(order_date):
    """Check whether orders already exist for the given simulation date."""
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT EXISTS (
            SELECT 1
            FROM orders
            WHERE order_placed_at::date = %s
        )
    """, (order_date.date(),))

    exists = cur.fetchone()[0]

    cur.close()
    conn.close()

    return exists

def run_simulation(start_date, num_days=30, start_orders=1000, growth_rate=0.03):
    """
    Simulates growing daily order volume.
    growth_rate=0.03 means ~3% more orders each day than the previous day
    (compounding growth), mirroring real business growth curves —
    not a straight linear increase, which would look artificial.
    """
    current_date = start_date
    current_orders = start_orders

    for day in range(1, num_days + 1):

        if date_has_orders(current_date):
            print(f"⚠️ {current_date.date()}: orders already exist. Skipping.")
        else:
            generate_orders_for_day(
                current_date,
                num_orders=int(current_orders)
            )

        current_date += timedelta(days=1)
        current_orders *= (1 + growth_rate)  # compound growth

if __name__ == "__main__":
    run_simulation(datetime(2026, 2, 7), num_days=22, start_orders=2890)