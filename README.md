# 🧠 Early Childhood Development and Maternal Work
This study investigates how mothers’ employment status influences various aspects of child development, including the achievement of developmental milestones, weight, and overall health outcomes.
 
---

## 🛠️ Dataset and Methodology

- **Data:** The analysis is based on micro-level data,  Türkiye Child Survey Micro Data Set, collected in 2022.   
- **Methodology:** The study applies econometric techniques to explore the relationship between women’s maternal work and early childhood development, controlling for various socioeconomic factors. Advanced econometric techniques—including OLS and logit regressions, multiple hypothesis testing, and sample reweighting—were employed to ensure robust and credible empirical analysis. 

---

## 📂 Repository Structure

1. **`master.do`**: Runs all the individual `.do` files in the correct sequence to reproduce the full analysis.
2. **`database_creation.do`**:  Merges datasets and prepares for the analysis
3. **`variable_creation_child.do`**:  Constructs variables belongs to children
4. **`variable_creation_parents.do`**:  Constructs variables belongs to parents
5. **`variable_creation_households.do`**:  Retrieves variables on household characteristics 
6. **`sample_selection.do`**:  Performs sample selection and upweighting 
7. **`descriptives.do`**:  Produces descriptive statistics and figures 
8. **`results.do`**: Produces main results of the study
9. **`results_activity.do`**: Produces additional results on maternal work and parental engagement 
10. **`results_heterogeneity.do`**: Performs heterogeneity analysis to identify differences based on maternal education, grandparent presence, and fathers` status in household
11. **`figures.do`**: Reports figures

---

## 📂 Input Data Sources

### Türkiye Child Survey Micro Data Set, 2022

Access to the following datasets can be requested from TURKSTAT: [https://tuik_mikro_veri](https://www.tuik.gov.tr/Kurumsal/Mikro_Veri)  
TURKSTAT provides the original data folder in CSV format. For analysis purposes, the files should be converted to Stata (.dta) format, ensuring that variable names are in lowercase.

- `TCS_Household_Microdata.dta` – Household characteristics
- `TCS_Individual_0-17_Microdata.dta` – Child questionnaire 
- `TCS_Individuallist_Microdata.dta` – Household roster

---

## 📦 Required Stata Packages

Stata version 14 is required to perform the analysis.  
The following user-written Stata packages are required to run the do-files associated with this project:

| Name        | Description                                               | Package  |
|-------------|-----------------------------------------------------------|----------|
| **zanthro** | Anthropometric Z-scores                                   | dm0004_1 |
| **orth_out**| Automate and export summary stats/orthogonality tables    | orth_out |
| **stndzxage** | Standardized z-scores by age     | [stndzxage](https://ideas.repec.org/c/boc/bocode/s458634.html) |
| **eststo**  | Estimates storage and tabulation                          | st0085_2 |
| **mylabels**| Custom value labels for graphs                            |gr0092_1  |
| **wyoung**  | Adjust p-values for multiple tests                        |wyoung    |

---

## 🗂️ Folder Structure

To replicate the analysis, please ensure the following folder structure is in place. Microdata obtained from TURKSTAT should be placed in the `datain` folder. The provided do-files should be copied into the `do` folder. The folders `dataout`, `figures`, and `results` can remain empty initially, as they will be populated by the output generated during execution of the do-file.

<details>
<summary><strong>datain</strong></summary>  
 
- `TCS_Household_Microdata.dta`  
- `TCS_Individual_0-17_Microdata.dta`  
- `TCS_Individuallist_Microdata.dta`
  
</details>

<details>
<summary><strong>do</strong></summary>  
 
1. **`master.do`**   
2. **`database_creation.do`**  
3. **`variable_creation_child.do`**   
4. **`variable_creation_parents.do`**   
5. **`variable_creation_households.do`**   
6. **`sample_selection.do`**   
7. **`descriptives.do`**   
8. **`results.do`**   
9. **`results_activity.do`**   
10. **`results_heterogeneity.do`**  
11. **`figures.do`**
    
</details>

<details>
<summary><strong>dataout</strong></summary>
</details>

<details>
<summary><strong>figures</strong></summary>
</details>

<details>
<summary><strong>results</strong></summary>
</details>
