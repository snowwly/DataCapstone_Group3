use Bionic_blobs
select count(*) as zillowhousebb from ZillowNYC_Housing_Counts_BB
select count(*) as zillowhouse from Zillow_Home_Listings

select * from NYCBoroughs_BB
select count(*) as boroughs from  NYCBoroughs_BB

select * from locations_bb

select count(*) as attractionsbb from Attractions_BB
select count(*) as attractions from AttractionsDistinct

select count(*) as hotelsbb from Hotels_BB
select count(*) as hotels from Hotels

select count(*) from Zillow_Rental_Homes_BB
select count(*) from Zillow_RentalHome_Prices

select count(*) from Crime_Types_BB


select count(*) as nyccrimebb from NYC_Crimes_BB

select count(*) as hostsbb from Hosts_BB
select count(*) as hosts from host2

select count(*)  as listingbb from listings_BB
select count(*) as listing from listings

select count(*) as reviewsbb from reviews_BB
select count(*) as reviews from reviews

select count(*) as calendarsbb from Calendars_BB
select count(*) as calendars from calendar

select number_of_people,price from Listings_BB
inner join Reviews_BB on Listings_BB.Listing_ID = Reviews_BB.Listing_ID
inner join locations_bb on listings_bb.listing_id = locations_bb.ID
where Borough_id = 4
order by price desc