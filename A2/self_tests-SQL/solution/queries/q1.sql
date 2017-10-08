create view q1(travelerId,email,year,numRequests,numBooking) as 
values 
(1002,'fn3@domain.com',NULL,0,0),
(1003,'fn4@domain.com',NULL,0,0),
(1000,'fn1@domain.com',2015,2,1), 
(1001,'fn2@domain.com',2015,1,1);

CREATE TABLE oracle_q1 AS 
select * from q1;