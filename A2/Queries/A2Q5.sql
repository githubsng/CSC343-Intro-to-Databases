SET search_path TO bnb, public;


-- Clear Views
DROP VIEW IF EXISTS rating1 CASCADE;
DROP VIEW IF EXISTS rating2 CASCADE;
DROP VIEW IF EXISTS rating3 CASCADE;
DROP VIEW IF EXISTS rating4 CASCADE;
DROP VIEW IF EXISTS rating5 CASCADE;
DROP VIEW IF EXISTS Glue CASCADE; 


/* CORRECTION: https://piazza.com/class/isyrturax8v7iu?cid=362
Q5, Q8:  Clarification on HomeownerRating and TravelerRating: The HomeownerRating contains the ratings 
the homeowner makes (of a traveler) and the TravelerRating contains the ratings a traveler makes (of the homeowner). 
*/

-- List of all homeowners and their bnb ratings
CREATE VIEW Glue AS
-- SELECT Listing.owner, HomeownerRating.rating
-- FROM Listing, HomeownerRating
-- WHERE Listing.listingID = HomeownerRating.listingID;
SELECT Listing.owner, TravelerRating.rating
FROM Listing, TravelerRating
WHERE Listing.listingID = TravelerRating.listingID;

-- Count of 5 star homeowner ratings
CREATE VIEW rating5 AS
SELECT Glue.owner, COUNT(*) as r5
FROM Glue
WHERE Glue.rating = 5
GROUP BY Glue.owner;

-- Count of 4 star homeowner ratings
CREATE VIEW rating4 AS
SELECT Glue.owner, COUNT(*) as r4
FROM Glue
WHERE Glue.rating = 4
GROUP BY Glue.owner;

-- Count of 3 star homeowner ratings
CREATE VIEW rating3 AS
SELECT Glue.owner, COUNT(*) as r3
FROM Glue
WHERE Glue.rating = 3
GROUP BY Glue.owner;

-- Count of 2 star homeowner ratings
CREATE VIEW rating2 AS
SELECT Glue.owner, COUNT(*) as r2
FROM Glue
WHERE Glue.rating = 2
GROUP BY Glue.owner;

-- Count of 1 star homeowner ratings
CREATE VIEW rating1 AS
SELECT Glue.owner, COUNT(*) as r1
FROM Glue
WHERE Glue.rating = 1
GROUP BY Glue.owner;

-- Join all counted ratings with HomeownerIDs
SELECT Homeowner.HomeownerId, rating5.r5, rating4.r4, rating3.r3, rating2.r2, rating1.r1
FROM Homeowner 
LEFT JOIN rating5 
ON Homeowner.HomeownerID = rating5.owner
LEFT JOIN rating4
ON Homeowner.HomeownerID = rating4.owner
LEFT JOIN rating3
ON Homeowner.HomeownerID = rating3.owner
LEFT JOIN rating2
ON Homeowner.HomeownerID = rating2.owner
LEFT JOIN rating1
ON Homeowner.HomeownerID = rating1.owner
ORDER BY rating5.r5 DESC, rating4.r4 DESC, rating3.r3 DESC, rating2.r2 DESC, rating1.r1 DESC, Homeowner.HomeownerId ASC;