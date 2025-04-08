# Load and plot the data
load("~/GitHub/university-projects/Modelling in Space and Time/In progress/MOC.RData")


# --- Convert MOCmean to a tidy data frame ---
library(tidyverse)
library(lubridate)
library(ggplot2)
# Extract names and values
moc_values <- as.numeric(MOCmean)
moc_dates <- names(MOCmean)

# Fix formatting of date strings    
moc_dates_fixed <- ifelse(nchar(moc_dates) == 6,
                          paste0(substr(moc_dates, 1, 5), "0", substr(moc_dates, 6, 6)),
                          moc_dates)

# Convert to actual Date objects (use first of each month)
moc_dates_parsed <- ym(moc_dates_fixed)

# Create tidy tibble
moc_df <- tibble(
  date = moc_dates_parsed,
  amoc = moc_values
) %>% arrange(date)

# --- Plot ---
library(ggplot2)

ggplot(moc_df, aes(x = date, y = amoc)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_smooth(method = "loess", span = 0.2, se = TRUE, color = "darkred", linetype = "dashed") +
  labs(
    title = "Atlantic Meridional Overturning Circulation (AMOC) at 26°N",
    subtitle = "Monthly Mean Values from October 2017 to February 2023",
    x = "Date",
    y = "AMOC Strength (Sv)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  scale_x_date(date_breaks = "4 months", date_labels = "%b %Y") +
  geom_point(size = 1.5, alpha = 0.7)
