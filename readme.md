# SPMI II RE-AIM Analysis Project

This repository contains all materials for the preliminary **RE-AIM cross-site analysis** for the SPMI II initiative. The goal of this project is to produce reproducible, high-quality data processing, exploratory visualizations, and a brief scientific report summarizing early implementation patterns across sites.

### **Project Structure**

```
spmi-reaim/
├─ data-raw/        # Original data inputs
├─ data/            # Cleaned, analysis-ready datasets
├─ figures/         # Exported plots
├─ R/               # Reusable scripts for data cleaning and analysis
│   ├─ analysis.R            # Exploratory analysis sandbox
│   └─ requirements.R        # List of required packages
├─ renv/            # R virtual environment  
├─ reports/         # R Markdown / Quarto deliverables
│   └─ reaim_report.Rmd
└─ README.md        # Project overview
```

### **Workflow**

1. Raw files into `data-raw/`.
2. ~~Run `R/01_clean_reaim.R` to generate~~ Manually clean raw data into `data/reaim_site_level.csv`.
3. Knit `reports/reaim_report.Rmd` to produce the HTML report and figures. (Not done)