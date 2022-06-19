# p_radka_Matouchova_project_SQL
SQL project version Maria DB 22.0.4

-- SQL skript generující primární a sekundární tabulky

CREATE OR REPLACE TABLE t_radka_matouchova_project_SQL_mezivypocet_01 as /*nový sloupec years pro sloučení tabulek mezd a cen potravin*/
SELECT
  *,
  ROUND(AVG(value),2) as avg_price /*průměrná cen potraviny ze všech českých krajů*/
from
	(select
	*,
	substring(date_from,1,4) as `year` /*filtrování roku z celého časového údoje*/
	from czechia_price
	) as mezivypocet
group by `year`, category_code;


create or replace table t_radka_matouchova_project_SQL_mezivypocet_02 as /*průměrné mzdy všech odvětví českého hospodářství za vybrané roky*/
select
	name as industry_branch,
	payroll_year,
	ROUND(AVG(value),0) as average_income /*čtvtletní průměr mezd*/
from czechia_payroll as cp
inner join czechia_payroll_industry_branch cpib 
on cpib.code = cp.industry_branch_code
where `value_type_code` = 5958 /*vyfiltrování mezd od počtu zaměstnanců*/
and payroll_year >= 2006 and payroll_year <= 2018 /*vyfiltrování let podle tabulky czechia_price*/
group by name, payroll_year;


create or replace table t_radka_matouchova_project_SQL_primary_final as /*sloučené neslučitelné tabulky mezd všech odvětví a cen všech produktů*/
select
radka01.year,
cpc.name as grocery,
avg_price,
price_unit,
radka02.industry_branch,
average_income,
average_income - lag(average_income) OVER (PARTITION BY radka02.industry_branch order by radka01.year) as year_increase
from t_radka_matouchova_project_SQL_mezivypocet_01 as radka01
join t_radka_matouchova_project_SQL_mezivypocet_02 as radka02
on radka01.year = radka02.payroll_year
join czechia_price_category cpc
on radka01.category_code = cpc.code;
