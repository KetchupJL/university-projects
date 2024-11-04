######################## Creating main analysis visualisations

#1. Heatmaps of Predicted Probabilities by Region and Season
# Load libraries
library(lme4)
library(dplyr)
library(ggplot2)
library(stringr)
library(tidyr)
library(ploty)

# Get predicted probabilities
TestData1$predicted_probability <- predict(hlm_model_random_slopes, newdata = TestData1, re.form = NULL, allow.new.levels = TRUE, type = "response")

# Prepare data for heatmap
heatmap_data <- TestData1 %>%
  select( -geometry, -path) %>%
  group_by(region, season) %>%
  summarise(predicted_probability = mean(predicted_probability, na.rm = TRUE)) %>%
  ungroup()

# Editing Region names for aesthetic
heatmap_data <- heatmap_data %>%
  mutate(region = str_extract(region, "^[^ ]+"))  # Extract the first word

unique_regions <- unique(heatmap_data$region)
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

# Add sub-region information using case_when for multiple region matches
heatmap_data <- heatmap_data %>%
  mutate(sub_region = case_when(
    region %in% c("Chernihiv", "Kiev", "Sumy", "Zhytomyr") ~ "North Ukraine",
    region %in% c("Kherson", "Mykolaiv", "Odessa") ~ "South Ukraine",
    region %in% c("Dnipropetrovsk", "Donetsk", "Kharkiv", "Luhansk", "Zaporizhia") ~ "East Ukraine",
    region %in% c("Chernivtsi", "Cherkasy", "Ivano-Frankivsk", "Khmelnytskyi", 
                  "Lviv", "Poltava", "Rivne", "Ternopil", "Vinnytsia", 
                  "Volyn", "Zakarpattia") ~ "West Ukraine",
    region == "Autonomous" ~ "Crimea",
    region %in% c("Kirovohrad", "Poltava", "Vinnytsia") ~ "Central Ukraine",
    TRUE ~ NA_character_  # Assign NA if the region does not match any specified condition

# Step 1: Remove rows with NA in the predicted_probability column
heatmap_data <- heatmap_data %>%
  filter(!is.na(predicted_probability)) %>%  # Exclude rows where predicted_probability is NA
  arrange(sub_region, predicted_probability)  # Order by sub-region and probability for a cleaner look

# Step 2: Create the heatmap plot with consistent formatting
heatmap_plot <- ggplot(heatmap_data, aes(x = season, y = reorder(region, predicted_probability), fill = predicted_probability)) +
  
  # Create tiles for each region-season combination and add detailed tooltips
  geom_tile(color = "white", aes(text = paste("Region:", region, "<br>",
                                              "Sub-region:", sub_region, "<br>",
                                              "Predicted Probability:", round(predicted_probability, 2)))) +
  
  # Enhanced color gradient
  scale_fill_gradientn(colors = c("lightblue", "yellow", "orange", "darkred"), na.value = "grey50") +
  
  # Add titles, axis labels, and legend title
  labs(
    title = "Predicted Probabilities of War-related Fires",
    subtitle = "Seasonal average probability by region in Ukraine",
    x = "Season",
    y = "Region",
    fill = "Predicted Probability"
  ) +
  
  # Consistent theme settings for Arial font
  theme_minimal() +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5, family = "Arial"),
    plot.subtitle = element_text(size = 14, hjust = 0.5, family = "Arial"),
    axis.title.x = element_text(size = 14, family = "Arial"),  # Increased font size for readability
    axis.title.y = element_text(size = 14, family = "Arial"),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10, family = "Arial"),
    axis.text.y = element_text(size = 10, face = "bold", family = "Arial"),
    legend.title = element_text(size = 12, face = "bold", family = "Arial"),
    legend.text = element_text(size = 10, family = "Arial"),
    legend.key.width = unit(0.5, "cm"),
    legend.key.height = unit(2, "cm"),
    legend.position = "right",
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  
  # Add annotations with larger font size for better visibility
  annotate("text", x = "Autumn", y = "Luhansk", label = "High Probability", color = "black", size = 4, hjust = 0, family = "Arial", fontface = "bold") +
  annotate("text", x = "Summer", y = "Zaporizhia", label = "High Activity", color = "black", size = 4, hjust = 0, family = "Arial", fontface = "bold")

# Convert ggplot to an interactive plotly plot
interactive_heatmap <- ggplotly(heatmap_plot, tooltip = "text")

# Display the interactive plot
interactive_heatmap


###############################################################################################
###############################################################################################
###############################################################################################

#2.	Seasonal Trend Plot with War-related and Non-War-related Fires over time 


# Creating new data
fires_daily_agg <- fires_with_regions %>%
  group_by(date, season) %>%
  summarise(
    fires_per_day = mean(fires_per_day, na.rm = TRUE),
    war_fires_per_day = mean(war_fires_per_day, na.rm = TRUE),
    .groups = 'drop'  # Prevent warnings about grouping
  )

fires_daily_agg <- fires_daily_agg %>%
  mutate(
    year = year(date),              # Extract the year from the date
    month = month(date, label = TRUE, abbr = TRUE))  # Extract month names
    
    # Create a seasonal indicator column
    fires_daily_agg <- fires_daily_agg %>%
      mutate(season = case_when(
        month(date) %in% c(12, 1, 2) ~ "Winter",
        month(date) %in% c(3, 4, 5) ~ "Spring",
        month(date) %in% c(6, 7, 8) ~ "Summer",
        month(date) %in% c(9, 10, 11) ~ "Autumn",
        TRUE ~ "Unknown"))

    write.csv(fires_daily_agg, "C:/Users/james/OneDrive/Documents/Working With Data (MTHM501/Ukraine War-Fires - MTHM501 Project/Data/fires_daily_agg.csv", row.names = FALSE)
 
    # Load required libraries
    library(ggplot2)
    library(gridExtra)
    library(lubridate)
    library(dplyr)
    library(grid)
    
    # Define colors for seasons for enhanced clarity
    season_colors <- c("Winter" = "#1f77b4", "Spring" = "#2ca02c", "Summer" = "#ff7f0e", "Autumn" = "#d62728")
    
    # Ensure fires_daily_agg has seasons labeled appropriately
    fires_daily_agg <- fires_daily_agg %>%
      mutate(
        season = case_when(
          month(date) %in% c(12, 1, 2) ~ "Winter",
          month(date) %in% c(3, 4, 5) ~ "Spring",
          month(date) %in% c(6, 7, 8) ~ "Summer",
          month(date) %in% c(9, 10, 11) ~ "Autumn",
          TRUE ~ NA_character_
        )
      )
    
    # Create the first plot with the legend included
    plot_with_legend <- ggplot(fires_daily_agg %>% filter(year == 2022), aes(x = date, y = war_fires_per_day, fill = season)) +
      geom_bar(stat = "identity", width = 0.6, color = "black", alpha = 0.8) +
      scale_fill_manual(values = season_colors, guide = guide_legend(direction = "horizontal")) +  # Set legend to horizontal
      labs(subtitle = "War-related Fires per Day - 2022", y = "War Fires per Day") +
      ylim(0, 5000)+
      theme_minimal(base_family = "Arial") +
      theme(
        plot.subtitle = element_text(hjust = 0.5, size = 14, face = "bold"),
        axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
        axis.text.y = element_text(size = 10),
        axis.title.y = element_text(size = 12, face = "bold"),
        panel.grid.major.x = element_line(color = "grey80", linetype = "dotted", size = 0.5),
        panel.grid.major.y = element_line(color = "grey85"),
        panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "#f9f9f9"),
        legend.position = "top"  # Place the legend at the top
      )
    
    # Generate the remaining plots without the legend
    plot_list <- lapply(setdiff(unique(fires_daily_agg$year), 2022), function(y) {
      ggplot(fires_daily_agg %>% filter(year == y), aes(x = date, y = war_fires_per_day, fill = season)) +
        geom_bar(stat = "identity", width = 0.6, color = "black", alpha = 0.8, show.legend = FALSE) +  # Suppress legend here
        scale_fill_manual(values = season_colors, na.translate = FALSE) +
        labs(subtitle = paste("War-related Fires per Day -", y)) +
        scale_x_date(limits = c(as.Date(paste0(y, "-01-01")), as.Date(paste0(y, "-12-31"))), date_breaks = "1 month", date_labels = "%b") +
        ylim(0, 5000) +
        theme_minimal(base_family = "Arial") +
        theme(
          plot.subtitle = element_text(hjust = 0.5, size = 14, face = "bold"),
          axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
          axis.text.y = element_text(size = 10),
          axis.title.y = element_blank(),
          panel.grid.major.x = element_line(color = "grey80", linetype = "dotted", size = 0.5),
          panel.grid.major.y = element_line(color = "grey85"),
          panel.grid.minor = element_blank(),
          plot.background = element_rect(fill = "#f9f9f9")
        )
    })
    
    # Arrange the plots vertically with the legend only in the first plot
    combined_plot <- arrangeGrob(
      grobs = c(list(plot_with_legend), plot_list),  # Include plot_with_legend as the first plot
      ncol = 1
    )
    
    # Add main title and data source text
    final_output <- grid.arrange(
      combined_plot,
      top = textGrob("Seasonal Trends of War-related Fires in Ukraine", gp = gpar(fontsize = 24, fontface = "bold", family = "Arial")),
      bottom = textGrob("Data Source: Fires in Ukraine (2022-2024)", gp = gpar(fontsize = 12, fontface = "italic", family = "Arial"), hjust = 1)
    )
    
    # Display the final output
    grid.draw(final_output)


###############################################################################################
###############################################################################################
###############################################################################################


###############################################################################################
###############################################################################################
###############################################################################################

