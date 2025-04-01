# Question 1 Script

# Part A:

# Load required libraries
library(geoR)
library(tidyverse)

# Read the data
kuroshio100 <- read.csv("~/GitHub/university-projects/Modelling in Space and Time/In progress/kuroshio100.csv")

# Summarise NA counts
# colSums(is.na(kuroshio100))

# Across all columns apart from `date` and `id`, there are 1557 missing values

# Remove rows with missing essential spatial data
kuroshio100_clean <- kuroshio100 %>%
  drop_na(lon, lat)

library(ggplot2)
library(viridis)

# SST spatial scatter plot
ggplot(kuroshio100, aes(x = lon, y = lat, color = sst)) +
  geom_point(size = 3, alpha = 0.9, shape = 16) +
  scale_color_viridis_c(
    option = "C",
    direction = -1,
    name = "SST (°C)",
    limits = c(min(kuroshio100$sst, na.rm = TRUE), max(kuroshio100$sst, na.rm = TRUE)),
    oob = scales::squish
  ) +
  labs(
    title = "Sea Surface Temperature Observations – Kuroshio Current (Jan 1996)",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
    axis.title = element_text(face = "bold"),
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10),
    panel.grid = element_blank()
  )

data(kuroshio100)
plot(kuroshio100)

################################################################################


# Part B

set.seed(444)  # For reproducibility

# Using the cleaned dataset to ensure we dont chose missing values.
# 5 random points
test_points <- kuroshio100_clean %>%
  sample_n(5)

# Display their information
test_points %>%
  select(id, lon, lat, sst)


# Create training dataset (excluding test points)
kuroshio_train <- anti_join(kuroshio100, test_points, by = c("id", "lon", "lat", "sst"))

# Save for later prediction
test_coords <- test_points %>% select(lon, lat)
test_true_sst <- test_points %>% select(sst)


################################################################################


# Part C

library(geoR)

# Convert training dataset into a geodata object
# kuro_geo_train1 <- as.geodata(kuroshio_train, coords.col = c("lon", "lat"), data.col = "sst")

# Jitter duplicated coordinates very slightly
kuro_geo_train2 <- jitterDupCoords(
  as.geodata(kuroshio_train, coords.col = c("lon", "lat"), data.col = "sst"),
  max = 1e-5
)
# max = 1e-5 means the jitter is in the order of 0.00001 — completely negligible in geographic terms.
# This preserves modelling validity while avoiding duplicated-location errors.


# Empirical variogram with binning

# Full range
emp_variog_full <- variog(kuro_geo_train, option = "bin", max.dist = 2.5, uvec = seq(0, 2.5, length.out = 20))

# Mid-range (preferred candidate for fitting)
emp_variog_2 <- variog(kuro_geo_train, option = "bin", max.dist = 2.0, uvec = seq(0, 2.0, length.out = 20))

# Cleanest for model fitting
emp_variog_1.8 <- variog(kuro_geo_train, option = "bin", max.dist = 1.8, uvec = seq(0, 1.8, length.out = 18))


library(tibble)
library(dplyr)

variog_df <- bind_rows(
  tibble(dist = emp_variog_full$u, semivar = emp_variog_full$v, version = "max.dist = 2.5"),
  tibble(dist = emp_variog_2$u, semivar = emp_variog_2$v, version = "max.dist = 2.0"),
  tibble(dist = emp_variog_1.8$u, semivar = emp_variog_1.8$v, version = "max.dist = 1.8")
)


ggplot(variog_df, aes(x = dist, y = semivar)) +
  geom_point(size = 2, colour = "black") +
  geom_line(colour = "darkred", linewidth = 1) +
  facet_wrap(~ version, ncol = 1, scales = "free_x") +
  labs(
    title = "Comparison of Empirical Variograms (Different Maximum Distances)",
    x = "Distance (spatial units)",
    y = "Semi-variance"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    axis.title = element_text(face = "bold"),
    strip.text = element_text(face = "bold", size = 12),
    panel.grid.major = element_line(color = "grey85"),
    panel.grid.minor = element_blank()
  )


#  Fit Parametric Variogram Models

# Exponential model
fit_exp <- variofit(
  emp_variog_1.8,
  cov.model = "exponential",
  ini.cov.pars = c(1, 1),
  nugget = 0.1,
  weights = "equal"
)

# Gaussian model
fit_gau <- variofit(
  emp_variog_1.8,
  cov.model = "gaussian",
  ini.cov.pars = c(1, 1),
  nugget = 0.1,
  weights = "equal"
)

# Matérn model (kappa = 1.5)
fit_mat1 <- variofit(
  emp_variog_1.8,
  cov.model = "matern",
  kappa = 1.5,
  ini.cov.pars = c(2, 1),   # partial sill = 2, range = 1
  nugget = 0.5,             # starting nugget guess
  weights = "equal"
)

fit_mat2 <- variofit(
  emp_variog_1.8,
  cov.model = "matern",
  kappa = 1.5,
  ini.cov.pars = c(1.5, 0.8),
  nugget = 0.3,
  weights = "equal"
)


# Plot empirical variogram
plot(emp_variog_1.8,
     main = "Fitted Variogram Models (max.dist = 1.8)",
     xlab = "Distance (spatial units)", ylab = "Semi-variance")

# Overlay each fitted model
lines(fit_exp, col = "blue", lwd = 2)
lines(fit_gau, col = "forestgreen", lwd = 2)
lines(fit_mat1, col = "purple", lwd = 2, lty = 2)
lines(fit_mat2, col = "darkorange", lwd = 2, lty = 3)

# Legend for identification
legend("bottomright",
       legend = c("Exponential", "Gaussian", "Matérn (v1)", "Matérn (v2)"),
       col = c("blue", "forestgreen", "purple", "darkorange"),
       lty = c(1, 1, 2, 3),
       lwd = 2)

fit_exp$value
fit_gau$value
fit_mat1$value



# Extract Fitted Parameters from Each Model

# Exponential
params_exp <- fit_exp$cov.pars
nugget_exp <- fit_exp$nugget

# Gaussian
params_gau <- fit_gau$cov.pars
nugget_gau <- fit_gau$nugget

# Matérn
params_mat <- fit_mat1$cov.pars
nugget_mat <- fit_mat1$nugget

# Create parameter summary table
param_table <- data.frame(
  Model = c("Exponential", "Gaussian", "Matérn (κ = 1.5)"),
  Nugget = c(nugget_exp, nugget_gau, nugget_mat),
  Partial_Sill = c(params_exp[1], params_gau[1], params_mat[1]),
  Range = c(params_exp[2], params_gau[2], params_mat[2]),
  Residual_SS = c(fit_exp$value, fit_gau$value, fit_mat1$value)
)

print(param_table)

# Perform LOOCV
xv.kriging <- xvalid(kuro_geo_train, model = fit_mat1)

# Plot residuals
par(mfrow = c(3, 2), mar = c(4, 2, 2, 2))
plot(xv.kriging, error = TRUE, std.error = FALSE, pch = 19)

# Kriging prediction at 5 withheld locations
kriged <- krige.conv(
  geodata = kuro_geo_train2,
  locations = test_coords,
  krige = krige.control(
    cov.model = "matern",
    cov.pars = fit_mat1$cov.pars,
    nugget = fit_mat1$nugget,
    kappa = 1.5
  )
)

# Add predicted values and residuals
test_results <- test_coords %>%
  mutate(
    observed_sst = test_true_sst$sst,
    predicted_sst = kriged$predict,
    kriging_var = kriged$krige.var,
    residual = observed_sst - predicted_sst
  )

# Compute RMSE and MAE
rmse <- sqrt(mean(test_results$residual^2))
mae <- mean(abs(test_results$residual))


ggplot(test_results, aes(x = observed_sst, y = predicted_sst)) +
  geom_point(size = 3) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "red") +
  labs(
    title = "Observed vs Predicted SST at Withheld Locations",
    x = "Observed SST (°C)",
    y = "Predicted SST (°C)"
  ) +
  theme_minimal(base_size = 13)

library(dplyr)
library(knitr)
library(kableExtra)

test_results %>%
  mutate(
    `Observed SST (°C)` = round(observed_sst, 2),
    `Predicted SST (°C)` = round(predicted_sst, 2),
    `Residual (°C)` = round(residual, 2),
    `Kriging Variance` = round(kriging_var, 3)
  ) %>%
  select(lon, lat, `Observed SST (°C)`, `Predicted SST (°C)`, `Residual (°C)`, `Kriging Variance`) %>%
  kable(format = "html", caption = "Observed vs Predicted SST with Kriging Variance",
        col.names = c("Longitude", "Latitude", "Observed SST (°C)", "Predicted SST (°C)",
                      "Residual (°C)", "Kriging Variance")) %>%
  kable_styling(full_width = FALSE, bootstrap_options = c("striped", "hover"))


################################################################################

# Part D

fit_gp <- likfit(
  kuro_geo_train2,
  ini.cov.pars = c(26, 4)
)

# Perform LOOCV
xv.gp <- xvalid(kuro_geo_train2, model = fit_gp)

# Plot residuals
par(mfrow = c(3, 2), mar = c(4, 2, 2, 2))
plot(xv.gp, error = TRUE, std.error = FALSE, pch = 19)


# Kriging prediction using GP mode
pred_gp <- krige.conv(
  geodata = kuro_geo_train2,
  locations = test_coords,
  krige = krige.control(
    obj.model = fit_gp
  )
)

# Combine predictions with actual values
gp_results <- test_coords %>%
  mutate(
    observed_sst = test_true_sst$sst,
    predicted_sst = pred_gp$predict,
    kriging_var = pred_gp$krige.var,
    residual = observed_sst - predicted_sst
  )
# Compute error metrics
rmse_gp <- sqrt(mean(gp_results$residual^2))
mae_gp <- mean(abs(gp_results$residual))

# Output metrics
print(rmse_gp)
print(mae_gp)

# Create evaluation table
library(knitr)
gp_results %>%
  mutate(
    `Observed SST (°C)` = round(observed_sst, 2),
    `Predicted SST (°C)` = round(predicted_sst, 2),
    `Residual (°C)` = round(residual, 2),
    `Kriging Variance` = round(kriging_var, 3)
  ) %>%
  select(lon, lat, `Observed SST (°C)`, `Predicted SST (°C)`, `Residual (°C)`, `Kriging Variance`) %>%
  kable(format = "latex", booktabs = TRUE, caption = "Observed vs Predicted SST at Withheld Locations – GP Model")

# Plot: Observed vs Predicted
ggplot(gp_results, aes(x = observed_sst, y = predicted_sst)) +
  geom_point(size = 3) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "red") +
  labs(
    title = "Observed vs Predicted SST (GP Model)",
    x = "Observed SST (°C)",
    y = "Predicted SST (°C)"
  ) +
  theme_minimal(base_size = 13)


################################################################################

# Part E







################################################################################


