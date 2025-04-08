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

library(dplyr)
library(gt)
install.packages("moments")
library(moments)

# Enhanced summary
amoc_summary <- moc_df %>%
  summarise(
    Mean = mean(amoc),
    SD = sd(amoc),
    Min = min(amoc),
    Max = max(amoc),
    Median = median(amoc),
    IQR = IQR(amoc),
    CV = sd(amoc) / mean(amoc),
    Skewness = skewness(amoc),
    Kurtosis = kurtosis(amoc),
    N = n()
  ) %>%
  pivot_longer(everything(), names_to = "Statistic", values_to = "Value")

# Display table
gt(amoc_summary) %>%
  fmt_number(columns = "Value", decimals = 2) %>%
  tab_header(
    title = "Expanded Summary Statistics of AMOC Time Series",
    subtitle = "October 2017 – February 2023"
  )

ggplot(moc_df, aes(x = amoc)) +
  geom_histogram(aes(y = ..density..), fill = "lightblue", colour = "black", bins = 15) +
  geom_density(colour = "darkred", size = 1) +
  labs(title = "Distribution of AMOC Strength",
       x = "AMOC Strength (Sv)", y = "Density") +
  theme_minimal()

#############################################################################

# Part B

# First we need to covert to time series data
# Convert to time series object (monthly frequency)
amoc_ts <- ts(moc_df$amoc, start = c(2017, 10), frequency = 12)

# Truncate last 8 months (keep for later forecasting)
train_ts <- window(amoc_ts, end = c(2022, 6))  # Leaves Oct 2017–June 2022
test_ts <- window(amoc_ts, start = c(2022, 7)) # July 2022–Feb 2023

# Now we plot the acf and pacf to determine which model is most appropriate

# Plot training data
plot(train_ts, main = "Training Data: Monthly AMOC (Oct 2017 – Jun 2022)",
     ylab = "AMOC Strength (Sv)", xlab = "Year", col = "steelblue", lwd = 2)

# ACF and PACF
par(mfrow = c(1, 2))  # 1 row, 2 columns

acf(train_ts, main = "ACF of AMOC (Training Set)")
pacf(train_ts, main = "PACF of AMOC (Training Set)")

par(mfrow = c(1, 1))  # reset



# Fit ARMA(1,0) and ARMA(2,0) models to undifferenced training series
arma_1_0 <- arima(train_ts, order = c(1, 0, 0), method = "ML")
arma_2_0 <- arima(train_ts, order = c(2, 0, 0), method = "ML")

# View summaries
summary(arma_1_0)
summary(arma_2_0)

# Ljung–Box test
Box.test(residuals(arma_1_0), lag = 10, type = "Ljung-Box")
Box.test(residuals(arma_2_0), lag = 10, type = "Ljung-Box")


# ARMA(1,0)
par(mfrow = c(1, 3), mar = c(4, 4, 2, 1))
plot(residuals(arma_1_0), main = "ARMA(1,0) Residuals", ylab = "Residuals", col = "steelblue")
acf(residuals(arma_1_0), main = "ACF of Residuals")
qqnorm(residuals(arma_1_0)); qqline(residuals(arma_1_0))

# ARMA(2,0)
par(mfrow = c(1, 3), mar = c(4, 4, 2, 1))
plot(residuals(arma_2_0), main = "ARMA(2,0) Residuals", ylab = "Residuals", col = "darkred")
acf(residuals(arma_2_0), main = "ACF of Residuals")
qqnorm(residuals(arma_2_0)); qqline(residuals(arma_2_0))
par(mfrow = c(1, 1))  # Reset layout



# ARIMA Model Fitting: 

# First-order differencing
diff_amoc <- diff(train_ts)

# Plot layout: 1 row, 3 plots
par(mfrow = c(1, 3), mar = c(4, 4, 3.5, 1))  # slightly increase top margin for spacing

# Plot 1: Differenced Series
plot(diff_amoc, 
     main = "First-order Differenced AMOC", 
     ylab = "Differenced Value", 
     xlab = "Time", 
     col = "steelblue", 
     lwd = 1.2)

# Plot 2: ACF
acf(diff_amoc, 
    main = "ACF of Differenced Series", 
    col = "black")

# Plot 3: PACF
pacf(diff_amoc, 
     main = "PACF of Differenced Series", 
     col = "black")

# Reset layout
par(mfrow = c(1, 1))
ar(mfrow = c(1, 1))



# ---- Fit Models ----
arima_110 <- arima(train_ts, order = c(1,1,0), method = "ML")
arima_011 <- arima(train_ts, order = c(0,1,1), method = "ML")
arima_111 <- arima(train_ts, order = c(1,1,1), method = "ML")

# ---- Set up plotting layout ----
par(mfrow = c(3, 3), mar = c(4, 4, 2, 1))

# ---- Diagnostics for ARIMA(1,1,0) ----
plot(residuals(arima_110), main = "ARIMA(1,1,0) Residuals", ylab = "Residuals", col = "steelblue")
acf(residuals(arima_110), main = "ACF: ARIMA(1,1,0)")
qqnorm(residuals(arima_110)); qqline(residuals(arima_110))

# ---- Diagnostics for ARIMA(0,1,1) ----
plot(residuals(arima_011), main = "ARIMA(0,1,1) Residuals", ylab = "Residuals", col = "darkred")
acf(residuals(arima_011), main = "ACF: ARIMA(0,1,1)")
qqnorm(residuals(arima_011)); qqline(residuals(arima_011))

# ---- Diagnostics for ARIMA(1,1,1) ----
plot(residuals(arima_111), main = "ARIMA(1,1,1) Residuals", ylab = "Residuals", col = "darkgreen")
acf(residuals(arima_111), main = "ACF: ARIMA(1,1,1)")
qqnorm(residuals(arima_111)); qqline(residuals(arima_111))

# ---- Reset layout ----
par(mfrow = c(1, 1))

# ---- Ljung–Box Tests ----
lb_110 <- Box.test(residuals(arima_110), lag = 10, type = "Ljung-Box")
lb_011 <- Box.test(residuals(arima_011), lag = 10, type = "Ljung-Box")
lb_111 <- Box.test(residuals(arima_111), lag = 10, type = "Ljung-Box")

# ---- AIC + p-value summary ----
cat("ARIMA(1,1,0): AIC =", AIC(arima_110), ", Ljung-Box p =", lb_110$p.value, "\n")
cat("ARIMA(0,1,1): AIC =", AIC(arima_011), ", Ljung-Box p =", lb_011$p.value, "\n")
cat("ARIMA(1,1,1): AIC =", AIC(arima_111), ", Ljung-Box p =", lb_111$p.value, "\n")







