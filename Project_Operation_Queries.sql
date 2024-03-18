--Stored Procedure 1

CREATE PROCEDURE usp_HandleBaggage
    @flight_code VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    -- Logic to associate baggage with a flight and ensure all are accounted for
    UPDATE Baggage_Tracking
    SET status = 'Loaded'
    WHERE flight_code = @flight_code AND status = 'Check-In';
END;

EXEC usp_HandleBaggage @flight_code = 'SA107';


-----------------------------------------------------
--Stored Procedure 2

CREATE PROCEDURE usp_ManageBookingCancellation
    @booking_id INT,
    @passport_id INT,
    @ticket_id INT,
    @is_cancellation BIT
AS
BEGIN
    SET NOCOUNT ON;
    IF @is_cancellation = 1
    BEGIN
        UPDATE Booking
        SET booking_status = 'Cancelled'
        WHERE booking_id = @booking_id and passport_id = @passport_id and ticket_id = @ticket_id;
        INSERT INTO Cancellation (passport_id,ticket_id, date_of_cancellation)
        VALUES (@passport_id, @ticket_id,GETDATE()); 
    END
    ELSE
    BEGIN
        UPDATE Booking
        SET booking_status = 'Confirmed'
        WHERE booking_id = @booking_id;
        --Add delete entry from cancellation table
    END
END;

EXEC usp_ManageBookingCancellation @booking_id = 8050, @passport_id = 223, @ticket_id = 364, @is_cancellation = 1;

---------------------------------------------------------
--Stored Procedure 3

ALTER PROCEDURE usp_CalculateTotalLuggageWeight
    @flight_code VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @totalWeight DECIMAL(10, 2);

    SELECT @totalWeight = SUM(b.weight)
    FROM Baggage b
    INNER JOIN Booking bo ON b.passport_id = bo.passport_id
    WHERE bo.flight_code = @flight_code;
    RETURN ISNULL(@totalWeight, 0);
END;
GO

DECLARE @result DECIMAL(10, 2);
EXEC @result = usp_CalculateTotalLuggageWeight @flight_code = 'SA107';
SELECT @result AS TotalWeight;

--------------------------------------------------------
--Stored Procedure 4

CREATE PROCEDURE usp_UpdateFlightStatus
    @flight_code VARCHAR(20),
    @is_delayed BIT,
    @is_scheduled BIT,
    @is_ontime BIT
AS
BEGIN
    SET NOCOUNT ON;
    IF @is_delayed = 1
    BEGIN
        UPDATE Flight
        SET [status] = 'Delayed'
        WHERE flight_code = @flight_code;
    END
    ELSE IF @is_scheduled = 1
    BEGIN
        UPDATE Flight
        SET [status] = 'Scheduled'
        WHERE flight_code = @flight_code;
    END
    ELSE IF @is_ontime = 1
    BEGIN
        UPDATE Flight
        SET [status] = 'On Time'
        WHERE flight_code = @flight_code;
    END
END;
GO

EXEC usp_UpdateFlightStatus @flight_code = 'AC115', @is_delayed = 1, @is_scheduled = 0, @is_ontime = 0;


--------------------------------------------------------------------------------
--UDF 1

CREATE FUNCTION udf_CalculateTotalFlightRevenue(@flight_code VARCHAR(20))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @totalRevenue DECIMAL(10,2);
    SELECT @totalRevenue = SUM(price)
    FROM Ticket t
    INNER JOIN Booking b ON t.ticket_id = b.ticket_id
    WHERE b.flight_code = @flight_code;
    RETURN ISNULL(@totalRevenue, 0);
END;

DECLARE @result DECIMAL(10, 2);
EXEC @result = udf_CalculateTotalFlightRevenue @flight_code = 'DL111';
SELECT @result AS Total_Revenue;




------------------------------------------------------------------------------------

--UDF 2
CREATE FUNCTION udf_ConvertTicketPrice(@ticket_id INT, @toCurrency VARCHAR(3))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @price DECIMAL(10,2);
    DECLARE @conversionRate DECIMAL(10,2);
    
    SELECT @price = price FROM Ticket WHERE ticket_id = @ticket_id;
    
    SET @conversionRate = CASE @toCurrency
                            WHEN 'USD' THEN 1
                            WHEN 'EUR' THEN 0.85
                            WHEN 'GBP' THEN 0.75
                            ELSE 1 
                          END;
    RETURN @price * @conversionRate;
END;

DECLARE @result DECIMAL(10, 2);
EXEC @result =udf_ConvertTicketPrice @ticket_id = 316, @toCurrency= 'GBP';
SELECT @result AS Converted_Price;

SELECT * FROM Ticket;


--------------------------------------------------------------------------------------
--UDF on Computed Column
CREATE FUNCTION udf_CalculateAge
(
    @Birthdate  DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT
    SET @Age = DATEDIFF(YEAR, @Birthdate , GETDATE()) - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @Birthdate , GETDATE()), @Birthdate ) > GETDATE() THEN 1 ELSE 0 END
    RETURN @Age
END;

ALTER TABLE Passenger
ADD age AS dbo.udf_CalculateAge(dob);

ALTER TABLE Employee
ADD age AS dbo.udf_CalculateAge(dob);

SELECT * FROM Passenger;
SELECT * FROM Employee;

---------------------------------------------------------------------------------------
-- VIEW 1

ALTER VIEW vw_BaggageTracking AS
SELECT bt.track_id,p.first_name, p.last_name, b.passport_id, b.weight, b.size, b.status, 
       f.flight_code, f.departure_time, f.arrival_time
FROM Baggage_tracking bt
JOIN Baggage b ON bt.baggage_id = b.baggage_id
JOIN Flight f ON bt.flight_code = f.flight_code
JOIN Passenger p ON b.passport_id = p.passport_id

;
GO

SELECT * FROM dbo.vw_BaggageTracking

-------------------------------------------------------------
-- VIEW 2

ALTER VIEW vw_PassengerBookings AS
SELECT p.first_name, p.last_name, p.passport_id,p.sex,b.booking_id, b.date_of_booking, b.booking_status, b.flight_code,a.airline_name,
       t.source, t.destination,t.class,t.seat_num, t.travel_date
FROM Passenger p
JOIN Booking b ON p.passport_id = b.passport_id
JOIN Ticket t ON b.ticket_id = t.ticket_id
JOIN Flight f ON b.flight_code = f.flight_code
JOIN Airline a ON f.airline_id = a.airline_id
where b.booking_status = 'Confirmed';

SELECT * FROM vw_PassengerBookings

--------------------------------------------------------------
-- VIEW 3

CREATE VIEW vw_CurrentFlightsStatus AS
SELECT f.flight_code, f.departure_time, f.arrival_time, f.status, 
       a.airport_name AS source_airport, b.airport_name AS destination_airport
FROM Flight f
JOIN Airport a ON f.source_airport_id = a.airport_id
JOIN Airport b ON f.destination_airport_id = b.airport_id
WHERE f.status = 'Scheduled' OR f.status = 'Delayed' OR f.status = 'On Time';

SELECT * FROM vw_CurrentFlightsStatus

---------------------------------------------------------------------
-- VIEW 4

CREATE VIEW vw_AirlineMaxRevenue AS
SELECT 
    a.airline_name,
    SUM(t.price) AS TotalRevenue
FROM 
    Airline a
JOIN 
    Flight f ON a.airline_id = f.airline_id
JOIN 
    Booking b ON f.flight_code = b.flight_code
JOIN 
    Ticket t ON b.[ticket_id] = t.[ticket_id]
GROUP BY 
    a.airline_name

SELECT * FROM vw_AirlineMaxRevenue order by TotalRevenue DESC

--------------------------------------------------------------------
-- VIEW 5

CREATE VIEW vw_CheckAvailibility AS
SELECT f.flight_code,t.* 
FROM Ticket t
LEFT JOIN Booking b ON t.ticket_id = b.ticket_id
JOIN Flight f ON t.travel_date = f.departure_time
WHERE b.ticket_id IS NULL

SELECT * FROM vw_CheckAvailibility

-----------------------------------------------------------------------
-- VIEW 6

CREATE VIEW vw_EMPLOYEE_AIRPORT_VISUALIZATION AS
SELECT e.employee_id, e.first_name, e.last_name, e.sex,e.job_type, a.airport_name 
FROM Employee e JOIN Airport a ON e.airport_id = a.airport_id

SELECT * FROM vw_EMPLOYEE_AIRPORT_VISUALIZATION

-----------------------------------------------------------------------------------------------------
--Trigger 1

CREATE TRIGGER trg_AuditPassengerUpdate
ON Passenger
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
 
    INSERT INTO PassengerAudit(passport_id, first_name, last_name, update_timestamp)
    SELECT passport_id, first_name, last_name, GETDATE()
    FROM inserted;
END;
GO

INSERT INTO Passenger (first_name, last_name, sex, dob, address)
VALUES
('Apoorv', 'Dhaygude', 'Male', '1999-11-18', '123 Pune Main St, Maharashtra, India')

SELECT * FROM PassengerAudit

------------------------------------------------------------------------------------
--Trigger 2

CREATE TRIGGER trg_AuditFlightStatusChange
ON Flight
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
 
    IF UPDATE([status])
    BEGIN
        INSERT INTO FlightStatusAudit(flight_code, old_status, new_status, change_timestamp)
        SELECT i.flight_code, d.status, i.status, GETDATE()
        FROM inserted i
        INNER JOIN deleted d ON i.flight_code = d.flight_code
        WHERE i.status != d.status;
    END
END;
GO

SELECT * FROM FlightStatusAudit

----------------------------------------------------------------------------

--COLUMN DATA ENCRYPTION:

CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'India#99600';
 
SELECT NAME KeyName,
symmetric_key_id KeyID,
key_length KeyLength,
algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;
go
 
CREATE CERTIFICATE PassengerPassport
WITH SUBJECT = 'Passenger Passport';
GO
 
CREATE SYMMETRIC KEY PassengerPassport_SM
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE PassengerPassport;
GO
 
OPEN SYMMETRIC KEY PassengerPassport_SM
DECRYPTION BY CERTIFICATE PassengerPassport;

UPDATE Passenger
SET [password] = EncryptByKey(Key_GUID('PassengerPassport_SM'), CONVERT(VARBINARY, 'Ethan'))
where [passport_id] ='210';
SELECT * FROM Passenger


--Decrypt
OPEN SYMMETRIC KEY PassengerPassport_SM
DECRYPTION BY CERTIFICATE PassengerPassport;
SELECT *,
CONVERT(varchar, DecryptByKey([password]))
AS 'Decrypted password'
FROM Passenger;
GO

-------------------------------------------------------------
-- Non-clustered index on the Booking table for passport_id to quickly find bookings by passenger:
CREATE NONCLUSTERED INDEX nc_index_booking_passport
ON Booking (passport_id);

--Non-clustered index on the Employee table for job_type to efficiently query employees by their job type
CREATE NONCLUSTERED INDEX idx_nc_employee_job_type
ON Employee (job_type);

--Non-clustered index on the Baggage table for status to quickly access baggage by their current status (e.g., 'Checked-in', 'Loaded', etc.)
CREATE NONCLUSTERED INDEX idx_nc_baggage_status
ON Baggage (status);

----------------------------------------------------------------------------------------