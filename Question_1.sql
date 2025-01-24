--Question 1

--Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?


SELECT 	
	ind_beg_end.industry,
	round(mzda1,2) AS avg_wage_beginning,
	round(mzda2,2) AS avg_wage_end,
	round(((power(mzda2/mzda1,1.0/(SELECT count(DISTINCT YEAR) FROM t_veronika_abonyiova_project_SQL_primary_final))::NUMERIC)-1)*100,2) AS avg_growth_perc, --geometric mean of the wage growth in % for the monitored period
	round((mzda2/mzda1-1)*100,2) AS total_growth_perc, --total growth in % for the monitored period
	(WITH --yearly average wage for each period together with average for the previous period
		yearly_wages AS (
		SELECT 
			YEAR,
			va.industry AS industry,
			average_wage,
			LAG(average_wage) OVER (PARTITION BY industry ORDER BY year) AS prev_average_wage
		FROM t_veronika_abonyiova_project_SQL_primary_final va
		GROUP BY YEAR, va.industry, va.average_wage
		)
	SELECT -- number of period where average wage is greater than average wage of the previous period
		count(*)
	FROM yearly_wages yw
	WHERE prev_average_wage<average_wage AND yw.industry = ind_beg_end.industry) AS wage_growth,
	(WITH --yearly average wage for each period together with average for the previous period
		yearly_wages AS (
		SELECT 
			YEAR,
			va.industry AS industry,
			average_wage,
			LAG(average_wage) OVER (PARTITION BY industry ORDER BY year) AS prev_average_wage
		FROM t_veronika_abonyiova_project_SQL_primary_final va
		GROUP BY YEAR, va.industry, va.average_wage
		)
	SELECT -- number of period where average wage is lower than average wage of the previous period
		count(*)
	FROM yearly_wages yw
	WHERE prev_average_wage>average_wage AND yw.industry = ind_beg_end.industry) AS wage_dec
FROM (WITH 
		min_year AS (SELECT 
			min(year)	
			FROM t_veronika_abonyiova_project_SQL_primary_final),
		max_year AS (SELECT 
			max(year)	
			FROM t_veronika_abonyiova_project_SQL_primary_final)
	SELECT 
		DISTINCT industry AS industry,
		(SELECT average_wage 
		FROM t_veronika_abonyiova_project_SQL_primary_final va2 
		WHERE YEAR in (SELECT * FROM min_year) AND va2.industry = va1.industry) AS mzda1,
		(SELECT average_wage 
		FROM t_veronika_abonyiova_project_SQL_primary_final va2 
		WHERE YEAR in (SELECT * FROM max_year) AND va2.industry = va1.industry) AS mzda2
		FROM t_veronika_abonyiova_project_SQL_primary_final va1
		WHERE industry IS NOT NULL) AS ind_beg_end
ORDER BY wage_growth desc;


