# Advanced Statistical Modelling: Reaction Times and Classification
### MSc Applied Data Science & Statistics – University of Exeter

This project explores advanced statistical modelling through two distinct approaches: **Bayesian hierarchical modelling of cognitive reaction times** and **supervised machine learning classification**. The work demonstrates strong applied skills in R, JAGS, and statistical communication, and was submitted as part of the *Advanced Topics in Statistics (MTHM017)* module.

> 📄 [View Full Report (PDF)](./Adv_stats_proj.pdf)

---

## 📌 Overview

### 🔹 Part A: Bayesian Modelling of Reaction Times
This analysis models cognitive reaction times for **schizophrenic** and **non-schizophrenic** individuals using:
- A **hierarchical normal model** for non-schizophrenics
- A **two-component mixture model** for schizophrenics, incorporating:
  - A Bernoulli latent delay indicator
  - A log-transformed delay term (τ)
  - A shift parameter (β) for reaction time inflation

> Models implemented using **JAGS** with detailed MCMC diagnostics, posterior summaries, predictive simulations, and variability assessments.

### 🔹 Part B: Classification of Simulated Data
A supervised machine learning pipeline is used to classify synthetic groups from two predictors (X1, X2), using:
- **K-Nearest Neighbours (KNN)** – tuned via cross-validation
- **Quadratic Discriminant Analysis (QDA)**
- **Random Forest (RF)** – with variable importance
- **Support Vector Machines (SVM)** – tested with RBF, polynomial, and sigmoid kernels

> Evaluated via accuracy, sensitivity/specificity, ROC-AUC, and confusion matrices.

---

## 🧠 Key Learning Outcomes
- Bayesian hierarchical modelling using JAGS
- MCMC simulation, convergence diagnostics, and posterior inference
- Probabilistic modelling of latent processes (delay likelihood)
- Practical experience with classification algorithms and tuning
- Interpretation and communication of statistical models

---

## 🛠️ Tools & Technologies

| Category             | Tools & Packages                                             |
|----------------------|--------------------------------------------------------------|
| **Bayesian Modelling** | `rjags`, `coda`, `MCMCvis`, `R2jags`, `tidyverse`             |
| **Machine Learning**   | `class`, `e1071`, `caret`, `randomForest`, `MASS`             |
| **Visualisation**     | `ggplot2`, `gt`, `lattice`                                   |
| **Report**            | RMarkdown & PDF (Quarto-compatible structure)               |

---

## 🧪 Project Components

```
├── Adv_stats_proj.Rmd      # Reproducible code + write-up
├── Adv_stats_proj.pdf      # Full coursework report
├── rtimes.csv              # Reaction time dataset
├── Classification.csv      # Training data for classification task
├── ClassificationTrue.csv  # Ground truth for classification evaluation
```

---

## 🧾 Context
- **Module**: MTHM017 – Advanced Topics in Statistics  
- **Type**: Individual MSc Coursework  
- **Grade**: *Pending*  
- **Submission Date**: March 2025

---

<p align="center">
  <img src="https://img.shields.io/badge/Bayesian%20Modelling-JAGS-blue?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/ML%20Classification-KNN%2C%20QDA%2C%20SVM%2C%20RF-orange?style=for-the-badge"/>
</p>

> Questions or feedback? Contact: **james066lewis@gmail.com**
