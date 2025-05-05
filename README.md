# 🧠 Early Childhood Development and Maternal Work
This study investigates how mothers’ employment status influences various aspects of child development, including the achievement of developmental milestones, weight, and overall health outcomes.
 
---

## 🛠️ Dataset and Methodology

- **Data:** The analysis is based on micro-level data,  Türkiye Child Survey Micro Data Set, collected in 2022.   
- **Methodology:** The study applies econometric techniques to explore the relationship between women’s maternal work and early childhood development, controlling for various socioeconomic factors. Advanced econometric techniques—including OLS and logit regressions, multiple hypothesis testing, and sample reweighting—were employed to ensure robust and credible empirical analysis. 

---

## 📂 Repository Structure

1. **`master.do`**: Runs all the individual `.do` files in the correct sequence to reproduce the full analysis.
2.  **`database_creation_parents.do`**: Identifies parents' demographics
3. **`years_schooling.do`**: Imputes years of schooling based on ISCED
4. **`database_childw'x'.do`**: Identifies respondents' children
5. **`variable_creation_child.do`**: Combines information from several waves to produce final variables
6. **`job_history_parents.do`**: Combines child age with parents' job histories
7. **`job_episode.do`**: Creates the main dataset to produce age-earning profiles
8. **`job_episode_country.do`**: Estimates parental wage income using age-earning profiles
9. **`family_background.do`**: Constructs family background characteristics
10. **`main_dataset.do`**: Produces the master dataset
11. **`results.do`**: Reports tables
12. **`figures.do`**: Reports figures

---

## 📂 Input Data Sources

### 1. Türkiye Child Survey Micro Data Set, 2022

Access to the following datasets can be requested from TURKSTAT: [https://tuik_mikro_veri](https://www.tuik.gov.tr/Kurumsal/Mikro_Veri)
TURKSTAT provides the original data folder in CSV format. For analysis purposes, the files should be converted to Stata (.dta) format, ensuring that variable names are in lowercase.

- `TCS_Household_Microdata.dta` – Household characteristics
- `TCS_Individual_0-17_Microdata.dta` – Child questionnaire 
- `TCS_Individuallist_Microdata.dta` – Household roster



