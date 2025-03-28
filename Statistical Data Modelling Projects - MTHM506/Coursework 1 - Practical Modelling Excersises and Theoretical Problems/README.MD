# Statistical Modelling of AIDS Cases
### *MTHM506 – Statistical Data Modelling Individual Coursework*

This project explores temporal trends in AIDS cases using advanced Generalized Linear Models (GLMs). The analysis evaluates Poisson, Gaussian, and Negative Binomial regression approaches and culminates in the selection of a best-fitting model to address overdispersion and non-linearity in the data.

> 📈 Grade: 84% | MSc Applied Data Science & Statistics (2025)

<p align="center">
  <img src="./figures/nb_fit_plot.png" alt="Negative Binomial Fit Plot" width="600"/>
  <br><br>
  <a href="./Individual-Project.pdf">
    <img src="https://img.shields.io/badge/View%20Full%20Report-PDF-blue?style=for-the-badge"/>
  </a>
</p>

---

## Project Summary

This analysis focuses on two objectives:
1. **Nonlinear Model Estimation via Maximum Likelihood (Question 1)**
2. **Count Regression Model Comparison (Poisson, Gaussian, Negative Binomial) for AIDS data (Question 2)**

---

## Key Learning Outcomes
- Maximum Likelihood Estimation for nonlinear Gaussian models
- Implementation of custom log-likelihood functions in R
- Use of GLMs for count data with log-link functions
- Detection and correction of model misspecification (overdispersion, non-linearity)
- Model selection using AIC, deviance, diagnostic plots, and hypothesis testing

---

## Part A: MLE and Predictive Modelling (Simulated Dataset)

- Developed a nonlinear model \( y_i \sim N\left( \frac{\theta_1 x_i}{\theta_2 + x_i}, \sigma^2 \right) \)
- Estimated parameters \( \theta_1, \theta_2, \sigma \) using `nlm()` and custom log-likelihood in R
- Constructed 95% confidence intervals and conducted a Z-test for hypothesis evaluation
- Produced fitted means and prediction intervals alongside raw data for validation

---

## Part B: Modelling UK AIDS Cases (1983–1994)

### Models Compared
- **Poisson Regression**: Log-linear model with count assumptions
- **Gaussian GLM**: Log-link model applied to count data
- **Negative Binomial Regression**: Final model selected due to overdispersion

### Modelling Enhancements
- Polynomial extensions (Quadratic, Cubic, Quartic) tested via nested model comparisons
- Overdispersion assessed using dispersion statistics and Breusch-Pagan test

### Final Model:
\[ Y_i \sim NB(\mu_i, \theta), \quad \log(\mu_i) = \beta_0 + \beta_1 x_i + \beta_2 x_i^2 + \beta_3 x_i^3 \]

> The **Negative Binomial Cubic Model** provided the best fit: lowest AIC (405), random residuals, and captured heteroscedasticity.

---

## Selected Visuals

### Model Fits and Predictions
![NB Prediction](./figures/nb_fit_plot.png)

### Deviance Residuals
![Residuals](./figures/dev_resid_nb.png)

### Model Comparison Table (AIC)
| Model                  | AIC       |
|------------------------|-----------|
| Poisson Base           | 1154.09   |
| Poisson Cubic          | 470.63    |
| Gaussian Cubic         | 440.88    |
| **NB Cubic (Final)**   | **405.97**|

---

## Project Structure
```
├── code.R                 # Main R script (MLE + GLMs)
├── Individual-Project.pdf # Final report
├── aids_data.csv          # AIDS dataset
├── figures/               # Visual outputs (residuals, predictions, model diagnostics)
```

---

## Technologies Used
- **R** for statistical analysis
- Packages: `glm`, `MASS`, `ggplot2`, `lmtest`, `AER`, `stats4`

---

## Citation
> Lewis, J. (2025). *Statistical Modelling of AIDS Trends Using GLMs*. MSc Statistical Modelling Coursework (MTHM506), University of Exeter.

---

<p align="center">
  <img src="https://img.shields.io/badge/Best%20Model-Negative%20Binomial%20Cubic-green?style=for-the-badge"/>
</p>

> For collaboration or questions, contact **james066lewis@gmail.com**
