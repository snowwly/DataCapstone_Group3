
USE Bionic_blobs

select * from Hotels 
where hotel_name = 'Flushing Ymca'

select * from Hotels
where hotel_latitude = 40.76419
and hotel_longitude= -73.82648

select * from Hotels where hotel_name = 'Beautiful Studio Near Central Park'

update Hotels
set hotel_address = '138-46 Northern Blvd.'
where hotel_name = 'Flushing Ymca'

update Hotels
set hotel_name = 'Beautiful Studio Near Central Park 1'
where hotel_name = 'Beautiful Studio Near Central Park'
and hotel_address = '244 East 71st Street'

Insert into ZillowNYC_Housing_Counts_BB(NYC,[Date],[Year],[Month],Count)
(
    select RegionName,[Date],[Year],[Month],Count_of_Homes_Listed
    from Zillow_Home_Listings
);

select * from ZillowNYC_Housing_Counts_BB
select count(*) as zillowhousebb from ZillowNYC_Housing_Counts_BB
select count(*) as zillowhouse from Zillow_Home_Listings

--NYCBoroughs_BB-------------------------------------------------
Insert into NYCBoroughs_BB(Borough_name,County_name)
(
    select distinct Neighborhood,RegionName
    from Zillow_RentalHome_Prices
)

select * from NYCBoroughs_BB
select count(*) as boroughs from  NYCBoroughs_BB

--Locations_BB-------------------------------------------------------------------------------------------------------------------

--the locations from listings--------------------------------------------
SET IDENTITY_INSERT Locations_BB ON
Insert into Locations_BB(ID,Latitude,Longitude,Borough_ID,Dataset)
(
    select distinct location.id, latitude,longitude,NYCBoroughs_BB.ID,'Listings' as Dataset
    from location left outer join NYCBoroughs_BB
    on location.neighbourhood_group_cleansed = NYCBoroughs_BB.Borough_name
)
SET IDENTITY_INSERT Locations_BB OFF

select * from locations_bb

--the locatoins for attractoins--------------------------------------
Insert into Locations_BB(Latitude,Longitude,Borough_ID,[Address],Zipcode,Dataset)
(
    select distinct latitude,longitude, NYCBoroughs_BB.ID,[Address],Zipcode,'Attractions' as Dataset
    from AttractionsDistinct left outer join NYCBoroughs_BB 
    on AttractionsDistinct.Neighborhood = NYCBoroughs_BB.Borough_name
    where latitude is not null
    -- and NYCBoroughs_BB.ID is not null
)

select * from Locations_BB
where Borough_ID is null


select * from Locations_BB
where zipcode is not null

-- locations for crime dataset------------------------------------------

insert into Locations_BB (Latitude,Longitude,Borough_ID,Dataset)
(
    select distinct Latitude,Longitude,NYCBoroughs_BB.ID , 'Crimes' as Dataset
    from NYCcrime inner join NYCBoroughs_BB 
    on NYCcrime.Borough = NYCBoroughs_BB.Borough_name
)
select * from Locations_BB where Borough_ID is null

--locations for hotels--------------------------------
insert into Locations_BB (Latitude,Longitude,Borough_ID,[Address],Zipcode,Dataset)
(
    select distinct hotel_latitude,hotel_longitude,NYCBoroughs_BB.ID,hotel_address,hotel_postal_code, 'Hotels' as Dataset
    from Hotels left outer join NYCBoroughs_BB 
    on Hotels.hotel_Neighborhood = NYCBoroughs_BB.Borough_name

)

select * from Locations_BB where address is not null
--END OF LOCATIONS --------------------------------------------------------------------------------------------------------------------
--Attractions table-----------------------
insert into Attractions_BB (Attraction_name,Website,Location_ID)
(
    select Attraction, Website, Locations_BB.ID 
    from AttractionsDistinct inner join Locations_BB
    on (AttractionsDistinct.latitude = Locations_BB.Latitude
    and AttractionsDistinct.longitude = Locations_BB.Longitude
    and Locations_BB.Dataset = 'Attractions')
    
)

select * from Attractions_BB
select count(*) as attractionsbb from Attractions_BB
select count(*) as attractions from AttractionsDistinct


--Hotels table-------------------------



insert into Hotels_BB (Hotel_name,Hotel_star_rating,Hotel_high_rate,Hotel_low_rate,Location_ID)
(
    select hotel_name,hotel_star_rating,hotel_high_rate,hotel_low_rate,Locations_BB.ID
    from Hotels inner join Locations_BB
    on (Hotels.hotel_latitude = Locations_BB.Latitude
    and Hotels.hotel_longitude = Locations_BB.Longitude
    and Hotels.hotel_address = Locations_BB.Address
    and Hotels.hotel_postal_code  = Locations_BB.Zipcode
    and Locations_BB.Dataset = 'Hotels')
 
)

select * from Hotels_BB
select count(*) as hotelsbb from Hotels_BB
select count(*) as hotels from Hotels
--Zillow Rental Homes BB -------------------------------------
insert into Zillow_Rental_Homes_BB(NYC_Borough_ID,[Date],[Year],[Month],Avg_Rental_Home_Price)
(
    select NYCBoroughs_BB.ID, [Date],[Year],[Month],Avg_Rental_Home_Price
    from Zillow_RentalHome_Prices inner join NYCBoroughs_BB
    on Zillow_RentalHome_Prices.Neighborhood = NYCBoroughs_BB.Borough_name
)
select count(*) from Zillow_Rental_Homes_BB
select count(*) from Zillow_RentalHome_Prices

--CrimeTypes-------------------------------
insert into Crime_Types_BB(Crime_Description,Level_Of_Offense)
(
    select distinct [Crime Description], [Level Of Offense]
    from NYCcrime
)

select count(*) from Crime_Types_BB
select count(distinct concat([Crime Description], [Level Of Offense])) from NYCcrime


insert into NYC_Crimes_BB(Complain_Number,Date_Occured,Crime_Type_ID,Location_ID)
(
    select [Complain Number],[Date Occured],Crime_Types_BB.ID, Locations_BB.ID
    from NYCcrime
    left join Crime_Types_BB
    on (NYCcrime.[Level of Offense] = Crime_Types_BB.Level_Of_Offense
    and NYCcrime.[Crime Description] = Crime_Types_BB.Crime_Description)
    left join (Locations_BB inner join NYCBoroughs_BB on Locations_BB.Borough_ID = NYCBoroughs_BB.ID)
    on (NYCcrime.Latitude = Locations_BB.Latitude
    and NYCcrime.Longitude=Locations_BB.Longitude
    and Locations_BB.Dataset = 'Crimes'
    and NYCcrime.Borough = NYCBoroughs_BB.Borough_name)
)

select count(*) as nyccrime from NYCcrime
select count(*) as nyccrimebb from NYC_Crimes_BB



select * from NYC_Crimes_BB
where Crime_Type_ID is null


--hosts-------------------------------
insert into Hosts_BB (Host_ID,Host_is_superhost,Host_listings_count,Host_since,
Host_response_time,Host_response_rate,Host_acceptance_rate)
(
    select distinct host_id,host_is_superhost,host_listings_count,host_since,host_response_time,
    host_response_rate,host_acceptance_rate
    from host2
)

select count(*) as hostsbb from Hosts_BB
select count(*) as hosts from host2

select count(distinct HOST_ID) from Hosts_BB

select * from hosts_BB
order by host_id desc
--Listings table--------------------------
insert into Listings_BB(Listing_ID,Host_ID,Listing_Name,About,[Type],Number_of_People,Min_n,
Max_n,First_Review_Date,Price_Str,Price)
(
    select Listing_ID,Host_ID,Listing_Name,About,[Type],Number_of_People,Min_n,
Max_n,First_Review_Date,Price_Str,Price
      from listingschanged
)

select count(*)  as listingbb from listings_BB
select count(*) as listing from listings
-- select * from listings_BB
--reviews----------------------------

-- delete from reviews 
-- where id in (
-- select id from Reviews
-- where id in (select id from reviews group by id having count(*) >1)) 

insert into Reviews_BB(ID,Listing_ID, [Date],ReviewerID,Comment)
(
    select distinct id,listing_id,[date],reviewer_id,comments 
    from reviews
)
select count(*) as reviewsbb from reviews_BB
-- select count(*) as reviews from reviews
-- select count(distinct id) from reviews



insert into Calendars_BB(Listing_ID,Count)
(
    select distinct fk_c_listing_id,count 
    from calendar
)

select count(*) as calendarsbb from Calendars_BB

select count(*) as calendars from calendar






