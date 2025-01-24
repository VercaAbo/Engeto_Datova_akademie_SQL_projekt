-- creation of the secondary table


CREATE TABLE t_veronika_abonyiova_project_sql_secondary_final (
	country text,
	year int, 
	GDP NUMERIC,
	population TEXT,
	GINI numeric
	);

WITH 
-- common years for payrolls and prices
years AS (
	SELECT DISTINCT 
		cpay.payroll_year
		FROM czechia_payroll cpay
		INTERSECT 
		SELECT DISTINCT
		EXTRACT(year FROM cp.date_from)
	FROM czechia_price cp)
INSERT INTO t_veronika_abonyiova_project_SQL_secondary_final (country, year, GDP, population, gini)
	SELECT * FROM (SELECT 
	e.country, 
	e.YEAR,
	e.gdp AS GDP,
	e.population AS population,
	e.gini AS gini
	FROM economies e
	JOIN countries c
	ON c.country = e.country
	WHERE YEAR IN (SELECT * FROM years) AND c.continent = 'Europe')
	ORDER BY country, year;
