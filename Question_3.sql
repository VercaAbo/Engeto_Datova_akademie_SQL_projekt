-- Question 3

-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

SELECT 	
	prod_beg_end.product,
	round(price_beg,2) AS avg_price_beginning,
	round(price_end,2) AS avg_price_end,
	round(((power(price_end/price_beg,1.0/(SELECT count(DISTINCT YEAR) FROM t_veronika_abonyiova_project_SQL_primary_final))::NUMERIC)-1)*100,2) AS avg_growth_perc, --geometric mean of the wage growth in % for the monitored period
	round((price_end/price_beg-1)*100,2) AS total_growth_perc --total growth in % for the monitored period
FROM (WITH min_year AS (SELECT 
			min(year)	
			FROM t_veronika_abonyiova_project_SQL_primary_final),
		max_year AS (SELECT 
			max(year)	
			FROM t_veronika_abonyiova_project_SQL_primary_final)
	SELECT 
		DISTINCT va1.product AS product,
		(SELECT average_price 
		FROM t_veronika_abonyiova_project_SQL_primary_final va2 
		WHERE YEAR in (SELECT * FROM min_year) AND va2.product = va1.product) AS price_beg,
		(SELECT average_price 
		FROM t_veronika_abonyiova_project_SQL_primary_final va2 
		WHERE YEAR in (SELECT * FROM max_year) AND va2.product = va1.product) AS price_end
		FROM t_veronika_abonyiova_project_SQL_primary_final va1
	WHERE product IS NOT NULL) AS prod_beg_end
ORDER BY avg_growth_perc ASC;