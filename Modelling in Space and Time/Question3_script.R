temps <- read.csv("~/GitHub/university-projects/Modelling in Space and Time/In progress/MaxTempCalifornia.csv")
meta <- read_csv("~/GitHub/university-projects/Modelling in Space and Time/In progress/metadataCA.csv")

library(ggmap)
library(ggspatial)
library(sf)
library(dplyr)
library(viridis)


register_stadiamaps(key = "API-Key")

# Convert to sf object
meta_sf <- st_as_sf(meta, coords = c("Long", "Lat"), crs = 4326)

ca_map <- get_stadiamap(bbox = c(left = -125, bottom = 32, right = -114, top = 42),
                        zoom = 7, maptype = "stamen_terrain")


# Plot with elevation gradient
ggmap(ca_map) +
  geom_sf(data = meta_sf, inherit.aes = FALSE, aes(color = Elev), size = 3) +
  geom_text(data = meta, aes(x = Long, y = Lat, label = Location), size = 3, color = "black") +
  scale_color_viridis(option = "A", name = "Elevation (m)") +
  ggtitle("California Sites with Elevation Context") +
  theme_minimal()

library(ggridges)
library(dplyr)
library(hrbrthemes)

temps_long <- read.csv("MaxTempCalifornia.csv") %>%
  pivot_longer(-Date, names_to = "Site", values_to = "Temp") %>%
  mutate(Date = as.Date(as.character(Date), format = "%Y%m%d")) %>%
  left_join(meta, by = c("Site" = "Location"))

temps_long <- temps_long %>%
  mutate(Site_order = reorder(Site, Temp, mean))


temps_long %>%
  ggplot(aes(x = Temp, y = Site_order, fill = ..x..)) +
  geom_density_ridges_gradient(scale = 3, rel_min_height = 0.01) +
  annotate("text", 
           x = max(temps_long$Temp) + 1, 
           y = temps_long %>% filter(Temp == max(Temp)) %>% pull(Site_order) %>% unique(),
           label = paste0("Hottest: ", max(temps_long$Temp), "°C"), 
           hjust=0, size=3) +
  annotate("text", 
           x = min(temps_long$Temp) - 1, 
           y = temps_long %>% filter(Temp == min(Temp)) %>% pull(Site_order) %>% unique(),
           label = paste0("Coldest: ", min(temps_long$Temp), "°C"), 
           hjust=1, size=3) +
  scale_fill_gradientn(
    colours = c("navyblue", "deepskyblue", "lightyellow", "orange", "firebrick"),
    name = "Max Temp (°C)"
  ) +
  labs(
    title = "Distribution of Max Daily Temperatures by Site (2012)",
    subtitle = "Sites ordered by mean temperature | Colour gradient reflects temperature from cold (blue) to hot (red)",
    x = "Max Temperature (°C)",
    y = "Site"
  ) +
  theme_minimal() +
  theme(
    legend.position = "right",
    plot.title.position = "plot",
    panel.spacing = unit(0.1, "lines"),
    panel.grid = element_blank(),
    axis.text.y = element_text(hjust=0)
  )

library(dplyr)
library(gt)

summary_table <- temps_long %>%
  group_by(Site) %>%
  summarise(
    Mean_Temp = round(mean(Temp, na.rm = TRUE), 1),
    Median_Temp = round(median(Temp, na.rm = TRUE), 1),
    Min_Temp = round(min(Temp, na.rm = TRUE), 1),
    Max_Temp = round(max(Temp, na.rm = TRUE), 1),
    SD_Temp = round(sd(Temp, na.rm = TRUE), 1)
  ) %>%
  arrange(desc(Mean_Temp))

summary_table %>%
  gt() %>%
  tab_header(
    title = "Summary Statistics of Maximum Daily Temperatures",
    subtitle = "Across 11 California Sites (2012)"
  ) %>%
  cols_label(
    Site = "Site",
    Mean_Temp = "Mean (°C)",
    Median_Temp = "Median (°C)",
    Min_Temp = "Min (°C)",
    Max_Temp = "Max (°C)",
    SD_Temp = "SD (°C)"
  )


##############################################################################
##############################################################################
##############################################################################


# Part B


temps_13 <- temps_long %>%
  filter(Date == as.Date("2012-12-13")) %>%
  select(Site, Temp) %>%
  left_join(meta %>% select(Location, Long, Lat), by = c("Site" = "Location")) %>%
  mutate(
    Long = case_when(
      Site == "San.Francisco" ~ -122.4269,
      Site == "San.Diego" ~ -117.1831,
      Site == "Santa.Cruz" ~ -121.9911,
      Site == "Death.Valley" ~ -116.8669,
      TRUE ~ Long
    ),
    Lat = case_when(
      Site == "San.Francisco" ~ 37.7705,
      Site == "San.Diego" ~ 32.7336,
      Site == "Santa.Cruz" ~ 36.9905,
      Site == "Death.Valley" ~ 36.4622,
      TRUE ~ Lat
    )
  )

# Empirical variogram

# Prediction Sites
pred_sites <- c("San.Diego", "Fresno")

# Training Data (sites used to fit the model)
train_data <- temps_13 %>%
  filter(!Site %in% pred_sites)

# Test Data (sites we will predict)
test_data <- temps_13 %>%
  filter(Site %in% pred_sites)

library(geoR)

geo_data <- as.geodata(train_data, coords.col = c("Long", "Lat"), data.col = "Temp")

vario_emp <- variog(geo_data, max.dist = 600, option='bin')

plot(vario_emp,
     main = "Empirical Variogram of Max Temp (13 Dec 2012)",
     xlab = "Distance (km)",
     ylab = "Semivariance",
     pch = 19, cex = 1.2, col = "black")
lines(lowess(vario_emp$u, vario_emp$v), col = "blue", lwd = 2)


######
# fit Gaussian Process (GP) models via Maximum Likelihood Estimation



xv_mle <- xvalid(geo_data, model = model_mle)


# Check the summary of the Exponential model
summary(mle_model_exp)

