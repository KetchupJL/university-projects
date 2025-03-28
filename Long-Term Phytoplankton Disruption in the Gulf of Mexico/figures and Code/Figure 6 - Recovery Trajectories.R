# Ensure libraries are loaded
library(dplyr)
library(forecast)
library(ggplot2)
library(lubridate)

# Generate STL for each zone
stl_result_core <- stl(ts(core_df$log_chlor_a, start = c(year(min(core_df$date)), month(min(core_df$date))), frequency = 12), s.window = "periodic")
stl_result_wide <- stl(ts(wide_df$log_chlor_a, start = c(year(min(wide_df$date)), month(min(wide_df$date))), frequency = 12), s.window = "periodic")
stl_result_control <- stl(ts(Control_df$log_chlor_a, start = c(year(min(Control_df$date)), month(min(Control_df$date))), frequency = 12), s.window = "periodic")

trend_df <- bind_rows(
  tibble(
    Date = core_df$date,
    Trend = stl_result_core$time.series[, "trend"],
    Zone = "DWH Core"
  ),
  tibble(
    Date = wide_df$date,
    Trend = stl_result_wide$time.series[, "trend"],
    Zone = "DWH Wide"
  ),
  tibble(
    Date = Control_df$date,
    Trend = stl_result_control$time.series[, "trend"],
    Zone = "Offshore Control"
  )
) %>%
  filter(Date >= as.Date("2010-01-01"))


library(dplyr)
library(forecast)
library(tibble)
library(lubridate)

zones <- c("log_DWH_Core", "log_DWH_Wide", "log_Control")
labels <- c("DWH Core", "DWH Wide", "Offshore Control")

# Initialise list
trend_list <- list()

for (i in seq_along(zones)) {
  z_col <- zones[i]
  z_name <- labels[i]
  
  temp_df <- chl_ts_df %>%
    select(Date = date, log_chlor_a = !!sym(z_col)) %>%
    filter(!is.na(log_chlor_a)) %>%
    arrange(Date)
  
  ts_data <- ts(temp_df$log_chlor_a, start = c(year(min(temp_df$Date)), month(min(temp_df$Date))), frequency = 12)
  stl_result <- stl(ts_data, s.window = "periodic")
  
  trend_list[[z_name]] <- tibble(
    Date = seq.Date(from = min(temp_df$Date), by = "month", length.out = length(ts_data)),
    Trend = stl_result$time.series[, "trend"],
    Zone = z_name
  )
}

# Combine into full data frame
trend_df <- bind_rows(trend_list)

baseline_means <- trend_df %>%
  filter(Date < as.Date("2010-01-01")) %>%
  group_by(Zone) %>%
  summarise(baseline = mean(Trend, na.rm = TRUE))

trend_df <- left_join(trend_df, baseline_means, by = "Zone")

ggplot(trend_df, aes(x = Date, y = Trend)) +
  geom_rect(
    aes(xmin = as.Date("2010-04-20"), xmax = as.Date("2010-07-15"),
        ymin = -Inf, ymax = Inf),
    fill = "red", alpha = 0.08, inherit.aes = FALSE
  ) +
  geom_hline(aes(yintercept = baseline), linetype = "dashed", colour = "darkgrey") +
  geom_line(color = "black", size = 0.6) +
  geom_smooth(method = "loess", se = FALSE, colour = "steelblue", size = 0.9, linetype = "dotted") +
  facet_wrap(~ Zone, ncol = 1, scales = "free_y") +
  labs(
    title = "Recovery of Phytoplankton Trends Post-Deepwater Horizon",
    subtitle = "STL-derived trend components (log-transformed chlorophyll-a), with pre-spill baseline reference",
    x = "Date",
    y = "STL Trend (log₁₀ chlorophyll-a)",
    caption = "Dashed grey line: Pre-2010 baseline. Red shading: DWH spill period (Apr–Jul 2010). Blue dotted line: LOESS smooth of STL trend."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    strip.text = element_text(size = 12, face = "bold"),
    panel.spacing = unit(1.2, "lines"),
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11.5)
  )
ggsave("figures/recovery.pdf", width = 14, height = 10, dpi = 300)






# Fit trend slopes post-spill
library(broom)

trend_slopes <- trend_df %>%
  filter(Date >= as.Date("2011-01-01"), Date <= as.Date("2014-12-31")) %>%
  group_by(Zone) %>%
  do(tidy(lm(Trend ~ as.numeric(Date), data = .))) %>%
  filter(term == "as.numeric(Date)")

print(trend_slopes)

trend_slope_table <- data.frame(
  Zone = c("DWH Core", "DWH Wide", "Offshore Control"),
  Slope = c(1.93e-4, -2.07e-4, 4.13e-4),
  p_value = c(0.636, 0.180, 0.002)
)

# Format and display the table
trend_slope_table %>%
  gt() %>%
  tab_header(
    title = md("**Post-Spill Trend Slopes (2011–2014)**"),
    subtitle = md("Linear slopes fitted to STL-derived chlorophyll-a trend components")
  ) %>%
  fmt_scientific(
    columns = c(Slope),
    decimals = 2
  ) %>%
  fmt_number(
    columns = c(p_value),
    decimals = 3
  ) %>%
  cols_label(
    Zone = "Zone",
    Slope = "Trend Slope (β)",
    p_value = "*p*-value"
  ) %>%
  tab_options(
    table.font.size = 12,
    heading.title.font.size = 14,
    heading.subtitle.font.size = 12,
    data_row.padding = px(4)
  )
