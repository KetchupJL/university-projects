library(terra)
library(ggplot2)
library(sf)
library(viridis)

# Load raster
resid_rast <- rast("figures/stl_residual_mean_2010_14.tif")

# Convert to data frame
resid_df <- as.data.frame(resid_rast, xy = TRUE, na.rm = TRUE)
colnames(resid_df) <- c("lon", "lat", "residual")

# Convert your sf zones to one frame
# Add zone labels
zone_a$zone <- "DWH Core"
zone_b$zone <- "DWH Wide"
zone_c$zone <- "Control"

# Combine to single sf object
zones_sf <- rbind(zone_a, zone_b, zone_c)


library(ggplot2)
library(sf)
library(viridis)

# Macondo wellhead location (approximate)
macondo_lon <- -88.3659
macondo_lat <- 28.7381

ggplot() +
  # Residuals as background
  geom_raster(data = resid_df, aes(x = lon, y = lat, fill = residual), interpolate = TRUE) +
  
  # Diverging fill scale
  scale_fill_gradient2(
    low = "darkblue", mid = "white", high = "darkred", midpoint = 0,
    name = "Mean STL Residual\n(2010–2014)",
    guide = guide_colourbar(barwidth = 1.5, barheight = 10)
  ) +
  
  # Overlay polygons
  geom_sf(data = zones_sf, fill = NA, colour = "black", linewidth = 0.4) +
  
  # Macondo wellhead marker
  annotate("point", x = macondo_lon, y = macondo_lat, colour = "black", shape = 4, size = 3, stroke = 1.2) +
  annotate("text", x = macondo_lon, y = macondo_lat + 0.4, label = "Macondo Well", size = 4, hjust = 0.5) +
  
  # Custom axis labels
  scale_x_continuous(name = "Longitude (°W)", breaks = seq(-92, -84, 2)) +
  scale_y_continuous(name = "Latitude (°N)", breaks = seq(24, 31, 2)) +
  
  coord_sf(xlim = c(-93, -84), ylim = c(24, 31), expand = FALSE) +
  labs(
    title = "Mean STL Residuals of Chlorophyll-a (2010–2014)",
    subtitle = "Red = positive anomaly (increased biomass); Blue = negative anomaly (suppression)",
    x = "Longitude", y = "Latitude"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 9),
    plot.caption = element_text(size = 9, colour = "grey30")
  )


ggsave("figures/map_stl_resid_mean_2010_14.pdf", width = 12, height = 10, dpi = 300)
