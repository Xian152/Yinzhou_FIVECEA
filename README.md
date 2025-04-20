---
title: "Effectiveness and Cost-effectiveness of a Free Influenza Vaccination Policy for Older Adults: Real-world Evidence from 179,878 Participants using a Regional Digital Health Platform"
author: "Xian Zhang"
date: "2025-04-15"
output: html_document
---
# Project Title: [Effectiveness and Cost-effectiveness of a Free Influenza Vaccination Policy for Older Adults: Real-world Evidence from 179,878 Participants using a Regional Digital Health Platform]

## Overview

This repository contains the cost-effectiveness analysis (CEA) code associated with the study:

**"[Effectiveness and Cost-effectiveness of a Free Influenza Vaccination Policy for Older Adults: Real-world Evidence from 179,878 Participants using a Regional Digital Health Platform]"**

We evaluated the cost-effectiveness of a government-funded trivalent influenza vaccination policy for older adults in China during the 2020/21 flu season. The analysis was conducted from both societal and healthcare system perspectives.

## Repository Structure

project-folder/
├── 1. CEA_basecase_scenario.do           # define basecase analysis and scenario analyses
├── 2. Single_parameter_analyses.do       # sensitivity analyses: single parameter analysis
├── 3. CEA_tornado_figure.Rmd             # sensitivity analyses: tornado figure for single parameter analysis
├── 4. Monte_Carlo_Samplying.do           # sensitivity analyses: monte carlo samplying and analysis
├── ceaparameter.xlsx                     # parameter input
├── LICENSE
└── README.md


## Method Summary

- **Approach**: Cost-effectiveness analysis (CEA)
- **Population**: Older adults (≥65 years) in a real-world cohort
- **Model**: Decision-tree Model
- **Perspectives**: Societal and healthcare system
- **Outcomes**: Incremental cost-effectiveness ratio (ICER)
- **Uncertainty**: One-way and probabilistic sensitivity analysis
- **Scenario Analyses**: 1.	Extended Age Eligibility: Expanding free vaccination eligibility from adults aged ≥70 to all individuals aged ≥60.
                         2. High-Risk Prioritization: Prioritizing individuals with chronic conditions for all individuals aged ≥65 for free vaccination.

---

## 💻 Software Requirements
- **STATA version**: ≥ 13
- **R version**: ≥ 4.2

Before running the scripts, please install the required R packages：
```{r cars}
install.packages(c("heemod", "BCEA", "dplyr", "ggplot2", "reshape2", "readr", "tidyverse", "haven", "stringr", "patchwork", "gridExtra", "plotrix", "ggbreak", "break"))
```
