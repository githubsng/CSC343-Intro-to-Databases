create view q3(homeowner,listingID,year,city) as
values (4000, 3000,2016,'c1'), (4001,3001,2016,'c2');
 
CREATE TABLE oracle_q3 AS 
select * from q3;
