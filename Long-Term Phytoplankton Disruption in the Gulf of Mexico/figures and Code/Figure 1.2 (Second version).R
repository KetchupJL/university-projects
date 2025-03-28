
library(ggplot2)
library(viridis)

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

ggsave("figures/chlorophyll_facet.pdf", width = 14, height = 10, dpi = 300)

