oil <- rast("Essay/layer_28399/Cumulative_TCNNA_SAR/Cumulative_TCNNA_SAR.tif.ovr")
rcl <- matrix(c(
  -Inf, 0,     0,  # No oiling
  0,   30,    1,  # Low
  30,   60,    2,  # Moderate
  60,   Inf,   3   # High
), ncol = 3, byrow = TRUE)

oil_classified <- classify(oil, rcl)


library(sf)
library(dplyr)
library(readr)
library(tidyr)

# 1. Read the chlorophyll data
chl <- read_delim("Essay/zonemodis.txt", delim = "\t") %>%
  drop_na(chlor_a)

# 2. Convert to sf object
chl_sf <- st_as_sf(chl, coords = c("longitude", "latitude"), crs = 4326)

# 3. Assign zones
chl_sf$zone <- NA

for (zone_name in names(zones)) {
  zone_poly <- zones[[zone_name]]
  chl_sf$zone[st_within(chl_sf, zone_poly, sparse = FALSE)[,1]] <- zone_name
}

# Oil spill data
library(readr)
library(sf)

# Step 1: Read the CSV as a regular data frame
incidents <- read_csv("essay/incidents.csv")

# Step 2: Convert to sf object using lon/lat columns
incidents_sf <- st_as_sf(incidents,
                         coords = c("lon", "lat"),
                         crs = 4326)

# Convert dates
incidents_sf$open_date <- as.Date(incidents_sf$open_date, format = "%d/%m/%Y")

# Filter to spills with 'Oil'
oil_spills <- incidents_sf %>% filter(threat == "Oil")

#######################


# 4. Aggregate stats
chl_stats <- chl_sf %>%
  filter(!is.na(zone)) %>%
  group_by(zone, time = as.Date(time)) %>%
  summarise(mean_chl = mean(chlor_a, na.rm = TRUE),
            sd_chl = sd(chlor_a, na.rm = TRUE),
            .groups = 'drop')
