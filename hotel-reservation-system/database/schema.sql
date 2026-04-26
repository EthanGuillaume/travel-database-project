-- schema.sql
-- Hotel Reservation System - Table Definitions (MySQL)
-- Run this file to create all tables (without data).

CREATE TABLE IF NOT EXISTS users (
    user_id   INT PRIMARY KEY,
    username  VARCHAR(50)  NOT NULL,
    user_type VARCHAR(20)  NOT NULL,
    CONSTRAINT chk_user_type CHECK (user_type IN ('registered', 'guest'))
);

CREATE TABLE IF NOT EXISTS city (
    city_id              INT PRIMARY KEY,
    city_name            VARCHAR(50)    NOT NULL,
    country              VARCHAR(50),
    region               VARCHAR(50),
    description          VARCHAR(200),
    avg_hotel_price_low  DECIMAL(10,2),
    avg_hotel_price_high DECIMAL(10,2),
    CONSTRAINT chk_price_low  CHECK (avg_hotel_price_low  >= 0),
    CONSTRAINT chk_price_high CHECK (avg_hotel_price_high >= avg_hotel_price_low)
);

CREATE TABLE IF NOT EXISTS hotel (
    hotel_id            INT PRIMARY KEY,
    hotel_name          VARCHAR(100)   NOT NULL,
    address             VARCHAR(200),
    price_per_night     DECIMAL(10,2),
    star_rating         INT,
    restaurant_included TINYINT(1),
    description         VARCHAR(200),
    availability_status VARCHAR(20),
    city_id             INT,
    FOREIGN KEY (city_id) REFERENCES city(city_id),
    CONSTRAINT chk_hotel_price  CHECK (price_per_night     >= 0),
    CONSTRAINT chk_star_rating  CHECK (star_rating         BETWEEN 1 AND 5),
    CONSTRAINT chk_restaurant   CHECK (restaurant_included IN (0,1)),
    CONSTRAINT chk_avail_status CHECK (availability_status IN ('available','unavailable'))
);

CREATE TABLE IF NOT EXISTS registered_user (
    user_id              INT PRIMARY KEY,
    email                VARCHAR(100)   NOT NULL UNIQUE,
    password_hash        VARCHAR(100)   NOT NULL,
    preferred_budget_min DECIMAL(10,2),
    preferred_budget_max DECIMAL(10,2),
    availability_start   DATE,
    availability_end     DATE,
    preferred_city_id    INT,
    FOREIGN KEY (user_id)           REFERENCES users(user_id),
    FOREIGN KEY (preferred_city_id) REFERENCES city(city_id),
    CONSTRAINT chk_budget_min CHECK (preferred_budget_min >= 0),
    CONSTRAINT chk_budget_max CHECK (preferred_budget_max >= preferred_budget_min),
    CONSTRAINT chk_avail_dates CHECK (availability_end >= availability_start)
);

CREATE TABLE IF NOT EXISTS guest_user (
    user_id          INT PRIMARY KEY,
    browse_only_flag TINYINT(1),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT chk_browse_flag CHECK (browse_only_flag IN (0,1))
);

CREATE TABLE IF NOT EXISTS reservation (
    reservation_id     INT PRIMARY KEY,
    check_in_date      DATE          NOT NULL,
    check_out_date     DATE          NOT NULL,
    number_of_guests   INT,
    total_cost         DECIMAL(10,2),
    reservation_status VARCHAR(20),
    user_id            INT,
    hotel_id           INT,
    FOREIGN KEY (user_id)  REFERENCES registered_user(user_id),
    FOREIGN KEY (hotel_id) REFERENCES hotel(hotel_id),
    CONSTRAINT chk_guests      CHECK (number_of_guests   >  0),
    CONSTRAINT chk_total_cost  CHECK (total_cost         >= 0),
    CONSTRAINT chk_res_status  CHECK (reservation_status IN ('pending','confirmed','cancelled')),
    CONSTRAINT chk_dates       CHECK (check_out_date     >  check_in_date)
);
