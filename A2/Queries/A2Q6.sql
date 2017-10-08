SET search_path TO bnb, public;

-- Clear Views
DROP VIEW IF EXISTS CommittedTravelers;
DROP VIEW IF EXISTS BookingCounts CASCADE;
DROP VIEW IF EXISTS NoOverlap CASCADE;
DROP VIEW IF EXISTS Overlap CASCADE;  

-- All travelers and listingIDs from bookingrequests that do overlap with bookings
CREATE VIEW Overlap AS
SELECT DISTINCT BookingRequest.travelerID, BookingRequest.listingID
FROM BookingRequest
WHERE (BookingRequest.travelerID, BookingRequest.listingID) IN (
	SELECT DISTINCT Booking.travelerID, Booking.listingID
	FROM Booking
);

-- All travelers and listingIDs from bookingrequests that do not overlap with bookings
CREATE VIEW NoOverlap AS
SELECT DISTINCT BookingRequest.travelerID, BookingRequest.listingID
FROM BookingRequest
WHERE (BookingRequest.travelerID, BookingRequest.listingID) NOT IN (
	SELECT DISTINCT Booking.travelerID, Booking.listingID
	FROM Booking
);

-- Total listings booked
CREATE VIEW BookingCounts AS
SELECT Overlap.travelerID, count(*) AS numListings
FROM Overlap
GROUP BY Overlap.travelerID;

-- Overlap MINUS NoOverlap
CREATE VIEW CommittedTravelers AS
(SELECT DISTINCT travelerID FROM Overlap) 
EXCEPT ALL 
(SELECT DISTINCT travelerID FROM Nooverlap);

-- Committed travelers, their surname and number of bookings
SELECT CommittedTravelers.TravelerID, Traveler.surname, BookingCounts.numListings
FROM Traveler, CommittedTravelers, BookingCounts
WHERE Traveler.travelerID = CommittedTravelers.travelerID
AND CommittedTravelers.travelerID = BookingCounts.travelerID
ORDER BY CommittedTravelers.TravelerID ASC;