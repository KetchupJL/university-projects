# War-Related Fires in Ukraine: MTHM501 Project

**Project Overview**  
This project investigates whether spatial and temporal factors can be used to classify fires as war-related in Ukraine. It leverages data from the onset of the Russian invasion in February 2022 through October 2024, exploring the effects of regional proximity to conflict zones and seasonal variations on fire classification.
Grade: TBC

### [Full Project Report](./MTHM501%20Report.pdf) 


![Ukraine War Fires Animation](./Plots%20and%20Tables/ukraine_fire_animation.gif)

## Table of Contents
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

## Background
The conflict between Ukraine and Russia escalated into a full-scale war in 2022, leading to widespread destruction and thousands of civilian casualties. Fires have become a common consequence of conflict-related incidents, affecting both military and civilian infrastructure. Classifying these fires as war-related or non-war-related is essential for emergency response planning and conflict impact assessment. This project examines the spatial and temporal patterns of fire incidents in Ukraine, aiming to determine if these factors can accurately classify fires as war-related.

## Research Objectives
The primary objective of this project is to investigate if spatial and temporal factors can predict whether a fire incident is war-related. This includes understanding the distribution of war-related fires across different regions of Ukraine and observing if these incidents vary by season.

### Specific Questions
1. Are certain regions or seasons more associated with war-related fires?
2. Can factors like population density and sustained fire activity reliably predict war-related fires?
3. Which spatial and temporal patterns provide the most accurate predictions for classifying fires?

## Hypotheses
- **Null Hypothesis (H0)**: Spatial and temporal factors do not influence the classification of fires as war-related.
- **Alternative Hypothesis (H1)**: Spatial and temporal factors are significant predictors of war-related fires.

## Data
The analysis uses a primary dataset sourced from The Economist's Ukraine War-fire model, accessed through Kaggle. It contains over 60,000 observations with the following key variables:
- **Geospatial**: Latitude, longitude
- **Temporal**: Date, AQC time
- **Contextual**: Population density, sustained fire activity

Additionally, a GeoJSON file mapping Ukraine's regions is integrated to enhance the spatial analysis.

### Data Wrangling and Preprocessing
- **Cleaning**: Unnecessary fields were removed (e.g., ‘city’ and ‘year’), and missing values were handled. Variables were renamed for clarity.
- **Formatting**: Date variables were reformatted to capture seasonal trends, and categorical variables were prepared for modeling.
- **Spatial Context**: The data was transformed into spatial features to align with regional boundaries, facilitating a regional analysis of war-related fires.

## Methods
This analysis uses **hierarchical modeling** to account for the nested nature of spatial and temporal data, employing **Generalized Linear Mixed Models (GLMM)**. Specifically, two models were used:
1. **Random Intercept Model (RIM)**: Captures varying intercepts across regions and seasons.
2. **Random Slopes Model (RSM)**: Allows the slopes of population density and sustained fire activity to vary, capturing fluctuations across regions and seasons.

### Model Specifications
- **RIM**: `glmer(war_fire ~ population_density + sustained_excess_fires + (1 | region) + (1 | season) + (1 | id_big), data = TestData1, family = binomial)`
- **RSM**: `glmer(war_fire ~ population_density + sustained_excess_fires + (1 + population_density | region) + (1 + sustained_excess_fires | season) + (1 | id_big), data = TestData1, family = binomial)`

### Key R Packages
- **Data Manipulation**: `dplyr`, `tidyverse`
- **Visualization**: `ggplot2`, `gganimate`, `plotly`
- **Tables**: `knitr`, `kableExtra`, `gt`
- **Modeling**: `lme4`, `sjplot2`, `lmerTest`, `sjstats`
- **Spatial Analysis**: `sf`, `spatial`

## Results
The results indicate that spatial and temporal patterns significantly affect the classification of fires as war-related. Key findings include:
- **Regional Concentrations**: War-related fires are heavily concentrated in Eastern and Northern Ukraine, particularly near the Russian border.
- **Seasonal Patterns**: War-related fire incidents peak in the summer and autumn, with the highest daily averages observed from July to October.
- **Model Performance**: The RSM outperformed the RIM, offering a better fit by capturing regional and seasonal variations more effectively.

### Statistical Significance
- **Sustained Fire Activity**: Statistically significant across both models (p < 2e-16).
- **Population Density**: Significant only in the RIM, suggesting its effect varies when random slopes are included.

## Key Visualizations

### Animated Map
![Ukraine War Fires Animation](./ukraine_fire_animation.gif)
This animated map shows the progression of war-related fires in Ukraine over time. Red dots represent war-related fires, while grey dots indicate non-war fires. Created using `gganimate`, it provides a dynamic view of fire activity across regions from 2022 onward.

### Seasonal Trend Plot
The seasonal trend plot shows peaks in war-related fire activity between July and October, illustrating a temporal pattern that aligns with intensified conflict periods.

## Interactive Visualizations
An interactive heatmap of predicted probabilities for war-related fires is available. This map enables users to explore spatial and temporal patterns dynamically, showing higher probabilities in Eastern and Northern Ukraine and seasonal peaks.

### Accessing the Interactive Heatmap
The plot is also accessible on GitHub: [Interactive Heatmap](https://github.com/KetchupJL/university-projects).

## Implications and Limitations

### Implications
These findings have practical implications for conflict management and emergency response planning:
- **Resource Allocation**: High-risk regions and seasons can be prioritized for fire prevention and response.
- **Conflict Monitoring**: Temporal and spatial patterns provide insights into conflict escalation and its environmental impacts.

### Limitations
- **Binary Classification**: The sustained fire activity variable does not capture the intensity or duration of fires, limiting the depth of analysis.
- **Data Bias**: Cloud cover in satellite imagery may obscure some fires, potentially leading to underreporting.

### Future Research
Further studies could improve upon these findings by refining the sustained fire activity variable and incorporating conflict-specific data. Ground-based observations could also complement satellite data, providing a more comprehensive understanding of war-related fires.

## Getting Started

### Prerequisites
- **R and RStudio**: This project requires R for data processing and analysis.
- **Packages**: Install the required packages by running the following in R:
  ```R
  install.packages(c("ggplot2", "gganimate", "ggspatial", "plotly", "lme4", "tidyverse", "sf"))
