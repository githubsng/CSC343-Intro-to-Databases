SET search_path TO bnb, public;


-- Clear views
DROP VIEW IF EXISTS NumRatedInLastTen CASCADE;
DROP VIEW IF EXISTS NumImproving CASCADE;
DROP VIEW IF EXISTS AlwaysImproving CASCADE;
DROP VIEW IF EXISTS NonDecreasing CASCADE;
DROP VIEW IF EXISTS RatedInLastTen CASCADE;


/* https://piazza.com/class/isyrturax8v7iu?cid=362
Clarification on HomeownerRating and TravelerRating: The HomeownerRating contains the ratings 
the homeowner makes (of a traveler) and the TravelerRating contains the ratings a traveler makes (of the homeowner). 
*/

-- All Homeowners rated in the last 10 years (aka contributors)
CREATE VIEW RatedInLastTen AS
SELECT 
	Listing.owner, 
	sum(TravelerRating.rating) AS summedRatings, 
	count(TravelerRating.rating) AS totalNumRatings,
	CAST(sum(TravelerRating.rating) AS FLOAT) / CAST(count(TravelerRating.rating) AS FLOAT) AS annualAvgRating,
	date_part('year', TravelerRating.startDate) AS byYear
FROM TravelerRating, Listing
WHERE 
	TravelerRating.listingID = Listing.listingID AND
	TravelerRating.startDate >= (current_date - interval '1 year' * 10)
GROUP BY 
	Listing.owner, date_part('year', TravelerRating.startDate)
ORDER BY
	Listing.owner, date_part('year', TravelerRating.startDate);


CREATE VIEW NonDecreasing AS
SELECT DISTINCT R1.owner
FROM RatedInLastTen AS R1, RatedInLastTen AS R2
WHERE
	R1.owner = R2.owner AND
	R1.byYear < R2.byYear AND
	R1.annualAvgRating > R2.annualAvgRating;


-- Homeowners that never decreased in ratings over a 10 year period
CREATE VIEW AlwaysImproving AS
(SELECT DISTINCT owner FROM RatedInLastTen)  
EXCEPT ALL
(SELECT DISTINCT owner FROM NonDecreasing);


-- Number of homeowners that never decreased in rating
CREATE VIEW NumImproving AS
SELECT Count(*) FROM AlwaysImproving;


-- Total Number of homeowners rated in the last 10 years
CREATE VIEW NumRatedInLastTen AS
SELECT COUNT (DISTINCT owner) FROM RatedInLastTen; 


-- Solution
SELECT
	CAST(CAST(NumImproving.count AS FLOAT) / CAST(NumRatedInLastTen.count AS FLOAT)*100 AS INT) AS percentage
FROM 
	NumRatedInLastTen, NumImproving;