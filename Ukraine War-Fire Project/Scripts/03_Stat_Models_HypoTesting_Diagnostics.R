# HLM #############################
fires_with_region <- read.csv("C:/Users/james/OneDrive/Documents/Working With Data (MTHM501/Ukraine War-Fires - MTHM501 Project/Data/fires_with_region.csv")


# Check data structure
str(fires_with_regions)

# Converting sf object to a regular data frame
TestData1 <- as.data.frame(fires_with_regions)

################# Standardising the population density parameter for the HLM

# Standardise population_density

# Apply log transformation (add a small constant to avoid log(0) if needed)
TestData1$population_density <- log(TestData1$population_density + 1)
# Standardisation
TestData1$population_density <- scale(TestData1$population_density, center = TRUE, scale = TRUE)


# Visualising this odd distribution

hist(TestData1$population_density, main = "Distribution of Standardized Population Density", xlab = "Standardized Population Density")


write.csv(TestData1, "C:/Users/james/OneDrive/Documents/Working With Data (MTHM501/Ukraine War-Fires - MTHM501 Project/Data/TestData1.csv", row.names = FALSE)


# Inspect the data frame
str(TestData1)

# Loading packages

require(lmerTest)
require(tidyverse)
require(readxl)
require(magrittr)
require(sjPlot)
require(sjmisc)
require(sjstats)
require(arm)
require(performance)


###################################################
# Fit the hierarchical logistic model - random intercept model
hlm_model_intercept <- glmer(war_fire ~ population_density + sustained_excess_fires +
                    (1 | region) + (1 | season) + (1 | id_big),
                  data = TestData1, family = binomial)

# Display the model summary
summary(hlm_model_intercept)
  
#################################################
## Random slopes model

hlm_model_random_slopes <- glmer(war_fire ~ population_density + sustained_excess_fires +
                                   (1 + population_density | region) +
                                   (1 + sustained_excess_fires | season)+
                                   (1 | id_big),
                                 data = TestData1, family = binomial)

summary(hlm_model_random_slopes)


#######################################################################
######################### Analysis ####################################
## Summary stats

# Create the data for the table
library(knitr)
library(kableExtra)

# Streamlined data, focusing on key parameters and rounding values
model_comparison <- data.frame(
  Parameter = c("AIC", "BIC", 
                "Variance (id_big)", "Variance (region)", "Variance (season)",
                "Intercept Estimate", "Population Density Estimate", 
                "Sustained Fire Activity Estimate"),
  `Random Slopes Model` = c("420760.1", "420868.3", 
                            "1.223", "0.423", "0.502",
                            "-17.65", "-0.12", "16.49"),
  `Intercept Model` = c("422560.3", "422625.2", 
                        "1.208", "0.442", "0.314",
                        "-21.79", "0.02", "20.72"),
  `p-value (Random Slopes)` = c("", "", 
                                "", "", "",
                                "<2e-16", "0.266", "<2e-16"),  # p-values for random slopes model
  `p-value (Intercept)` = c("", "", 
                            "", "", "",
                            "<2e-16", "0.0012", "<2e-16")  # p-values for intercept model
)

# Create and format the table
kable(model_comparison, caption = "Comparison of Hierarchical Models with p-values") %>%
  kable_styling(full_width = FALSE, position = "center") %>%
  column_spec(2:3, width = "4cm") %>%  # Set column width for better layout
  column_spec(4:5, width = "3cm", color = "black") %>%  # p-values columns styling
  column_spec(2, bold = TRUE, color = "darkblue") %>%
  column_spec(3, bold = TRUE, color = "darkgreen") %>%
  row_spec(1:2, background = "#e6f2ff") %>%  # Highlight AIC/BIC rows for readability
  pack_rows("Model Fit Statistics", 1, 2, bold = TRUE, background = "#f7f7f7") %>%
  pack_rows("Random Effects", 3, 5, bold = TRUE, background = "#f9f9f9") %>%
  pack_rows("Fixed Effects", 6, 8, bold = TRUE, background = "#f7f7f7")



#######################################################################
######################################################################
#########################################################################

# Model diagnostics

############## Binned Residuals Plot
# Load required libraries
library(ggplot2)
library(dplyr)
library(patchwork)  # For combining plots

# Set seed for reproducibility
# Ensuring that the sample selection below can be reproduced in future runs
set.seed(123)

# Random Intercept Model: Sample and prepare binned data
# Here, I sample 10,000 residuals and fitted values from the model to reduce computational load
sample_intercept <- sample(seq_along(residuals(hlm_model_intercept, type = "response")), 10000)
residuals_intercept <- residuals(hlm_model_intercept, type = "response")[sample_intercept]
fitted_intercept <- fitted(hlm_model_intercept)[sample_intercept]

# Creating a binned dataset to examine mean residuals within ranges of fitted values
binned_intercept <- data.frame(
  fitted_intercept = fitted_intercept,
  residuals_intercept = residuals_intercept
) %>%
  mutate(bins = cut(fitted_intercept, breaks = seq(0, 1, by = 0.1))) %>%  # Divide fitted values into 10 bins (0.1 intervals)
  group_by(bins) %>%
  summarize(
    mean_fitted_intercept = mean(fitted_intercept, na.rm = TRUE),        # Mean fitted probability within each bin
    mean_residuals_intercept = mean(residuals_intercept, na.rm = TRUE)    # Mean residual within each bin
  )

# Random Slopes Model: Sample and prepare binned data
# I repeat the sampling and binning process for the Random Slopes Model for a fair comparison
sample_slopes <- sample(seq_along(residuals(hlm_model_random_slopes, type = "response")), 10000)
residuals_slopes <- residuals(hlm_model_random_slopes, type = "response")[sample_slopes]
fitted_slopes <- fitted(hlm_model_random_slopes)[sample_slopes]

# Creating a binned dataset for the Random Slopes Model
binned_slopes <- data.frame(
  fitted_slopes = fitted_slopes,
  residuals_slopes = residuals_slopes
) %>%
  mutate(bins = cut(fitted_slopes, breaks = seq(0, 1, by = 0.1))) %>%  # Again, 10 bins (0.1 intervals)
  group_by(bins) %>%
  summarize(
    mean_fitted_slopes = mean(fitted_slopes, na.rm = TRUE),        # Mean fitted probability within each bin
    mean_residuals_slopes = mean(residuals_slopes, na.rm = TRUE)    # Mean residual within each bin
  )

# Improved plot for Random Intercept Model
# Creating a residual plot for the Random Intercept Model, with visual enhancements for clarity
RIM_Bin <- ggplot(binned_summary_intercept, aes(x = mean_fitted_intercept, y = mean_residuals_intercept)) +
  geom_point(color = "blue", size = 3) +  # Using larger blue points for visibility
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +  # Adding a reference line at zero for bias assessment
  geom_smooth(method = "loess", se = FALSE, color = "forestgreen", size = 1.2) +  # Adding a LOESS curve to show trend in residuals
  labs(
    title = "Binned Residuals Plot for Random Intercept Model",  # Specific title for this model
    x = "Average Predicted Probability of War-Related Fires",     # X-axis shows fitted probability
    y = "Average Residual (Observed - Predicted)"                 # Y-axis shows mean residual
  ) +
  annotate("text", x = 0.8, y = 0.05, label = "Systematic Bias at Extremes", color = "blue", size = 3, hjust = 0) +  # Annotation highlighting observed bias
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),           # Formatting title for readability
    axis.title = element_text(size = 12),                          # Adjusting axis titles for readability
    plot.subtitle = element_text(size = 10),                       # Formatting subtitle
    axis.text = element_text(size = 10)                            # Adjusting axis text for clarity
  )

# Improved plot for Random Slopes Model
# Creating a similar residual plot for the Random Slopes Model
RSM_Bin <- ggplot(binned_summary_slopes, aes(x = mean_fitted_slopes, y = mean_residuals_slopes)) +
  geom_point(color = "purple", size = 3) +  # Larger purple points for consistency and visibility
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +  # Reference line at zero for assessing bias
  geom_smooth(method = "loess", se = FALSE, color = "darkorchid", size = 1.2) +  # LOESS curve for trend analysis in residuals
  labs(
    title = "Binned Residuals Plot for Random Slopes Model",       # Specific title for this model
    x = "Average Predicted Probability of War-Related Fires",      # X-axis shows fitted probability
    y = "Average Residual (Observed - Predicted)"                  # Y-axis shows mean residual
  ) +
  annotate("text", x = 0.8, y = 0.04, label = "Improved Fit Across Range", color = "purple", size = 3, hjust = 0) +  # Annotation noting better fit
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),           # Formatting title for consistency
    axis.title = element_text(size = 12),                          # Adjusting axis titles for readability
    plot.subtitle = element_text(size = 10),                       # Formatting subtitle
    axis.text = element_text(size = 10)                            # Adjusting axis text for clarity
  )

# Combine the plots vertically with patchwork and add an overall title
# Using patchwork to stack the two residual plots vertically, making it easy to compare the models
combined_plot <- (RIM_Bin / RSM_Bin) +  # Stacking the plots
  plot_annotation(
    title = "Comparison of Model Fit: Random Intercept vs. Random Slopes",   # Overall title to contextualize the plot
    subtitle = "Assessing Linearity and Bias in Predicted Probabilities for War-Related Fires",  # Subtitle to clarify purpose
    theme = theme(
      plot.title = element_text(size = 16, face = "bold"),   # Emphasizing the overall title for readability
      plot.subtitle = element_text(size = 12)                # Making subtitle legible
    )
  )

# Display the combined plot for visualization
combined_plot  # Displaying the combined plot



##################################################################
###############################################################################################
###############################################################################################
###############################################################################################

#######################
# Checking Normality of residuals
library(ggplot2)

# Plot for the Random Intercept Model
RIM_HIS <- ggplot(data.frame(residuals = residuals(hlm_model_intercept)), aes(x = residuals)) +
  geom_histogram(aes(y = ..density..), bins = 30, fill = "lightblue", color = "black") +  # Histogram with density scaling
  geom_density(color = "blue", size = 1) +  # Density curve for residuals
  stat_function(fun = dnorm, args = list(mean = mean(residuals(hlm_model_intercept)), 
                                         sd = sd(residuals(hlm_model_intercept))), 
                color = "red", linetype = "dashed") +  # Overlay normal curve for comparison
  labs(title = "Residuals Distribution of Random Intercept Model", x = "Residuals", y = "Density") +
  theme_minimal()

# Q-Q Plot for Random Intercept Model
RIM_QQ <- ggplot(data.frame(residuals = residuals(hlm_model_intercept)), aes(sample = residuals)) +
  stat_qq() + 
  stat_qq_line(color = "red") +
  labs(title = "Q-Q Plot of Residuals for Random Intercept Model", x = "Theoretical Quantiles", y = "Sample Quantiles") +
  theme_minimal()

# Plot for the Random Slopes Model
RSM_HIS <- ggplot(data.frame(residuals = residuals(hlm_model_random_slopes)), aes(x = residuals)) +
  geom_histogram(aes(y = ..density..), bins = 30, fill = "lightblue", color = "black") +  # Histogram with density scaling
  geom_density(color = "blue", size = 1) +  # Density curve for residuals
  stat_function(fun = dnorm, args = list(mean = mean(residuals(hlm_model_random_slopes)), 
                                         sd = sd(residuals(hlm_model_random_slopes))), 
                color = "red", linetype = "dashed") +  # Overlay normal curve for comparison
  labs(title = "Residuals Distribution of Random Slopes Model", x = "Residuals", y = "Density") +
  theme_minimal()

# Q-Q Plot for Random Slopes Model
RSM_QQ <- ggplot(data.frame(residuals = residuals(hlm_model_random_slopes)), aes(sample = residuals)) +
  stat_qq() + 
  stat_qq_line(color = "red") +
  labs(title = "Q-Q Plot of Residuals for Random Slopes Model", x = "Theoretical Quantiles", y = "Sample Quantiles") +
  theme_minimal()

RIM_HIS + RSM_HIS
RIM_QQ + RSM_QQ # May take a while to load

###############################################################################################
####################
###############################################################################################
###############################################################################################

# Calculating ICC

# For Random Intercept Model
icc(hlm_model_intercept)

# For Random Slopes Model
icc(hlm_model_random_slopes) # This takes too long to load.. so ill work it out manually...

# Extract variance components from the random slopes model
variance_components <- VarCorr(hlm_model_random_slopes)

# Calculate the random intercept and random slope variances
region_intercept_variance <- attr(variance_components$region, "stddev")[1]^2  # Variance of random intercept for 'region'
population_density_slope_variance <- attr(variance_components$region, "stddev")[2]^2  # Variance of random slope for 'population_density'

season_intercept_variance <- attr(variance_components$season, "stddev")[1]^2  # Variance of random intercept for 'season'

# Set the residual variance for logistic regression
residual_variance <- pi^2 / 3

# Calculate Total Variance
total_variance <- region_intercept_variance + population_density_slope_variance + season_intercept_variance + residual_variance

# Calculate ICC
icc_RSM <- (region_intercept_variance + season_intercept_variance) / total_variance
icc_RSM


# Calculate ICC
icc_RSM <- intercept_variance / (intercept_variance + slope_variance + residual_variance)
icc_RSM



################################################

# Random Effect Variance Plot
library(sjPlot)
library(ggplot2)
library(patchwork)
library(stringr)

# Helper function to get the first word of each region name
# This function extracts only the first word from the region name (for concise labeling on the plot)
get_first_word <- function(region_name) {
  str_extract(region_name, "^[^ ]+")
}

# Define custom colors for different random effects in the Random Slopes Model (RSM)
# Each effect has its own color for easier identification in the plot
colors <- c("population_density" = "blue", "region (Intercept)" = "green", "season (Intercept)" = "orange", "sustained_excess_fires" = "purple")

# Random Effect Variance Plot for Region (Random Intercept Model - RIM)
RE_Region_In <- plot_model(hlm_model_intercept, type = "re")[[2]] +
  scale_y_log10(labels = scales::comma) +  # Apply log scale to the y-axis to better visualize variance differences
  scale_x_discrete(labels = function(x) sapply(x, get_first_word)) +  # Only display the first word of each region
  labs(title = "Variance by Region (RIM)", x = "Region", y = "Variance (log scale)") +  # Set plot titles and labels
  theme_minimal() +  # Use a minimal theme for a clean look
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate x-axis text for readability
    axis.text.y = element_text(size = 10)
  ) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "grey")  # Add a reference line at variance = 1 for context

# Random Effect Variance Plot for Season (Random Intercept Model - RIM)
RE_Season_In <- plot_model(hlm_model_intercept, type = "re")[[3]] +
  scale_y_log10(labels = scales::comma) +  # Log scale for y-axis (variance)
  labs(title = "Variance by Season (RIM)", x = "Season", y = "Variance (log scale)") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    axis.text.y = element_text(size = 10)
  ) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "grey")  # Reference line at variance = 1

# Combine the plots for the Random Intercept Model (RIM)
# This combines the region and season variance plots for the RIM, creating a single view of variance by both factors
RIM_Variance_Plots <- (RE_Region_In | RE_Season_In) +
  plot_annotation(title = "Random Effect Variance by Region and Season - Random Intercept Model")

# Random Effect Variance Plot for Region (Random Slopes Model - RSM)
RE_Region_Sl <- plot_model(hlm_model_random_slopes, type = "re")[[2]] +
  scale_y_log10(labels = scales::comma) +  # Log scale for variance on y-axis
  scale_x_discrete(labels = function(x) sapply(x, get_first_word)) +  # Only the first word of each region
  labs(title = "Variance by Region (RSM)", x = "Region", y = "Variance (log scale)") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.text.y = element_text(size = 10)
  ) +
  scale_color_manual(values = colors) +  # Assign custom colors to different random effects
  geom_vline(xintercept = 1, linetype = "dashed", color = "grey")  # Reference line at variance = 1

# Random Effect Variance Plot for Season (Random Slopes Model - RSM)
RE_Season_Sl <- plot_model(hlm_model_random_slopes, type = "re")[[3]] +
  scale_y_log10(labels = scales::comma) +  # Log scale for y-axis
  labs(title = "Variance by Season (RSM)", x = "Season", y = "Variance (log scale)") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    axis.text.y = element_text(size = 10)
  ) +
  scale_color_manual(values = colors) +  # Apply the custom colors to make effects more distinguishable
  geom_vline(xintercept = 1, linetype = "dashed", color = "grey")  # Reference line at variance = 1

# Combine the Random Slopes Model (RSM) plots
# This combines the region and season variance plots for the RSM to give a complete view of random effect variability
RSM_Variance_Plots <- (RE_Region_Sl | RE_Season_Sl) +
  plot_annotation(title = "Random Effect Variance by Region and Season - Random Slopes Model")

# Final combined plot of RIM and RSM for comparison
# Here, I combine the RIM and RSM plots in a single view to compare the models' variance across regions and seasons
Final_Variance_Plot <- (RIM_Variance_Plots / RSM_Variance_Plots) +
  plot_annotation(
    title = "Comparison of Random Effect Variance by Region and Season",
    subtitle = "Random Intercept Model (Top) vs Random Slopes Model (Bottom)",
    caption = "Note: Variance is presented on a logarithmic scale for clarity. This plot highlights how random effects vary by region and season, providing insights into the spatial and temporal variability of war-related fire classifications.",
    theme = theme(
      plot.title = element_text(size = 16, face = "bold"),
      plot.subtitle = element_text(size = 12),
      plot.caption = element_text(size = 10, hjust = 0.5)
    )
  )

# Display the final plot
# This produces the final combined plot showing random effect variances across both models for my report
Final_Variance_Plot


###############################################################################################
###############################################################################################
###############################################################################################

# Comparing models

anova(hlm_model_intercept, hlm_model_random_slopes)



################################
# Conducting a Likely-hood ratio test
# Null model without random effects
model_null <- glm(war_fire ~ population_density + sustained_excess_fires, 
                    data = TestData1, family = binomial)

summary(model_null)
# Likelihood ratio test
anova(model_null, hlm_model_random_slopes, test = "LRT")

