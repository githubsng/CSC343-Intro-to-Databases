TRUNCATE TABLE Traveler CASCADE;
TRUNCATE TABLE Homeowner CASCADE;
TRUNCATE TABLE Listing CASCADE;
TRUNCATE TABLE BookingRequest CASCADE;
TRUNCATE TABLE Booking CASCADE;
TRUNCATE TABLE HomeownerRating CASCADE;
TRUNCATE TABLE CityRegulation CASCADE;
TRUNCATE TABLE TravelerRating CASCADE;

INSERT INTO Traveler VALUES (1000, 'n1', 'f1', 'fn1@domain.com');
INSERT INTO Traveler VALUES (1001, 'n2', 'f2', 'fn2@domain.com');
INSERT INTO Traveler VALUES (1002, 'n3', 'f3', 'fn3@domain.com');

INSERT INTO Homeowner VALUES (4000, 'hn1', 'hf1', 'hfn1@domain.com');
INSERT INTO Homeowner VALUES (4001, 'hn2', 'hf2', 'hfn2@domain.com');
INSERT INTO Homeowner VALUES (4003, 'hn3', 'hf3', 'hfn3@domain.com');

INSERT INTO Listing VALUES (3000, 'condo', 2, 4, 'gym', 'c1', 4000);
INSERT INTO Listing VALUES (3001, 'house', 2, 4, 'gym', 'c2', 4001);
INSERT INTO Listing VALUES (3002, 'house', 2, 4, 'gym', 'c2', 4003);

INSERT INTO BookingRequest VALUES (6003, 1000, 3000, '2015-10-05', 1, 1, 175);
INSERT INTO BookingRequest VALUES (6000, 1001, 3000, '2016-10-16', 1, 1, 25);

INSERT INTO Booking VALUES (3000, '2015-10-05', 1000, 1, 1, 175);
INSERT INTO Booking VALUES (3000, '2016-10-16', 1001, 1, 1, 25);

INSERT INTO TravelerRating VALUES (3000, '2016-10-16', 4, 'cmt1');
INSERT INTO HomeownerRating VALUES (3000, '2016-10-16', 4, 'cmt1');

INSERT INTO CityRegulation VALUES ('c1', 'condo', 'min', 30);
INSERT INTO CityRegulation VALUES ('c2', 'house', 'max', 90);
