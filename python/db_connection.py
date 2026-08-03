from dotenv import load_dotenv
import os
import psycopg2

# Load variables from .env into the environment
load_dotenv()


# Read credentials
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

print("Password loaded:", DB_PASSWORD)

def get_connection():
    """
    Creates and returns a connection object to the PostgreSQL database.
    This function will be reused by every other script in the project
    so we don't repeat connection logic everywhere.
    """
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )
    return conn

# Quick test — only runs when this file is executed directly
if __name__ == "__main__":
    try:
        conn = get_connection()
        print("✅ Connected to PostgreSQL successfully!")
        conn.close()
    except Exception as e:
        print("❌ Connection failed:", e)