Insert into ZillowNYC_Housing_Counts_BB(NYC,[Date],[Year],[Month],Count)
(
    select RegionName,[Date],[Year],[Month],Count_of_Homes_Listed
    from Zillow_Home_Listings
);

select * from ZillowNYC_Housing_Counts_BB

--NYCBoroughs_BB-------------------------------------------------
Insert into NYCBoroughs_BB(Borough_name,County_name)
(
    select distinct Neighborhood,RegionName
    from Zillow_RentalHome_Prices
)

select * from NYCBoroughs_BB

--Locations_BB--------------------------------------

--the locations from listings-------------------------------
SET IDENTITY_INSERT Locations_BB ON
Insert into Locations_BB(ID,Latitude,Longitude,Borough_ID)
(
    select distinct location.id, latitude,longitude,NYCBoroughs_BB.ID 
    from location left outer join NYCBoroughs_BB
    on location.neighbourhood_group_cleansed = NYCBoroughs_BB.Borough_name
)
SET IDENTITY_INSERT Locations_BB OFF

select * from locations_bb

--the locatoins for attractoins--------------------------------------
Insert into Locations_BB(Latitude,Longitude,Borough_ID,[Address],Zipcode)
(
    select distinct latitude,longitude, NYCBoroughs_BB.ID,[Address],Zipcode
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

insert into Locations_BB (Latitude,Longitude,Borough_ID)
(
    select distinct Latitude,Longitude,NYCBoroughs_BB.ID 
    from NYCcrime left outer join NYCBoroughs_BB 
    on NYCcrime.Borough = NYCBoroughs_BB.Borough_name
)
select * from Locations_BB where Borough_ID is null

--locations for hotels--------------------------------
insert into Locations_BB (Latitude,Longitude,Borough_ID,[Address],Zipcode)
(
    select distinct hotel_latitude,hotel_longitude,NYCBoroughs_BB.ID,hotel_address,hotel_postal_code
    from Hotels left outer join NYCBoroughs_BB 
    on Hotels.hotel_Neighborhood = NYCBoroughs_BB.Borough_name

)

select * from Locations_BB where address is not null

--Attractions table-----------------------
insert into Attractions_BB (Attraction_name,Website,Location_ID)
(
    select Attraction, Website, Locations_BB.ID 
    from AttractionsDistinct inner join Locations_BB
    on AttractionsDistinct.latitude = Locations_BB.Latitude
    and AttractionsDistinct.longitude = Locations_BB.Longitude
    
)

select * from Attractions_BB

--Hotels table-------------------------

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

insert into Hotels_BB (Hotel_name,Hotel_star_rating,Hotel_high_rate,Hotel_low_rate,Location_ID)
(
    select hotel_name,hotel_star_rating,hotel_high_rate,hotel_low_rate,Locations_BB.ID
    from Hotels inner join Locations_BB
    on Hotels.hotel_latitude = Locations_BB.Latitude
    and Hotels.hotel_longitude = Locations_BB.Longitude
    and Hotels.hotel_address = Locations_BB.Address
    and Hotels.hotel_postal_code  = Locations_BB.Zipcode
 
)
--Zillow Rental Homes BB -------------------------------------
insert into Zillow_Rental_Homes_BB(NYC_Borough_ID,[Date],[Year],[Month],Avg_Rental_Home_Price)
(
    select NYCBoroughs_BB.ID, [Date],[Year],[Month],Avg_Rental_Home_Price
    from Zillow_RentalHome_Prices inner join NYCBoroughs_BB
    on Zillow_RentalHome_Prices.Neighborhood = NYCBoroughs_BB.Borough_name
)

--CrimeTypes-------------------------------
insert into Crime_Types_BB(Crime_Description,Level_Of_Offense)
(
    select distinct [Crime Description], [Level Of Offense]
    from NYCcrime
)

insert into NYC_Crimes_BB(Complain_Number,Date_Occured,Crime_Type_ID,Location_ID)
(
    select [Complain Number],[Date Occured],Crime_Types_BB.ID, Locations_BB.ID
    from NYCcrime inner join Crime_Types_BB
    on NYCcrime.[Level of Offense] = Crime_Types_BB.Level_Of_Offense
    and NYCcrime.[Crime Description] = Crime_Types_BB.Crime_Description
    inner join Locations_BB
    on NYCcrime.Latitude = Locations_BB.Latitude
    and NYCcrime.Longitude=Locations_BB.Longitude
)

select * from NYC_Crimes_BB
where Location_ID is null

select * from NYC_Crimes_BB
where Crime_Type_ID is null

select * from NYC_Crimes_BB

--Listings table--------------------------
insert into Listings_BB(Listing_ID,Host_ID,Listing_Name,About,[Type],Number_of_People,Min_n,
Max_n,Review_Date,Price_Str)
(
    select id,[fk_l_host_id],[name],[abt]
     ,[type]
      ,[#ppl]
      ,[min_n]
      ,[max_n]
      ,[1_rvw]
      ,[$]
      from listings
)

select * from listings_BB
order by listing_ID desc
--reviews----------------------------

insert into Reviews_BB(ID,Listing_ID, [Date],ReviewerID,Comment)
(
    select id,listing_id,[date],reviewer_id,comments 
    from reviews
)

insert into Calendars_BB(Listing_ID,Count)
(
    select fk_c_listing_id,count 
    from calendar
)

insert into Hosts_BB (Host_ID,Host_is_superhost,Host_listings_count,Host_since,
Host_response_time,Host_response_rate,Host_acceptance_rate)
(
    select host_id,host_is_superhost,host_listings_count,host_since,host_response_time,
    host_response_rate,host_acceptance_rate
    from host2
)

