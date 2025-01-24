-- creation of the primary table 
CREATE TABLE t_veronika_abonyiova_project_SQL_primary_final (
    year INT,
    average_wage NUMERIC,
    industry TEXT,
    average_price NUMERIC,
    product TEXT,
    value_type text
);

-- inserting data into the primary table
WITH 
-- common years for payrolls and prices
years AS (
	SELECT DISTINCT 
		cpay.payroll_year
		FROM czechia_payroll cpay
		INTERSECT 
		SELECT DISTINCT
		EXTRACT(year FROM cp.date_from)
	FROM czechia_price cp),
-- for each product, number of years where we have data
years_of_prices AS (
	SELECT 
		category_code,
		count(category_code) AS price_years_count,
		(SELECT count(*) FROM years) AS years,
		count(category_code)/(SELECT count(*) FROM years)::NUMERIC AS rate
	FROM (
		SELECT 
			EXTRACT(year FROM cp.date_from) AS YEAR,
			cp.category_code,
			avg(cp.value) as average_price	
		FROM czechia_price cp
		GROUP BY YEAR, category_code)
	GROUP BY category_code),
-- list of products where number of years with data is less than half of all analyzed years
insuff_data_products AS (
	SELECT 
		category_code
	FROM years_of_prices
	WHERE years_of_prices.rate < 0.5),
-- for each industry, number of years where we have data
years_of_wages AS (
	SELECT 
		industry,
		count(industry) AS wage_years_count,
		(SELECT count(*) FROM years) AS years,
		count(industry)/(SELECT count(*) FROM years)::NUMERIC AS rate
	FROM (
		SELECT 
			cpay.payroll_year AS YEAR,
			cpay.industry_branch_code AS industry,
			avg(cpay.value) AS average_wage	
		FROM czechia_payroll cpay
		WHERE value_type_code = '5958' AND cpay.payroll_year IN (SELECT * FROM years) AND cpay.industry_branch_code IS NOT null
		GROUP BY YEAR, cpay.industry_branch_code)
	GROUP BY industry),
-- list of industries where number of years with data is less than half of all analyzed years
insuff_data_wages AS (
	SELECT 
		industry
	FROM years_of_wages
	WHERE years_of_wages.rate < 0.5)
INSERT INTO t_veronika_abonyiova_project_SQL_primary_final (year, average_wage, industry, average_price, product, value_type)
SELECT * 
	--average wages per years/industries and per year without industry detail
	FROM (SELECT 
		cpay.payroll_year AS YEAR,
		avg(cpay.value) AS average_wage,
		cpib.name AS industry,
		NULL AS average_price,
		NULL AS product,
		'Průměrná mzda' AS value_type
	FROM czechia_payroll cpay
	LEFT JOIN czechia_payroll_industry_branch cpib
		ON cpay.industry_branch_code = cpib.code
	WHERE cpay.value_type_code = 5958 AND cpay.payroll_year IN (SELECT * FROM years)
	GROUP BY cpay.payroll_year, cpib.name
UNION 
	--average prices per years/products
	SELECT 
		EXTRACT(year FROM cp.date_from) AS YEAR,
		null AS average_wage,
		null AS industry,
		avg(cp.value) as average_price,
		cpc.name AS product,
		'Průměrná cena' AS value_type
	FROM czechia_price cp
	LEFT JOIN czechia_price_category cpc 
		ON cp.category_code = cpc.code
	WHERE EXTRACT(year FROM cp.date_from) IN (SELECT * FROM years) AND cp.category_code NOT IN (SELECT * FROM insuff_data_products) AND cp.region_code IS null
	GROUP BY EXTRACT(year FROM cp.date_from), cpc.name
UNION
	-- average prices per year without product detail 
	SELECT
	EXTRACT(year FROM cp.date_from) AS YEAR,
		null AS average_wage,
		null AS industry,
		avg(cp.value) as average_price,
		null AS product,
		'Průměrná cena' AS value_type
	FROM czechia_price cp
	LEFT JOIN czechia_price_category cpc 
		ON cp.category_code = cpc.code
	WHERE EXTRACT(year FROM cp.date_from) IN (SELECT * FROM years) AND cp.category_code NOT IN (SELECT * FROM insuff_data_products) AND cp.region_code IS null
	GROUP BY EXTRACT(year FROM cp.date_from))
ORDER BY YEAR, industry, product;
