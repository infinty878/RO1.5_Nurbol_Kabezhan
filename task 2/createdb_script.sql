DROP DATABASE IF EXISTS airline_booking_system;
CREATE DATABASE airline_booking_system;
USE airline_booking_system;

CREATE TABLE country (
    country_id   INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE city (
    city_id   INT AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(50) NOT NULL
);

CREATE TABLE airports (
    airport_id   INT AUTO_INCREMENT PRIMARY KEY,
    iata_code    CHAR(3) NOT NULL UNIQUE,
    airport_name VARCHAR(100) NOT NULL,
    city_id      INT NOT NULL,
    country_id   INT NOT NULL,
    CONSTRAINT fk_airports_city FOREIGN KEY (city_id) REFERENCES city(city_id),
    CONSTRAINT fk_airports_country FOREIGN KEY (country_id) REFERENCES country(country_id)
);

CREATE TABLE flights (
    flight_id       INT AUTO_INCREMENT PRIMARY KEY,
    flight_number   VARCHAR(20) NOT NULL UNIQUE,
    dep_airport_id  INT NOT NULL,
    arr_airport_id  INT NOT NULL,
    CONSTRAINT fk_flights_dep_airport FOREIGN KEY (dep_airport_id) REFERENCES airports(airport_id),
    CONSTRAINT fk_flights_arr_airport FOREIGN KEY (arr_airport_id) REFERENCES airports(airport_id)
);

CREATE TABLE aircraft_models (
    model_id     INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer VARCHAR(50) NOT NULL,
    model_name   VARCHAR(50) NOT NULL,
    capacity     INT NOT NULL,
    CONSTRAINT chk_aircraft_models_capacity CHECK (capacity > 0)
);

CREATE TABLE aircrafts (
    aircraft_id  INT AUTO_INCREMENT PRIMARY KEY,
    model_id     INT NOT NULL,
    tail_number  VARCHAR(15) NOT NULL UNIQUE,
    CONSTRAINT fk_aircrafts_model FOREIGN KEY (model_id) REFERENCES aircraft_models(model_id)
);

CREATE TABLE seats (
    seat_id     INT AUTO_INCREMENT PRIMARY KEY,
    aircraft_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    seat_class  VARCHAR(20) NOT NULL,
    UNIQUE (aircraft_id, seat_number),
    CONSTRAINT chk_seats_class CHECK (seat_class IN ('Economy', 'Business')),
    CONSTRAINT fk_seats_aircraft FOREIGN KEY (aircraft_id) REFERENCES aircrafts(aircraft_id)
);

CREATE TABLE economy_seats (
    economy_id INT PRIMARY KEY,
    CONSTRAINT fk_economy_seats FOREIGN KEY (economy_id) REFERENCES seats(seat_id)
);

CREATE TABLE business_seats (
    business_id INT PRIMARY KEY,
    CONSTRAINT fk_business_seats FOREIGN KEY (business_id) REFERENCES seats(seat_id)
);

CREATE TABLE flight_instances (
    instance_id    INT AUTO_INCREMENT PRIMARY KEY,
    flight_id      INT NOT NULL,
    aircraft_id    INT NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time   DATETIME NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    CONSTRAINT chk_flight_instances_departure_date CHECK (departure_time > '2026-01-01 00:00:00'),
    CONSTRAINT chk_flight_instances_status CHECK (status IN ('Scheduled', 'Departed', 'Arrived', 'Cancelled', 'Delayed')),
    CONSTRAINT fk_flight_instances_flight FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    CONSTRAINT fk_flight_instances_aircraft FOREIGN KEY (aircraft_id) REFERENCES aircrafts(aircraft_id)
);

CREATE TABLE roles (
    role_id   INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    role_id     INT NOT NULL,
    number      INT NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    iin         BIGINT NOT NULL UNIQUE,
    CONSTRAINT fk_employees_role FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

CREATE TABLE flight_crew (
    instance_id     INT NOT NULL,
    employee_id     INT NOT NULL,
    assignment_role VARCHAR(30) NOT NULL,
    PRIMARY KEY (instance_id, employee_id),
    CONSTRAINT fk_flight_crew_instance FOREIGN KEY (instance_id) REFERENCES flight_instances(instance_id),
    CONSTRAINT fk_flight_crew_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE passengers (
    passenger_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name   VARCHAR(50) NOT NULL,
    last_name    VARCHAR(50) NOT NULL,
    passport_num VARCHAR(20) NOT NULL UNIQUE,
    email        VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE bookings (
    booking_id   INT AUTO_INCREMENT PRIMARY KEY,
    passenger_id INT NOT NULL,
    booking_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount       DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_bookings_amount CHECK (amount >= 0),
    CONSTRAINT fk_bookings_passenger FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id)
);

CREATE TABLE tickets (
    ticket_id   INT AUTO_INCREMENT PRIMARY KEY,
    booking_id  INT NOT NULL,
    instance_id INT NOT NULL,
    fare        DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_tickets_fare CHECK (fare >= 0),
    CONSTRAINT fk_tickets_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT fk_tickets_instance FOREIGN KEY (instance_id) REFERENCES flight_instances(instance_id)
);

CREATE TABLE boarding_passes (
    pass_id   INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL UNIQUE,
    seat_id   INT NOT NULL,
    CONSTRAINT fk_boarding_passes_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id),
    CONSTRAINT fk_boarding_passes_seat FOREIGN KEY (seat_id) REFERENCES seats(seat_id)
);