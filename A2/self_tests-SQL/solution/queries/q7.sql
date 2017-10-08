create view q7(travelerID,largestBargainPercentage,listingID) as 
values (1001, 75, 3000), (1001, 75, 3001), (1001, 75, 3002);

CREATE TABLE oracle_q7 AS 
select * from q7;