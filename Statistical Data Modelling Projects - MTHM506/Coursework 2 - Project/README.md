# Quantifying Spatio-Temporal Tuberculosis Risk in Brazil using GAMs

This repository contains all code, figures, and outputs for my MSc Statistical Data Modelling individual coursework (MTHM506) at the University of Exeter. The project aims to investigate the spatio-temporal structure and socio-economic drivers of tuberculosis (TB) risk across 557 microregions in Brazil over the years 2012–2014 using Generalized Additive Models (GAMs).

## Project Overview

The primary objective of this analysis is to:
- Estimate TB rates (cases per population unit) across Brazil using count data from 2012 to 2014.
- Identify key socio-economic covariates significantly influencing TB risk.
- Quantify spatial, temporal, and spatio-temporal variation in TB incidence using smooth functions within the GAM framework.

## Dataset

The dataset `TBdata` includes:
- **Epidemiological**: TB case counts and population data by microregion and year.
- **Socio-economic covariates**: Indigenous population proportion, illiteracy, urbanisation, density, poverty, poor sanitation, unemployment, and timeliness of reporting.
- **Spatial information**: Region ID, longitude and latitude.
- **Temporal variable**: Year (2012–2014).

## Methodology

Generalized Additive Models (GAMs) were used to model TB cases assuming a Poisson (or Tweedie) distribution, with a log link function and an offset for log population. The models incorporate:
- **Smooth terms** for covariates to capture non-linear effects.
- **Factor-smooth interactions** to explore temporal variation in covariate effects (`s(x, by=Year)`).
- **Spatial smoothing** using thin-plate splines over coordinates (`s(lon, lat)`).
- **Spatio-temporal structure** via tensor product interactions (`te(lon, lat, Year)`).

Model selection was guided by AIC, deviance explained, and diagnostics. Visualisations include smoothed effect plots and spatial risk maps using the `plot.map` function provided in the data package.

## Structure

- `report.qmd` – Three-page main report (R Markdown or Quarto).
- `appendix/` – Supplementary plots, model outputs, and commented R code.
- `scripts/` – All R scripts used for cleaning, analysis, and plotting.
- `data/` – `datasets_project.RData` containing TBdata and mapping utilities.
- `figures/` – Risk maps and diagnostic visualisations.

## Technologies Used

- **R** (mgcv, tidyverse, gt, fields, maps, sp)
- Quarto / RMarkdown for reproducible reporting

## Key Learning Outcomes

- Advanced application of semi-parametric models (GAMs)
- Integration of spatial and temporal smoothing
- Model interpretation and critical evaluation
- Communication of findings in a scientifically rigorous, concise format
