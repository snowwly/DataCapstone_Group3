# Databricks notebook source
# MAGIC %md
# MAGIC Create mount point to reference file location

# COMMAND ----------

###### Mount Point 1 through Oauth security.
client_id = "5c0c63bf-b70d-461a-b3cb-fe0f9aeebe4a"
client_secret = "TvR8Q~Fn4FAsZTFIZO.-umdb61Kd2mfQDQdZBaQW"
tenant_id = "d4e104e3-ae7d-4371-a239-745aa8960cc9"

storage_account = "cohort50storage"
storage_container = "group3"

### Clone Notebook to your workspace and update to your name
mount_point = "/mnt/grp_sc"

configs = {"fs.azure.account.auth.type": "OAuth",
       "fs.azure.account.oauth.provider.type": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
       "fs.azure.account.oauth2.client.id": client_id,
       "fs.azure.account.oauth2.client.secret": client_secret,
       "fs.azure.account.oauth2.client.endpoint": f"https://login.microsoftonline.com/{tenant_id}/oauth2/token",
       "fs.azure.createRemoteFileSystemDuringInitialization": "true"}

try: 
    dbutils.fs.unmount(mount_point)
except:
    pass

dbutils.fs.mount(
source = f"abfss://{storage_container}@{storage_account}.dfs.core.windows.net/",
mount_point = mount_point,
extra_configs = configs)


# COMMAND ----------

# MAGIC %md
# MAGIC Read in .csv files from data blob

# COMMAND ----------

dataframes = {}
file_path = dbutils.fs.ls('/mnt/grp_sc/Detailed_data')

for file in file_path:
    key = file.name[:file.name.find('.')]
    dataframes[key] = spark.read.option("escape","\"")\
        .option("header","true")\
        .option("inferSchema", "true")\
        .option("multiline","true")\
        .csv(file.path)

# COMMAND ----------

# MAGIC %md
# MAGIC Clean data

# COMMAND ----------

#initialize variable to be able to use in future steps 
listings = dataframes['listings']

# COMMAND ----------

dataframes['location'] = listings[
    [
    "id", 
    "neighbourhood_group_cleansed",
    "latitude",
    "longitude"
    ]
]

# COMMAND ----------

dataframes['host'] = listings[
    [
    "host_id",
    "host_is_superhost", 
    "host_listings_count",
    "host_since",
    "host_response_time",
    "host_response_rate",
    "host_acceptance_rate"
    ]
]

# COMMAND ----------

dataframes['amenities'] = listings[
    [
    "id",
    "amenities"
    ]
].withColumnRenamed("id","fk_a_listing_id")

# COMMAND ----------

dataframes['listings'] = dataframes['listings']\
    .withColumnRenamed("neighbourhood_group_cleansed", "neighborhood_grp")\
    .withColumnRenamed("latitude", "lat")\
    .withColumnRenamed("longitude", "long")\
    .withColumnRenamed("minimum_nights", "min_n")\
    .withColumnRenamed("maximum_nights", "max_n")\
    .withColumnRenamed("description", "abt")\
    .withColumnRenamed("first_review", "1_rvw")\
    .withColumnRenamed("property_type", "type")\
    .withColumnRenamed("accommodates", "#ppl")\
    .withColumnRenamed("host_id", "fk_l_hostId")\
    .withColumnRenamed("price", "$")\
    .drop(
        "listing_url", 
        "source",
        "scrape_id", 
        "last_scraped", 
        "neighborhood_overview",
        "picture_url", 
        "host_url", 
        "host_name", 
        "host_location", 
        "host_about", 
        "host_thumbnail_url", 
        "host_picture_url", 
        "host_neighbourhood", 
        "host_total_listings_count", 
        "host_verifications", 
        "host_has_profile_pic", 
        "host_identity_verified", 
        "neighbourhood", 
        "bathrooms", 
        "bathrooms_text", 
        "bedrooms", 
        "beds", 
        "minimum_minimum_nights", 
        "maximum_minimum_nights", 
        "minimum_maximum_nights", 
        "maximum_maximum_nights", 
        "calendar_updated", 
        "has_availability", 
        "availability_30", 
        "availability_60", 
        "availability_90", 
        "number_of_reviews_ltm", 
        "number_of_reviews_l30d", 
        "last_review", 
        "review_scores_accuracy", 
        "review_scores_cleanliness", 
        "review_scores_checkin", 
        "review_scores_communication", 
        "review_scores_value", 
        "license", 
        "instant_bookable", 
        "calculated_host_listings_count", 
        "calculated_host_listings_count_private_rooms", 
        "calculated_host_listings_count_shared_rooms", 
        "reviews_per_month",
        "host_since",
        "host_response_time",
        "host_response_rate",
        "host_acceptance_rate",
        "amenities",
        "room_type",
        "review_scores_rating",
        "number_of_reviews",
        "calendar_last_scraped",
        "maximum_nights_avg_ntm",
        "minimum_nights_avg_ntm",
        "calculated_host_listings_count_entire_homes",
        "review_scores_location",
        "availability_365",
        "host_is_superhost", 
        "host_listings_count",
        "lat",
        "long",
        "neighborhood_grp",
        "neighborhood",
)

# COMMAND ----------

dataframes['reviews'] = dataframes['reviews'].drop(
    'reviewer_name'
)

# COMMAND ----------

dataframes['reviews']

# COMMAND ----------

dataframes['calendar'] = dataframes['calendar']\
    .where("available == 't'")\
    .groupBy('listing_id').count()\
    .withColumnRenamed("listing_id", "fk_c_listing_id")\
    .withColumnRenamed("count", "days_avail")

# COMMAND ----------

# MAGIC %md Load data to SQL database

# COMMAND ----------

database = 'Bionic_blobs'
user = 'Bionic_blobs'
password = 'SuperSecurepw!'
server = "cohort50sqlserver.database.windows.net"
 
for table_name in dataframes.keys():
    table = f"dbo.{table_name}"
    dataframes[table_name].write.format("jdbc").option(
        "url", f"jdbc:sqlserver://{server}:1433;databaseName={database};"
        ) \
        .mode("overwrite") \
        .option("dbtable", table) \
        .option("user", user) \
        .option("password", password) \
        .option("driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver") \
        .save()

# COMMAND ----------

#For adding individual tables after initial upload

#database = 'Bionic_blobs'
#user = 'Bionic_blobs'
#password = 'SuperSecurepw!'
#server = "cohort50sqlserver.database.windows.net"
#table_name = 'INSERT TABLE NAME HERE'
 
#dataframes[table_name].write.format("jdbc").option(
#    "url", f"jdbc:sqlserver://{server}:1433;databaseName={database};"
#    ) \
#    .mode("overwrite") \
#    .option("dbtable", table_name) \
#    .option("user", user) \
#    .option("password", password) \
#    .option("driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver") \
#    .save()

# COMMAND ----------

###scaleable test
#database = 'Bionic_blobs'
#user = 'Bionic_blobs'
#password = 'SuperSecurepw!'
#server = "cohort50sqlserver.database.windows.net"
#N = 5

#for table_name in dataframes.keys():
#    table = f"dbo.{table_name}"
#    tmp = dataframes[table_name]
#    smol = spark.createDataFrame(tmp.take(N), schema=tmp.schema)
#    smol.write.format("jdbc").option(
#        "url", f"jdbc:sqlserver://{server}:1433;databaseName={database};"
#        ) \
#        .mode("overwrite") \
#        .option("dbtable", table) \
#        .option("user", user) \
#        .option("password", password) \
#        .option("driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver") \
#        .save()
