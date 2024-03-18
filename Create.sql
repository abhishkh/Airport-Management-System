-- Create Database
CREATE DATABASE AIRPORT_MANAGEMENT_SYSTEM;

USE AIRPORT_MANAGEMENT_SYSTEM

-- Create Tables

-- Airport Table
    CREATE TABLE Airport (
        airport_id INT IDENTITY(125,1) UNIQUE NOT NULL,
        airport_name VARCHAR(200) NOT NULL,
        city VARCHAR(200) NOT NULL,
        [state] VARCHAR(200) NOT NULL,
        country VARCHAR(200) NOT NULL,
        CONSTRAINT [Airport_PK] PRIMARY KEY ([airport_id] ASC)
    );

-- Employee Table
    CREATE TABLE Employee (
        employee_id INT IDENTITY(1,1) NOT NULL,
        airport_id INT NOT NULL,
        first_name VARCHAR(200) NOT NULL,
        last_name VARCHAR(200) NOT NULL,
        sex VARCHAR(10) NOT NULL constraint sex_chk check (sex in ('Male','Female','Other')),
        dob DATE,
        [address] VARCHAR(200),
        salary DECIMAL(10, 2) NOT NULL,
        job_type VARCHAR(200) NOT NULL,
        CONSTRAINT [Employee_FK1] FOREIGN KEY (airport_id) REFERENCES Airport(airport_id),
        CONSTRAINT [Employee_PK] PRIMARY KEY ([employee_id] ASC)
    );

-- Passenger Table
    CREATE TABLE Passenger (
        passport_id INT IDENTITY(200,1) NOT NULL,
        first_name VARCHAR(200) NOT NULL,
        last_name VARCHAR(200) NOT NULL,
        sex VARCHAR(10) NOT NULL constraint sex1_chk check (sex in ('Male','Female','Other')),
        dob DATE ,
        [address] VARCHAR(255) 
        CONSTRAINT [Passenger_PK] PRIMARY KEY ([passport_id] ASC)
    );

-- Ticket Table
    CREATE TABLE Ticket (
        ticket_id INT IDENTITY(315,1) NOT NULL,
        source VARCHAR(200) NOT NULL,
        destination VARCHAR(200) NOT NULL,
        seat_num INT NOT NULL,
        travel_date DATETIME NOT NULL,
        class VARCHAR(200) CONSTRAINT class_chk CHECK (class in ('Economy','Business')),
        price DECIMAL(10, 2) NOT NULL,
        CONSTRAINT [Ticket_PK] PRIMARY KEY ([ticket_id] ASC)
    );

-- Airline Table
    CREATE TABLE Airline (
        airline_id INT IDENTITY(60,1) NOT NULL,
        airline_name VARCHAR(200) NOT NULL,
        contact VARCHAR(200),
        CONSTRAINT [Airline_PK] PRIMARY KEY ([airline_id] ASC)
    );

-- Flight Table
    CREATE TABLE Flight (
        flight_code VARCHAR(200) NOT NULL,
        flightType VARCHAR(200) NOT NULL,
        departure_time DATETIME NOT NULL,
        arrival_time DATETIME NOT NULL,
        duration INT,
        [status] VARCHAR(200) CONSTRAINT status_chk CHECK ([status] in ('Scheduled','Delayed', 'On Time')),
        airline_id INT,
        source_airport_id INT,
        destination_airport_id INT,
        CONSTRAINT [Flight_FK1] FOREIGN KEY (airline_id) REFERENCES Airline(airline_id),
        CONSTRAINT [Flight_FK2] FOREIGN KEY (source_airport_id) REFERENCES Airport(airport_id),
        CONSTRAINT [Flight_FK3] FOREIGN KEY (destination_airport_id) REFERENCES Airport(airport_id),
        CONSTRAINT [Flight_PK] PRIMARY KEY ([flight_code] ASC)
    );

-- Baggage Table
    CREATE TABLE Baggage (
        baggage_id INT IDENTITY(6000,1) NOT NULL,
        passport_id INT NOT NULL,
        [weight] DECIMAL(5, 2),
        [size] VARCHAR(200) CONSTRAINT size_chk CHECK ([size] in ('Small','Medium', 'Large')),
        [status] VARCHAR(200),
        CONSTRAINT [Baggage_FK] FOREIGN KEY (passport_id) REFERENCES Passenger(passport_id),
        CONSTRAINT [Baggage_PK] PRIMARY KEY ([baggage_id] ASC)
    );

-- Booking Table
    CREATE TABLE Booking (
        booking_id INT IDENTITY(8000,1) NOT NULL,
        passport_id INT NOT NULL,
        ticket_id INT NOT NULL,
        flight_code VARCHAR(200) NOT NULL,
        date_of_booking DATETIME NOT NULL,
        booking_status VARCHAR(200),
        CONSTRAINT [Booking_FK1] FOREIGN KEY (passport_id) REFERENCES Passenger(passport_id),
        CONSTRAINT [Booking_FK2] FOREIGN KEY (ticket_id) REFERENCES Ticket(ticket_id),
        CONSTRAINT [Booking_FK3] FOREIGN KEY (flight_code) REFERENCES Flight(flight_code),
        CONSTRAINT [Booking_PK] PRIMARY KEY ([booking_id] ASC)
    );


-- Cancellation Table
    CREATE TABLE Cancellation (
        cancellation_id INT IDENTITY(700,1) NOT NULL,
        passport_id INT NOT NULL,
        ticket_id INT NOT NULL,
        date_of_cancellation DATETIME,
        CONSTRAINT [Cancellation_FK1] FOREIGN KEY (passport_id) REFERENCES Passenger(passport_id),
        CONSTRAINT [Cancellation_FK2] FOREIGN KEY (ticket_id) REFERENCES Ticket(ticket_id),
        CONSTRAINT [Cancellation_PK] PRIMARY KEY ([cancellation_id] ASC)
    );

-- Immigration Clearance Table
    CREATE TABLE Immigration_Clearance (
        immigration_id INT IDENTITY(990,1) NOT NULL,
        employee_id INT NOT NULL,
        passport_id INT NOT NULL,
        CONSTRAINT [Immigration_FK1] FOREIGN KEY (passport_id) REFERENCES Passenger(passport_id),
        CONSTRAINT [Immigration_FK2] FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
        CONSTRAINT [Immigration_PK] PRIMARY KEY ([immigration_id] ASC)
    );

-- Baggage Tracking Table
    CREATE TABLE Baggage_Tracking (
        track_id INT IDENTITY(777,1) NOT NULL,
        baggage_id INT NOT NULL,
        flight_code VARCHAR(200) NOT NULL,
        [status] VARCHAR(200) NOT NULL,
        FOREIGN KEY (baggage_id) REFERENCES Baggage(baggage_id),
        CONSTRAINT [Baggage_Tracking_FK1] FOREIGN KEY (baggage_id) REFERENCES Baggage(baggage_id),
        CONSTRAINT [Baggage_Tracking_FK2] FOREIGN KEY (flight_code) REFERENCES Flight(flight_code),
        CONSTRAINT [Baggage_Tracking_PK] PRIMARY KEY ([track_id] ASC)
    );

 -- Passenger Audit Table
    CREATE TABLE PassengerAudit (
        pa_audit_id INT IDENTITY(3030,1) NOT NULL,
        passport_id INT,
        first_name VARCHAR(200),
        last_name VARCHAR(200) ,
        update_timestamp DATETIME,
        CONSTRAINT [PassengerAudit_PK] PRIMARY KEY ([pa_audit_id] ASC),
        CONSTRAINT [PassengerAudit_FK] FOREIGN KEY (passport_id) REFERENCES Passenger(passport_id)
    );

-- Flight Status Audit Table
    CREATE TABLE FlightStatusAudit (
        flight_code VARCHAR(200) ,
        old_status VARCHAR(200) ,
        new_status VARCHAR(200) ,
        change_timestamp DATETIME,
        CONSTRAINT [FlightStatusAudit_FK] FOREIGN KEY (flight_code) REFERENCES Flight(flight_code)
    );