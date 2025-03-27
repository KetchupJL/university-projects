# MTHM506 - Statistical Data Modelling - Individual Project

## Overview
This repository contains the implementation of an individual project for the MTHM506 - Statistical Data Modelling module. The project involves exploring and modeling the AIDS case trends in the UK using various statistical methods, including Poisson, Gaussian, and Negative Binomial regression models. The primary goal is to compare these models in terms of fit, predictive performance, and statistical validity.

## Project Structure
- **Question 1**: Exploratory analysis, likelihood functions, maximum likelihood estimation, hypothesis testing, and predictive modeling.
- **Question 2**: Data fitting with Poisson and Gaussian regression models, model diagnostics, hypothesis testing for model extensions, and the final selection of the Negative Binomial model.

## Key Results
The analysis covers:
- Fitting Poisson, Normal, and Negative Binomial regression models.
- Comparison of models using AIC, residuals, and overdispersion tests.
- Identification of the best-fitting model for the dataset, which is the Negative Binomial Cubic model, addressing overdispersion and fitting the non-linear trends in the data.

## Technologies Used
- **R**: The analysis and modeling were conducted using R, leveraging various packages for data manipulation, modeling, and visualization.
- **Packages**: `glm`, `ggplot2`, `AIC`, `deviance`, `bptest`, `glm.nb`

## Methodology
1. **Data Preprocessing**: Exploratory analysis of the AIDS case data, including transformation of the date variable for time series analysis.
2. **Modeling**: Comparison of Poisson, Normal, and Negative Binomial models, with extensions to include polynomial terms to capture non-linearity.
3. **Model Evaluation**: Use of AIC, residual deviance, and hypothesis testing to assess model fit and identify overdispersion.
4. **Final Model Selection**: The Negative Binomial Cubic model, which addresses the issues of overdispersion and non-linear trends in the data, was selected as the best model.

## Conclusion
The project successfully models the AIDS case trends in the UK and compares different regression approaches, with a final recommendation to use the Negative Binomial Cubic model for better predictive accuracy.

---

## Project Submission Details
- **Module**: MTHM506 - Statistical Data Modelling
- **Grade**: 84%

## Files
- `Individual-Project.pdf`: The complete report detailing the project, analysis, methodology, and results.
- `aids_data.csv`: The AIDS case data used for modeling (if available).
- `code.R`: The R script containing all analysis, modeling, and visualization code.

## License
This project is licensed under the MIT License.
