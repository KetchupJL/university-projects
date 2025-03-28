# MTHM503 – Applications of Data Science and Statistics

### MSc Applied Data Science & Statistics – Coursework Project

This project comprises three diverse sections showcasing applied data science workflows: **dimensionality reduction and classification of gene expression data**, **regression analysis of sea level trends**, and **unsupervised clustering of power demand profiles**. The work integrates statistical modelling, machine learning, and exploratory analysis using R and Python.

> 📊 Grade: 74% | University of Exeter – March 2025

<p align="center">
  <a href="./MTHM503_Project.pdf">
    <img src="https://img.shields.io/badge/View%20Full%20Report-PDF-blue?style=for-the-badge"/>
  </a>
</p>

---

## 🔍 Section A: Gene Expression Classification (PCA + Logistic Regression)

- **Objective**: Predict tumour type using microarray gene expression data (54,000+ features)
- **Steps**:
  - Data cleaning, scaling, and exploratory analysis
  - **Principal Component Analysis (PCA)** for dimensionality reduction
  - Logistic Regression classifier trained on top 55 PCs (explaining 90% of variance)
  - Model evaluated using test accuracy (88%)

### Key Takeaways
- PCA visualisation shows early clustering by cancer type
- Logistic regression effectively handles high-dimensional inputs after transformation

---

## 🌊 Section B: Sea Level Change Modelling

- **Objective**: Model long-term trends in sea level rise (2000–2024) across 3 global locations
- **Method**: Linear regression applied to monthly satellite-derived measurements
- **Evaluation**:
  - R² scores: World (0.94), Bering Sea (0.53), Mediterranean (0.14)
  - Residual analysis highlights strong seasonality in regional data

### Visuals
- Time series plots with fitted trend lines
- Residual plot showing volatility in Mediterranean and Bering Sea

---

## ⚡ Section C: Power Demand Clustering via Hierarchical Methods

- **Objective**: Identify daily power usage profiles across over 500 substations
- **Steps**:
  - Normalised weekday profiles from 10-minute interval data
  - Distance matrix and Ward linkage hierarchical clustering
  - Optimal cluster count = 6 (Silhouette Score: 0.486)

### Interpretation
- Clusters reflect different daily consumption patterns:
  - Sharp peaks, gradual builds, stable baselines
  - Business vs. residential or industrial usage signatures

### Visuals
- Clustermap of distance matrix
- Dendrogram of substation profiles
- Silhouette plot
- Daily demand patterns by cluster

---

## 🧠 Skills Developed
- Principal Component Analysis and variance analysis
- Classification using logistic regression and accuracy metrics
- Time series regression and residual diagnostics
- Unsupervised clustering and silhouette evaluation
- Data cleaning, transformation, and visual storytelling

---

## Project Files
```
├── MTHM503_Project.pdf        # Full project report
├── gene_file.csv              # Gene expression dataset
├── sealevel.csv               # Global sea level measurements
├── January_2013.csv           # Power usage dataset
├── code/                      # Scripts for each section
├── plots/                     # Visual outputs (cluster plots, PCA, regression)
```

---

## Technologies Used
- **Python**: `pandas`, `scikit-learn`, `matplotlib`, `seaborn`, `scipy`
- **R (optional extension)**: For statistical visualisation and reporting

---

<p align="center">
  <img src="https://img.shields.io/badge/Dimensionality%20Reduction-PCA-yellow?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Unsupervised%20Learning-Clustering-green?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Trend%20Analysis-Regression-blue?style=for-the-badge"/>
</p>

> For queries or collaboration: **james066lewis@gmail.com**
