SET search_path TO bnb, public;


-- Clear views
DROP VIEW IF EXISTS Solution CASCADE;
DROP VIEW IF EXISTS NullViolators CASCADE;
DROP VIEW IF EXISTS MaxViolators CASCADE;
DROP VIEW IF EXISTS MinViolators CASCADE;
DROP VIEW IF EXISTS BookingDayGroups CASCADE;
DROP VIEW IF EXISTS BookingDaySeries CASCADE;
DROP VIEW IF EXISTS ValidBookings CASCADE;
DROP VIEW IF EXISTS InvalidOverlaps CASCADE;
DROP VIEW IF EXISTS StartEndDatesByBookings CASCADE; 


-- All Bookings and their start and end dates
CREATE VIEW StartEndDatesByBookings AS
SELECT
	Booking.listingID,
	Booking.travelerID, 
	Booking.startdate, 
	Booking.startdate + interval '1 day' * Booking.numNights as enddate,
	Booking.numNights
FROM
	Booking;

-- Bookings that have overlapping listingIDs and dates
-- NOTE: Booking Primary Key is (listingID, startdate)
CREATE VIEW InvalidOverlaps AS
SELECT Inv1.listingID, Inv1.travelerID, Inv1.startdate, Inv1.enddate, Inv1.numNights
FROM StartEndDatesByBookings AS Inv1
JOIN StartEndDatesByBookings AS Inv2
ON Inv1.listingID = Inv2.listingID AND Inv1.startdate <> Inv2.startdate
WHERE (Inv1.startdate > Inv2.startdate and Inv1.startdate < Inv2.enddate) OR
	  (Inv1.enddate > Inv2.startdate and Inv1.enddate < Inv2.enddate);


-- All valid, non-overlapping bookings
CREATE VIEW ValidBookings AS
(SELECT * FROM StartEndDatesByBookings)
EXCEPT
(SELECT * FROM InvalidOverlaps);


-- A generated series of valid booked days by listing
CREATE VIEW BookingDaySeries AS
SELECT 
	listingID,
	generate_series(startDate,endDate,'1 day') AS daySeries
FROM ValidBookings;


-- All valid booked days grouped by listing and year
CREATE VIEW BookingDayGroups AS
SELECT 
    listingID,
    date_part('year', daySeries) AS year,
    count(daySeries) AS numDaysPerYear
FROM BookingDaySeries
GROUP BY 
	listingID, 
	date_part('year', daySeries);


-- Owners who have violated the min days of a bylaw
CREATE VIEW MinViolators AS
SELECT
	BookingDayGroups.listingID,
	BookingDayGroups.year,
	BookingDayGroups.numDaysPerYear,
	Listing.owner,
	Listing.propertyType,
	Listing.city,
	CityRegulation.regulationType,
	CityRegulation.days
FROM
	BookingDayGroups, Listing, CityRegulation
WHERE
	BookingDayGroups.listingID = Listing.ListingID AND 
	CityRegulation.city = Listing.city AND 
	CityRegulation.propertyType = Listing.propertyType AND
	CityRegulation.regulationType = 'min' AND
	BookingDayGroups.numDaysPerYear < CityRegulation.days;

-- Owners that have violated the max days of a bylaw
CREATE VIEW MaxViolators AS
SELECT
	BookingDayGroups.listingID,
	BookingDayGroups.year,
	BookingDayGroups.numDaysPerYear,
	Listing.owner,
	Listing.propertyType,
	Listing.city,
	CityRegulation.regulationType,
	CityRegulation.days
FROM
	BookingDayGroups, Listing, CityRegulation
WHERE
	BookingDayGroups.listingID = Listing.ListingID AND 
	CityRegulation.city = Listing.city AND 
	CityRegulation.propertyType = Listing.propertyType AND
	CityRegulation.regulationType = 'max' AND
	BookingDayGroups.numDaysPerYear > CityRegulation.days;

-- If Listing.propertyType is NULL, all bylaws apply to this listing (both max and min)
CREATE VIEW NullViolators AS
SELECT
	BookingDayGroups.listingID,
	BookingDayGroups.year,
	BookingDayGroups.numDaysPerYear,
	Listing.owner,
	Listing.propertyType,
	Listing.city,
	CityRegulation.regulationType,
	CityRegulation.days
FROM
	BookingDayGroups JOIN Listing ON BookingDayGroups.listingID = Listing.ListingID
	JOIN CityRegulation ON Listing.city = CityRegulation.city AND
	(CityRegulation.regulationType = 'max' AND BookingDayGroups.numDaysPerYear > CityRegulation.days) OR
	(CityRegulation.regulationType = 'min' AND BookingDayGroups.numDaysPerYear < CityRegulation.days)
WHERE 
	Listing.propertyType IS NULL;	


--Add all the violators together
CREATE VIEW Solution AS 
(SELECT
	listingID,
	year,
	owner,
	city
FROM MinViolators)
UNION
(SELECT
	listingID,
	year,
	owner,
	city
FROM MaxViolators)
UNION
(SELECT
	listingID,
	year,
	owner,
	city
FROM NullViolators);

-- Solution
SELECT DISTINCT 
	owner as homeowner,
	listingID,
	CAST(year AS INT),
	city
FROM Solution
ORDER BY owner, listingID, year, city;