CREATE SCHEMA IF NOT EXISTS airline;
SET search_path TO airline;

CREATE TABLE IF NOT EXISTS airline.country (
    country_id   SERIAL      PRIMARY KEY,
    country_name VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS airline.city (
    city_id   SERIAL      PRIMARY KEY,
    city_name VARCHAR(60) NOT NULL
);

CREATE TABLE IF NOT EXISTS airline.airports (
    airport_id   SERIAL       PRIMARY KEY,
    iata_code    CHAR(3)      NOT NULL UNIQUE,
    airport_name VARCHAR(100) NOT NULL,
    city_id      INT          NOT NULL,
    country_id   INT          NOT NULL,
    CONSTRAINT fk_airports_city    FOREIGN KEY (city_id)    REFERENCES airline.city(city_id),
    CONSTRAINT fk_airports_country FOREIGN KEY (country_id) REFERENCES airline.country(country_id)
);

CREATE TABLE IF NOT EXISTS airline.flights (
    flight_id      SERIAL      PRIMARY KEY,
    flight_number  VARCHAR(20) NOT NULL UNIQUE,
    dep_airport_id INT         NOT NULL,
    arr_airport_id INT         NOT NULL,
    CONSTRAINT chk_flights_different_airports CHECK (dep_airport_id <> arr_airport_id),
    CONSTRAINT fk_flights_dep FOREIGN KEY (dep_airport_id) REFERENCES airline.airports(airport_id),
    CONSTRAINT fk_flights_arr FOREIGN KEY (arr_airport_id) REFERENCES airline.airports(airport_id)
);

CREATE TABLE IF NOT EXISTS airline.aircraft_models (
    model_id     SERIAL      PRIMARY KEY,
    manufacturer VARCHAR(50) NOT NULL,
    model_name   VARCHAR(50) NOT NULL,
    capacity     INT         NOT NULL,
    CONSTRAINT chk_aircraft_models_capacity CHECK (capacity > 0)
);

CREATE TABLE IF NOT EXISTS airline.aircrafts (
    aircraft_id INT         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    model_id    INT         NOT NULL,
    tail_number VARCHAR(15) NOT NULL UNIQUE,
    CONSTRAINT fk_aircrafts_model FOREIGN KEY (model_id) REFERENCES airline.aircraft_models(model_id)
);

CREATE TABLE IF NOT EXISTS airline.seats (
    seat_id     INT         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aircraft_id INT         NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    seat_class  VARCHAR(20) NOT NULL,
    CONSTRAINT chk_seats_class CHECK (seat_class IN ('Economy', 'Business')),
    UNIQUE (aircraft_id, seat_number),
    CONSTRAINT fk_seats_aircraft FOREIGN KEY (aircraft_id) REFERENCES airline.aircrafts(aircraft_id)
);

CREATE TABLE IF NOT EXISTS airline.economy_seats (
    economy_id INT PRIMARY KEY,
    CONSTRAINT fk_economy_seats FOREIGN KEY (economy_id) REFERENCES airline.seats(seat_id)
);

CREATE TABLE IF NOT EXISTS airline.business_seats (
    business_id INT PRIMARY KEY,
    CONSTRAINT fk_business_seats FOREIGN KEY (business_id) REFERENCES airline.seats(seat_id)
);

CREATE TABLE IF NOT EXISTS airline.roles (
    role_id   SERIAL      PRIMARY KEY,
    role_name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS airline.employees (
    employee_id SERIAL       PRIMARY KEY,
    first_name  VARCHAR(50)  NOT NULL,
    last_name   VARCHAR(50)  NOT NULL,
    role_id     INT          NOT NULL,
    number      INT          NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    iin         BIGINT       NOT NULL UNIQUE,
    CONSTRAINT fk_employees_role FOREIGN KEY (role_id) REFERENCES airline.roles(role_id)
);

CREATE TABLE IF NOT EXISTS airline.flight_instances (
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

CREATE TABLE IF NOT EXISTS airline.flight_crew (
    instance_id     INT         NOT NULL,
    employee_id     INT         NOT NULL,
    assignment_role VARCHAR(30) NOT NULL,
    PRIMARY KEY (instance_id, employee_id),
    CONSTRAINT fk_flight_crew_instance FOREIGN KEY (instance_id) REFERENCES airline.flight_instances(instance_id),
    CONSTRAINT fk_flight_crew_employee FOREIGN KEY (employee_id) REFERENCES airline.employees(employee_id)
);

CREATE TABLE IF NOT EXISTS airline.passengers (
    passenger_id INT          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    passport_num VARCHAR(20)  NOT NULL UNIQUE,
    email        VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS airline.bookings (
    booking_id   SERIAL        PRIMARY KEY,
    passenger_id INT           NOT NULL,
    booking_date TIMESTAMPTZ   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount       NUMERIC(10,2) NOT NULL,
    CONSTRAINT chk_bookings_amount CHECK (amount >= 0),
    CONSTRAINT fk_bookings_passenger FOREIGN KEY (passenger_id) REFERENCES airline.passengers(passenger_id)
);

CREATE TABLE IF NOT EXISTS airline.tickets (
    ticket_id   SERIAL        PRIMARY KEY,
    booking_id  INT           NOT NULL,
    instance_id INT           NOT NULL,
    fare        NUMERIC(10,2) NOT NULL,
    CONSTRAINT chk_tickets_fare CHECK (fare >= 0),
    CONSTRAINT fk_tickets_booking  FOREIGN KEY (booking_id)  REFERENCES airline.bookings(booking_id),
    CONSTRAINT fk_tickets_instance FOREIGN KEY (instance_id) REFERENCES airline.flight_instances(instance_id)
);

CREATE TABLE IF NOT EXISTS airline.boarding_passes (
    pass_id   SERIAL PRIMARY KEY,
    ticket_id INT    NOT NULL UNIQUE,
    seat_id   INT    NOT NULL,
    CONSTRAINT fk_boarding_passes_ticket FOREIGN KEY (ticket_id) REFERENCES airline.tickets(ticket_id),
    CONSTRAINT fk_boarding_passes_seat   FOREIGN KEY (seat_id)   REFERENCES airline.seats(seat_id)
);


INSERT INTO airline.country (country_name) VALUES 
('Kazakhstan'),
('USA'),
('France');

INSERT INTO airline.city (city_name) VALUES 
('Almaty'),
('Astana'),
('New York'),
('Paris');

INSERT INTO airline.airports (iata_code, airport_name, city_id, country_id) VALUES 
('ALA', 'Almaty International', 1, 1),
('NQZ', 'Nursultan Nazarbayev International', 2, 1),
('JFK', 'John F. Kennedy', 3, 2),
('CDG', 'Charles de Gaulle', 4, 3);

INSERT INTO airline.flights (flight_number, dep_airport_id, arr_airport_id) VALUES 
('KC101', 1, 3), 
('KC202', 2, 4);

INSERT INTO airline.aircraft_models (manufacturer, model_name, capacity) VALUES 
('Boeing', '787 Dreamliner', 250),
('Airbus', 'A320neo', 180);

INSERT INTO airline.aircrafts (model_id, tail_number) VALUES 
(1, 'P4-KCA'),
(2, 'P4-KCB');

INSERT INTO airline.seats (aircraft_id, seat_number, seat_class) VALUES 
(1, '1A', 'Business'),
(1, '12B', 'Economy'),
(2, '2A', 'Business'),
(2, '15C', 'Economy');

INSERT INTO airline.economy_seats (economy_id) VALUES 
(2),
(4);

INSERT INTO airline.business_seats (business_id) VALUES 
(1),
(3);

INSERT INTO airline.roles (role_name) VALUES 
('Pilot'),
('Co-Pilot'),
('Flight Attendant');

INSERT INTO airline.employees (first_name, last_name, role_id, number, email, iin) VALUES 
('John', 'Doe', 1, 1001, 'john.doe@airline.com', 800101456789),
('Jane', 'Smith', 2, 1002, 'jane.smith@airline.com', 900202123456),
('Anna', 'Lee', 3, 1003, 'anna.lee@airline.com', 950303654321);

INSERT INTO airline.flight_instances (flight_id, aircraft_id, departure_time, arrival_time, status) VALUES 
(1, 1, '2026-06-01 10:00:00+00', '2026-06-01 22:00:00+00', 'Scheduled'),
(2, 2, '2026-07-15 08:00:00+00', '2026-07-15 14:00:00+00', 'Scheduled');

INSERT INTO airline.flight_crew (instance_id, employee_id, assignment_role) VALUES 
(1, 1, 'Captain'),
(1, 2, 'First Officer'),
(1, 3, 'Senior Cabin Crew'),
(2, 1, 'Captain');

INSERT INTO airline.passengers (first_name, last_name, passport_num, email) VALUES 
('Michael', 'Johnson', 'N12345678', 'michael.j@example.com'),
('Emily', 'Davis', 'N87654321', 'emily.d@example.com');

INSERT INTO airline.bookings (passenger_id, booking_date, amount) VALUES 
(1, '2026-04-10 12:00:00+00', 1500.00),
(2, '2026-04-12 14:30:00+00', 800.00);

INSERT INTO airline.tickets (booking_id, instance_id, fare) VALUES 
(1, 1, 1500.00),
(2, 2, 800.00);

INSERT INTO airline.boarding_passes (ticket_id, seat_id) VALUES 
(1, 1),
(2, 4);
