from flask import Flask, request, jsonify, send_from_directory
from db import get_db
import os

app = Flask(__name__)

# figure out where the frontend folder is
FRONTEND = os.path.join(os.path.dirname(__file__), '..', 'frontend')
FRONTEND = os.path.abspath(FRONTEND)


# serves the main html page
@app.route('/')
def index():
    return send_from_directory(FRONTEND, 'index.html')


# serves js, css, etc
@app.route('/<path:path>')
def static_files(path):
    return send_from_directory(FRONTEND, path)


# returns all cities from the database
@app.route('/api/cities', methods=['GET'])
def get_cities():
    conn = get_db()
    cities = conn.execute("select * from city").fetchall()
    return jsonify([dict(row) for row in cities])


# returns all hotels for a given city
@app.route('/api/cities/<int:city_id>/hotels', methods=['GET'])
def get_hotels(city_id):
    conn = get_db()
    hotels = conn.execute(
        "select * from hotel where city_id = ?",
        (city_id,)
    ).fetchall()
    return jsonify([dict(row) for row in hotels])


# creates a new user account
@app.route('/api/auth/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')

    conn = get_db()

    try:
        # make sure email isn't already taken
        existing = conn.execute(
            "select * from registered_user where email = ?",
            (email,)
        ).fetchone()

        if existing:
            return jsonify({"error": "Email already in use"}), 400

        # add to users table first to get the user_id
        cursor = conn.execute(
            "insert into users (username, user_type) values (?, 'registered')",
            (username,)
        )
        user_id = cursor.lastrowid

        # then add email + password to registered_user
        conn.execute(
            "insert into registered_user (user_id, email, password_hash) values (?, ?, ?)",
            (user_id, email, password)
        )

        conn.commit()

        # send back the user info so the frontend can log them in
        return jsonify({"user_id": user_id, "username": username, "user_type": "registered"}), 201

    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500


# no session support, so this always returns not logged in
@app.route('/api/auth/me', methods=['GET'])
def get_current_user():
    return jsonify({"user": None})


# checks email + password and returns the user if correct
@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    conn = get_db()

    # look up by email, joining users and registered_user together
    row = conn.execute(
        """
        select u.user_id, u.username, u.user_type
        from users u
        join registered_user ru on u.user_id = ru.user_id
        where ru.email = ? and ru.password_hash = ?
        """,
        (email, password)
    ).fetchone()

    if row:
        return jsonify(dict(row))
    else:
        return jsonify({"error": "Invalid email or password"}), 401


# nothing to clear since we don't have sessions, just return ok
@app.route('/api/auth/logout', methods=['POST'])
def logout():
    return jsonify({"message": "Logged out"})


# books a hotel for a user
@app.route('/api/reservations', methods=['POST'])
def create_reservation():
    data = request.get_json()

    user_id = data.get('user_id')
    hotel_id = data.get('hotel_id')
    check_in = data.get('check_in_date')
    check_out = data.get('check_out_date')
    guests = data.get('number_of_guests', 1)

    conn = get_db()

    # check if someone already booked this hotel for overlapping dates
    # overlap means: existing check-in is before our check-out AND existing check-out is after our check-in
    conflict = conn.execute(
        """
        select check_in_date, check_out_date
        from reservation
        where hotel_id = ?
          and reservation_status != 'cancelled'
          and check_in_date < ?
          and check_out_date > ?
        """,
        (hotel_id, check_out, check_in)
    ).fetchone()

    if conflict:
        return jsonify({
            "error": f"Those dates overlap with an existing booking ({conflict['check_in_date']} to {conflict['check_out_date']}). Please choose different dates."
        }), 409

    # work out how much it costs total
    hotel = conn.execute("select price_per_night from hotel where hotel_id = ?", (hotel_id,)).fetchone()
    from datetime import date
    nights = (date.fromisoformat(check_out) - date.fromisoformat(check_in)).days
    total_cost = round(hotel['price_per_night'] * nights, 2)

    cursor = conn.execute(
        """
        insert into reservation
        (check_in_date, check_out_date, number_of_guests, total_cost, reservation_status, user_id, hotel_id)
        values (?, ?, ?, ?, 'pending', ?, ?)
        """,
        (check_in, check_out, guests, total_cost, user_id, hotel_id)
    )

    conn.commit()

    return jsonify({"reservation_id": cursor.lastrowid, "total_cost": total_cost}), 201


# marks a reservation as cancelled
@app.route('/api/reservations/<int:reservation_id>/cancel', methods=['POST'])
def cancel_reservation(reservation_id):
    conn = get_db()
    conn.execute(
        "update reservation set reservation_status = 'cancelled' where reservation_id = ?",
        (reservation_id,)
    )
    conn.commit()
    return jsonify({"message": "Reservation cancelled"})


# gets all reservations for a user, joined with hotel and city names
@app.route('/api/users/<int:user_id>/reservations', methods=['GET'])
def get_user_reservations(user_id):
    conn = get_db()
    reservations = conn.execute(
        """
        select r.*, h.hotel_name, c.city_name
        from reservation r
        join hotel h on r.hotel_id = h.hotel_id
        join city c on h.city_id = c.city_id
        where r.user_id = ?
        """,
        (user_id,)
    ).fetchall()
    return jsonify([dict(row) for row in reservations])


if __name__ == '__main__':
    app.run(debug=True)



