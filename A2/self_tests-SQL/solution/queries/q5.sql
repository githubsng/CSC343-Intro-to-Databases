create view q5(homeownerID , r5, r4, r3,r2,r1) as values
(4001,NULL,NULL,1,NULL,NULL), (4003,2,NULL,NULL,NULL,NULL), (4000,1,2,NULL,NULL,NULL);

CREATE TABLE oracle_q5 AS 
select * from q5;
