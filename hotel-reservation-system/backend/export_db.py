"""
export_db.py — Export all database tables to CSV files.

Usage:
    python hotel-reservation-system/backend/export_db.py

Outputs CSV files to: hotel-reservation-system/database/exports/
Open them in Excel, VS Code, or any spreadsheet app to browse the data.
"""

import csv
import os
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv

load_dotenv('../../.env')  # Load DB credentials from .env file

DB_CONFIG = {
    "host":     os.getenv("DB_HOST",     "localhost"),
    "port":     int(os.getenv("DB_PORT", "3306")),
    "user":     os.getenv("DB_USER",     "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME",     "hotel_reservation_db"),
}

TABLES = ["city", "hotel", "users", "registered_user", "guest_user", "reservation"]

EXPORT_DIR = os.path.join(
    os.path.dirname(__file__), "..", "database", "exports"
)


def export_all():
    os.makedirs(EXPORT_DIR, exist_ok=True)

    try:
        conn = mysql.connector.connect(**DB_CONFIG)
    except Error as e:
        print(f"Could not connect to MySQL: {e}")
        print("Make sure MySQL is running: brew services start mysql")
        return

    cursor = conn.cursor()

    for table in TABLES:
        cursor.execute(f"SELECT * FROM {table}")
        rows = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]

        filepath = os.path.join(EXPORT_DIR, f"{table}.csv")
        with open(filepath, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow(columns)
            writer.writerows(rows)

        print(f"Exported {len(rows):>3} rows → {filepath}")

    cursor.close()
    conn.close()
    print(f"\nDone. Open the CSVs in: {os.path.abspath(EXPORT_DIR)}")


if __name__ == "__main__":
    export_all()
