# Zones

library(sf)
library(terra)

# Define polygons
zone_a <- st_as_sf(st_sfc(st_polygon(list(rbind(
  c(-89, 28), c(-88, 28), c(-88, 29), c(-89, 29), c(-89, 28)
)))), crs = 4326)

zone_b <- st_as_sf(st_sfc(st_polygon(list(rbind(
  c(-90.5, 27), c(-87, 27), c(-87, 30), c(-90.5, 30), c(-90.5, 27)
)))), crs = 4326)

zone_c <- st_as_sf(st_sfc(st_polygon(list(rbind(
  c(-93, 23), c(-91, 23), c(-91, 24), c(-93, 24), c(-93, 23)
)))), crs = 4326)

# Optional: combine for batch processing
zones <- list(DWH_Core = zone_a, DWH_Wide = zone_b, Control = zone_c)




# Rename raster layers if not already
names(chl) <- month.name[1:12]

chl_zone_means <- lapply(zones, function(zone) {
  ext <- terra::extract(chl, vect(zone), fun = mean, na.rm = TRUE)
  # Drop the first column (ID), keep only chlorophyll values
  chlor_vals <- as.numeric(ext[1, -1])
  data.frame(month = month.name, chlor_a = chlor_vals)
})


# Convert to tidy data frame
library(dplyr)
library(tidyr)
chl_df <- bind_rows(
  lapply(names(chl_zone_means), function(name) {
    chl_zone_means[[name]] %>%
      mutate(zone = name)
  }), .id = NULL
)



library(ggplot2)

ggplot(chl_df, aes(x = factor(month, levels = month.name), y = chlor_a, colour = zone, group = zone)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.8, shape = 21, stroke = 0.4, fill = "white") +
  scale_y_log10(labels = scales::label_number(accuracy = 0.01)) +
  scale_colour_viridis_d(option = "C", end = 0.85) +
  theme_minimal(base_family = "Times", base_size = 13) +
  labs(
    title = "Seasonal Chlorophyll-a Climatology by Exposure Zone",
    subtitle = "MODIS-Aqua (2002–2024)",
    x = "Month",
    y = "Mean Chlorophyll-a (mg/m³)",
    colour = "Region"
  ) +
  theme_minimal(base_family = "Times", base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12, margin = margin(b = 10)),
    axis.title = element_text(size = 13),
    axis.text = element_text(size = 11),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "top",
    legend.title = element_text(face = "bold", size = 12),
    legend.text = element_text(size = 11),
    panel.grid.minor = element_blank(),
    plot.margin = margin(t = 10, r = 10, b = 10, l = 14)  # Increased left margin
  )

ggsave("figures/monthly_chlorophyll_climatology.pdf", width = 12, height = 9, dpi = 300)