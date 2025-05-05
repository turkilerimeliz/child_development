# 🧠 Early Childhood Development and Maternal Work
This study investigates how mothers’ employment status influences various aspects of child development, including the achievement of developmental milestones, weight, and overall health outcomes.
 
---

## 🛠️ Dataset and Methodology

- **Data:** The analysis is based on micro-level data,  Türkiye Child Survey Micro Data Set, collected in 2022.   
- **Methodology:** The study applies econometric techniques to explore the relationship between women’s maternal work and early childhood development, controlling for various socioeconomic factors. Advanced econometric techniques—including OLS and logit regressions, multiple hypothesis testing, and sample reweighting—were employed to ensure robust and credible empirical analysis. 

---

## 📂 Repository Structure

1. **`master.do`**: Runs all the individual `.do` files in the correct sequence to reproduce the full analysis.
2. **`database_creation.do`**:  
3. **`variable_creation_child.do`**:  
4. **`variable_creation_parents.do`**:  
5. **`variable_creation_households.do`**:  
6. **`sample_selection.do`**:  
7. **`descriptives.do`**:  
8. **`results.do`**: 
9. **`results_activity.do`**: 
10. **`results_heterogeneity.do`**: 
11. **`figures.do`**: Reports figures

---

## 📂 Input Data Sources

### 1. Türkiye Child Survey Micro Data Set, 2022

Access to the following datasets can be requested from TURKSTAT: [https://tuik_mikro_veri](https://www.tuik.gov.tr/Kurumsal/Mikro_Veri)
TURKSTAT provides the original data folder in CSV format. For analysis purposes, the files should be converted to Stata (.dta) format, ensuring that variable names are in lowercase.

- `TCS_Household_Microdata.dta` – Household characteristics
- `TCS_Individual_0-17_Microdata.dta` – Child questionnaire 
- `TCS_Individuallist_Microdata.dta` – Household roster



