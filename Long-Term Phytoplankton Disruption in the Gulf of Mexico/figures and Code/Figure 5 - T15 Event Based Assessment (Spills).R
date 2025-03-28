library(readr)
library(dplyr)
library(lubridate)
library(terra)
library(stringr)
library(purrr)
library(tibble)
library(ggplot2)

# === Load and filter spill metadata ===
spill_df_raw <- read_csv("incidents.csv")

spill_df <- spill_df_raw %>%
  filter(
    !is.na(lat), !is.na(lon), !is.na(open_date),
    threat == "Oil",
    !is.na(max_ptl_release_gallons)
  ) %>%
  mutate(
    open_date = dmy(open_date)
  ) %>%
  arrange(desc(max_ptl_release_gallons)) %>%  # sort by size
  slice(1:15)  # take top 15 spills

# === Load chlorophyll raster stack ===
nc_folder <- "C:/Users/james/OneDrive/Documents/Communicating Data/Essay/choloro/requested_files 2"
nc_files <- list.files(path = nc_folder, pattern = "\\.nc$", full.names = TRUE)

# Extract dates from filenames
dates <- basename(nc_files) %>%
  str_extract("\\d{8}(?=_)") %>%
  as.Date(format = "%Y%m%d")

# Load individual layers and assign names
chl_list <- lapply(seq_along(nc_files), function(i) {
  r <- rast(nc_files[i])
  names(r) <- format(dates[i], "%Y-%m-%d")
  return(r)
})

# Combine into one SpatRaster
chl_stack <- rast(chl_list)

# Define time window
month_window <- -48:48
n_months <- length(month_window)

# === Function to extract time series around each spill ===
extract_chl_ts <- function(event_id, lat, lon, date, month_window, chl_stack, dates) {
  ts_df <- data.frame()
  
  for (i in seq_along(month_window)) {
    target_date <- date %m+% months(month_window[i])
    date_idx <- which.min(abs(dates - target_date))
    if (length(date_idx) == 0 || is.na(date_idx)) next
    
    val <- tryCatch({
      extract_val <- terra::extract(chl_stack[[date_idx]], matrix(c(lon, lat), ncol = 2))
      if (!is.null(extract_val) && ncol(extract_val) == 1) extract_val[1, 1] else NA
    }, error = function(e) NA)
    
    ts_df <- bind_rows(ts_df, tibble(
      id = event_id,
      event_date = date,
      month_relative = month_window[i],
      chlor_a = val,
      lat = lat,
      lon = lon
    ))
  }
  return(ts_df)
}
all_chl_ts <- purrr::pmap_dfr(
  list(spill_df$id, spill_df$lat, spill_df$lon, spill_df$open_date),
  extract_chl_ts,
  month_window = month_window,
  chl_stack = chl_stack,
  dates = dates
)

# === Summary trend plot (optional) ===
chl_summary <- all_chl_ts %>%
  group_by(month_relative) %>%
  summarise(
    mean_chl = mean(chlor_a, na.rm = TRUE),
    sd_chl = sd(chlor_a, na.rm = TRUE),
    n = sum(!is.na(chlor_a)),
    se = sd_chl / sqrt(n),
    lower = mean_chl - 1.96 * se,
    upper = mean_chl + 1.96 * se
  )

mean_chlorophyll_top15_spills <- ggplot(chl_summary, aes(x = month_relative, y = mean_chl)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "skyblue", alpha = 0.3) +
  geom_line(color = "steelblue", linewidth = 1.1) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "red", linewidth = 0.8) +
  labs(
    title = "Mean Chlorophyll-a Response for 15 Largest Gulf Oil Spills",
    subtitle = "MODIS-Aqua, ±4 years around largest recorded events by potential volume",
    x = "Months Since Spill",
    y = expression("Mean Chlorophyll-a (mg·m"^-3*")")
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12),
    axis.title = element_text(size = 13),
    axis.text = element_text(size = 11),
    panel.grid.minor = element_blank(),
    panel.spacing = unit(1.2, "lines"),
    plot.margin = margin(t = 10, r = 10, b = 10, l = 12)
  )

ggsave("figures/mean_chlorophyll_top15_spills.pdf", mean_chlorophyll_top15_spills,
       width = 12, height = 7, dpi = 300)
