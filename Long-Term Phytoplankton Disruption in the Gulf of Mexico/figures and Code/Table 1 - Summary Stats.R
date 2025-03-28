# Function to extract STL residuals and compute summary stats
summarise_stl_residuals <- function(df, label) {
  ts_data <- ts(df$log_chlor_a, start = c(year(min(df$date)), month(min(df$date))), frequency = 12)
  stl_result <- stl(ts_data, s.window = "periodic")
  
  stl_df <- data.frame(
    date = seq.Date(from = min(df$date), by = "month", length.out = length(ts_data)),
    remainder = stl_result$time.series[, "remainder"]
  ) %>%
    mutate(
      period = case_when(
        date < as.Date("2010-01-01") ~ "Pre-Spill (2002–2009)",
        date >= as.Date("2010-01-01") & date <= as.Date("2014-12-31") ~ "Spill Impact (2010–2014)",
        date >= as.Date("2015-01-01") ~ "Post-2015 Recovery"
      )
    ) %>%
    group_by(period) %>%
    summarise(
      `Mean Residual` = mean(remainder, na.rm = TRUE),
      `SD Residual` = sd(remainder, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(Zone = label)
  
  return(stl_df)
}

# Construct input data frames for each zone
core_df <- chl_ts_df %>% select(date, log_chlor_a = log_DWH_Core)
wide_df <- chl_ts_df %>% select(date, log_chlor_a = log_DWH_Wide)
control_df <- chl_ts_df %>% select(date, log_chlor_a = log_Control)

# Run summaries
summary_core <- summarise_stl_residuals(core_df, "DWH Core")
summary_wide <- summarise_stl_residuals(wide_df, "DWH Wide")
summary_control <- summarise_stl_residuals(control_df, "Control")

# Combine all
stl_summary_all <- bind_rows(summary_core, summary_wide, summary_control) %>%
  relocate(Zone, .before = period) %>%
  arrange(Zone, period)


library(gt)

gt_table <- stl_summary_all %>%
  mutate(
    `Mean Residual` = round(`Mean Residual`, 3),
    `SD Residual` = round(`SD Residual`, 3)
  ) %>%
  gt() %>%
  tab_header(
    title = md("**STL Residual Summary by Zone and Time Period**"),
    subtitle = "Mean and standard deviation of STL residuals (log-transformed chlorophyll-a)"
  ) %>%
  fmt_number(columns = where(is.numeric), decimals = 3) %>%
  cols_label(
    Zone = "Zone",
    period = "Period",
    `Mean Residual` = "Mean Residual",
    `SD Residual` = "SD Residual"
  ) %>%
  tab_options(
    table.font.names = "Arial",
    heading.title.font.size = 14,
    heading.subtitle.font.size = 12,
    table.font.size = 12,
    data_row.padding = px(5)
  )
gt_table


gtsave(gt_table, filename = "figures/gt_table.png")
