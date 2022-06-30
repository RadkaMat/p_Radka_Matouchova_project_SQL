# p_Radka_Matouchova_project_SQL
SQL project created in Maria DB server, DBeaver version 22.0.4

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
/*pozn. k ř.46: meziroční přírustek průměrného příjmu*/

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
