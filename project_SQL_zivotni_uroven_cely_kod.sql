# p_Radka_Matouchova_project_SQL
SQL project version Maria DB 22.0.4

-- SQL skript generující primární a sekundární tabulky

CREATE OR REPLACE TABLE t_radka_matouchova_project_SQL_mezivypocet_01 AS /*průměrná ceny potravin ze všech českých krajů*/
   SELECT
          *,
          ROUND(AVG(value),2) AS avg_price 
    FROM
	  (SELECT
	          *,
	          SUBSTRING(date_from,1,4) AS `year`
	     FROM czechia_price
	  ) AS mezivypocet
GROUP BY 
	 year,
	 category_code;
/*pozn. k ř. 13: nový sloupec s vyfiltrovyným rokem pro pozdějsí sloučení tabulek mezd a cen potravin*/

CREATE OR REPLACE TABLE t_radka_matouchova_project_SQL_mezivypocet_02 AS /*průměrné mzdy všech odvětví českého hospodářství za vybrané roky*/
   SELECT
	  name AS industry_branch,
	  payroll_year,
	  ROUND(AVG(value),0) AS average_income /*čtvtletní průměr mezd*/
     FROM czechia_payroll AS cp
INNER JOIN czechia_payroll_industry_branch cpib 
       ON cpib.code = cp.industry_branch_code
    WHERE `value_type_code` = 5958 
      AND payroll_year >= 2006 
      AND payroll_year <= 2018
 GROUP BY 
 	  name, 
	  payroll_year;
 /*pozn. k ř.29: vyfiltrování mezd od počtu zaměstnanců
pozn. k ř.30 a 31: vyfiltrování let podle tabulky czechia_price*/

CREATE OR REPLACE TABLE t_radka_matouchova_project_SQL_primary_final AS /*sloučené neslučitelné tabulky mezd všech odvětví a cen všech produktů*/
   SELECT
	  radka01.year,
	  cpc.name AS grocery,
	  avg_price,
	  price_unit,
	  radka02.industry_branch,
	  average_income,
	  average_income - LAG(average_income) OVER (PARTITION BY radka02.industry_branch 
						     ORDER BY radka01.year) AS year_increase
     FROM t_radka_matouchova_project_SQL_mezivypocet_01 AS radka01
     JOIN t_radka_matouchova_project_SQL_mezivypocet_02 AS radka02
       ON radka01.year = radka02.payroll_year
     JOIN czechia_price_category cpc
       ON radka01.category_code = cpc.code;
/*pozn. k ř.46:meziroční přírustek průměrného příjmu*/

CREATE OR REPLACE TABLE t_radka_matouchova_project_SQL_secondary_final AS /*vyfiltrování evropských zemí*/
   SELECT
	  e.country,
	  year AS years,
	  GDP,
	  gini,
	  c.population
     FROM economies e
     JOIN countries c
       ON c.country = e.country
    WHERE year >= 2006 AND year <= 2018
      AND region_in_world LIKE '%Europe%'
 ORDER BY year;

-- SQL skript generující datové podklady pro 1. výzkumnou otázku
CREATE OR REPLACE VIEW v_radka_matouchova_project_SQL_first_question AS /*vyhodnocení, zda mzdy rostou nebo klesají*/
   SELECT
	  industry_branch,
	  average_income,
	  CASE WHEN SUM(year_increase) >= 0 THEN 'Mzdy rostou'
	       ELSE 'Mzdy klesají' END AS `first_answer`
     FROM AS 
	  (
	  SELECT
		 industry_branch,
		 year,
		 average_income,
		 year_increase
	    FROM t_radka_matouchova_project_SQL_primary_final
	GROUP BY 
		  industry_branch,
		  year 
 	  ) AS prepocet
 GROUP BY 
	  industry_branch;

-- SQL skript generující datové podklady pro 2. výzkumnou otázku

CREATE OR REPLACE VIEW v_radka_matouchova_project_SQL_second_question AS /*výpočet kupní síly ve vztahu k mléku a chlebu*/
   SELECT
	  year,
	  grocery,
	  price_unit,
	  industry_branch,
	  average_income,
	  ROUND(average_income/avg_price,0) AS purchasing_power
     FROM t_radka_matouchova_project_SQL_primary_final
    WHERE grocery IN ('Mléko polotučné pasterované','Chléb konzumní kmínový')
      AND year IN ('2006','2018')
 ORDER BY 
 	  grocery, 
	  industry_branch, 
	  year;

-- SQL skript generující datové podklady pro 3. výzkumnou otázku

CREATE OR REPLACE VIEW v_radka_matouchova_project_SQL_third_question AS
   SELECT
	  YEAR,
	  grocery,
	  price_unit,
	  MIN(percent_inc) AS `min_percent_inc`
    FROM
	 (
	 SELECT
		YEAR,
		grocery,
		avg_price,
		price_unit,
		avg_price - lag(avg_price) OVER (PARTITION BY grocery ORDER BY YEAR) AS `increase`,
		ROUND((avg_price - lag(avg_price) OVER (PARTITION by grocery 
							ORDER BY YEAR))/(avg_price/100),2) AS `percent_inc` 
	   FROM t_radka_matouchova_project_SQL_primary_final
       GROUP BY grocery,
		YEAR
	) AS percent_counting;
/*pozn. k ř. 125: procentuální meziroční přírustek průměrné mzdy*/

-- SQL skript generující datové podklady pro 4. výzkumnou otázku

CREATE OR REPLACE TABLE t_radka_matouchova_project_SQL_fourth_question_calculation AS
   SELECT
	  *,
	  CASE WHEN per_difference >= 20 THEN 'výzarné zdražení'
	       ELSE 'nevýrazné' END AS fourth_answer
     FROM
	  (
	  SELECT
		 year,
		 grocery,
		 avg_price,
		 industry_branch,
		 average_income,
		 ROUND((avg_price - LAG(avg_price) OVER (PARTITION BY grocery 
							 ORDER BY year))/(avg_price/100),2) AS `per_inc_price`,
		 ROUND((average_income - LAG(average_income) OVER (PARTITION BY grocery 
								   ORDER BY year))/(average_income/100),2) AS `per_inc_income`,
		 (ROUND((avg_price - LAG(avg_price) OVER (PARTITION BY grocery 
							  ORDER BY year))/(avg_price/100),2))
		 - (ROUND((average_income - LAG(average_income) OVER (PARTITION BY grocery 
								      ORDER BY year))/(average_income/100),2)) AS `per_difference` /*dlouhý výpočet*/
	    FROM t_radka_matouchova_project_SQL_primary_final
          GROUP BY 
		  grocery,year,
		  industry_branch
	  ) as percent_counting2;
/*pozn. k ř. 148: Procentuální nárust cen potravin
pozn. k ř. 150: Procentuální nárust mezd
pozn. k ř. 152: Rozdíl mezi procentální nárustem cen potravin a procentuálním nárustem mezd*/

CREATE OR REPLACE VIEW v_radka_matouchova_project_SQL_fourth_question AS
   SELECT
	  year,
	  grocery,
	  avg_price,
	  industry_branch,
	   average_income,
	  per_difference
     FROM t_radka_matouchova_project_SQL_fourth_question_calculation
    WHERE fourth_answer = 'výzarné zdražení';
  
-- SQL skript generující datové podklady pro 5. výzkumnou otázku

CREATE OR REPLACE TABLE t_radka_matouchova_project_SQL_fifth_question_calculation_01 AS /*vyfiltrování DPH pro Českou republiku*/
   SELECT
	  *,
	  ROUND((GDP - LAG(GDP) OVER (PARTITION BY country 
				      ORDER BY years))/(GDP/100),2) AS `per_inc_GDP`
     FROM t_radka_matouchova_project_SQL_secondary_final
    WHERE country = 'Czech Republic'

CREATE OR REPLACE TABLE t_radka_matouchova_project_SQL_fifth_question_calculation_02 AS /*procentuální narůst mezd a nákupního košíku k následujícímu roku*/
   SELECT
	  *,
	  LEAD(per_inc_income) OVER (PARTITION BY industry_branch
				     ORDER BY year) AS `per_inc_income_next_year`,
	  SUM(avg_price) AS `shopping_cart`,
	  LEAD(per_inc_shop_cart) OVER (PARTITION BY industry_branch
					ORDER BY year) AS `per_inc_shop_cart_next_year`
    FROM
	  (
	  SELECT
		 year,
		 grocery,
		 avg_price,
		 price_unit,
		 ROUND((SUM(avg_price) - LAG(SUM(avg_price)) OVER (PARTITION BY industry_branch 
								   ORDER BY year, industry_branch))/(SUM(avg_price)/100),2) AS `per_inc_shop_cart`,
		 industry_branch,
		 average_income,
		 ROUND((average_income - LAG(average_income) OVER (PARTITION BY industry_branch 
								  ORDER BY year, industry_branch))/(average_income/100),2) AS `per_inc_income`	
	    FROM t_radka_matouchova_project_SQL_primary_final
          GROUP BY 
		 industry_branch,
		 year
	   ) AS calculation_fifth_q
 GROUP BY 
 	  industry_branch,
	  year;
/*pozn. k ř. 191: Pro zjednodušení výpočtu vlivu DPH jsou všechny kategorie potravit sečteny do jednoho čísla tzv. nákupní košík AS shopping cart.*/

CREATE OR REPLACE VIEW v_radka_matouchova_project_SQL_fifth_question AS /*Zhodnocení vlivu HDP ČR na mzdy a ceny potravin*/
   SELECT
	  year,
	  GDP,
	  shopping_cart,
	  industry_branch,
	  average_income,
	  per_inc_GDP,
	  per_inc_shop_cart,
	  per_inc_income,
	  per_inc_income_next_year,
	  CASE WHEN (per_inc_shop_cart >= per_inc_GDP) AND (per_inc_income >= per_inc_GDP) AND (per_inc_income_next_year >= per_inc_GDP) AND (per_inc_shop_cart_next_year >= per_inc_GDP) THEN 'velký vliv DPH'
	       ELSE 'bez vlivu DPH' END AS fifth_answer
     FROM t_radka_matouchova_project_SQL_fifth_question_calculation_02 AS pri
     JOIN t_radka_matouchova_project_SQL_fifth_question_calculation_01 AS sec
       ON pri.year = sec.years;
