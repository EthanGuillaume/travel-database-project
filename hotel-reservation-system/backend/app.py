from flask import Flask, request, jsonify, send_from_directory
from db import get_db
import os

app = Flask(__name__)

# Path to frontend
FRONTEND = os.path.join(os.path.dirname(__file__), '..', 'frontend')
FRONTEND = os.path.abspath(FRONTEND)


# -------------------------
# Serve frontend
# -------------------------
@app.route('/')
def index():
    return send_from_directory(FRONTEND, 'index.html')


@app.route('/<path:path>')
def static_files(path):
    return send_from_directory(FRONTEND, path)


# -------------------------
# API ROUTES
# -------------------------

# 1. Get all cities
@app.route('/api/cities', methods=['GET'])
def get_cities():
    conn = get_db()
    cities = conn.execute("SELECT * FROM city").fetchall()
    return jsonify([dict(row) for row in cities])


# 2. Get hotels in a city
@app.route('/api/cities/<int:city_id>/hotels', methods=['GET'])
def get_hotels(city_id):
    conn = get_db()
    hotels = conn.execute(
        "SELECT * FROM hotel WHERE city_id = ?",
        (city_id,)
    ).fetchall()

    return jsonify([dict(row) for row in hotels])


@app.route('/api/auth/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('email')

    conn = get_db()

    try:
        # check if exists
        existing = conn.execute(
            "SELECT * FROM users WHERE username = ?",
            (username,)
        ).fetchone()

        if existing:
            return jsonify({"error": "User already exists"}), 400

        # insert into users
        cursor = conn.execute(
            "INSERT INTO users (username, user_type) VALUES (?, 'registered')",
            (username,)
        )

        user_id = cursor.lastrowid

        # insert into registered_user
        conn.execute(
            """
            INSERT INTO registered_user (user_id, email, password_hash)
            VALUES (?, ?, ?)
            """,
            (user_id, username, "dummy_password")
        )

        conn.commit()

        return jsonify({"message": "User created"}), 201

    except Exception as e:
        conn.rollback() 
        return jsonify({"error": str(e)}), 500


@app.route('/api/auth/me', methods=['GET'])
def get_current_user():
    # For now, just return "not logged in"
    return jsonify({"user": None})


@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json()

    username = data.get('email')  # frontend sends "email"

    conn = get_db()

    user = conn.execute(
        "SELECT * FROM users WHERE username = ?",
        (username,)
    ).fetchone()

    if user:
        return jsonify(dict(user))
    else:
        return jsonify({"error": "Invalid user"}), 401


@app.route('/api/auth/logout', methods=['POST'])
def logout():
    return jsonify({"message": "Logged out"})


# 4. Create reservation
@app.route('/api/reservations', methods=['POST'])
def create_reservation():
    data = request.get_json()

    print("Incoming data:", data)  # debug

    user_id = data.get('user_id') or 1
    hotel_id = data.get('hotel_id')

    check_in = data.get('check_in_date') or "2026-05-01"
    check_out = data.get('check_out_date') or "2026-05-05"
    guests = data.get('number_of_guests', 1)

    conn = get_db()

    conn.execute(
        """
        INSERT INTO reservation 
        (check_in_date, check_out_date, number_of_guests, total_cost, reservation_status, user_id, hotel_id)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        (check_in, check_out, 1, 100.0, 'pending', user_id, hotel_id)
    )

    conn.commit()

    return jsonify({"message": "Reservation created"}), 201


# 5. Get reservations for a user
@app.route('/api/users/<int:user_id>/reservations', methods=['GET'])
def get_user_reservations(user_id):
    conn = get_db()

    reservations = conn.execute(
    """
    SELECT 
        r.*, 
        h.hotel_name as hotel_name, 
        c.city_name as city_name
    FROM reservation r
    JOIN hotel h ON r.hotel_id = h.hotel_id
    JOIN city c ON h.city_id = c.city_id
    WHERE r.user_id = ?
    """,
    (user_id,)
    ).fetchall()

    return jsonify([dict(row) for row in reservations])


# -------------------------
# Run server
# -------------------------
if __name__ == '__main__':
    app.run(debug=True)


