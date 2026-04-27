# travel-database-project

Hotel database / travel project and website.

## Local database setup

Each developer creates their own local SQLite database — no server required.

```bash
# 1. Set up a virtual environment
cd hotel-reservation-system/backend
python3 -m venv .venv
source .venv/bin/activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Create (or reset) your local database
python db.py
```

This runs `database/schema-creator.sql`, which:

- Drops and recreates all tables
- Inserts all 44 European capital cities
- Inserts 2 real-world hotels per city (88 hotels total)

The database file `travel.db` is created inside `backend/`

```

## Schema

| Table             | Description                               |
| ----------------- | ----------------------------------------- |
| `users`           | All users (registered or guest)           |
| `registered_user` | Registered user details and preferences   |
| `guest_user`      | Guest (browse-only) users                 |
| `city`            | European capital cities with price ranges |
| `hotel`           | Hotels linked to a city                   |
| `reservation`     | Reservations made by registered users     |
```
