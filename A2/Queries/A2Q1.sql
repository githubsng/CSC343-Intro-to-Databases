SET search_path TO bnb, public;

-- Clear Views
DROP VIEW IF EXISTS STEP1 CASCADE;
DROP VIEW IF EXISTS TotalRequests CASCADE;
DROP VIEW IF EXISTS TotalBookings CASCADE; 


/*
According to Piazza:
https://piazza.com/class/isyrturax8v7iu?cid=368
https://piazza.com/class/isyrturax8v7iu?cid=545
https://piazza.com/class/isyrturax8v7iu?cid=534
There seems to be some conflicting informtion. For this question, will assume last 10 completed years as being January 1, 2006 - January 1, 2016
*/


-- All bookings made for each traveler
CREATE VIEW TotalBookings AS
SELECT travelerId, date_part('year', startdate) AS year, count(*) AS numBooking
FROM booking
-- WHERE startdate >= (current_date - interval '1 year' * 10)
WHERE startdate >= '2006-01-01' AND startdate < '2016-01-01' 
GROUP BY travelerId, date_part('year', startdate);

-- All Requests made for each traveler
CREATE VIEW TotalRequests AS 
SELECT travelerId, date_part('year', startdate) AS year, count(*) AS numRequests
FROM BookingRequest
-- WHERE startdate >= (current_date - interval '1 year' * 10)
WHERE startdate >= '2006-01-01' AND startdate < '2016-01-01' 
GROUP BY travelerId, date_part('year', startdate);

-- Combine Traveler list with total requests
CREATE VIEW STEP1 AS
	SELECT Traveler.travelerId, Traveler.email, TotalRequests.year, coalesce(TotalRequests.numRequests, 0) as numRequests
	FROM Traveler LEFT JOIN TotalRequests ON Traveler.travelerId = TotalRequests.travelerId;

-- Combine Traveler list with total requests and total bookings
SELECT STEP1.travelerId, STEP1.email, STEP1.year, STEP1.numRequests, coalesce(TotalBookings.numBooking, 0) as numBooking
FROM STEP1 LEFT JOIN TotalBookings ON STEP1.travelerId = TotalBookings.travelerId
ORDER BY STEP1.year DESC;