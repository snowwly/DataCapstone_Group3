drop table if exists ZillowNYC_Housing_Counts_BB;
drop table if exists NYC_Crimes_BB;
drop table if exists Crime_Types_BB;
drop table if exists Zillow_Rental_Homes_BB;
drop table if exists Hotels_BB;
drop table if exists Attractions_BB;

drop table if exists Hosts_BB;
drop table if exists Calendars_BB;
drop table if exists Reviews_BB;
drop table if exists Listings_BB;

drop table if exists Locations_BB;
drop table if exists NYCBoroughs_BB;




CREATE TABLE ZillowNYC_Housing_Counts_BB
(
    ID int primary key identity(1,1),
    NYC varchar(100) not null,
    [Date] date not null,
    [Year] int not null,
    [Month] int not null,
    Count int not null,
    Constraint CK_Date UNIQUE ([Date])


)

Create Table NYCBoroughs_BB
(
    ID int primary key identity(1,1),
    Borough_name varchar(100) not null,
    County_name varchar(100 )not null,

    CONSTRAINT CK_Borough_Name unique (Borough_name)

)

Create Table Locations_BB
(
    --ID DECIMAL(38,0) primary key IDENTITY(1,1),
    ID bigint primary key IDENTITY(1,1),
    Latitude float not null,
    Longitude float not null,
    Borough_ID int null,
    Zipcode varchar(100) null,
    [Address] varchar(100) null,
    Dataset varchar(100) not null,

    CONSTRAINT FK_NYCBoroughs_Locations_BoroughID FOREIGN KEY (Borough_ID)
    REFERENCES NYCBoroughs_BB(ID)

)

Create table Attractions_BB
(
    ID int primary key identity(1,1),
    Attraction_name varchar(100) not null,
    Website varchar(100) null,
    --Location_ID DECIMAL(38,0) not null,
    Location_ID bigint not null,

    CONSTRAINT CK_Attraction_name UNIQUE(Attraction_name),
    CONSTRAINT FK_Locations_Attractions_Location_ID FOREIGN KEY (Location_ID)
    REFERENCES Locations_BB(ID)
)

Create table Hotels_BB
(
    ID int primary key identity(1,1),
    Hotel_name varchar(100) not null,
    Hotel_star_rating float not null,
    Hotel_high_rate float not null,
    Hotel_low_rate float not null,
    Location_ID bigint not null,
   -- Location_ID DECIMAL(38,0) not null,

    CONSTRAINT CK_Hotel_name_Location UNIQUE(Hotel_name,Location_ID),
    CONSTRAINT FK_Locations_Hotels_Location_ID FOREIGN KEY (Location_ID)
    REFERENCES Locations_BB(ID)
)

CREATE TABLE Zillow_Rental_Homes_BB
(
    ID int primary key identity(1,1),
    NYC_Borough_ID int not null,
    [Date] date not null,
    [Year] int not null,
    [Month] int not null,
    Avg_Rental_Home_Price float not null,
    Constraint CK_Date_Borough_ID UNIQUE (NYC_Borough_ID,[Date]),
    CONSTRAINT FK_NYCBoroughs_Zillow_Rental_Homes_Borough_ID FOREIGN KEY (NYC_Borough_ID)
    REFERENCES NYCBoroughs_BB(ID)



)

-- NYC Crimes ---------------------------------------------------

Create Table Crime_Types_BB
(
    ID int primary key identity(1,1),
    Crime_Description varchar(100) not null,
    Level_Of_Offense varchar(100 )not null

)

Create Table NYC_Crimes_BB
(
    ID int primary key identity(1,1),
    Complain_Number bigint not null,
    Date_Occured date not null,
    Crime_Type_ID int not null,
   -- Location_ID DECIMAL(38,0) not null,
   Location_ID bigint not null,


    CONSTRAINT FK_Crime_Type_NYC_Crimes_CrimeTypeID FOREIGN KEY (Crime_Type_ID)
    REFERENCES Crime_Types_BB(ID),

    CONSTRAINT FK_Locations_NYC_Crimes_LocationID FOREIGN KEY (Location_ID)
    REFERENCES Locations_BB(ID)

)

--Airbnb listings------------------------------------------

Create table Listings_BB
(
    -- Listing_ID DECIMAL(38,0) primary key,
    Listing_ID bigint primary key,
    Host_ID bigint not null,
    Listing_Name varchar(1000) null,
    About varchar(8000) null,
    Price_Str varchar(8000) not null,
    Price float null,
    [Type] varchar(1000) null,
    Number_of_People int null,
    Min_n int null,
    Max_n int null,
    Review_Date date null,

    CONSTRAINT FK_Locations_Listings_ListingID FOREIGN KEY (Listing_ID)
    REFERENCES Locations_BB(ID)

)

Create table Reviews_BB
(   ID bigint,
    Listing_ID bigint,
    --Listing_ID DECIMAL(38,0) ,
    [Date] date null,
    ReviewerID int null,
    Comment varchar(8000) null,
    CONSTRAINT FK_Listings_Reviews_ListingID FOREIGN KEY (Listing_ID)
    REFERENCES Listings_BB(Listing_ID)
)

Create table Calendars_BB
(  
    --Listing_ID DECIMAL(38,0) primary key,
    Listing_ID bigint primary key,
    Count int not null,
    CONSTRAINT FK_Listings_Calendar_ListingID FOREIGN KEY (Listing_ID)
    REFERENCES Listings_BB(Listing_ID)
)

-- Create table Amentities_BB
-- (   ID int primary key identity(1,1),
--     Host_ID bigint not null,
--     Amentity_Name varchar(8000) null,

-- )

Create table Hosts_BB
(
    ID int primary key identity(1,1),
    Host_ID bigint not null,
    [Host_is_superhost] varchar(10) null,
    [Host_listings_count] int null,
    [Host_since] date null,
    [Host_response_time] varchar(100) null,
    [Host_response_rate] varchar(100) null,
    [Host_acceptance_rate] varchar(100) null
)

