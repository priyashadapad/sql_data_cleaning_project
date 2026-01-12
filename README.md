# SQL Data Cleaning Project – Layoffs Dataset

## Project Overview

This project focuses on cleaning and preparing raw layoffs data using SQL. The objective was to transform messy, inconsistent data into a clean, analysis-ready dataset by applying practical data cleaning techniques commonly used in analytics and data engineering workflows.

The project demonstrates SQL skills such as handling duplicates, standardizing text fields, fixing date formats, managing null values, and removing unusable records.

---

## Tools & Technologies

* SQL (MySQL Workbench)
* Window Functions (ROW_NUMBER) for duplicate handling
* Common Table Expressions (CTEs) for validation
* DDL & DML commands for table creation, updates, and deletes

---

## Dataset Description

The dataset contains company layoff information with the following columns:

* company
* location
* industry
* total_laid_off
* percentage_laid_off
* date
* stage
* country
* funds_raised_millions

A staging table approach was used to ensure raw data safety during cleaning.

---

## Data Cleaning Steps

### 1. Created a Staging Table

To protect the raw data, a staging table was created before performing transformations:

```sql
CREATE TABLE layoff_staging LIKE layoffs;
INSERT INTO layoff_staging SELECT * FROM layoffs;
```

---

### 2. Removed Duplicate Records

Duplicates were identified using ROW_NUMBER() across all relevant columns:

```sql
ROW_NUMBER() OVER (
  PARTITION BY company, location, industry, total_laid_off,
  percentage_laid_off, date, stage, country, funds_raised_millions
)
```

Duplicate rows were removed by creating a new table and deleting rows with `Row_Num > 1`.

---

### 3. Standardized Data

Columns were cleaned and standardized:

* **Company** – Trimmed extra spaces
* **Industry** – Standardized variations (e.g., "Crypto Currency" → "Crypto")
* **Country** – Removed trailing characters (e.g., "United States." → "United States")
* **Date** – Converted from text to proper DATE datatype

```sql
UPDATE layoff_staging2
SET company = TRIM(company);
```

---

### 4. Handled Null and Blank Values

* Identified missing values using `IS NULL`
* Populated missing industry values using self-joins
* Removed records where both `total_laid_off` and `percentage_laid_off` were null

```sql
DELETE FROM layoff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
```

---

### 5. Removed Temporary Columns

Columns used for cleaning, such as `Row_Num`, were removed after cleaning was completed:

```sql
ALTER TABLE layoff_staging2
DROP COLUMN Row_Num;
```

---

## Outcome

* Cleaned, standardized, and deduplicated dataset
* Correct data types applied
* Ready for analysis, reporting, or integration with BI tools

---

## Key Learnings

* Practical experience with real-world data cleaning
* Effective use of window functions to handle duplicates
* Importance of staging tables in data workflows
* Handling inconsistent text and date formats in SQL
* Preparing datasets for downstream analytics

