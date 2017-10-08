DROP SCHEMA IF EXISTS bnb cascade;
CREATE SCHEMA bnb;
SET search_path TO bnb, public;

-- A person who is registered as a traveler who uses the company's rental services.
-- We store their last (surname), first name and email
CREATE TABLE Traveler (
  travelerId integer PRIMARY KEY,
  surname varchar(25) NOT NULL,
  firstname varchar(15) NOT NULL,
  email varchar(30)
) ;

-- A homeowner rents her properties.  We store last (surname), first name and email.
-- A homeowner can have many properties.
CREATE TABLE Homeowner (
  homeownerId integer PRIMARY KEY,
  surname varchar(25) NOT NULL,
  firstname varchar(15) NOT NULL,
  email varchar(30)
) ;

CREATE DOMAIN propertyType varchar(9)
       check (value in ('trailer', 'apartment', 'condo', 'house'));

-- A listing is a specific property that is listed on bnb.
-- The listing must be one of the valid property types and includes
-- the number of rooms in the property and the maximum number of people who
-- can sleep at the property.
-- amenities is a string that describes other amenities (like parking or laundry).
-- city is the city in which the property resides.
-- owner is the property owner, who must be a registered homeowner with bnb.
CREATE TABLE Listing (
   listingId integer PRIMARY KEY,
   propertyType propertyType,
   rooms integer,
   sleeps integer,	 
   amenities varchar(100),
   city varchar(30) NOT NULL,
   owner integer REFERENCES homeowner
) ;

CREATE DOMAIN regulationType varchar(3)
       not null
       check (value = 'max' or value = 'min');

-- Different cities have different regulations imposed on short term rentals like bnb.
-- The regulationType indicates whether the regulation limits the maximum number of days (max)
-- or minimum number of days (min) over which a property can be rented.
-- days indicates the maximum (or minimum) number of days.
-- A city may have many regulations on different types of properties and may have
-- both a max and min limit on the same property type.
CREATE TABLE CityRegulation (
       city  varchar(30), 
       propertyType propertyType,
       regulationType regulationType,
       days integer,
       PRIMARY KEY (city, propertyType, regulationType)    
       );

-- A booking request has a unique identifier and is made by a single traveler
-- for a specific listing.  There must be a start date for the request and number of nights.
-- The numGuests attribute indicates the requested number of guests, and
-- the offerPrice attribute indicates the price the traveler is offering for the entire
-- stay (this is not the per night price but rather the price for the entire stay).

-- NOTE TO SELF, no BookingRequest can have the same 1) Traveler 2) ListingID and 3) Start date for the booking.
CREATE TABLE BookingRequest (
	requestId integer PRIMARY KEY,
	travelerId integer REFERENCES traveler,
	listingId integer REFERENCES listing,
	startdate date NOT NULL,  
	numNights integer NOT NULL default 1, 
	numGuests integer NOT NULL default 1,
	offerPrice integer,
	UNIQUE (travelerId, listingId, startdate)
	);

-- After negotiation between the traveler and homeowner, if they come to agreement,
-- a booking is made in the system.
-- A booking is a stay that has been paid for.
-- It is identified by a listingID and startdate.
CREATE TABLE Booking (
       listingId integer REFERENCES listing,
       startdate date NOT NULL,
       travelerID integer REFERENCES traveler,
       numNights integer NOT NULL default 1,
       numGuests integer NOT NULL default 1,
       price integer NOT NULL,
       PRIMARY KEY (listingId, startdate)
) ;
	
-- The possible values of a rating are between one and five stars.
CREATE DOMAIN stars AS smallint 
   DEFAULT NULL
   CHECK (VALUE >= 1 AND VALUE <= 5);

-- For a given booking, a homeowner may (at her discretion)
-- rate the a traveler who made the booking.

--NOTE TO SELF: only one rating allowed, identified by listingID and startDate
--FOREIGN KEY...
CREATE TABLE HomeownerRating (
   listingID integer NOT NULL,
   startDate date NOT NULL,
   rating stars NOT NULL,
   comment varchar(200),
   PRIMARY KEY (listingId, startDate),
   FOREIGN KEY (listingId, startDate) REFERENCES Booking
) ;

-- For a given booking, a traveler may (at her discretion)
-- rate the homeowner who owns the listing.
CREATE TABLE TravelerRating (
   listingID integer NOT NULL,
   startDate date NOT NULL,
   rating stars NOT NULL,
   comment varchar(200),
   PRIMARY KEY (listingId, startDate),
   FOREIGN KEY (listingId, startDate) REFERENCES Booking
) ;

