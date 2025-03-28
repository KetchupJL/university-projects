library(terra)
library(stringr)
library(lubridate)
library(dplyr)

# Step 1: Load and stack all monthly chlorophyll-a rasters
nc_folder <- "C:/Users/james/OneDrive/Documents/Communicating Data/Essay/choloro/requested_files 2"
nc_files <- list.files(path = nc_folder, pattern = "\\.nc$", full.names = TRUE)

# Extract dates from filenames
dates <- basename(nc_files) %>%
  str_extract("\\d{8}(?=_)") %>%
  as.Date(format = "%Y%m%d")

# Stack rasters in time order
chl_stack <- rast(nc_files[order(dates)])
dates <- dates[order(dates)]  # match order


# Recalculate layer indices for 2010–2014 in the 270-month sequence
spill_window_idx <- which(dates >= as.Date("2010-01-01") & dates <= as.Date("2014-12-31"))



get_stl_residual_mean <- function(x) {
  if (sum(is.na(x)) > 0.2 * length(x)) return(NA)  # too sparse
  ts_data <- try(ts(log10(x + 1e-5), start = c(2002, 8), frequency = 12), silent = TRUE)
  if (inherits(ts_data, "try-error")) return(NA)
  
  stl_out <- try(stl(ts_data, s.window = "periodic"), silent = TRUE)
  if (inherits(stl_out, "try-error")) return(NA)
  
  resids <- stl_out$time.series[, "remainder"]
  mean(resids[spill_window_idx], na.rm = TRUE)
}


# Optional: Crop to focus region (saves compute)
zone_bbox <- ext(-92, -85, 25, 30)  # adjust as needed (Texas–Mississippi shelf)
chl_crop <- crop(chl_stack, zone_bbox)

# Apply STL per pixel — use terra::app
chl_resid_mean_2010_14 <- app(chl_crop, fun = get_stl_residual_mean)

# Save output
writeRaster(chl_resid_mean_2010_14, "figures/stl_residual_mean_2010_14.tif", overwrite = TRUE)
