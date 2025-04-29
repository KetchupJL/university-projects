# Advanced Spatio-Temporal Modelling of Ocean and Climate Data  
### *MTHM505 – Data Science and Statistical Modelling in Space and Time Coursework*

This project explores spatial, temporal, and spatio-temporal modelling techniques applied to real-world climate datasets. It covers kriging, Gaussian Processes (MLE and Bayesian), ARIMA time series modelling, and Dynamic Linear Models (DLMs), culminating in a comprehensive comparison of predictive performances across different modelling frameworks.

> 📈 MSc Applied Data Science & Statistics (2025)

<p align="center">
  <br><br>
  <a href="Modelling in Space and Time/Project Submission.pdf">
    <img src="https://img.shields.io/badge/View%20Full%20Report-PDF-blue?style=for-the-badge"/>
  </a>
</p>

---

## Project Summary

This analysis focuses on three major objectives:
1. **Spatial Prediction of Sea Surface Temperatures (SST)** using variogram analysis, kriging, Gaussian processes (MLE and Bayesian).
2. **Time Series Forecasting of Atlantic Ocean Circulation (AMOC)** using ARIMA models, SARIMA, and DLMs.
3. **Spatio-Temporal Prediction of California Daily Temperatures** combining spatial and time series methods.

---

## Key Learning Outcomes
- Empirical and theoretical variogram construction
- Kriging interpolation and Gaussian Process modelling
- Bayesian parameter estimation with discrete priors
- Fitting and diagnosing ARIMA and DLMs
- Forecasting and uncertainty quantification in spatial and temporal domains
- Model comparison using AIC, RMSE, cross-validation, and residual diagnostics

---

## Part A: Spatial Modelling of Sea Surface Temperature (Kuroshio Current)

- Exploratory spatial analysis and sample variogram fitting
- **Ordinary Kriging** using Matérn and Squared Exponential models
- **Gaussian Process MLE Modelling** with maximum likelihood parameter estimation
- **Bayesian Gaussian Process** with discrete priors over lengthscale and nugget
- Predictions at 5 withheld SST locations and model validation through cross-validation

---

## Part B: Time Series Modelling of Atlantic Overturning Circulation (AMOC)

### Models Compared
- **ARMA and ARIMA** models for monthly AMOC data
- **SARIMA** models for quarterly-averaged AMOC data
- **Dynamic Linear Models (DLMs)** with trend and seasonal components

### Modelling Enhancements
- Manual differencing and stationarity tests
- Identification of optimal (p,d,q) orders via ACF/PACF interpretation
- Forecasting final 8 months and 2 quarters using both ARIMA and DLM frameworks
- Forecast accuracy assessed via RMSE and residual diagnostics

---

## Part C: Combined Spatio-Temporal Modelling of California Temperatures

- **Spatial Gaussian Process Modelling** to predict temperatures at San Diego and Fresno (13 Dec 2012)
- **Time Series ARIMA Forecasts** for 9–13 Dec and 13–17 Dec
- Model selection based on forecast performance for 13 December predictions
- Integration and critical comparison of spatial vs temporal modelling approaches

---

## Selected Visuals

### Comparison of Empirical Variograms for SST
![Comparison of Empirical Variograms](https://github.com/KetchupJL/university-projects/blob/main/Modelling%20in%20Space%20and%20Time/figures/Empirical%20Variograms.png)

### Kriging vs GP Predictions for SST
![Predictions](https://github.com/KetchupJL/university-projects/blob/main/Modelling%20in%20Space%20and%20Time/figures/Predicted%20SST.png)

### AMOC Plot
![AMOC Plot](https://github.com/KetchupJL/university-projects/blob/main/Modelling%20in%20Space%20and%20Time/figures/AMOC%20Plot.png)

### California Temperature ARIMA Model Residuals
![California Forecast](https://github.com/KetchupJL/university-projects/blob/main/Modelling%20in%20Space%20and%20Time/figures/Resdiuals%20ARIMA%20Models.png)

### California Temperature Forecasts
![California Forecast](https://github.com/KetchupJL/university-projects/blob/main/Modelling%20in%20Space%20and%20Time/figures/Q3%20Predictions.png)

---

## Project Structure
```
├── figures/               # Visual outputs (variograms, forecasts, prediction intervals)
├── Data/                  # Original datasets (kuroshio100.csv, MOC.Rdata, MaxTempCalifornia.csv)
├── Proj_R_Code                  # Quarto file for each project section (SST, AMOC, California)
├── Project Submission.pdf # Final Quarto report
├── Project Brief.pdf              # Project overview
├── README.md              # Project overview
```

---

## Technologies Used
- **R** for statistical analysis
- Packages: `geoR`, `gstat`, `forecast`, `dlm`, `ggplot2`, and more
- Quarto for professional reporting and reproducibility

---

<p align="center">
  <img src="https://img.shields.io/badge/Best%20Methods-GP%20MLE%20%7C%20DLMs-green?style=for-the-badge"/>
</p>

> For collaboration or questions, contact **james066lewis@gmail.com**
