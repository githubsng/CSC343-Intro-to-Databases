-- solution is booking added to database
DO $$
BEGIN
	IF current_schema = 'datab' THEN
		CREATE TABLE oracle_booking (
			   listingId integer,
			   startdate date NOT NULL,
			   travelerID integer,
			   numNights integer NOT NULL default 1,
			   numGuests integer NOT NULL default 1,
			   price integer NOT NULL,
			   PRIMARY KEY (listingId, startdate)
		);
		INSERT INTO oracle_booking VALUES (3000, '2016-10-05', 1000, 2, 1, 120);
	END IF;
END$$;
