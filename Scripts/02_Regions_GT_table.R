library(gt)
library(dplyr)

fires_cleaned_for_summary <- fires_with_regions %>%
  as.data.frame() %>%        # Converts it into a regular data frame
  select(-geometry)          # Remove the geometry column explicitly

TestData1 <- TestData1 %>%
  mutate(region = str_extract(region, "^[^ ]+"))  # Extract the first word

unique_regions <- unique(TestData1$region)
print(unique_regions)

# Creating sub-regions column
region_mapping <- c(
  "Autonomous" = "Crimea",
  "Cherkasy" = "Central Ukraine",
  "Chernihiv" = "North Ukraine",
  "Chernivtsi" = "West Ukraine",
  "Dnipropetrovsk" = "East Ukraine",
  "Donetsk" = "East Ukraine",
  "Ivano-Frankivsk" = "West Ukraine",
  "Kharkiv" = "East Ukraine",
  "Kherson" = "South Ukraine",
  "Khmelnytskyi" = "West Ukraine",
  "Kiev" = "North Ukraine",
  "Kirovohrad" = "Central Ukraine",
  "Luhansk" = "East Ukraine",
  "Lviv" = "West Ukraine",
  "Mykolaiv" = "South Ukraine",
  "Odessa" = "South Ukraine",
  "Poltava" = "Central Ukraine",
  "Rivne" = "West Ukraine",
  "Sumy" = "North Ukraine",
  "Ternopil" = "West Ukraine",
  "Vinnytsia" = "Central Ukraine",
  "Volyn" = "West Ukraine",
  "Zakarpattia" = "West Ukraine",
  "Zaporizhia" = "East Ukraine",
  "Zhytomyr" = "North Ukraine"
)

# Update the heatmap_data with new region names
TestData1 <- TestData1 %>%
  mutate(sub_region = recode(region, !!!region_mapping))  # Create new sub_region column

# Define the mapping for sub-regions and corresponding regions
region_mapping <- list(
  "North Ukraine" = c("Chernihiv", "Kiev", "Sumy", "Zhytomyr"),
  "South Ukraine" = c("Kherson", "Mykolaiv", "Odessa"),
  "East Ukraine" = c("Dnipropetrovsk", "Donetsk", "Kharkiv", "Luhansk", "Zaporizhia"),
  "West Ukraine" = c("Chernivtsi", "Cherkasy", "Ivano-Frankivsk", "Khmelnytskyi", 
                     "Lviv", "Poltava", "Rivne", "Ternopil", "Vinnytsia", 
                     "Volyn", "Zakarpattia")
)


# Define the selected regions
selected_regions <- c("Chernihiv", "Sumy", "Kharkiv", "Zaporizhia", "Kiev", "Kherson", "Chernivtsi", "Zakarpattia")

# Filter TestData1 for only the selected regions and exclude rows with NA in relevant columns
war_fires_summary <- TestData1 %>%
  filter(region %in% selected_regions) %>%
  group_by(region) %>%
  summarise(
    total_fires = n(),
    war_fires = sum(war_fire, na.rm = TRUE),
    fires_per_day = mean(fires_per_day, na.rm = TRUE),
    war_fires_per_day = mean(war_fires_per_day, na.rm = TRUE),
    war_fire_percentage = (sum(war_fire, na.rm = TRUE) / n()) * 100,
    avg_pop_density = mean(population_density, na.rm = TRUE),
    avg_sustained_excess = mean(sustained_excess_fires, na.rm = TRUE),
    sub_region = first(sub_region)  # Use the first occurrence of sub_region for each region
  )

# Arrange by sub_region so that regions are automatically grouped by area in the table
war_fires_summary <- war_fires_summary %>%
  arrange(sub_region, region)

# Display the table using gt
war_fires_summary %>%
  gt() %>%
  
  # Add title and subtitle to the table
  tab_header(
    title = "Summary of War-related Fires by Region",
    subtitle = "Including population density and sustained excess fire activity"
  ) %>%
  
  # Format specific columns to have 1 decimal place
  fmt_number(
    columns = c(war_fire_percentage, avg_pop_density, avg_sustained_excess, fires_per_day, war_fires_per_day),
    decimals = 1
  ) %>%
  
  # Rename columns for better readability in the table
  cols_label(
    region = "Region",
    total_fires = "Total Fires",
    war_fires = "War Fires",
    war_fire_percentage = "War Fires (%)",
    avg_pop_density = "Avg. Pop Density",
    avg_sustained_excess = "Avg. Sustained Fire",
    fires_per_day = "Avg. Daily Fires",
    war_fires_per_day = "Avg. Daily War Fires",
    sub_region = "Area"
  ) %>%
  
  # Customize table options for font sizes and alignment
  tab_options(
    table.font.size = px(14),               # Font size for table content
    column_labels.font.size = px(16),       # Font size for column labels
    table.width = pct(100),                 # Set table width to 100% of available space
    heading.title.font.size = px(20),       # Font size for title
    heading.subtitle.font.size = px(16),    # Font size for subtitle
    heading.align = "center"                # Center-align the title and subtitle
  ) %>%
  
  # Apply row striping (alternate row coloring) with light gray color
  tab_style(
    style = cell_fill(color = "lightgray"),
    locations = cells_body(rows = seq(1, nrow(war_fires_summary), 2))  # Apply to every other row (odd rows)
  ) %>%
  
  # Add an outline around the entire table
  opt_table_outline() %>%
  
  # Apply color gradient to the "War Fires (%)" column for visual emphasis
  data_color(
    columns = vars(war_fire_percentage),
    colors = scales::col_numeric(
      palette = c("white", "lightgrey", "lightcoral", "red"),  # Color gradient from white to red
      domain = c(0, max(war_fires_summary$war_fire_percentage, na.rm = TRUE))  # Scale from 0 to max percentage
    )
  ) %>%
  
  # Add a bold vertical border to separate the "War Fires (%)" column
  tab_style(
    style = cell_borders(sides = "left", color = "black", weight = px(2)),
    locations = cells_body(columns = vars(war_fire_percentage))
  ) %>%
  
  # Highlight the "Area" column with a light blue background for visual separation
  tab_style(
    style = cell_fill(color = "lightblue"),
    locations = cells_body(columns = vars(sub_region))
  ) %>%
  
  # Set a light gray border around all table cells for a cleaner look
  tab_style(
    style = cell_borders(sides = "all", color = "gray", weight = px(1)),
    locations = cells_body()
  ) %>%
  
  # Add a footnote for the "War Fires (%)" column
  tab_footnote(
    footnote = "War fire percentage is based on total fires in each region.",
    locations = cells_column_labels(columns = vars(war_fire_percentage))
  ) %>%
  
  # Add a footnote for the "Avg. Sustained Fire" column
  tab_footnote(
    footnote = "Sustained fire-activity beyond prediction.",
    locations = cells_column_labels(columns = vars(avg_sustained_excess))
  )

