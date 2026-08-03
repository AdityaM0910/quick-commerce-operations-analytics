from db_connection import get_connection
from datetime import date, timedelta

def seed_calendar(start_date, end_date):
    conn = get_connection()
    cur = conn.cursor()

    calendar_data = []
    current = start_date
    while current <= end_date:
        calendar_data.append((
            current,
            current.strftime("%A"),          # day_name e.g. Monday
            current.isocalendar()[1],        # week_number
            current.strftime("%B"),          # month_name
            current.month,
            (current.month - 1) // 3 + 1,    # quarter
            current.year,
            current.weekday() >= 5           # is_weekend (Sat/Sun)
        ))
        current += timedelta(days=1)

    insert_query = """
        INSERT INTO calendar (calendar_date, day_name, week_number, month_name,
                               month_number, quarter, year, is_weekend)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """
    cur.executemany(insert_query, calendar_data)
    conn.commit()
    print(f"✅ Inserted {cur.rowcount} calendar rows.")
    cur.close()
    conn.close()

if __name__ == "__main__":
    # Covers your 30-day simulation plus buffer
    seed_calendar(date(2026, 1, 1), date(2026, 12, 31))