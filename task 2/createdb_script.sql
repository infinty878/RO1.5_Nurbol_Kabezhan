DROP SCHEMA IF EXISTS airline CASCADE;
CREATE SCHEMA airline;
SET search_path TO airline;

CREATE TABLE airline.country (
    country_id   SERIAL      PRIMARY KEY,
    country_name VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE airline.city (
    city_id   SERIAL      PRIMARY KEY,
    city_name VARCHAR(60) NOT NULL
);

CREATE TABLE airline.airports (
    airport_id   SERIAL       PRIMARY KEY,
    iata_code    CHAR(3)      NOT NULL UNIQUE,
    airport_name VARCHAR(100) NOT NULL,
    city_id      INT          NOT NULL,
    country_id   INT          NOT NULL,
    CONSTRAINT fk_airports_city    FOREIGN KEY (city_id)    REFERENCES airline.city(city_id),
    CONSTRAINT fk_airports_country FOREIGN KEY (country_id) REFERENCES airline.country(country_id)
);

CREATE TABLE airline.flights (
    flight_id      SERIAL      PRIMARY KEY,
    flight_number  VARCHAR(20) NOT NULL UNIQUE,
    dep_airport_id INT         NOT NULL,
    arr_airport_id INT         NOT NULL,
    CONSTRAINT chk_flights_different_airports CHECK (dep_airport_id <> arr_airport_id),
    CONSTRAINT fk_flights_dep FOREIGN KEY (dep_airport_id) REFERENCES airline.airports(airport_id),
    CONSTRAINT fk_flights_arr FOREIGN KEY (arr_airport_id) REFERENCES airline.airports(airport_id)
);

CREATE TABLE airline.aircraft_models (
    model_id     SERIAL      PRIMARY KEY,
    manufacturer VARCHAR(50) NOT NULL,
    model_name   VARCHAR(50) NOT NULL,
    capacity     INT         NOT NULL,
    CONSTRAINT chk_aircraft_models_capacity CHECK (capacity > 0)
);

CREATE TABLE airline.aircrafts (
    aircraft_id INT         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    model_id    INT         NOT NULL,
    tail_number VARCHAR(15) NOT NULL UNIQUE,
    CONSTRAINT fk_aircrafts_model FOREIGN KEY (model_id) REFERENCES airline.aircraft_models(model_id)
);

CREATE TABLE airline.seats (
    seat_id     INT         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aircraft_id INT         NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    seat_class  VARCHAR(20) NOT NULL,
    CONSTRAINT chk_seats_class CHECK (seat_class IN ('Economy', 'Business')),
    UNIQUE (aircraft_id, seat_number),
    CONSTRAINT fk_seats_aircraft FOREIGN KEY (aircraft_id) REFERENCES airline.aircrafts(aircraft_id)
);

CREATE TABLE airline.economy_seats (
    economy_id INT PRIMARY KEY,
    CONSTRAINT fk_economy_seats FOREIGN KEY (economy_id) REFERENCES airline.seats(seat_id)
);

CREATE TABLE airline.business_seats (
    business_id INT PRIMARY KEY,
    CONSTRAINT fk_business_seats FOREIGN KEY (business_id) REFERENCES airline.seats(seat_id)
);

CREATE TABLE airline.roles (
    role_id   SERIAL      PRIMARY KEY,
    role_name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE airline.employees (
    employee_id SERIAL       PRIMARY KEY,
    first_name  VARCHAR(50)  NOT NULL,
    last_name   VARCHAR(50)  NOT NULL,
    role_id     INT          NOT NULL,
    number      INT          NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    iin         BIGINT       NOT NULL UNIQUE,
    CONSTRAINT fk_employees_role FOREIGN KEY (role_id) REFERENCES airline.roles(role_id)
);

CREATE TABLE airline.flight_instances (
    instance_id    SERIAL      PRIMARY KEY,
    flight_id      INT         NOT NULL,
    aircraft_id    INT         NOT NULL,
    departure_time TIMESTAMPTZ NOT NULL,
    arrival_time   TIMESTAMPTZ NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    CONSTRAINT chk_flight_instances_departure_date CHECK (departure_time > TIMESTAMPTZ '2026-01-01 00:00:00+00'),
    CONSTRAINT chk_flight_instances_times          CHECK (arrival_time > departure_time),
    CONSTRAINT chk_flight_instances_status         CHECK (status IN ('Scheduled', 'Departed', 'Arrived', 'Cancelled', 'Delayed')),
    CONSTRAINT fk_flight_instances_flight   FOREIGN KEY (flight_id)   REFERENCES airline.flights(flight_id),
    CONSTRAINT fk_flight_instances_aircraft FOREIGN KEY (aircraft_id) REFERENCES airline.aircrafts(aircraft_id)
);

CREATE TABLE airline.flight_crew (
    instance_id     INT         NOT NULL,
    employee_id     INT         NOT NULL,
    assignment_role VARCHAR(30) NOT NULL,
    PRIMARY KEY (instance_id, employee_id),
    CONSTRAINT fk_flight_crew_instance FOREIGN KEY (instance_id) REFERENCES airline.flight_instances(instance_id),
    CONSTRAINT fk_flight_crew_employee FOREIGN KEY (employee_id) REFERENCES airline.employees(employee_id)
);

CREATE TABLE airline.passengers (
    passenger_id INT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    passport_num VARCHAR(20)  NOT NULL UNIQUE,
    email        VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE airline.bookings (
    booking_id   SERIAL        PRIMARY KEY,
    passenger_id INT           NOT NULL,
    booking_date TIMESTAMPTZ   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount       NUMERIC(10,2) NOT NULL,
    CONSTRAINT chk_bookings_amount CHECK (amount >= 0),
    CONSTRAINT fk_bookings_passenger FOREIGN KEY (passenger_id) REFERENCES airline.passengers(passenger_id)
);

CREATE TABLE airline.tickets (
    ticket_id   SERIAL        PRIMARY KEY,
    booking_id  INT           NOT NULL,
    instance_id INT           NOT NULL,
    fare        NUMERIC(10,2) NOT NULL,
    CONSTRAINT chk_tickets_fare CHECK (fare >= 0),
    CONSTRAINT fk_tickets_booking  FOREIGN KEY (booking_id)  REFERENCES airline.bookings(booking_id),
    CONSTRAINT fk_tickets_instance FOREIGN KEY (instance_id) REFERENCES airline.flight_instances(instance_id)
);

CREATE TABLE airline.boarding_passes (
    pass_id   SERIAL PRIMARY KEY,
    ticket_id INT    NOT NULL UNIQUE,
    seat_id   INT    NOT NULL,
    CONSTRAINT fk_boarding_passes_ticket FOREIGN KEY (ticket_id) REFERENCES airline.tickets(ticket_id),
    CONSTRAINT fk_boarding_passes_seat   FOREIGN KEY (seat_id)   REFERENCES airline.seats(seat_id)
);