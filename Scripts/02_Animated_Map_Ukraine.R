library(ggplot2)
library(gganimate)
library(dplyr)
library(lubridate)
library(sf)
ukraine_map <- st_read("C:/Users/james/OneDrive/Documents/Working With Data (MTHM501/Ukraine War-Fires - MTHM501 Project/Data/ukraine-with-regions_1530.geojson")

GeospacialDataSet <- st_as_sf(fires_cleaned, coords = c("longitude", "latitude"), crs = 4326, remove = FALSE)

# Spatial join to add regional information to GeospacialDataSet 
GeospacialDataSet <- st_join(GeospacialDataSet, regions, join = st_intersects)

# Adding 'region_name' from the regions dataset to GeospacialDataSet 
GeospacialDataSet <- GeospacialDataSet %>%
  mutate(region_name = regions$region_name) %>%
  rename(region = name)


# Load necessary libraries
library(ggplot2)
library(gganimate)
library(ggshadow)

# Create base map with Ukraine's boundaries
base_map <- ggplot(data = ukraine_map) +
  geom_sf(fill = "gray90", color = "black") +
  theme_minimal() +
  labs(
    title = 'Fire Events Over Time in Ukraine',
    subtitle = 'War-related fires, Non-war fires, and Sustained Excess',
    x = "Longitude",
    y = "Latitude"
  )

library(ggspatial)
base_map <- base_map +
  annotation_scale(location = "bl")  # Scale bar at bottom left

# Add point data layer for fire events
animated_map <- base_map +
  geom_point(
    data = GeospacialDataSet, 
    aes(
      x = longitude, 
      y = latitude, 
      color = factor(war_fire),
      shape = factor(sustained_excess_fires)
    ), 
    size = 2,  # Reduced size
    stroke = 1,
    alpha = ifelse(GeospacialDataSet$war_fire == 0, 0.4, 1)  # Reduce alpha for non-war fires
  ) +
  scale_color_manual(
    values = c("1" = "#0073C2", "0" = "darkred"),  # Blue for war-related, Orange for non-war
    labels = c("0" = "Non-War Fire", "1" = "War-Related Fire"),
    name = "Fire Type"
  ) +
  scale_shape_manual(
    values = c("0" = 21, "1" = 16),  # 21 = filled circle, 16 = circle with border
    labels = c("0" = "Sustained Activity", "1" = "No Sustained Activity"),
    name = "Sustained Fire Activity"
  ) +
  labs(
    title = "Fires in Ukraine Over Time: {frame_time}",
    subtitle = "Blue: War-Related Fires | Orange: Non-War Fires",
    x = "Longitude", y = "Latitude"
  ) +
  theme_minimal(base_family = "Arial") +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    legend.position = c(0.85, 0.85),
    legend.box = "vertical",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  ) +
  transition_time(date) +  # Animate over the 'date' variable
  shadow_mark(past = TRUE, alpha = 0.10) +  # Shadow mark for past events
  scale_color_manual(
    values = c("1" = "grey", "0" = "darkred"),  # Same as main points
    guide = "none" ) + # Suppress legend for shadow marks
  ease_aes('linear')

# To display or save the animation
animated_map
anim_save(
  filename = "ukraine_fire_animation.gif",
  animation = animated_map,
  width = 1600,         # Width in pixels
  height = 1200,        # Height in pixels
  end_pause = 15,       # Pause at the end of the animation for 15 frames
  res = 150             # Resolution in DPI
)