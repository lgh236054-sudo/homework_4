
#Packages
library(tidyverse)
library(sf)
library(countrycode)


#Read data in
GII <- read_csv(
  "data/HDR25_Composite_indices_complete_time_series.csv",
  locale = locale(encoding = "Latin1")
)


#Calc difference between years from iso codes
GII_change <- GII %>%
  select(iso3, gii_2010, gii_2019) %>%
  mutate(gii_change_2010_2019 = gii_2019 - gii_2010)


#Read in boundary layer shpfile
World_Countries <- st_read(
  "data/World_Countries_(Generalized)/World_Countries_Generalized.shp"
)


#Standardize the iso codes
World_Countries <- World_Countries %>%
  mutate(iso3 = countrycode(COUNTRY,
                           origin = "country.name",
                           destination = "iso3c"))


#Check which countries have na codes
World_Countries %>%
  filter(is.na(iso3)) %>%
  select(COUNTRY)


#Left join the two data files by iso 3 code
World_GII <- World_Countries %>%
  left_join(GII_change, by = "iso3")


#View and summary stats
head(World_GII)
summary(World_GII$gii_change_2010_2019)


#Create the joined map
dir.create("output", showWarnings = FALSE)
st_write(
  World_GII,
  "output/world_gii_change_2010_2019.geojson",
  delete_dsn = TRUE
)
