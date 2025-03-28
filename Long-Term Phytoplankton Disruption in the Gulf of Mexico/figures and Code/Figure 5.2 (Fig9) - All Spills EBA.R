library(readr)
library(dplyr)
library(lubridate)

# Load and clean spill metadata
spill_df <- read_csv("incidents.csv") %>%
  filter(!is.na(lat), !is.na(lon), !is.na(open_date), threat == "Oil") %>%
  mutate(open_date = dmy(open_date)) %>%
  select(id, open_date, lat, lon, name) %>%
  arrange(open_date)

library(terra)
library(stringr)

nc_folder <- "C:/Users/james/OneDrive/Documents/Communicating Data/Essay/choloro/requested_files 2"
nc_files <- list.files(path = nc_folder, pattern = "\\.nc$", full.names = TRUE)

# Extract dates from filenames
dates <- basename(nc_files) %>%
  str_extract("\\d{8}(?=_)") %>%
  as.Date(format = "%Y%m%d")

# Load individual layers and assign names
chl_list <- lapply(seq_along(nc_files), function(i) {
  r <- rast(nc_files[i])
  names(r) <- format(dates[i], "%Y-%m-%d")  # Tag layer with date
  return(r)
})

# Combine into one SpatRaster
chl_stack <- rast(chl_list)



# Recalculate layer indices for 2010–2014 in the 270-month sequence
spill_window_idx <- which(dates >= as.Date("2010-01-01") & dates <= as.Date("2014-12-31"))

# Define relative month range
month_window <- -48:48  # ±4 years
n_months <- length(month_window)



# Function to extract time series around one spill
extract_chl_ts <- function(event_id, lat, lon, date, month_window, chl_stack, dates) {
  ts_df <- data.frame()
  
  for (i in seq_along(month_window)) {
    # Target date for this step
    target_date <- date %m+% months(month_window[i])
    
    # Find closest date in stack
    date_idx <- which.min(abs(dates - target_date))
    if (length(date_idx) == 0 || is.na(date_idx)) next
    
    # Extract raster value at that point
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

# Apply across all spills
all_chl_ts <- purrr::pmap_dfr(
  list(spill_df$id, spill_df$lat, spill_df$lon, spill_df$open_date),
  extract_chl_ts,
  month_window = month_window,
  chl_stack = chl_stack,
  dates = dates
)

library(ggplot2)
library(dplyr)

# Aggregate: mean and confidence interval by relative month
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

# Plot: chlorophyll before and after spills
mean_chlorophyll_all_spills<- ggplot(chl_summary, aes(x = month_relative, y = mean_chl)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "skyblue", alpha = 0.3) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "red") +
  labs(
    title = "Mean Chlorophyll-a Response Aligned to Oil Spill Events",
    subtitle = "±4 years around 127 Gulf oil spills (2002–2025)",
    x = "Months Since Spill",
    y = expression("Chlorophyll-a (mg·m"^-3*")")
  )+
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
ggsave("figures/mean_chlorophyll_all_spills.pdf", width = 14, height = 8, dpi = 300)


