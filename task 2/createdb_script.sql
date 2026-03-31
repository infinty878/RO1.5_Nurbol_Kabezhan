DROP DATABASE IF EXISTS airline_booking_system;
CREATE DATABASE airline_booking_system;

USE airline_booking_system;

CREATE TABLE IF NOT EXISTS country (
    country_id   INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS city (
    city_id   INT AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS airports (
    airport_id   INT AUTO_INCREMENT PRIMARY KEY,
    iata_code    CHAR(3) NOT NULL UNIQUE,
    airport_name VARCHAR(100) NOT NULL,
    city_id      INT NOT NULL,
    country_id   INT NOT NULL,
    CONSTRAINT fk_airports_city
        FOREIGN KEY (city_id) REFERENCES city(city_id),
    CONSTRAINT fk_airports_country
        FOREIGN KEY (country_id) REFERENCES country(country_id)
);

CREATE TABLE IF NOT EXISTS flights (
    flight_id       INT AUTO_INCREMENT PRIMARY KEY,
    flight_number   VARCHAR(20) NOT NULL UNIQUE,
    dep_airport_id  INT NOT NULL,
    arr_airport_id  INT NOT NULL,
    CONSTRAINT fk_flights_dep_airport
        FOREIGN KEY (dep_airport_id) REFERENCES airports(airport_id),
    CONSTRAINT fk_flights_arr_airport
        FOREIGN KEY (arr_airport_id) REFERENCES airports(airport_id)
);

CREATE TABLE IF NOT EXISTS aircraft_models (
    model_id     INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer VARCHAR(50) NOT NULL,
    model_name   VARCHAR(50) NOT NULL,
    capacity     INT NOT NULL,
    CONSTRAINT chk_aircraft_models_capacity CHECK (capacity > 0)
);

CREATE TABLE IF NOT EXISTS aircrafts (
    aircraft_id  INT AUTO_INCREMENT PRIMARY KEY,
    model_id     INT NOT NULL,
    tail_number  VARCHAR(15) NOT NULL UNIQUE,
    CONSTRAINT fk_aircrafts_model
        FOREIGN KEY (model_id) REFERENCES aircraft_models(model_id)
);

CREATE TABLE IF NOT EXISTS seats (
    seat_id     INT AUTO_INCREMENT PRIMARY KEY,
    aircraft_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL UNIQUE,
    seat_class  VARCHAR(20) NOT NULL,
    CONSTRAINT chk_seats_class CHECK (seat_class IN ('Economy', 'Business')),
    CONSTRAINT fk_seats_aircraft
        FOREIGN KEY (aircraft_id) REFERENCES aircrafts(aircraft_id)
);

CREATE TABLE IF NOT EXISTS economy_seats (
    economy_id INT PRIMARY KEY,
    CONSTRAINT fk_economy_seats
        FOREIGN KEY (economy_id) REFERENCES seats(seat_id)
);

CREATE TABLE IF NOT EXISTS business_seats (
    business_id INT PRIMARY KEY,
    CONSTRAINT fk_business_seats
        FOREIGN KEY (business_id) REFERENCES seats(seat_id)
);

CREATE TABLE IF NOT EXISTS flight_instances (
    instance_id    INT AUTO_INCREMENT PRIMARY KEY,
    flight_id      INT NOT NULL,
    aircraft_id    INT NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time   DATETIME NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    CONSTRAINT chk_flight_instances_departure_date
        CHECK (departure_time > '2026-01-01 00:00:00'),
    CONSTRAINT chk_flight_instances_status
        CHECK (status IN ('Scheduled', 'Departed', 'Arrived', 'Cancelled', 'Delayed')),
    CONSTRAINT fk_flight_instances_flight
        FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    CONSTRAINT fk_flight_instances_aircraft
        FOREIGN KEY (aircraft_id) REFERENCES aircrafts(aircraft_id)
);

CREATE TABLE IF NOT EXISTS roles (
    role_id   INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    role_id     INT NOT NULL,
    number      INT NOT NULL,
    email       VARCHAR(100) NOT NULL,
    iin         BIGINT NOT NULL UNIQUE,
    CONSTRAINT fk_employees_role
        FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

CREATE TABLE IF NOT EXISTS flight_crew (
    instance_id     INT NOT NULL,
    employee_id     INT NOT NULL,
    assignment_role VARCHAR(30) NOT NULL,
    PRIMARY KEY (instance_id, employee_id),
    CONSTRAINT fk_flight_crew_instance
        FOREIGN KEY (instance_id) REFERENCES flight_instances(instance_id),
    CONSTRAINT fk_flight_crew_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE IF NOT EXISTS passengers (
    passenger_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name   VARCHAR(50) NOT NULL,
    last_name    VARCHAR(50) NOT NULL,
    passport_num VARCHAR(20) NOT NULL UNIQUE,
    email        VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS bookings (
    booking_id   INT AUTO_INCREMENT PRIMARY KEY,
    passenger_id INT NOT NULL,
    booking_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount       DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_bookings_amount CHECK (amount >= 0),
    CONSTRAINT fk_bookings_passenger
        FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id)
);

CREATE TABLE IF NOT EXISTS tickets (
    ticket_id   INT AUTO_INCREMENT PRIMARY KEY,
    booking_id  INT NOT NULL,
    instance_id INT NOT NULL,
    fare        DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_tickets_fare CHECK (fare >= 0),
    CONSTRAINT fk_tickets_booking
        FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT fk_tickets_instance
        FOREIGN KEY (instance_id) REFERENCES flight_instances(instance_id)
);

CREATE TABLE IF NOT EXISTS boarding_passes (
    pass_id   INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL UNIQUE,
    seat_id   INT NOT NULL,
    CONSTRAINT fk_boarding_passes_ticket
        FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id),
    CONSTRAINT fk_boarding_passes_seat
        FOREIGN KEY (seat_id) REFERENCES seats(seat_id)
);

INSERT INTO country (country_name) VALUES
    ('United States'),
    ('United Kingdom');

INSERT INTO city (city_name) VALUES
    ('New York'),
    ('Los Angeles'),
    ('London'),
    ('Chicago');

INSERT INTO airports (iata_code, airport_name, city_id, country_id) VALUES
    ('JFK', 'John F. Kennedy International Airport', 1, 1),
    ('LAX', 'Los Angeles International Airport', 2, 1),
    ('LHR', 'London Heathrow Airport', 3, 2),
    ('ORD', 'O\'Hare International Airport', 4, 1);

INSERT INTO flights (flight_number, dep_airport_id, arr_airport_id) VALUES
    ('AA100', 1, 2),
    ('BA200', 3, 1),
    ('UA300', 4, 2);

INSERT INTO aircraft_models (manufacturer, model_name, capacity) VALUES
    ('Boeing', '737-800', 189),
    ('Airbus', 'A320', 180);

INSERT INTO aircrafts (model_id, tail_number) VALUES
    (1, 'N12345'),
    (2, 'G-EUAB');

INSERT INTO seats (aircraft_id, seat_number, seat_class) VALUES
    (1, '1A', 'Business'),
    (1, '25B', 'Economy'),
    (2, '2A', 'Business'),
    (2, '30C', 'Economy');

INSERT INTO economy_seats (economy_id) VALUES
    (2),
    (4);

INSERT INTO business_seats (business_id) VALUES
    (1),
    (3);

INSERT INTO flight_instances (flight_id, aircraft_id, departure_time, arrival_time, status) VALUES
    (1, 1, '2026-03-15 08:00:00', '2026-03-15 11:30:00', 'Scheduled'),
    (2, 2, '2026-04-01 14:00:00', '2026-04-01 22:00:00', 'Scheduled'),
    (3, 1, '2026-05-10 06:00:00', '2026-05-10 08:30:00', 'Departed');

INSERT INTO roles (role_name) VALUES
    ('Pilot'),
    ('Flight Attendant');

INSERT INTO employees (first_name, last_name, role_id, number, email, iin) VALUES
    ('John', 'Smith', 1, 1001, 'john.smith@airline.com', 900101350001),
    ('Jane', 'Doe', 2, 1002, 'jane.doe@airline.com', 950515450002),
    ('Robert', 'Brown', 1, 1003, 'robert.brown@airline.com', 880720350003);

INSERT INTO flight_crew (instance_id, employee_id, assignment_role) VALUES
    (1, 1, 'Captain'),
    (1, 2, 'Lead Attendant'),
    (2, 3, 'Captain');

INSERT INTO passengers (first_name, last_name, passport_num, email) VALUES
    ('Alice', 'Johnson', 'US12345678', 'alice.j@email.com'),
    ('Bob', 'Williams', 'UK87654321', 'bob.w@email.com');

INSERT INTO bookings (passenger_id, booking_date, amount) VALUES
    (1, '2026-02-20 10:00:00', 450.00),
    (2, '2026-03-01 15:30:00', 1200.50);

INSERT INTO tickets (booking_id, instance_id, fare) VALUES
    (1, 1, 450.00),
    (2, 2, 1200.50);

INSERT INTO boarding_passes (ticket_id, seat_id) VALUES
    (1, 2),
    (2, 3);

SELECT * FROM country;
SELECT * FROM city;
SELECT * FROM airports;
SELECT * FROM flights;
SELECT * FROM aircraft_models;
SELECT * FROM aircrafts;
SELECT * FROM seats;
SELECT * FROM economy_seats;
SELECT * FROM business_seats;
SELECT * FROM flight_instances;
SELECT * FROM roles;
SELECT * FROM employees;
SELECT * FROM flight_crew;
SELECT * FROM passengers;
SELECT * FROM bookings;
SELECT * FROM tickets;
SELECT * FROM boarding_passes;
