--Question 4

-- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?


WITH 
yearly_avg_price AS (
    SELECT
        year AS year,
        average_price AS avg_price
    FROM
        t_veronika_abonyiova_project_SQL_primary_final
    WHERE product IS NULL AND value_type = 'Průměrná cena'
  	GROUP BY YEAR, average_price
  	ORDER BY YEAR),
yearly_avg_wage AS (
    SELECT
        YEAR AS year,
        avg(average_wage) AS avg_wage
    FROM
        t_veronika_abonyiova_project_sql_primary_final
        WHERE industry IS NULL
        GROUP BY YEAR),
prices_growth AS (
    SELECT
        year,
        avg_price,
        LAG(avg_price) OVER (ORDER BY year) AS prev_avg_price,
        avg_price/LAG(avg_price) OVER (ORDER BY year) AS yearly_growth_price
    FROM yearly_avg_price
    GROUP BY YEAR, avg_price),
wages_growth AS (
    SELECT
        year,
        avg_wage,
        LAG(avg_wage) OVER (ORDER BY year) AS prev_avg_wage,
        avg_wage/LAG(avg_wage) OVER (ORDER BY year) AS yearly_growth_wage
    FROM yearly_avg_wage
    GROUP BY YEAR, avg_wage)
SELECT 
	pg.YEAR,
	round(pg.avg_price,2) AS avg_price,
	round(pg.prev_avg_price,2) AS avg_price_prev,
	round((pg.yearly_growth_price -1)*100,2) AS price_growth,
	round(wg.avg_wage,2) AS avg_wage,
	round(wg.prev_avg_wage,2) AS avg_wage_prev,
	round((wg.yearly_growth_wage -1)*100,2) AS wage_growth,
	round((pg.yearly_growth_price -1)*100,2) - round((wg.yearly_growth_wage -1)*100,2) AS growth_diff
FROM prices_growth pg
JOIN wages_growth wg
ON pg.YEAR = wg.YEAR
;
    
   
   
   