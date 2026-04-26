-- schema.sql
-- Table definitions only (SQLite syntax).
-- Run schema-creator.sql to create + populate the database.

CREATE TABLE IF NOT EXISTS users (
    user_id   INTEGER PRIMARY KEY,
    username  TEXT NOT NULL,
    user_type TEXT NOT NULL,
    CHECK (user_type IN ('registered', 'guest'))
);

CREATE TABLE IF NOT EXISTS city (
    city_id              INTEGER PRIMARY KEY,
    city_name            TEXT NOT NULL,
    country              TEXT,
    region               TEXT,
    description          TEXT,
    avg_hotel_price_low  REAL,
    avg_hotel_price_high REAL,
    CHECK (avg_hotel_price_low >= 0),
    CHECK (avg_hotel_price_high >= avg_hotel_price_low)
);

CREATE TABLE IF NOT EXISTS hotel (
    hotel_id            INTEGER PRIMARY KEY,
    hotel_name          TEXT NOT NULL,
    address             TEXT,
    price_per_night     REAL,
    star_rating         INTEGER,
    restaurant_included INTEGER,
    description         TEXT,
    availability_status TEXT,
    city_id             INTEGER,
    FOREIGN KEY (city_id) REFERENCES city(city_id),
    CHECK (price_per_night >= 0),
    CHECK (star_rating BETWEEN 1 AND 5),
    CHECK (restaurant_included IN (0, 1)),
    CHECK (availability_status IN ('available', 'unavailable'))
);

CREATE TABLE IF NOT EXISTS registered_user (
    user_id              INTEGER PRIMARY KEY,
    email                TEXT NOT NULL UNIQUE,
    password_hash        TEXT NOT NULL,
    preferred_budget_min REAL,
    preferred_budget_max REAL,
    availability_start   TEXT,
    availability_end     TEXT,
    preferred_city_id    INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (preferred_city_id) REFERENCES city(city_id),
    CHECK (preferred_budget_min >= 0),
    CHECK (preferred_budget_max >= preferred_budget_min),
    CHECK (availability_end >= availability_start)
);

CREATE TABLE IF NOT EXISTS guest_user (
    user_id          INTEGER PRIMARY KEY,
    browse_only_flag INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    CHECK (browse_only_flag IN (0, 1))
);

CREATE TABLE IF NOT EXISTS reservation (
    reservation_id     INTEGER PRIMARY KEY,
    check_in_date      TEXT NOT NULL,
    check_out_date     TEXT NOT NULL,
    number_of_guests   INTEGER,
    total_cost         REAL,
    reservation_status TEXT,
    user_id            INTEGER,
    hotel_id           INTEGER,
    FOREIGN KEY (user_id) REFERENCES registered_user(user_id),
    FOREIGN KEY (hotel_id) REFERENCES hotel(hotel_id),
    CHECK (number_of_guests > 0),
    CHECK (total_cost >= 0),
    CHECK (reservation_status IN ('pending', 'confirmed', 'cancelled')),
    CHECK (check_out_date > check_in_date)
);
