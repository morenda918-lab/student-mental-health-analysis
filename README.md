# Student Mental Health Analysis  
### A Quantitative Research Project on Depression Risk and Educational Policy Implications

---

## Research Background

Adolescent mental health has become a critical issue in contemporary educational systems.  
This project applies rigorous statistical modeling to examine how life stress events and psychosocial factors predict depression risk among students.

The study aims to support evidence-based educational decision-making and early identification mechanisms within school systems.

---

## Data Source

This research utilizes nationally representative student survey data from:

- **Taiwan Assessment of Student Achievement: Longitudinal Study (TASAL)**

**Sample Size:** 7,177 students  
**Survey Period:** 2024–2025  
**Population:** National student sample (Taiwan)

Due to privacy regulations, raw data are not publicly available.

---

## Research Objectives

1. Develop robust statistical indicators for identifying depression risk.
2. Examine key psychosocial predictors of mental health outcomes.
3. Compare predictive performance across modeling approaches.
4. Derive policy-relevant implications for educational administration.

---

## Analytical Framework

The analytical workflow includes:

- Data preparation and preprocessing
- Feature engineering
- Exploratory data analysis
- Correlation analysis
- Predictive modeling
- High-risk subgroup identification
- ROC curve evaluation

The modeling approach emphasizes interpretability and policy applicability rather than purely algorithmic optimization.

---

## Key Variables

- Depression score change
- Life stress events
- Sleep pattern change
- Family cohesion change
- Parent–child relationship change
- Self-esteem change
- Academic stress
- Gender

---

## Main Findings

### Full Sample Analysis

- Best model accuracy: **87.9%**
- Strongest predictors:
  - Life stress events
  - Sleep quality change
  - Family climate change
  - Self-esteem
- Life stress events significantly correlated with depression scores  
  *(r = .373, p < 2e-16)*

### High-Risk Subgroup

- Prediction accuracy above 60%
- ROC analysis indicates satisfactory discrimination
- Encoding comparisons suggest model refinement potential

---

## Policy Implications

- Establish early warning systems in schools.
- Develop targeted interventions for high-risk students.
- Improve resource allocation efficiency.
- Support data-driven educational governance.

---

## Project Structure
 ```
student-mental-health-analysis/
│
├── 01_data_preparation.R      # Data import and initial inspection
├── 02_risk_classification.R   # CES-D risk classification and transition patterns
├── 03_statistical_modeling.R  # Logistic regression modeling and ROC evaluation
├── 04_visualization.R         # Figure generation and visualization pipeline
│
├── README.md
├── LICENSE
└── .gitignore
```

---

## Reproducibility Notes

Intermediate datasets and generated outputs (e.g., cleaned data, model objects, and figures) are excluded from this repository to comply with data privacy regulations.

All scripts are executable and will reproduce the full analytical workflow when appropriate data access is available.


## Technical Environment

- R (4.x)
- tidyverse
- haven
- Statistical modeling procedures
- ROC analysis

---

## Reproducibility Statement

All scripts are fully documented and structured to allow replication using datasets with comparable variable structures.  
The project demonstrates transparent and modular research workflow design suitable for large-scale educational datasets.

---

## Author

Tzu-Shen Lin, PhD  
Quantitative Research in Adolescent Development and Educational Policy
