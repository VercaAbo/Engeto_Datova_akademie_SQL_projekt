-- Question 5
--Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
-- projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?


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
		YEAR AS YEAR,
		avg(average_wage) AS avg_wage
	FROM
		t_veronika_abonyiova_project_sql_primary_final
	WHERE industry IS NULL
	GROUP BY YEAR
	ORDER BY YEAR),
prices_growth AS (
	SELECT
		YEAR,
		avg_price,
		LAG(avg_price) OVER (
		ORDER BY YEAR) AS prev_avg_price,
		avg_price / LAG(avg_price) OVER (
		ORDER BY YEAR) AS yearly_growth_price_cur,
		LAG(avg_price) OVER (
		ORDER BY YEAR DESC) AS next_avg_price,
		LAG(avg_price) OVER (
		ORDER BY YEAR DESC)/ avg_price AS yearly_growth_price_next
	FROM
		yearly_avg_price
	GROUP BY
		YEAR,
		avg_price),
wages_growth AS (
	SELECT
		YEAR,
		avg_wage,
		LAG(avg_wage) OVER (
		ORDER BY YEAR) AS prev_avg_wage,
		avg_wage / LAG(avg_wage) OVER (
		ORDER BY YEAR) AS yearly_growth_wage_cur,
		LAG(avg_wage) OVER (
		ORDER BY YEAR DESC) AS next_avg_wage,
		LAG(avg_wage) OVER (
		ORDER BY YEAR DESC)/ avg_wage AS yearly_growth_wage_next
	FROM
		yearly_avg_wage
	GROUP BY
		YEAR,
		avg_wage),
GDP_growth AS (
	SELECT 	
		DISTINCT YEAR,
		gdp,
		LAG(vas2.gdp) OVER (PARTITION BY country ORDER BY vas2.year) AS gdp_prev,
		gdp / LAG(vas2.gdp) OVER (PARTITION BY country ORDER BY	vas2.year) AS gdp_growth_cur
	FROM
		t_veronika_abonyiova_project_SQL_secondary_final vas2
	WHERE
		country = 'Czech Republic')	
SELECT 
	-- commented columns below are prepared for the case that also absolute values are valuable for the team
	pg.YEAR,
	--vas.gdp/1000000000 AS GDP_in_mld,
	round((gg.gdp_growth_cur -1)* 100, 2) AS gdp_growth_cur,
	--round(pg.prev_avg_price,2) AS avg_price_prev,
	--round(pg.avg_price,2) AS avg_price,
	--round(pg.next_avg_price,2) AS avg_price_next,
	round((pg.yearly_growth_price_cur -1)* 100,	2) AS price_growth_cur,
	round((pg.yearly_growth_price_next -1)* 100, 2) AS price_growth_next,
	--round(wg.prev_avg_wage,2) AS avg_wage_prev,
	--round(wg.avg_wage,2) AS avg_wage,
	--round(wg.next_avg_wage,2) AS avg_wage_next,
	round((wg.yearly_growth_wage_cur -1)* 100, 2) AS wage_growth_cur,
	round((wg.yearly_growth_wage_next -1)* 100,	2) AS wage_growth_next,
	(WITH corelation_table AS (
		SELECT
				vas.YEAR AS YEAR,
				gg.gdp_growth_cur AS gdp_growth_cur,
				pg.yearly_growth_price_cur AS price_growth_cur,
				pg.yearly_growth_price_next AS price_growth_next,
				wg.yearly_growth_wage_cur AS wage_growth_cur,
				wg.yearly_growth_wage_next AS wage_growth_next
		FROM
			t_veronika_abonyiova_project_SQL_secondary_final vas
		JOIN wages_growth wg
			ON
			vas.YEAR = wg.YEAR
		JOIN prices_growth pg
			ON
			vas.YEAR = pg.YEAR
		JOIN GDP_growth gg
			ON
			gg.YEAR = vas.YEAR
		WHERE
			country = 'Czech Republic')
	SELECT 	
		round(CORR(gdp_growth_cur,
		price_growth_cur)::NUMERIC,
		4)
	FROM
		corelation_table) AS cor_gdp_price_growth_cur,
	(WITH corelation_table AS (
		SELECT
				vas.YEAR AS YEAR,
				gg.gdp_growth_cur AS gdp_growth_cur,
				pg.yearly_growth_price_cur AS price_growth_cur,
				pg.yearly_growth_price_next AS price_growth_next,
				wg.yearly_growth_wage_cur AS wage_growth_cur,
				wg.yearly_growth_wage_next AS wage_growth_next
		FROM
			t_veronika_abonyiova_project_SQL_secondary_final vas
		JOIN wages_growth wg
			ON
			vas.YEAR = wg.YEAR
		JOIN prices_growth pg
			ON
			vas.YEAR = pg.YEAR
		JOIN GDP_growth gg
			ON
			gg.YEAR = vas.YEAR
		WHERE
			country = 'Czech Republic')
	SELECT 	
		round(CORR(gdp_growth_cur,
		price_growth_next)::NUMERIC,
		4)
	FROM
		corelation_table) AS cor_gdp_price_growth_next,
	(WITH corelation_table AS (
		SELECT
				vas.YEAR AS YEAR,
				gg.gdp_growth_cur AS gdp_growth_cur,
				pg.yearly_growth_price_cur AS price_growth_cur,
				pg.yearly_growth_price_next AS price_growth_next,
				wg.yearly_growth_wage_cur AS wage_growth_cur,
				wg.yearly_growth_wage_next AS wage_growth_next
		FROM
			t_veronika_abonyiova_project_SQL_secondary_final vas
		JOIN wages_growth wg
			ON
			vas.YEAR = wg.YEAR
		JOIN prices_growth pg
			ON
			vas.YEAR = pg.YEAR
		JOIN GDP_growth gg
			ON
			gg.YEAR = vas.YEAR
		WHERE
			country = 'Czech Republic')
	SELECT 	
		round(CORR(gdp_growth_cur,
		wage_growth_cur)::NUMERIC,
		4)
	FROM
		corelation_table) AS cor_gdp_wage_growth_cur,
	(WITH corelation_table AS (
		SELECT
				vas.YEAR AS YEAR,
				gg.gdp_growth_cur AS gdp_growth_cur,
				pg.yearly_growth_price_cur AS price_growth_cur,
				pg.yearly_growth_price_next AS price_growth_next,
				wg.yearly_growth_wage_cur AS wage_growth_cur,
				wg.yearly_growth_wage_next AS wage_growth_next
		FROM
			t_veronika_abonyiova_project_SQL_secondary_final vas
		JOIN wages_growth wg
			ON
			vas.YEAR = wg.YEAR
		JOIN prices_growth pg
			ON
			vas.YEAR = pg.YEAR
		JOIN GDP_growth gg
			ON
			gg.YEAR = vas.YEAR
		WHERE
			country = 'Czech Republic')
	SELECT 	
		round(CORR(gdp_growth_cur,
		wage_growth_next)::NUMERIC,
		4)
	FROM
		corelation_table) AS cor_gdp_wage_growth_next
FROM
	prices_growth pg
JOIN wages_growth wg
	ON pg.YEAR = wg.YEAR
JOIN GDP_growth AS gg
	ON gg.YEAR = pg.YEAR
JOIN yearly_avg_price avp
	ON avp.YEAR = pg.YEAR
; 

