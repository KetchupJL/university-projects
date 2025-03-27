# Load libraries
library(terra)
library(ggplot2)
library(dplyr)
library(viridis)

# Load NetCDF file
chl_file <- "Essay/modis_chlorophyll_climatology_2002_2024.nc"
chl <- terra::rast(chl_file)

# Check structure
chl

# Rename the 12 layers in your raster stack
names(chl) <- month.name[1:12]


# Plot a single month
plot(chl$April, main = "Mean April Chlorophyll-a (2002–2024)", col = viridis(100))

# Convert to data frame for ggplot
chl_df <- as.data.frame(chl, xy = TRUE, na.rm = TRUE)

# Example ggplot for multiple months
library(tidyr)
chl_long <- pivot_longer(chl_df, cols = month.name, names_to = "month", values_to = "chlor_a")

ggplot(chl_long, aes(x = x, y = y, fill = chlor_a)) +
  geom_raster() +
  coord_fixed() +
  scale_fill_viridis_c(trans = "log", option = "C") +
  facet_wrap(~month, ncol = 4) +
  labs(title = "Monthly Chlorophyll-a Climatology (MODIS-Aqua, 2002–2024)",
       fill = "mg/m³", x = "Longitude", y = "Latitude") +
  theme_minimal()

library(sf)
library(rnaturalearth)
coast <- ne_coastline(scale = "medium", returnclass = "sf")

ggplot() +
  geom_raster(data = chl_long, aes(x = x, y = y, fill = chlor_a)) +
  geom_sf(data = coast, colour = "white", linewidth = 0.3) +
  facet_wrap(~month, ncol = 4) +
  coord_sf(xlim = c(-98, -80), ylim = c(18, 31), expand = FALSE) +
  scale_fill_viridis_c(trans = "log", option = "C") +
  theme_minimal() +
  labs(title = "Monthly Chlorophyll-a Climatology (MODIS-Aqua, 2002–2024)",
       x = "Longitude", y = "Latitude", fill = "mg/m³")




# DWH spill core zone (approx. 1° × 1° box)
dwh_box <- st_as_sf(st_sfc(
  st_polygon(list(rbind(
    c(-89, 28), c(-88, 28), c(-88, 29), c(-89, 29), c(-89, 28)
  ))),
  crs = 4326
))

ggplot() +
  geom_raster(data = chl_long, aes(x = x, y = y, fill = chlor_a)) +
  geom_sf(data = coast, colour = "white", linewidth = 0.3) +
  geom_sf(data = dwh_box, fill = NA, colour = "red", linetype = "dashed", linewidth = 0.6) +
  facet_wrap(~month, ncol = 4) +
  coord_sf(xlim = c(-98, -80), ylim = c(18, 31), expand = FALSE) +
  scale_fill_viridis_c(
    trans = "log",
    option = "C",
    name = "Chlorophyll-a\n(mg·m⁻³)",
    guide = guide_colourbar(barwidth = 1.4, barheight = 12),
    labels = scales::label_number(accuracy = 0.01)
  ) +
  labs(
    title = "Monthly Chlorophyll-a Climatology (2002–2024)",
    subtitle = "MODIS-Aqua, log-transformed scale. Red box = DWH core analysis zone.",
    x = "Longitude (°W)",
    y = "Latitude (°N)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12, margin = margin(b = 10)),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    strip.text = element_text(size = 11, face = "bold"),
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 9),
    panel.spacing = unit(1.1, "lines"),
    plot.margin = margin(10, 10, 10, 12)
  )
