-- JDBC booking() Test Case #2: 
--     Description: request exists
--                  trivial, booking can be made
--     Input: requestID=6000, start='2016-10-05', numNights=2, price=100
--     Output: true
--             SELECT * FROM Booking WHERE listingID=3000 AND startDate='2016-10-05';
--                 => (3000, '2016-10-05', 1000, 2, 1, 100)

TRUNCATE TABLE Traveler CASCADE;
TRUNCATE TABLE Homeowner CASCADE;
TRUNCATE TABLE Listing CASCADE;
TRUNCATE TABLE BookingRequest CASCADE;
TRUNCATE TABLE Booking CASCADE;
TRUNCATE TABLE HomeownerRating CASCADE;
TRUNCATE TABLE CityRegulation CASCADE;
TRUNCATE TABLE TravelerRating CASCADE;

INSERT INTO Traveler VALUES (1000, 'n1', 'f1', 'fn1@domain.com');
INSERT INTO Homeowner VALUES (4000, 'hn1', 'hf1', 'hfn1@domain.com');
INSERT INTO Listing VALUES (3000, 'condo', 2, 4, 'gym', 'c1', 4000);
INSERT INTO BookingRequest VALUES (6000, 1000, 3000, '2016-10-05', 2, 1, 120);
