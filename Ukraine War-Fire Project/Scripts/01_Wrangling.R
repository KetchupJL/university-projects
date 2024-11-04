# Load necessary libraries for data wrangling and visualisation
library(dplyr)       # Data manipulation
library(tidyverse)   # Data science tools
library(ggplot2)     # Data visualisation

# Load libraries for handling geo-spatial data
library(sf)          # Spatial data handling

# Load library for date/time manipulation
library(lubridate)   # Working with dates

# Load fire datasets
# Main fire dataset (includes both war and non-war fire data)
fires <- read.csv("C:/Users/james/OneDrive/Documents/Working With Data (MTHM501/Ukraine War-Fires - MTHM501 Project/Data/ukraine_fires.csv")

# War-fire dataset (contains only war-fire related variables)
war_fires <- read.csv("C:/Users/james/OneDrive/Documents/Working With Data (MTHM501/Ukraine War-Fires - MTHM501 Project/Data/ukraine_war_fires.csv")

# Inspecting the structure and summary of both datasets
head(fires)
str(fires)
summary(fires)

head(war_fires)
str(war_fires)
summary(war_fires)

# Checking for missing data in both datasets
colSums(is.na(fires))
colSums(is.na(war_fires))

# Visualising missing data
library(Amelia)
# missmap(fires)  # This may take some time to load. All values for the 'city' variable are missing

# Remove the 'year' and 'city' columns due to incomplete data
fires_cleaned <- fires %>% select(-year, -city)

# Double-checking for any remaining missing values
colSums(is.na(fires_cleaned))

# Checking for duplicate rows (keeping them for now)
duplicate_rows <- fires_cleaned[duplicated(fires_cleaned), ]

# Identifying any completely empty rows (i.e., rows where all values are NA)
empty_rows <- fires_cleaned[rowSums(is.na(fires_cleaned)) == ncol(fires_cleaned), ]

# Check the structure of the dataset to ensure the columns are removed
str(fires_cleaned)


# Renaming columns for clarity and consistency
fires_cleaned <- fires_cleaned %>%
  rename(latitude = LATITUDE,
         longitude = LONGITUDE,
         time_of_day = ACQ_TIME,
         population_density = pop_density,
         urban_area = in_urban_area,
         excess_fires = excess_fire,
         sustained_excess_fires = sustained_excess)

# Removing unnecessary columns
fires_cleaned <- fires_cleaned %>%
  select(-time_of_year, -urban_area, -predicted_fire, -fire_in_window, 
         -length_of_war_fire_area, -war_fire_restrictive, 
         -in_ukraine_held_area, -fires_per_day_in_ukraine_held_area, 
         -war_fires_per_day_in_ukraine_held_area, 
         -fires_per_day_in_russia_held_area, 
         -war_fires_per_day_in_russia_held_area)

# Converting the 'date' column to Date type
fires_cleaned$date <- as.Date(fires_cleaned$date)

# Converting categorical variable 'war_fire' to factors
fires_cleaned$war_fire <- as.factor(fires_cleaned$war_fire)

# Double-checking the column types
str(fires_cleaned)

# Simplifying the 'time_of_day' variable for better analysis by clustering into periods of the day
fires_cleaned <- fires_cleaned %>%
  mutate(hour = floor(time_of_day / 100),
         time_of_day = case_when(
           hour >= 6 & hour < 12 ~ "Morning",
           hour >= 12 & hour < 18 ~ "Afternoon",
           hour >= 18 & hour < 24 ~ "Evening",
           TRUE ~ "Night"
         ))

# Setting the levels
fires_cleaned$time_of_day <- factor(fires_cleaned$time_of_day, 
                                    levels = c("Morning", "Afternoon", "Evening", "Night"))

# Adding spatial and temporal variables to enhance analysis

# Grouping fires by season using the 'lubridate' package for month extraction
fires_cleaned <- fires_cleaned %>%
  mutate(season = case_when(
    month(date) %in% c(12, 1, 2) ~ "Winter",
    month(date) %in% c(3, 4, 5) ~ "Spring",
    month(date) %in% c(6, 7, 8) ~ "Summer",
    month(date) %in% c(9, 10, 11) ~ "Autumn"
  ))

# Setting the levels
fires_cleaned$season <- factor(fires_cleaned$season, 
                                    levels = c("Winter", "Spring", "Summer", "Autumn"))

# Loading Ukraine regional boundaries dataset for spatial analysis
sf_use_s2(FALSE)  # Disabling spherical geometry operations
regions <- st_read("C:/Users/james/OneDrive/Documents/Working With Data (MTHM501/Ukraine War-Fires - MTHM501 Project/Data/ukraine-with-regions_1530.geojson")

# Ensuring the regions dataset is valid for spatial operations
regions <- st_make_valid(regions)

# Checking if lat/lon values are within valid ranges before transforming to 'sf'
fires_cleaned <- fires_cleaned %>%
  filter(between(latitude, -90, 90), between(longitude, -180, 180))

# Converting fire data to an sf object with latitude and longitude coordinates
fires_cleaned_sf <- fires_cleaned %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# Spatial join to add regional information to the fires dataset
fires_with_regions <- st_join(fires_cleaned_sf, regions, join = st_intersects)

# Adding 'region_name' from the regions dataset to the fires dataset
fires_with_regions <- fires_with_regions %>%
  mutate(region_name = regions$region_name) %>%
  rename(region = name)

# Summarising total war fires per region
total_war_fires <- fires_with_regions %>%
  group_by(region) %>%
  summarize(total_war_fires = sum(war_fire))

# Converting 'region','season' and 'id_big'to factors for random effects modelling
fires_with_regions$region <- as.factor(fires_with_regions$region)
fires_with_regions$season <- as.factor(fires_with_regions$season)
fires_with_regions$id_big <- as.factor(fires_with_regions$id_big)

# Converting war_fire to numeric
fires_with_regions$war_fire <- as.numeric(as.character(fires_with_regions$war_fire))

# Saving the cleaned dataset
write.csv(fires_with_regions, "C:/Users/james/OneDrive/Documents/Working With Data (MTHM501/Ukraine War-Fires - MTHM501 Project/Data/fires_with_region.csv", row.names = FALSE)

