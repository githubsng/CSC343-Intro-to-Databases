-- JDBC homeownerRating() Test Case #1: 
--     Description: 11 homeowners, <=2 reviews per homeowner
--                  trivial
--     Input: homeownerID=4000
--     Output: [4005, 4006, 4007, 4001, 4004, 4008, 4010, 4003, 4009]

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

INSERT INTO Homeowner VALUES (4000, 'hn1', 'hf1', 'hfn1@domain.com');
INSERT INTO Homeowner VALUES (4001, 'hn2', 'hf2', 'hfn2@domain.com');
INSERT INTO Homeowner VALUES (4002, 'hn3', 'hf3', 'hfn3@domain.com');
INSERT INTO Homeowner VALUES (4003, 'hn4', 'hf4', 'hfn4@domain.com');
INSERT INTO Homeowner VALUES (4004, 'hn5', 'hf5', 'hfn5@domain.com');
INSERT INTO Homeowner VALUES (4005, 'hn6', 'hf6', 'hfn6@domain.com');
INSERT INTO Homeowner VALUES (4006, 'hn7', 'hf7', 'hfn7@domain.com');
INSERT INTO Homeowner VALUES (4007, 'hn8', 'hf8', 'hfn8@domain.com');
INSERT INTO Homeowner VALUES (4008, 'hn9', 'hf9', 'hfn9@domain.com');
INSERT INTO Homeowner VALUES (4009, 'hn10', 'hf10', 'hfn10@domain.com');
INSERT INTO Homeowner VALUES (4010, 'hn11', 'hf11', 'hfn11@domain.com');

INSERT INTO Listing VALUES (3000, 'condo', 2, 4, 'gym', 'c1', 4000);
INSERT INTO Listing VALUES (3001, 'house', 2, 4, 'gym', 'c2', 4001);
INSERT INTO Listing VALUES (3002, 'condo', 2, 4, 'gym', 'c1', 4002);
INSERT INTO Listing VALUES (3003, 'house', 2, 4, 'gym', 'c2', 4003);
INSERT INTO Listing VALUES (3004, 'condo', 2, 4, 'gym', 'c1', 4004);
INSERT INTO Listing VALUES (3005, 'house', 2, 4, 'gym', 'c2', 4005);
INSERT INTO Listing VALUES (3006, 'condo', 2, 4, 'gym', 'c1', 4006);
INSERT INTO Listing VALUES (3007, 'house', 2, 4, 'gym', 'c2', 4007);
INSERT INTO Listing VALUES (3008, 'condo', 2, 4, 'gym', 'c1', 4008);
INSERT INTO Listing VALUES (3009, 'house', 2, 4, 'gym', 'c2', 4009);
INSERT INTO Listing VALUES (3010, 'condo', 2, 4, 'gym', 'c1', 4010);

INSERT INTO Booking VALUES (3000, '2016-10-05', 1000, 2, 1, 90);
INSERT INTO Booking VALUES (3000, '2016-01-05', 1001, 2, 1, 90);

INSERT INTO Booking VALUES (3001, '2016-01-05', 1001, 5, 1, 120);
INSERT INTO Booking VALUES (3001, '2016-10-05', 1000, 5, 1, 120);

INSERT INTO Booking VALUES (3002, '2016-10-05', 1000, 2, 1, 90);
INSERT INTO Booking VALUES (3002, '2016-01-05', 1001, 2, 1, 90);

INSERT INTO Booking VALUES (3003, '2016-01-05', 1001, 5, 1, 120);
INSERT INTO Booking VALUES (3003, '2016-10-05', 1000, 5, 1, 120);

INSERT INTO Booking VALUES (3004, '2016-10-05', 1000, 2, 1, 90);
INSERT INTO Booking VALUES (3004, '2016-01-05', 1001, 2, 1, 90);

INSERT INTO Booking VALUES (3005, '2016-01-05', 1001, 5, 1, 120);
INSERT INTO Booking VALUES (3005, '2016-10-05', 1000, 5, 1, 120);

INSERT INTO Booking VALUES (3006, '2016-10-05', 1000, 2, 1, 90);
INSERT INTO Booking VALUES (3006, '2016-01-05', 1001, 2, 1, 90);

INSERT INTO Booking VALUES (3007, '2016-01-05', 1001, 5, 1, 120);
INSERT INTO Booking VALUES (3007, '2016-10-05', 1000, 5, 1, 120);

INSERT INTO Booking VALUES (3008, '2016-10-05', 1000, 2, 1, 90);
INSERT INTO Booking VALUES (3008, '2016-01-05', 1001, 2, 1, 90);

INSERT INTO Booking VALUES (3009, '2016-01-05', 1001, 5, 1, 120);
INSERT INTO Booking VALUES (3009, '2016-10-05', 1000, 5, 1, 120);

INSERT INTO Booking VALUES (3010, '2016-10-05', 1000, 2, 1, 90);
INSERT INTO Booking VALUES (3010, '2016-01-05', 1001, 2, 1, 90);








--INSERT INTO TravelerRating VALUES (3000, '2016-10-05', 0, 'cmt');
INSERT INTO TravelerRating VALUES (3000, '2016-01-05', 3, 'cmt');					--1

INSERT INTO TravelerRating VALUES (3001, '2016-10-05', 2, 'cmt');					--2
INSERT INTO TravelerRating VALUES (3001, '2016-01-05', 4, 'cmt');					--3

-- no ratings for homeowner 3002, equivalent to having ratings of 0
--INSERT INTO TravelerRating VALUES (3002, '2016-10-05', 0, 'cmt');
--INSERT INTO TravelerRating VALUES (3002, '2016-01-05', 0, 'cmt');

--INSERT INTO TravelerRating VALUES (3003, '2016-10-05', 0, 'cmt');
INSERT INTO TravelerRating VALUES (3003, '2016-01-05', 1, 'cmt');					--4

INSERT INTO TravelerRating VALUES (3004, '2016-10-05', 2, 'cmt');					--5
INSERT INTO TravelerRating VALUES (3004, '2016-01-05', 3, 'cmt');					--6

INSERT INTO TravelerRating VALUES (3005, '2016-10-05', 4, 'cmt');					--7
INSERT INTO TravelerRating VALUES (3005, '2016-01-05', 5, 'cmt');					--8

--INSERT INTO TravelerRating VALUES (3006, '2016-10-05', 0, 'cmt');
INSERT INTO TravelerRating VALUES (3006, '2016-01-05', 5, 'cmt');					--9

INSERT INTO TravelerRating VALUES (3007, '2016-10-05', 5, 'cmt');					--10
INSERT INTO TravelerRating VALUES (3007, '2016-01-05', 5, 'cmt');					--11

INSERT INTO TravelerRating VALUES (3008, '2016-10-05', 4, 'cmt');					--12
INSERT INTO TravelerRating VALUES (3008, '2016-01-05', 3, 'cmt');					--13

--INSERT INTO TravelerRating VALUES (3009, '2016-10-05', 0, 'cmt');
INSERT INTO TravelerRating VALUES (3009, '2016-01-05', 1, 'cmt');					--14

INSERT INTO TravelerRating VALUES (3010, '2016-10-05', 4, 'cmt');					--15
INSERT INTO TravelerRating VALUES (3010, '2016-01-05', 3, 'cmt');					--16
