from generate_daily_orders import generate_orders_for_day
from datetime import datetime, timedelta

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
        generate_orders_for_day(current_date, num_orders=int(current_orders))

        current_date += timedelta(days=1)
        current_orders *= (1 + growth_rate)  # compound growth

if __name__ == "__main__":
    run_simulation(datetime(2026, 1, 2), num_days=29, start_orders=1030)