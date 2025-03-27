# 🌿 Long-Term Phytoplankton Disruption in the Gulf of Mexico  
### *A Zonal Time-Series Analysis of the Deepwater Horizon Oil Spill*

This MSc research project investigates the long-term ecological impact of the 2010 Deepwater Horizon (DWH) oil spill on phytoplankton productivity in the Gulf of Mexico. Leveraging satellite-derived chlorophyll-a data, spatial analysis, and advanced time-series decomposition techniques, this study identifies how phytoplankton dynamics were disrupted—and to what extent they recovered—following one of the most significant marine pollution events in history.

---

## 🔍 Overview

- **Research Aim**  
  To quantify the long-term impacts of Deepwater Horizon on chlorophyll-a concentrations (a proxy for phytoplankton biomass) and to evaluate ecosystem recovery across spatial zones. The project also investigates whether similar disturbances are observed in other Gulf of Mexico oil spill events.

- **Analytical Strategy**  
  - Zonal time-series STL decomposition  
  - Chlorophyll residual mapping (2010–2014)  
  - Event-aligned time-series extraction for 127 oil spills  
  - Comparative analysis of top 15 spills by potential volume  
  - Evaluation of recovery slope and post-impact trajectories

- **Key Finding**  
  The Deepwater Horizon event produced an ecologically exceptional, multi-year suppression of phytoplankton productivity that was not observed in other Gulf spills—demonstrating the importance of spatial scale, duration, and exposure intensity in driving ecosystem responses.

---

## 🧰 Tools & Technologies

| Category             | Tools & Packages                                                                  |
|----------------------|-----------------------------------------------------------------------------------|
| **Programming**       | R (v4.3+)                                                                         |
| **Spatial Analysis**  | `terra`, `sf`, `stars`, `exactextractr`                                           |
| **Time-Series**       | `forecast`, `zoo`, `tsibble`, `lubridate`                                        |
| **Data Wrangling**    | `dplyr`, `purrr`, `tidyr`, `stringr`                                              |
| **Visualisation**     | `ggplot2`, `ggridges`, `viridis`, `patchwork`, `gt`                               |
| **Reporting**         | Quarto (`.qmd`) – reproducible scientific reporting framework                    |

---

## 📈 Key Analyses

1. **STL Decomposition of Zonal Time-Series**  
   Seasonal and trend disruption assessed across three defined regions: DWH Core, Wider Spill Zone, and Offshore Control.

2. **Spatial Residual Mapping (2010–2014)**  
   Mapped chlorophyll anomalies to identify geographic patterns in post-spill ecosystem behaviour.

3. **Event-Aligned Spill Analysis**  
   Constructed time-series around 127 spill events to evaluate chlorophyll responses pre- and post-disturbance.

4. **Top 15 Spill Evaluation**  
   Subset analysis based on maximum potential volume to test for signal scaling with spill magnitude.

5. **Recovery Trajectory Assessment**  
   Modelled post-spill trend slopes to determine the persistence, directionality, and completeness of recovery.

---

## 🧠 Skills Developed

- Application of ecological remote sensing techniques
- Advanced time-series decomposition (STL)
- Spatial zonal statistics and control zone design
- Scientific visualisation and reproducible reporting
- Handling and integrating large satellite datasets in R

---

## 📘 Citation

> Lewis, J. (2025). *Long-Term Phytoplankton Disruption in the Gulf of Mexico: A Zonal Time-Series Analysis of the Deepwater Horizon Spill*. MSc Communicating Data Science, University of Exeter.

---

## 📬 Contact

To discuss this project, share feedback, or explore collaboration:

- GitHub: [@KetchupJL](https://github.com/KetchupJL)  
- University of Exeter – MSc Applied Data Science (2024–2025)
