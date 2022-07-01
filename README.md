Komentář autora README.sql k datovým podkladům

1. Primární tabulka = t_radka_matouchova_project_SQL_primary_final
   přepočet ceny potravin z jednotlivých krajů ČR na celorepublikový a ROČNÍ průměr = t_radka_matouchova_project_SQL_mezivypocet_01, 
   přepočet mezd za jednotlivá čtvrtletí na celoroční průměr = t_radka_matouchova_project_SQL_mezivypocet_02
   zkoumané časové období mezd se odvíjí od primární tabulky s cenami potravin
!!! Pro výpočet mezd byly zahrnuty hodnoty fyzického i přepočteného počtu zaměstnanců, 
    tzn. ve výsledku není rozlišováno, zda zaměstnanci pracují na plný pracovní úvazek, či ne
    Veškeré mzdy jsou hrubé mzdy před zdaněním !!!

2. Sekundární tabulka = t_radka_matouchova_project_SQL_secondary_final
   zkoumané časové období informací o Evropských státech se odvíjí od primární tabulky s cenami potravin

3. První výzkumná otázka = v_radka_matouchova_project_SQL_first_question
   výpočet meziročního změna hodnoty mezd k jednotlivým odvětvím národního hospodářství dále jen NH
   Vyhodnocení: pokud by byl součet změn hodnot mezd za všechny zkoumané roky kladné číslo, výsledkem je: mzdy rostou v opačném případě: mzdy klesají.
   
4. Druhá výzkumná otázka = v_radka_matouchova_project_SQL_second_question
   výpočet kolikrát se průměrná cena vybraných potravinových komodit (mléko, chleba) vejde do průměrné mzdy
   Vyhodnocení: kolik litrů mléka nebo kil chleba je možné si pořítid ze mzdy jednotlivých odvětví NH za roky 2006 a 2018
   
5. Třetí výzkumná otázka = v_radka_matouchova_project_SQL_third_question
   výpočet meziročního nárůstu cen u všech potravin
   vyběr potraviny s nejmenším procentuálním meziročním nárůstem
   Vyhodnocení: Nalezení potraviny, která nejvíce zlevnila z roku na rok.
   
6. Čtvrtá výzkumná otázka = v_radka_matouchova_project_SQL_fourth_question
   výpočet procentuální meziroční změny cen potravin a mezd a jejich rozdíl
   Vyhodnocení: pokud rozdíl je větší než 20 (%), výsledkem je výrazné zdražení
   vyfiltrování výrazného zdražení

7. Pátá výzkumná otázka = v_radka_matouchova_project_SQL_fifth_question
   součet všech cen potravin do jedné hodnoty  za jednotlivé roky = nákupní košík, kolik stojí nákup všech potravin ve vybraných letech
   výpočet procentuální změny ceny nákupního košíku a mezd k současnému a následujícímu roku
   Vyhodnocení: pokud nárůst cen potravin a mezd v daném a následujícím roce byl vyšší než nárůst DPH v daném roce, vliv DPH byl potvrzen (vše v %)
   
   Zdroj všech podkladových dat, otevřená data ČR: https://data.gov.cz/datov%C3%A1-sada?iri=https%3A%2F%2Fdata.gov.cz%2Fzdroj%2Fdatov%C3%A9-sady%2F00025593%2F7ddcb833bddeeb84db39004d7e276b87
