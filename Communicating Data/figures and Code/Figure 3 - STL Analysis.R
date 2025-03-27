# Load libraries
library(terra)
library(sf)
library(dplyr)
library(lubridate)
library(stringr)

# Set path to NetCDF files
nc_folder <- "C:/Users/james/OneDrive/Documents/Communicating Data/Essay/choloro/requested_files 2"
nc_files <- list.files(path = nc_folder, pattern = "\\.nc$", full.names = TRUE)

# Extract start dates from filenames
dates <- nc_files %>%
  basename() %>%
  str_extract("\\d{8}(?=_)") %>%
  as.Date(format = "%Y%m%d")

zones_vect <- list(
  DWH_Core = vect(zone_a),
  DWH_Wide = vect(zone_b),
  Control = vect(zone_c)
)

# Initialise empty list to store results
zone_ts_list <- list(DWH_Core = numeric(), DWH_Wide = numeric(), Control = numeric())

for (i in seq_along(nc_files)) {
  r <- rast(nc_files[i])  # Load 1-month raster
  
  # Extract zonal means
  for (zone_name in names(zones_vect)) {
    mean_val <- terra::extract(r, zones_vect[[zone_name]], fun = mean, na.rm = TRUE)[1, 2]  # second column is data
    zone_ts_list[[zone_name]] <- c(zone_ts_list[[zone_name]], mean_val)
  }
}

chl_ts_df <- data.frame(
  date = dates,
  DWH_Core = zone_ts_list$DWH_Core,
  DWH_Wide = zone_ts_list$DWH_Wide,
  Control = zone_ts_list$Control
) %>%
  arrange(date) %>%
  mutate(
    log_DWH_Core = log10(DWH_Core + 1e-5),
    log_DWH_Wide = log10(DWH_Wide + 1e-5),
    log_Control = log10(Control + 1e-5)
  )

library(ggplot2)
library(forecast)
library(dplyr)
library(scales)
library(patchwork)

plot_stl_report <- function(df, zone_label, spill_start = as.Date("2010-04-01"), spill_end = as.Date("2014-12-31")) {
  df <- df %>% 
    filter(!is.na(log_chlor_a)) %>%
    arrange(date)
  
  # Create time series object
  ts_data <- ts(df$log_chlor_a, start = c(year(min(df$date)), month(min(df$date))), frequency = 12)
  stl_result <- stl(ts_data, s.window = "periodic")
  
  # Build data frame for plotting
  stl_df <- data.frame(
    date = seq.Date(from = min(df$date), by = "month", length.out = length(ts_data)),
    observed = rowSums(stl_result$time.series),
    trend = stl_result$time.series[, "trend"],
    seasonal = stl_result$time.series[, "seasonal"],
    remainder = stl_result$time.series[, "remainder"]
  )
  
  # Aesthetic base
  base_theme <- theme_minimal(base_size = 12) +
    theme(axis.title.x = element_blank(),
          axis.text.x = element_text(angle = 45, hjust = 1),
          plot.title = element_text(size = 14, face = "bold"),
          strip.text = element_text(size = 12, face = "bold"))
  
  highlight_spill <- geom_rect(aes(xmin = spill_start, xmax = spill_end, ymin = -Inf, ymax = Inf),
                               fill = "grey90", alpha = 0.5, inherit.aes = FALSE)
  
  g1 <- ggplot(stl_df, aes(x = date, y = observed)) +
    highlight_spill +
    geom_line(size = 0.7) +
    labs(title = "Observed (log-transformed)", y = "log(Chl-a)") +
    base_theme
  
  g2 <- ggplot(stl_df, aes(x = date, y = trend)) +
    highlight_spill +
    geom_line(color = "firebrick", size = 0.7) +
    labs(title = "Trend", y = "") +
    base_theme
  
  g3 <- ggplot(stl_df, aes(x = date, y = seasonal)) +
    highlight_spill +
    geom_line(color = "dodgerblue4", size = 0.7) +
    labs(title = "Seasonal Component", y = "") +
    base_theme
  
  g4 <- ggplot(stl_df, aes(x = date, y = remainder)) +
    highlight_spill +
    geom_hline(yintercept = 0, linetype = "dashed", colour = "grey30") +
    geom_line(color = "darkgreen", size = 0.7) +
    labs(title = "Residual (Anomaly)", x = "Date", y = "") +
    base_theme
  
  # Combine
  full_plot <- (g1 / g2 / g3 / g4) +
    plot_annotation(
      title = paste0("STL Decomposition of Chlorophyll-a – ", zone_label),
      subtitle = "Shaded region indicates Deepwater Horizon impact window (2010–2014)",
      theme = theme(plot.title = element_text(size = 16, face = "bold"))
    )
  
  return(full_plot)
}

# Create single-zone dataframe for plotting
core_df <- chl_ts_df %>%
  select(date, log_chlor_a = log_DWH_Core)

# Generate the professional STL plot
stl_plot_core <- plot_stl_report(df = core_df, zone_label = "DWH Core Zone")

# Save it
ggsave("fig_stl_core.pdf", stl_plot_core, width = 10, height = 8)

####################

# Create single-zone dataframe for plotting
wide_df <- chl_ts_df %>%
  select(date, log_chlor_a = log_DWH_Wide)

# Generate the professional STL plot
stl_plot_wide <- plot_stl_report(df = wide_df, zone_label = "DWH Wide Zone")

# Save it
ggsave("fig_stl_Wide.pdf", stl_plot_wide, width = 10, height = 8)

####################

# Create single-zone dataframe for plotting
control_df <- chl_ts_df %>%
  select(date, log_chlor_a = log_Control)

# Generate the professional STL plot
stl_plot_control <- plot_stl_report(df = control_df, zone_label = "DWH Control Zone")

# Save it
ggsave("fig_stl_Control.pdf", stl_plot_Control, width = 10, height = 8)
