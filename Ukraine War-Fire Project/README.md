# War Fires in Ukraine: Spatio-Temporal Intelligence from Satellite Data

This project explores whether we can identify war-related fires in Ukraine using patterns in satellite data — based on time, geography, and local conflict dynamics. As a postgraduate Data Scientist, I used R, spatial mapping, and advanced statistical modelling (GLMMs) to uncover these patterns, combining open-source data with exploratory analysis and hierarchical models.

---

<p align="center">
  <img src="./Plots and Tables/ukraine_fire_animation.gif" alt="Animated War Fires Map" width="600"/>
  <br><br>
  <a href="https://KetchupJL.github.io/university-projects/Predicted%20Probabilities%20of%20War-Related%20Fires%20Heatmap.html">
    <img src="https://img.shields.io/badge/🔎%20View%20Interactive%20Heatmap%20Here-blue?style=for-the-badge"/>
  </a>
</p>

## 🛠️ Tools & Technologies

- **Language**: R, RStudio
- **Statistical Modelling**: `lme4`, `sjPlot`, `sjstats`, `performance`
- **Geospatial Analysis**: `sf`, `gganimate`, `ggspatial`, `plotly`
- **Data Wrangling**: `tidyverse`, `lubridate`, `dplyr`
- **Tables + Report Styling**: `gt`, `knitr`, `kableExtra`

---

## 📌 Key Insights (TL;DR)

- Fires closer to the Russian border and in summer months were more likely to be war-related
- Hierarchical modelling improved classification accuracy
- Interactive heatmaps and animations revealed clear spatial patterns

---

## 📚 Table of Contents
- [Background](#background)
- [Research Objectives](#research-objectives)
- [Hypotheses](#hypotheses)
- [Data](#data)
- [Methods](#methods)
- [Results](#results)
- [Key Visualizations](#key-visualizations)
- [Interactive Visualizations](#interactive-visualizations)
- [Implications and Limitations](#implications-and-limitations)
- [Getting Started](#getting-started)
- [References](#references)

---

## 🧭 Background

The conflict between Ukraine and Russia escalated into a full-scale war in 2022, leading to widespread destruction. Fires have become a common consequence of conflict-related incidents. This project examines the spatial and temporal patterns of fire incidents in Ukraine to determine whether these patterns can classify fires as war-related.

## 🎯 Research Objectives

The main goal is to assess whether spatial and temporal features can predict if a fire is war-related. Sub-questions include:

1. Are certain regions or seasons more associated with war-related fires?
2. Can population density and excess fire activity predict fire classification?
3. Which spatial-temporal patterns are most useful?

## 🧪 Hypotheses

- **H0**: Spatial and temporal factors do not influence fire classification.
- **H1**: Spatial and temporal features significantly improve fire classification.

## 📊 Data

- Over 60,000 fire records (2022–2024) from [The Economist / Kaggle Dataset]
- Includes latitude, longitude, date, population density, sustained fire activity
- GeoJSON used for regional mapping and spatial joins

### 🔧 Data Preparation
- Cleaned missing/unnecessary fields
- Reformatting time fields to seasons
- Converted to spatial data structures with `sf`

## ⚙️ Methods

Used **Generalized Linear Mixed Models (GLMM)** with both random intercept and random slope structures:

```r
# Random Intercept Model (RIM)
glmer(war_fire ~ population_density + sustained_excess_fires + 
      (1 | region) + (1 | season) + (1 | id_big), 
      data = TestData1, family = binomial)

# Random Slopes Model (RSM)
glmer(war_fire ~ population_density + sustained_excess_fires + 
      (1 + population_density | region) + (1 + sustained_excess_fires | season) + 
      (1 | id_big), 
      data = TestData1, family = binomial)
```

<details>
<summary>📦 R Packages Used</summary>

- `lme4`, `sjPlot`, `sjstats`, `performance`
- `sf`, `ggplot2`, `gganimate`, `plotly`
- `dplyr`, `lubridate`, `tidyverse`
- `knitr`, `gt`, `kableExtra`

</details>

## 📈 Results

<details>
<summary>Click to expand key findings</summary>

- **Spatial Concentration**: Eastern & Northern Ukraine have highest war-fire density
- **Seasonal Trend**: Fires peak between July and October
- **Statistical Findings**: 
  - Sustained fire activity: strong, consistent predictor (p < 2e-16)
  - Population density: significant only in RIM
  - RSM provided better model fit than RIM

</details>

## 🗺️ Key Visualizations

### 🧨 Animated Fire Map
![Animated Map](./Plots%20and%20Tables/ukraine_fire_animation.gif)

### 🌤️ Seasonal Trends Plot
![Seasonal Trends](./Plots%20and%20Tables/Seasonal%20Trends%20Plot.png)

---

## 🌍 Interactive Visualizations

- 🔥 [Live Interactive Heatmap](https://KetchupJL.github.io/university-projects/Predicted%20Probabilities%20of%20War-Related%20Fires%20Heatmap.html)
- Explore predicted probabilities by region & season

---

## 🧩 Implications and Limitations

### Implications
- Supports early warning systems and emergency planning
- Identifies high-risk areas and timeframes for resource allocation

### Limitations
- Binary fire variable lacks nuance (e.g. intensity/duration)
- Satellite occlusion (cloud cover) may underreport fires

## 📌 Future Work
- Enhance fire classification features with severity metrics
- Integrate conflict-specific ground reports with satellite data

---

## ⚙️ Getting Started

> This project runs in R with the following prerequisites:

```r
install.packages(c("ggplot2", "gganimate", "ggspatial", "plotly", "lme4", "tidyverse", "sf"))
```

---

## 📝 References

- The Economist / Kaggle Ukraine Fires Dataset
- R Documentation for `glmer`, `lme4`, `sjPlot`, `sf`

---

### 📄 [Full Project Report (PDF)](./MTHM501%20Report.pdf)

---

<p align="center">
  <img src="https://img.shields.io/badge/MSc%20Applied%20Data%20Science%20Project-Grade%3A%2082%25-blue?style=for-the-badge"/>
</p>
