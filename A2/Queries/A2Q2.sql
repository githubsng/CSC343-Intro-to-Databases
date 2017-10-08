SET search_path TO bnb, public;

-- Clear Views
DROP VIEW IF EXISTS Answer;
DROP VIEW IF EXISTS GrabCorrectTie CASCADE;
DROP VIEW IF EXISTS MostRequestedCity CASCADE;
DROP VIEW IF EXISTS GetScrapers CASCADE;
DROP VIEW IF EXISTS RequestsNotInBooking CASCADE;
DROP VIEW IF EXISTS TotalRequests CASCADE;
DROP VIEW IF EXISTS TotalTravelers CASCADE;


--get all travelers to calculate average
 CREATE VIEW TotalTravelers AS
 select  
 	count(travelerId) as num
 from 
 	Traveler;
 
 --get all booking requests to calculate average
CREATE VIEW TotalRequests AS
select  
	count(requestID) as num
from 
	BookingRequest;

--get number of booking requests that are not in booking
CREATE VIEW RequestsNotInBooking AS
SELECT 
	travelerId,
	listingId, 
	count(distinct requestID) as numRequests
FROM 
	BookingRequest
WHERE 
	travelerId  NOT IN(
	SELECT travelerID
	FROM Booking)
group by 
		travelerId, 
		listingId;


--get all travelers who has ten times the average booking requests that has never booked anything
CREATE VIEW GetScrapers AS
SELECT 
	RequestsNotInBooking.travelerId,
	RequestsNotInBooking.numRequests,
	RequestsNotInBooking.listingId
FROM RequestsNotInBooking, 
	BookingRequest,
	TotalRequests,
	TotalTravelers
GROUP BY 
	RequestsNotInBooking.numRequests,
	RequestsNotInBooking.travelerId,
	TotalRequests.num,
	TotalTravelers.num,
	RequestsNotInBooking.listingId
HAVING 
	RequestsNotInBooking.numRequests > TotalRequests.num/TotalTravelers.num::numeric * 10;

--get most requested city
CREATE VIEW MostRequestedCity AS
SELECT 
	travelerId,
	max(numRequests) as numRequests
FROM GetScrapers
GROUP BY travelerId;

--get max cities alphabetically if there is a tie
CREATE VIEW GrabCorrectTie AS
SELECT 
	MostRequestedCity.travelerId, 
	MostRequestedCity.numRequests, 
	min(Listing.city) as mostRequestedCity
FROM 
	MostRequestedCity,
	GetScrapers,
	Listing
WHERE 
	MostRequestedCity.travelerID = GetScrapers.travelerID  
	and 
	GetScrapers.listingId = Listing.listingId
GROUP BY 
	MostRequestedCity.travelerId,MostRequestedCity.numRequests;


--get personal details of the traveler with most requested city that comes alphabetically first, 
--in the order that was dictated on the handout
CREATE VIEW Answer AS
SELECT distinct 
	Traveler.travelerId,
	Traveler.firstname || ' ' || Traveler.surname as name, 
	coalesce(Traveler.email,'unknown') as email,
	GrabCorrectTie.mostRequestedCity,
	GrabCorrectTie.numRequests
FROM 
	GrabCorrectTie,
	Traveler, 
	Listing,
	GetScrapers
WHERE 
	GrabCorrectTie.travelerId = Traveler.travelerId 
	and 
	GetScrapers.numRequests = GrabCorrectTie.numRequests 
ORDER BY 
	GrabCorrectTie.numRequests DESC, 
	Traveler.travelerId ASC;

SELECT * FROM Answer;