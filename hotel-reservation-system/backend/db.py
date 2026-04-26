# db.py
# Run this to set up your local database: python3 db.py
# Uses SQLite so no database server is needed.

import os
import sqlite3

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "travel.db")
SCHEMA_CREATOR = os.path.join(BASE_DIR, "..", "database", "schema-creator.sql")


def get_db():
    # call this from app.py whenever you need a db connection
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db():
    # reads schema-creator.sql and runs it — drops + recreates everything
    # safe to re-run if you want a fresh database
    with open(SCHEMA_CREATOR, "r") as f:
        sql = f.read()

    conn = sqlite3.connect(DB_PATH)
    conn.executescript(sql)
    conn.close()
    print(f"done — database created at {DB_PATH}")


if __name__ == "__main__":
    init_db()
