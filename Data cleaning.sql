-- SQL Project - Data Cleaning
# Data cleaning involves following steps
-- 1. Remove duplicatess
-- 2. standardize the data
-- 3. Blank or null values
-- 4. Remove the column


-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
-- So create a same copy of layoff
create table layoff_staging
like layoffs;

-- insert into layoff_staging
insert layoff_staging
select * from layoffs;

select * from layoff_staging;

-- 1) Remove duplicates

#Here we get the unique values
select *, row_number()
over(partition by company, location, industry, total_laid_off,
 percentage_laid_off, `date`, stage, country, funds_raised_millions) as Row_Num
from layoff_staging;

# these are real duplicates
With duplicate_cte as
(
select *, row_number()
over(partition by company, location, industry, total_laid_off,
 percentage_laid_off, `date`, stage, country, funds_raised_millions) as Row_Num
from layoff_staging
)
select * from duplicate_cte where Row_Num > 1;

#one solution, which I think is a good one. Is to create a new column and add those row numbers in. Then delete where row numbers are over 2, then delete that column
CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
   `Row_Num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoff_staging2 where Row_Num > 1;

insert into layoff_staging2
select *, row_number()
over(partition by company, location, industry, total_laid_off,
 percentage_laid_off, `date`, stage, country, funds_raised_millions) as Row_Num
from layoff_staging;

DELETE from layoff_staging2 where Row_Num > 1;

---------------------------------------------------------------------------------

-- 2) Standardization of columns
#Checking each columns and standardizing them
#Checking company column
select company from layoff_staging2;
select company, trim(company) from layoff_staging2;

#update comapny column to remove the spaces
update layoff_staging2
set company = trim(company);

#checking and updating industry column to make the standard crypto names instead of crypto currency
select * from layoff_staging2 where industry like 'Crypto';
select distinct industry from layoff_staging2 order by 1;

update layoff_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

#nothing too clean here in this column location
select distinct location from layoff_staging2;

#Cleaning column country, Here we removed the trailings for United states values
select distinct country from layoff_staging2;
select distinct country from layoff_staging2 where country like 'United States%';

update layoff_staging2
set country = Trim(trailing '.' from country)
where country like 'United States%';

#here we have set the date column to new datatype that is date
select `date`, str_to_date(`date`,'%m/%d/%y') from layoff_staging2;

update layoff_staging2
set `date` = str_to_date(`date`,'%m/%d/%Y');

select `date` from layoff_staging2;

#Change the datatype of date as using above update statement didnt update it to date datatype
alter table layoff_staging2
modify column `date` Date;

#to look null use IS NULL 
select * from layoff_staging2 
where total_laid_off IS NULL and percentage_laid_off IS NULL;

----------------------------------------------------------------
-- 3) Seach missing and null values
select * from layoff_staging2
where industry IS NULL or industry = '';

select * from layoff_staging2
where company = 'Airbnb';

-- we should set the blanks to nulls since those are typically easier to work with
update layoff_staging2
set industry = ''
where industry = null;

-- now if we check those are all null
select t1.industry, t2.industry from layoff_staging2 t1
join layoff_staging2 t2
on t1.company = t2.company
and t1.location=t2.location
where (t1.industry IS NULL or t1.industry = '')
and t2.industry is not null;

-- now we need to populate those nulls if possible
update layoff_staging2 t1
join layoff_staging2 t2
on t1.company=t2.company
set t1.industry = t2.industry
where t1.industry IS NULL and t2.industry is not null;

-- 4. remove any columns and rows we need to

-- Delete Useless data we can't really use
delete from layoff_staging2
where total_laid_off is null and percentage_laid_off is null;

select * from layoff_staging2;

alter table layoff_staging2
drop column Row_Num;


