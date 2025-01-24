-- Question 2

-- Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?


WITH 
min_year AS (SELECT 
	min(year)	
	FROM t_veronika_abonyiova_project_sql_primary_final),
max_year AS (SELECT 
	max(year)	
	FROM t_veronika_abonyiova_project_SQL_primary_final)
SELECT 
	YEAR,
	(SELECT round(avg(average_wage),2)
	FROM t_veronika_abonyiova_project_SQL_primary_final va3
	WHERE industry IS NULL AND va3.YEAR = va.YEAR) AS avg_wage,
	round((SELECT 
		average_price 
	 FROM t_veronika_abonyiova_project_SQL_primary_final va1
	 WHERE va.YEAR = va1.YEAR AND product = 'Mléko polotučné pasterované'),2) AS avg_price_milk,
	round(round(avg(average_wage),2)/round((SELECT 
		average_price 
	 FROM t_veronika_abonyiova_project_SQL_primary_final va1
	 WHERE va.YEAR = va1.YEAR AND product = 'Mléko polotučné pasterované'),2),2) AS amount_of_milk,
	 round((SELECT 
		average_price 
	 FROM t_veronika_abonyiova_project_SQL_primary_final va1
	 WHERE va.YEAR = va1.YEAR AND product = 'Chléb konzumní kmínový'),2) AS avg_price_bread,
	round(round(avg(average_wage),2)/round((SELECT 
		average_price 
	 FROM t_veronika_abonyiova_project_SQL_primary_final va1
	 WHERE va.YEAR = va1.YEAR AND product = 'Chléb konzumní kmínový'),2),2) AS kg_of_bread
FROM t_veronika_abonyiova_project_sql_primary_final va
WHERE YEAR IN (SELECT * FROM min_year) OR YEAR IN (SELECT * FROM max_year)
GROUP BY va.YEAR
ORDER BY YEAR ASC;
