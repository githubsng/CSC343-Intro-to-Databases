SET search_path TO bnb, public;

-- Clear Views
DROP VIEW IF EXISTS Goodbargainers CASCADE;
DROP VIEW IF EXISTS Savers CASCADE;
DROP VIEW IF EXISTS AvgListingRates CASCADE; 

-- Average per night of each listing i.e. average(per night rate)
CREATE VIEW AvgListingRates AS
SELECT Listing.listingID, AVG(CAST(booking.price AS FLOAT)/CAST(booking.numnights AS FLOAT)) as avgPrice
FROM Listing, Booking
WHERE Listing.listingID = Booking.listingID
GROUP BY Listing.listingID;


-- Travelers who have paid more than 25% less than the average per night cost for all listings
CREATE VIEW Savers AS
SELECT Booking.travelerID, Booking.listingID, 
	ROUND((CAST(AvgListingRates.avgPrice AS FLOAT) -
 		CAST(Booking.price/Booking.numNights AS FLOAT)) / 
 		CAST(AvgListingRates.avgPrice AS FLOAT) * 100) AS bargainPercentage
FROM Booking, AvgListingRates
WHERE
	Booking.listingID = AvgListingRates.listingID AND 
	(CAST(AvgListingRates.avgPrice AS FLOAT) - CAST(Booking.price/Booking.numNights AS FLOAT)) 
	/ CAST(AvgListingRates.avgPrice AS FLOAT) >= 0.25;


-- Bargainers who have saved at least 3 times
CREATE VIEW Goodbargainers AS
SELECT Savers.travelerID, MAX(Savers.bargainPercentage) AS largestBargainPercentage
FROM Savers
GROUP BY Savers.travelerID
HAVING COUNT(Savers.travelerID) >= 3;


-- 'Good Bargainers' with their largest bargain percentage and respective listing
SELECT Goodbargainers.travelerID, CAST(Goodbargainers.largestBargainPercentage AS INT), Savers.listingID
FROM Goodbargainers, Savers
WHERE Goodbargainers.travelerID = Savers.travelerID
AND Goodbargainers.largestBargainPercentage = Savers.bargainPercentage
ORDER BY Goodbargainers.largestBargainPercentage DESC, Goodbargainers.travelerID ASC;