# Long-Term Phytoplankton Disruption in the Gulf of Mexico  
## A Zonal Time-Series Analysis of the Deepwater Horizon Spill

**MSc Communicating Data Science (MTHM507)**  
**University of Exeter | March 2025**

---

### Overview

This research project explores the long-term ecological impacts of the 2010 Deepwater Horizon oil spill on phytoplankton productivity and seasonal dynamics in the Gulf of Mexico. Using satellite-derived chlorophyll-a concentration data from NASA MODISA (2002–2017), the study performs zonal decomposition, time-series analysis, and spatial anomaly mapping to quantify phytoplankton disruption in relation to the spill footprint.

By combining remote sensing, seasonal-trend decomposition, and spatial-temporal analysis, the report provides evidence of a post-spill phytoplankton depression (2011–2014), followed by recovery. Key findings are contextualised with in situ and modelling literature, offering original insights into ecosystem resilience and disturbance cycles.

---

### Technologies Used

- **R (RStudio)**  
  - `tidyverse`, `ggplot2`, `raster`, `stars`, `lubridate`, `sf`  
  - `stats`, `forecast`, `stlplus`, `dplyr`, `tibble`, `leaflet`  
  - NetCDF data processing and visualisation  
- **NASA MODISA L3m Data**  
  - 4km resolution monthly chlorophyll-a (chlor_a) concentration  
  - Downloaded via NASA OceanColor Giovanni portal  
- **Quarto** for scientific report generation  
- **LaTeX** (xelatex) for PDF rendering

---

### Key Methods

- **Zonal Chlorophyll Time-Series Analysis**  
  - Gulf partitioned into subregions: Spill Zone, Near Spill, and Control Zones  
  - STL decomposition applied to chlorophyll time-series in each zone  

- **Spatial Chlorophyll Anomaly Mapping**  
  - Spatial anomalies derived relative to a 2002–2009 climatology  
  - Focused visualisation of the 2010–2014 impact window

- **Comparative Statistics**  
  - Seasonal peak/mean comparisons pre- and post-2010  
  - Contextualised with environmental drivers (e.g. Mississippi discharge)

- **Literature-Integrated Interpretation**  
  - Findings integrated with biological, chemical, and remote sensing studies post-DWH  
  - Emphasis on spatial heterogeneity, species shifts, and carbon cycling

---

### Research Highlights

- Satellite time-series showed a depression in surface chlorophyll from 2011–2014 across the spill zone, consistent with ecological studies.
- Localised bloom anomalies were detected in August 2010 but were likely influenced by nutrient pulses from the Mississippi.
- Spatial patterns revealed stronger perturbation within the northern Gulf shelf, with long-term chlorophyll reduction isolated to affected zones.
- The recovery of phytoplankton productivity after ~2015 suggests resilience but with possible long-term changes in species composition.

---

### How to Run (Optional)

1. Clone the repo or download chlorophyll NetCDF files from NASA OceanColor:
   - `https://oceandata.sci.gsfc.nasa.gov`
2. Use the R scripts to:
   - Load and clean data
   - Run STL decomposition
   - Create chlorophyll anomaly maps
   - Export figures and tables

---

### Licence

Academic use only. Based on coursework submitted for MTHM507 – Communicating Data Science at the University of Exeter.

---

### Author

James Lewis  
MSc Applied Data Science and Statistics (2024–2025)  
[GitHub Profile](https://github.com/KetchupJL)
