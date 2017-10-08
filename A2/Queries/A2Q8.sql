SET search_path TO bnb, public;

-- Clear views
DROP VIEW IF EXISTS ScratchingBacks1 CASCADE;
DROP VIEW IF EXISTS ScratchingBacks2 CASCADE;

-- Count of reciprocals
CREATE VIEW ScratchingBacks1 AS 
SELECT Traveler.travelerID, count(Traveler.travelerID) AS reciprocals
FROM Traveler, Booking, TravelerRating, HomeownerRating 
WHERE Traveler.travelerID = Booking.travelerID
AND Booking.listingID = HomeownerRating.listingID
AND Booking.startDate = HomeownerRating.startDate
AND Booking.listingID = TravelerRating.listingID
AND Booking.startDate = TravelerRating.startDate
AND HomeownerRating.listingID = TravelerRating.listingID
AND HomeownerRating.startDate = TravelerRating.startDate
GROUP BY Traveler.travelerID;

-- Count of reciprocals that differ by one point or less
CREATE VIEW ScratchingBacks2 AS 
SELECT Traveler.travelerID, count(Traveler.travelerID) AS backScratches
FROM Traveler, Booking, TravelerRating, HomeownerRating
WHERE Traveler.travelerID = Booking.travelerID
AND Booking.listingID = HomeownerRating.listingID
AND Booking.startDate = HomeownerRating.startDate
AND Booking.listingID = TravelerRating.listingID
AND Booking.startDate = TravelerRating.startDate
AND HomeownerRating.listingID = TravelerRating.listingID
AND HomeownerRating.startDate = TravelerRating.startDate
AND ABS(HomeownerRating.rating - TravelerRating.rating) <= 1
GROUP BY Traveler.travelerID;

-- Combine TravelerID with reciprocals and recriprocals that differ by one point or less
SELECT 
	Traveler.travelerID, 
	COALESCE(ScratchingBacks1.reciprocals, 0) AS reciprocals, 
	COALESCE(ScratchingBacks2.backScratches, 0) AS backScratches
FROM Traveler 
	LEFT JOIN ScratchingBacks1 ON Traveler.travelerID = ScratchingBacks1.travelerID
	LEFT JOIN ScratchingBacks2 ON Traveler.travelerID = ScratchingBacks2.travelerID
ORDER BY reciprocals DESC, backScratches DESC;