library(mgcv)
library(tidyverse)

# Extract smooth terms from the GAM model (gam_model_tw)
smooth_terms <- plot(gam_model_tw, pages = 1, all.terms = TRUE, shade = TRUE, seWithMean = TRUE)

# Data frame to store all covariates smooth predictions
smooth_plot_data <- map_dfr(1:length(smooth_terms), function(i) {
  data.frame(
    Covariate = smooth_terms[[i]]$xlab,
    x = smooth_terms[[i]]$x,
    fit = smooth_terms[[i]]$fit,
    se = smooth_terms[[i]]$se
  )
})

# Compute confidence intervals
smooth_plot_data <- smooth_plot_data %>%
  mutate(lower_CI = fit - 1.96 * se,
         upper_CI = fit + 1.96 * se)

# Define clear and informative facet labels
facet_labels <- c(
  "s(Urbanisation)" = "Urbanisation (%)",
  "s(Density)" = "Dwelling Density (Dwellers/Room)",
  "s(Unemployment)" = "Unemployment (%)",
  "s(Poor_Sanitation)" = "Poor Sanitation (Higher = Worse)",
  "s(Poverty)" = "Poverty (%)",
  "s(Timeliness)" = "TB Notification Delay (Days)",
  "s(lon,lat)" = "Spatial Effect (Longitude & Latitude)"
)

# Filter out the 2-dimensional smooth (lon,lat), which needs separate treatment
smooth_plot_data_filtered <- smooth_plot_data %>%
  filter(Covariate != "s(lon,lat)")

# Plot using ggplot
ggplot(smooth_plot_data_filtered, aes(x = x, y = fit)) +
  geom_line(color = "darkblue", linewidth = 1.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  geom_ribbon(aes(ymin = lower_CI, ymax = upper_CI), alpha = 0.3, fill = "blue") +
  facet_wrap(~ Covariate, scales = "free_x", labeller = labeller(Covariate = facet_labels), ncol = 2) +
  labs(title = "Partial Effects of Socio-Economic Covariates on TB Risk",
       subtitle = "Estimated smooth terms with 95% confidence intervals",
       x = "Covariate Value",
       y = "Partial Effect (log-scale)",
       caption = "Positive values indicate increased risk; negative values indicate decreased risk.") +
  theme_bw(base_size = 14) +
  theme(
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 14, hjust = 0.5),
    strip.text = element_text(size = 16, face = "bold"),
    axis.title = element_text(size = 14),
    panel.spacing = unit(1, "lines")
  )



# Spatial Structure

plot.map <- function(x, Q, main = "", cex = 1, decimals = 2, palette = rev(hcl.colors(length(Q)-1, palette = "inferno"))) {
  n.levels <- length(Q) - 1
  cols <- palette  # directly use provided palette (already a vector of colours)
  n <- length(x)
  
  # Assign colours based on quantiles
  col <- rep(cols[1], n)
  for(i in 2:n.levels) {
    col[x >= Q[i] & x < Q[i + 1]] <- cols[i]
  }
  col[x >= Q[n.levels + 1]] <- cols[n.levels]
  
  # Format legend with clear control over decimal points
  legend.names <- c()
  for(i in 1:n.levels) {
    legend.names[i] <- paste0("[", round(Q[i], decimals), ", ", round(Q[i + 1], decimals), "]")
  }
  
  # Plotting clearly
  plot(brasil_micro, col = col, main = main, border = NA)
  legend('bottomright', legend = legend.names, fill = cols, cex = cex, title = "TB Rate")
}


# Generate predicted TB cases from the GAM
TBdata$predicted_cases <- predict(gam_model_tw, type = "response")

# Convert to TB rate per 100,000 population
TBdata$predicted_rate <- (TBdata$predicted_cases / TBdata$Population) * 100000

# Define quantiles clearly for legend (7 levels)
quantiles <- quantile(TBdata$predicted_rate, probs = seq(0, 1, length.out = 10))

# Define inverted inferno palette explicitly
my_palette <- rev(hcl.colors(length(quantiles)-1, palette = "inferno"))

# Plot with smaller legend size clearly
plot.map(x = TBdata$predicted_rate,
         Q = quantiles,
         main = "Spatial Structure of Predicted TB Risk (per 100,000 population)",
         cex = 1, 
         decimals = 2,
         palette = my_palette)



#####
# Spatial Temporal

TBdata$predicted_cases_sp <- predict(gam_model_SP, type = "response")

par(mfrow = c(3, 1))  # Arrange plots side by side for comparison

years <- c("2012", "2013", "2014")

# Define common quantiles for all years to keep the scale consistent
quantiles <- quantile(TBdata$predicted_rate_sp, probs = seq(0, 1, length.out = 8), na.rm = TRUE)

# Loop through each year and plot it clearly
for (year in years) {
  
  plot.map(
    x = TBdata$predicted_rate_sp[TBdata$Year == year],  # Filter TB rates for the year
    Q = quantiles,
    main = paste("Predicted TB Risk (per 100,000) - Year", year),
    cex = 1, 
    decimals = 2,
    palette = my_palette  # Uses the same colour scheme for all years
  )
}



#######
# Table showing critical regions:

library(dplyr)
library(gt)

# ✅ Step 1: Prepare Data
TBdata_new <- TBdata %>%
  dplyr::select(Region, Year, Indigenous, Illiteracy, Urbanisation, 
                Density, Poverty, Poor_Sanitation, Unemployment, Population, Timeliness, lon, lat) %>%
  mutate(Predicted_TB = predict(gam_model_tw, newdata = ., type = "response"),
         Predicted_TB_Scaled = (Predicted_TB / Population) * 100000)  # Scale to per 100,000 population

# ✅ Step 2: Compute Dynamic Threshold (Top 10% Each Year)
high_risk_threshold <- TBdata_new %>%
  group_by(Year) %>%
  summarise(Dynamic_Threshold = quantile(Predicted_TB_Scaled, 0.90, na.rm = TRUE), .groups = "drop")

# ✅ Step 3: Define Fixed Threshold
fixed_threshold <- 40  # Fixed high-risk threshold (40 per 100,000)

# ✅ Step 4: Count High-Risk Regions Exceeding Fixed Threshold
high_risk_regions_fixed <- TBdata_new %>%
  filter(Predicted_TB_Scaled > fixed_threshold) %>%
  group_by(Year) %>%
  summarise(Total_High_Risk_Regions = n(), .groups = "drop")

# ✅ Step 5: Identify the 3 Highest-Risk Regions Each Year
top_high_risk_regions <- TBdata_new %>%
  group_by(Year) %>%
  arrange(desc(Predicted_TB_Scaled)) %>%
  slice_head(n = 3) %>%
  summarise(Highest_Risk_Regions = paste(Region, collapse = ", "), .groups = "drop")

# ✅ Step 6: Merge Data into a Single Table
high_risk_summary <- high_risk_regions_fixed %>%
  left_join(high_risk_threshold, by = "Year") %>%
  left_join(top_high_risk_regions, by = "Year") %>%
  mutate(Dynamic_Threshold = round(Dynamic_Threshold, 2))  # Round for readability

# ✅ Step 7: Format & Style GT Table
high_risk_summary %>%
  gt() %>%
  tab_header(
    title = md("**High-Risk TB Regions Over Time**"),
    subtitle = "Regions exceeding fixed and dynamic TB rate thresholds"
  ) %>%
  fmt_number(columns = c(Total_High_Risk_Regions, Dynamic_Threshold), decimals = 2) %>%
  cols_label(
    Year = "Year",
    Total_High_Risk_Regions = "Regions Above Fixed Threshold (40 per 100k)",
    Dynamic_Threshold = "Top 10% Threshold",
    Highest_Risk_Regions = "Top 3 Highest-Risk Regions"
  ) %>%
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_column_labels(everything())
  ) %>%
  tab_options(
    table.font.size = 13,
    column_labels.font.size = 13,
    column_labels.font.weight = "bold",
    heading.align = "center",
    row.striping.include_table_body = TRUE,
    data_row.padding = px(10),
    table.border.top.width = px(2),
    table.border.bottom.width = px(2),
    table.border.bottom.color = "black",
    table.border.top.color = "black",
    table.width = pct(100)
  ) %>%
  tab_caption("Table: Summary of High-Risk TB Regions Over Time")
