install.packages("ggcorrplot")
library(ggcorrplot)
library(ggplot2)

# Data frame with relevent columns
cor_data <- fires_cleaned %>%
  select(war_fires_per_day, fires_per_day, population_density, pop_exact, sustained_excess_fires, war_fire, excess_fires, latitude, longitude)

# Check the structure of your data
str(cor_data)

# Convert factor columns to numeric if necessary
cor_data <- cor_data %>%
  mutate(across(where(is.factor), as.numeric)) %>%
  mutate(across(where(is.character), as.numeric))


# Calculate the correlation matrix
cor_matrix <- round(cor(cor_data), 1)
head(cor_matrix[, 1:9])


# Using hierarchical clustering
ggcorrplot(cor_matrix, hc.order = TRUE, outline.color = "white")
ggcorrplot(cor_matrix)
