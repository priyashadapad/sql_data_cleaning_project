-- Exploratory Data Analysis

select * from layoff_staging2;

select max(total_laid_off), max(percentage_laid_off) from layoff_staging2;
select * from layoff_staging2 where percentage_laid_off = 1 order by total_laid_off desc;
select * from layoff_staging2 where percentage_laid_off = 1 order by funds_raised_millions desc;

select company, sum(total_laid_off) from layoff_staging2
group by company order by 2 desc;

select min(`date`),max(`date`) from layoff_staging2;

select industry, sum(total_laid_off) from layoff_staging2
group by industry order by 2 desc;

select country, sum(total_laid_off) from layoff_staging2
group by country order by 2 desc;

select year(`date`), sum(total_laid_off) from layoff_staging2
group by year(`date`) order by 1 desc;

select stage, sum(total_laid_off) from layoff_staging2
group by stage order by 2 desc;

select substring(`date`,1,7) as `Month`, sum(total_laid_off) from layoff_staging2
where substring(`date`,1,7) is not null
group by `Month` order by 1 asc;

with rolling_cte as
(select substring(`date`,1,7) as `Month`, sum(total_laid_off) as total from layoff_staging2
where substring(`date`,1,7) is not null
group by `Month` order by 1 asc)
select `Month`,total,sum(total) OVER(order by `Month`) AS rolling from rolling_cte;

select company, year(`date`), sum(total_laid_off) from layoff_staging2
group by company, year(`date`);

-- Here in the below query we use to cte to get the dense rank 
with cte(company, years, laidoff) as
(select company, year(`date`), sum(total_laid_off) from layoff_staging2
group by company, year(`date`)), 
cte2 as 
(select *, dense_rank() over(partition by years order by laidoff desc) as ranking from cte where years is not null)
select * from cte2 where ranking <=5;


