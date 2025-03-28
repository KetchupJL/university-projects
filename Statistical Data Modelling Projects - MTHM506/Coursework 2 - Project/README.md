# Modelling Spatio-Temporal TB Risk in Brazil using GAMs

This project models the spread of tuberculosis (TB) across 557 microregions of Brazil between 2012 and 2014 using **Generalized Additive Models (GAMs)**. By combining spatial coordinates, temporal structure, and socio-economic factors, I identified regions of elevated TB risk and the drivers behind them.

> MSc Statistical Modelling (MTHM506) Coursework — Grade: NA%

<p align="center">
  <img src="https://github.com/KetchupJL/university-projects/blob/main/Statistical%20Data%20Modelling%20Projects%20-%20MTHM506/Coursework%202%20-%20Project/Figures/map.png" alt="Spatial Risk Map" width="600"/>
  <br><br>
  <a href="./report.qmd">
    <img src="https://img.shields.io/badge/View%20Full%20Report-PDF-blue?style=for-the-badge"/>
  </a>
</p>

---

## Tools & Techniques
- **R & Quarto**: for analysis and reporting
- **Packages**: `mgcv`, `tidyverse`, `gt`, `gratia`, `fields`, `sp`, `patchwork`
- **Modelling**: Generalized Additive Models with Tweedie and Negative Binomial families
- **Visuals**: Risk maps, temporal trends, spatial smooths, covariate effect plots

---

## Key Objectives
- Estimate TB incidence per 100,000 population using offset modelling
- Quantify the non-linear effect of socio-economic predictors on TB risk
- Detect spatial and temporal heterogeneity in risk

---

## Key Learning Outcomes

- Advanced application of semi-parametric models (GAMs)
- Integration of spatial and temporal smoothing
- Model interpretation and critical evaluation
- Communication of findings in a scientifically rigorous, concise format

---

## Dataset Overview

The `TBdata` dataset includes:
- TB case counts, population, year (2012–2014)
- Region ID, coordinates (longitude, latitude)
- 8 socio-economic indicators: Indigenous population %, Illiteracy, Urbanisation, Density, Poverty, Poor Sanitation, Unemployment, Timeliness of reporting

> Data aggregated at the microregion level (n = 1671 rows).

---

## Modelling Framework

### Final Tweedie Model
TB case counts were modelled with a log-population offset using:

```r
gam_model_tw <- gam(TB ~ Year + Indigenous + 
  s(Urbanisation) + s(Density) + s(Unemployment) + 
  s(Poor_Sanitation) + s(Poverty) + s(Timeliness) + 
  s(lon,lat) + offset(logPop),
  data = TBdata,
  family = tw,
  method = "REML",
  select = TRUE)
```

### Mathematical Notation

\[\log(\mu_i) = \log(Population_i) + \beta_0 + \beta_1 Year_i + \beta_2 Indigenous_i + \sum_{j=1}^6 f_j(X_{ji}) + f_{spatial}(lon_i, lat_i)\]

- \(f_j(X)\): smooth terms for socio-economic variables
- \(f_{spatial}\): thin-plate spline spatial effect

### Temporal Extension
Used `s(x, by = Year)` to model changing covariate effects over time.

\[\log(\mu_i) = \log(Pop_i) + \beta_0 + \sum_{y=2012}^{2014} \left( \sum_j f_{j,y}(X_{ji}) + f_{spatial,y}(lon_i, lat_i) \right)\]

---

## Results Overview

<details>
<summary>Key Findings</summary>

- Strong risk predictors: Poverty, Poor Sanitation, Timeliness of reporting
- Spatial clusters: High TB burden near Manaus, Cuiabá, Santos
- Temporal trends: Stable risk patterns, modest increase in poverty and Indigenous risk over time
- Model accuracy: Adjusted R² = 0.902, Deviance explained = 59.7%

</details>

---

## Visual Gallery

### Smooth Effects of Covariates
![Covariate Effects](https://github.com/KetchupJL/university-projects/blob/main/Statistical%20Data%20Modelling%20Projects%20-%20MTHM506/Coursework%202%20-%20Project/Figures/covariates.png)

### Observed vs Fitted
![Obs vs Fitted](https://github.com/KetchupJL/university-projects/blob/main/Statistical%20Data%20Modelling%20Projects%20-%20MTHM506/Coursework%202%20-%20Project/Figures/obv_vs_fit.png)

### Temporal Smooths (by Year)
![Temporal Smooths](https://github.com/KetchupJL/university-projects/blob/main/Statistical%20Data%20Modelling%20Projects%20-%20MTHM506/Coursework%202%20-%20Project/Figures/temporal_smooths.png)

---

## Project Structure

```
├── data/              # Cleaned datasets
├── scripts/           # R scripts for analysis
├── appendix/          # Plots, tables, outputs
├── figures/           # Final plots & maps
├── report.qmd         # 3-page main report (Quarto)
```

---

## References
- Wood, S. (2017). *Generalized Additive Models: An Introduction with R*
- Tavares et al. (2024). *TB Treatment Outcomes in Brazil*, Infectious Diseases of Poverty

---

<p align="center">
  <img src="https://img.shields.io/badge/MSc%20Project%20Grade-NA%25-blue?style=for-the-badge"/>
</p>

> For questions or collaboration: **james066lewis@gmail.com**
