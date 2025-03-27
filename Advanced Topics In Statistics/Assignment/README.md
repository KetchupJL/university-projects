# Advanced Statistical Modelling: Reaction Times and Classification
## MSc Applied Data Science & Statistics – Coursework (MTHM017)

This repository contains the full analysis and code for a two-part coursework project undertaken as part of the *Advanced Topics in Statistics* module at the University of Exeter. The project integrates Bayesian inference via JAGS with supervised machine learning classification in R, demonstrating advanced statistical modelling techniques applied to real and simulated datasets.

---

## 🧠 Part A: Bayesian Inference – Modelling Reaction Times in Schizophrenic Patients

This section applies a hierarchical Bayesian model to assess the cognitive reaction times of individuals, contrasting schizophrenic and non-schizophrenic participants. The key research question investigates whether increased variability and delayed responses in schizophrenic patients are consistent with known symptoms such as motor retardation and attention deficit.

### Key Methods:
- **Hierarchical Normal Model** for non-schizophrenics.
- **Two-component Mixture Model** for schizophrenics incorporating:
  - Log-transformed reaction times
  - Latent delay indicators (Bernoulli)
  - Delay shift parameter (τ)
- **JAGS** used for model specification and MCMC sampling.

### Analysis Includes:
- Full JAGS model specification, with priors and likelihood structure.
- MCMC diagnostics (trace plots, autocorrelation, convergence).
- Posterior summaries and interval estimates for β, λ, and τ (transformed back to original scale).
- Posterior predictive checks using simulated draws from the fitted model.
- Scatterplot assessment of model fit via predicted versus empirical variance in reaction times.

---

## 🤖 Part B: Supervised Machine Learning – Group Classification

The second part of the project applies supervised learning algorithms to classify a simulated dataset into two groups based on explanatory variables X1 and X2. The classification aims to discover the latent decision boundary that generated the data with added noise.

### Methods Used:
- **Linear Discriminant Analysis (LDA)**
- **Quadratic Discriminant Analysis (QDA)**
- **k-Nearest Neighbours (k-NN)**
- **Support Vector Machines (SVM)**

### Evaluation:
- Models trained/tested with 75/25 train-test split.
- Cross-validation and hyperparameter tuning (e.g. k-value, kernel type).
- Performance evaluated using:
  - Accuracy
  - Confusion matrices
  - ROC curves and AUC
- Final performance benchmarked against true labels (from noise-free version of the dataset).

---

## Technologies Used
- **R**: Core analysis environment
- **JAGS**: Bayesian model fitting via Gibbs sampling
- **Packages**:
  - `rjags`, `coda`, `ggplot2`, `MASS`, `class`, `e1071`, `randomForest`, `caret`

---

## Project Context
- **Module**: MTHM017 Advanced Topics in Statistics  
- **Assessment**: Individual MSc Coursework  
- **Grade**: *Pending*  
- **Submission Date**: March 2025

---

## Files Included
- `Adv_stats_proj.Rmd` – Complete R Markdown report with code, analysis, and results
- `Adv_stats_proj.pdf` – Compiled report in PDF format
- `rtimes.csv` – Reaction times dataset for Bayesian modelling
- `Classification.csv`, `ClassificationTrue.csv` – Simulated data for classification task

---

## Author
**James Lewis**  
MSc Applied Data Science and Statistics  
University of Exeter

