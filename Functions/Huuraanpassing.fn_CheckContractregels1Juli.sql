SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE function [Huuraanpassing].[fn_CheckContractregels1Juli] ( @Eenheidnr nvarchar(20) = 'OGEH-0004580' )
returns table 
as
/* #################################################################################################################################
VAN			JvdW
BETREFT		Functie om de 1 juli regels van huidige Empire-versie te vergelijken met die van het weekend van de huurverhoging
ZIE					18 05 811 Verzoek extra controle-rapportage tbv prolongatie juli (ontbrekende 
STATUS		Test
VERSIE		2
------------------------------------------------------------------------------------------------------------------------------------
WIJZIGING	  
20180606 JvdW - Versie 1: aangemaakt 
20190605 JvdW - Versie 2: Obv feedback PW afrondingsgevallen eruit filteren
20190610 JvdW - Versie 3: Overig - graag zonder component 400 en hoger 
20210531 JvdW - Versie 4: Van empire_dwh / empire_Staedion_Data verhuisd naar staedion_dm.Huuraanpassing (voorheen empire_dwh.[ITVF_controle_1_jul_contractregels])
20210602 JvdW - Versie 5: Toevoeging huurprijs per 30-6
------------------------------------------------------------------------------------------------------------------------------------
CHECK				
------------------------------------------------------------------------------------------------------------------------------------
select * from [staedion_dm].[Huuraanpassing].[fn_CheckContractregels1Juli] (default)


------------------------------------------------------------------------------------------------------------------------------------
STEEKPROEF
------------------------------------------------------------------------------------------------------------------------------------
DECLARE @Eenheidnr NVARCHAR(20) = 'OGEH-0001625'			-- huurprijs hvh is toch 580, er staat in pbi 566 ?
DECLARE @Eenheidnr NVARCHAR(20) = 'OGEH-0055942'			-- afronding, hoort er niet tussen te staan
DECLARE @Eenheidnr NVARCHAR(20) = 'OGEH-0000992'			-- 4** elementen: niet meenemen

select * from [staedion_dm].[Huuraanpassing].[fn_CheckContractregels1Juli] ( @Eenheidnr )
;
SELECT Eenheidnr = O.[Nr_]
	,C.[Ingangsdatum]
	,C.[Einddatum]
	,Elementnr = E.Nr_
	,Bedrag = Convert(FLOAT, E.[Bedrag (LV)])
	,Omschrijving = E.omschrijving
FROM empire_data.dbo.[Staedion$Contract] AS C
INNER JOIN empire_data.dbo.[Staedion$Element] AS E ON C.[Eenheidnr_] = E.[Eenheidnr_]
	AND C.[Volgnr_] = E.[Volgnummer]
INNER JOIN empire_data.dbo.[Staedion$Oge] AS O ON C.Eenheidnr_ = O.[Nr_]
WHERE C.[Ingangsdatum] <= DateFromParts(year(getdate()), 7, 1)
	AND (
		C.[Einddatum] = '1753-01-01'
		OR C.[Einddatum] >= DateFromParts(year(getdate()), 7, 1)
		)
	AND E.[Soort] = 0
	AND E.[Eenmalig] = 0
	AND O.[Nr_] = @Eenheidnr
;

SELECT Eenheidnr = O.[Nr_]
	,C.[Ingangsdatum]
	,C.[Einddatum]
	,Elementnr = E.Nr_
	,Bedrag = Convert(FLOAT, E.[Bedrag (LV)])
	,Omschrijving = E.omschrijving
FROM [staedion_dm].[Huuraanpassing].[Staedion$Contract] AS C
INNER JOIN [staedion_dm].[Huuraanpassing].[Staedion$Element] AS E ON C.[Eenheidnr_] = E.[Eenheidnr_]
	AND C.[Volgnr_] = E.[Volgnummer]
INNER JOIN [staedion_dm].[Huuraanpassing].[hvh].[Staedion$Oge] AS O ON C.Eenheidnr_ = O.[Nr_]
WHERE C.[Ingangsdatum] <= DateFromParts(year(getdate()), 7, 1)
	AND (
		C.[Einddatum] = '1753-01-01'
		OR C.[Einddatum] >= DateFromParts(year(getdate()), 7, 1)
		)
	AND E.[Soort] = 0
	AND E.[Eenmalig] = 0
	AND O.[Nr_] = @Eenheidnr


################################################################################################################################# */

RETURN
WITH CTE_peildata AS (
		SELECT datum AS Laaddatum
		FROM empire_dwh.dbo.tijd
		WHERE [last_loading_day] = 1
		)
	,CTE_BEVROREN_contractregels_actief_1_7 AS (
		SELECT C.[Eenheidnr_]
			,C.[Customer No_]
			,C.Volgnr_
			,E.[Nr_]
			,E.Elementsoort
			,convert(FLOAT, E.[Bedrag (LV)]) AS [Bedrag (LV)]
		FROM [staedion_dm].[Huuraanpassing].[Staedion$Contract] AS C
		INNER JOIN [staedion_dm].[Huuraanpassing].[Staedion$Element] AS E ON C.[Eenheidnr_] = E.[Eenheidnr_]
			AND C.[Volgnr_] = E.[Volgnummer]
		INNER JOIN [staedion_dm].[Huuraanpassing].[Staedion$Oge] AS O ON C.Eenheidnr_ = O.[Nr_]
		WHERE C.[Ingangsdatum] <= DateFromParts(year(getdate()), 7, 1)
			AND (
				C.[Einddatum] = '1753-01-01'
				OR C.[Einddatum] >= DateFromParts(year(getdate()), 7, 1)
				)
			AND E.[Soort] = 0
			AND E.[Eenmalig] = 0
			AND E.Tabel = 3
			AND E.Nr_ <= '399'
		)
	,CTE_HUIDIG_contractregels_actief_30_6 AS (
		SELECT C.[Eenheidnr_]
			,C.[Customer No_]
			,C.Volgnr_
			,E.[Nr_]
			,E.Elementsoort
			,E.Eenmalig
			,E.Diversen
			,C.[Aangemaakt op]
			,convert(FLOAT, E.[Bedrag (LV)]) [Bedrag (LV)]
		FROM empire_data.dbo.[Staedion$Contract] AS C
		INNER JOIN empire_data.dbo.[Staedion$Element] AS E ON C.[Eenheidnr_] = E.[Eenheidnr_]
			AND C.[Volgnr_] = E.[Volgnummer]
		INNER JOIN empire_data.dbo.[Staedion$Oge] AS O ON C.Eenheidnr_ = O.[Nr_]
		WHERE C.[Ingangsdatum] <= DateFromParts(year(getdate()), 6, 30)
			AND (
				C.[Einddatum] = '1753-01-01'
				OR C.[Einddatum] >= DateFromParts(year(getdate()), 6, 30)
				)
			AND E.[Soort] = 0
			AND E.[Eenmalig] = 0
			AND E.Tabel = 3
			AND E.Nr_ <= '399'
		)
	,CTE_HUIDIG_contractregels_actief_1_7 AS (
		SELECT C.[Eenheidnr_]
			,C.[Customer No_]
			,C.Volgnr_
			,E.[Nr_]
			,E.Elementsoort
			,E.Eenmalig
			,E.Diversen
			,C.[Aangemaakt op]
			,convert(FLOAT, E.[Bedrag (LV)]) [Bedrag (LV)]
		FROM empire_data.dbo.[Staedion$Contract] AS C
		INNER JOIN empire_data.dbo.[Staedion$Element] AS E ON C.[Eenheidnr_] = E.[Eenheidnr_]
			AND C.[Volgnr_] = E.[Volgnummer]
		INNER JOIN empire_data.dbo.[Staedion$Oge] AS O ON C.Eenheidnr_ = O.[Nr_]
		WHERE C.[Ingangsdatum] <= DateFromParts(year(getdate()), 7, 1)
			AND (
				C.[Einddatum] = '1753-01-01'
				OR C.[Einddatum] >= DateFromParts(year(getdate()), 7, 1)
				)
			AND E.[Soort] = 0
			AND E.[Eenmalig] = 0
			AND E.Tabel = 3
			AND E.Nr_ <= '399'
		)
	,CTE_HUIDIG_bestaat_1_7_regel AS (
		SELECT DISTINCT C.[Eenheidnr_]
			,C.[Customer No_]
		FROM empire_data.dbo.[Staedion$Contract] AS C
		INNER JOIN empire_data.dbo.[Staedion$Element] AS E ON C.[Eenheidnr_] = E.[Eenheidnr_]
			AND C.[Volgnr_] = E.[Volgnummer]
		INNER JOIN empire_data.dbo.[Staedion$Oge] AS O ON C.Eenheidnr_ = O.[Nr_]
		WHERE C.[Ingangsdatum] = DateFromParts(year(getdate()), 7, 1)
			AND (
				C.[Einddatum] = '1753-01-01'
				OR C.[Einddatum] >= C.[Ingangsdatum]
				)
		)
	,CTE_BEVROREN_bestaat_1_7_regel AS (
		SELECT DISTINCT C.[Eenheidnr_]
			,C.[Customer No_]
		FROM [staedion_dm].[Huuraanpassing].[Staedion$Contract] AS C
		INNER JOIN [staedion_dm].[Huuraanpassing].[Staedion$Element] AS E ON C.[Eenheidnr_] = E.[Eenheidnr_]
			AND C.[Volgnr_] = E.[Volgnummer]
		INNER JOIN [staedion_dm].[Huuraanpassing].[Staedion$Oge] AS O ON C.Eenheidnr_ = O.[Nr_]
		WHERE C.[Ingangsdatum] = DateFromParts(year(getdate()), 7, 1)
			AND (
				C.[Einddatum] = '1753-01-01'
				OR C.[Einddatum] >= C.[Ingangsdatum]
				)
		)
	,CTE_BEVROREN_TOTAAL_KAAL AS (
		SELECT Eenheidnr_
			,sum(convert(FLOAT, [Bedrag (LV)])) AS [Totaal Bedrag (LV)]
		FROM CTE_BEVROREN_contractregels_actief_1_7
		WHERE Elementsoort IN (4)
		GROUP BY Eenheidnr_
		)
	,CTE_HUIDIG_AANTAL_ELEMENTEN_1_7 AS (
		SELECT Eenheidnr_
			--,sum(convert(FLOAT, [Bedrag (LV)])) AS [Totaal Bedrag (LV)]
			--,Elementsamenstelling = sum(convert(int,Nr_)*100)
		      ,Elementsamenstelling = STRING_AGG(Nr_, '|') within GROUP (ORDER BY Nr_)
		FROM CTE_HUIDIG_contractregels_actief_1_7
		GROUP BY Eenheidnr_
		)
	,CTE_HUIDIG_TOTAAL_KAAL AS (
		SELECT Eenheidnr_
			,sum(convert(FLOAT, [Bedrag (LV)])) AS [Totaal Bedrag (LV)]
		FROM CTE_HUIDIG_contractregels_actief_1_7
		WHERE Elementsoort IN (4)
		GROUP BY Eenheidnr_
		)
	,CTE_HUIDIG_AANTAL_ELEMENTEN_30_6 AS (
		SELECT Eenheidnr_
			--,sum(convert(FLOAT, [Bedrag (LV)])) AS [Totaal Bedrag (LV)]
			--,Elementsamenstelling = sum(convert(int,Nr_)*100)
		      ,Elementsamenstelling = STRING_AGG(Nr_, '|') within GROUP (ORDER BY Nr_)
		FROM CTE_HUIDIG_contractregels_actief_30_6
		GROUP BY Eenheidnr_
		)
	,CTE_Aangemaakt_30_6 AS (
		SELECT Eenheidnr_
			,[Aangemaakt op] = MAX([Aangemaakt op])
		FROM CTE_HUIDIG_contractregels_actief_30_6
		GROUP BY Eenheidnr_
		)
	,CTE_BEVROREN_TOTAAL_OVERIG AS (
		SELECT Eenheidnr_
			,sum(convert(FLOAT, [Bedrag (LV)])) AS [Totaal Bedrag (LV)]
		FROM CTE_BEVROREN_contractregels_actief_1_7
		WHERE NOT (Elementsoort IN (4))
		GROUP BY Eenheidnr_
		)
	,CTE_HUIDIG_TOTAAL_OVERIG AS (
		SELECT Eenheidnr_
			,sum(convert(FLOAT, [Bedrag (LV)])) AS [Totaal Bedrag (LV)]
		FROM CTE_HUIDIG_contractregels_actief_1_7
		WHERE NOT (Elementsoort IN (4))
		GROUP BY Eenheidnr_
		)
	,CTE_Aangemaakt_1_7 AS (
		SELECT Eenheidnr_
			,[Aangemaakt op] = MAX([Aangemaakt op])
		FROM CTE_HUIDIG_contractregels_actief_1_7
		GROUP BY Eenheidnr_
		)
	,CTE_VERHUURMUTATIE AS (
		SELECT CTE.Eenheidnr_
			,[Ingevoerd door] = max(VHM.[Ingevoerd door])
		FROM CTE_HUIDIG_contractregels_actief_1_7 AS CTE
		JOIN empire_data.dbo.[staedion$verhuurmutatie] AS VHM ON VHM.Eenheidnr_ = CTE.Eenheidnr_
			AND VHM.Verhuurcontractvolgnr_ = CTE.Volgnr_
		GROUP BY CTE.Eenheidnr_
		)

SELECT Eenheid = E.bk_nr_
	,[Corpodata type] = T.fk_eenheid_type_corpodata_id
	,[Technisch type] = T.bk_code + ' ' + T.descr
	,[Huidig divisie veld] = D.bk_code
	,Thuisteam = E.staedion_thuisteam
	,Verhuuream = E.staedion_verhuurteam
	,OGEadres = replace(E.descr, E.bk_nr_ + ' ', '')
	,[OGE Straat] = E.straatnaam
	,[Huurder hvh weekend per 1-7] = Isnull(nullif(CTE_B_1_7.[Customer No_], ''), 'Leegstand')
	,[Huurder nu per 1-7] = Isnull(nullif(CTE_H_1_7.[Customer No_], ''), 'Leegstand')
	,[Huurder additioneel nu 1-7] = Isnull(nullif(A.[Customer No_], ''), 'Leegstand')
	,Ingangsdatum =  A.Ingangsdatum
	,Einddatum = isnull(convert(NVARCHAR(20), (
				CASE 
					WHEN A.Einddatum = '17530101'
						THEN NULL
					ELSE A.Einddatum
					END
				), 105), '')
	,[Had een bevroren 1-7-regel] = iif(CTE_B_1_7.Eenheidnr_ IS NULL, 'nee', 'ja')
	,[Heeft nu een 1-7-regel] = iif(CTE_H_1_7.Eenheidnr_ IS NULL, 'nee', 'ja')
	,[Huur kaal - bevroren - 1-7] = CTE_B_kaal.[Totaal Bedrag (LV)]
	,[Huur kaal - nu - 1-7] = CTE_H_kaal.[Totaal Bedrag (LV)]
	,[Huur overig - bevroren - 1-7] = CTE_B_overig.[Totaal Bedrag (LV)]
	,[Huur overig - nu - 1-7] = CTE_H_overig.[Totaal Bedrag (LV)]
	,[Afwijking in verhuurstatus] = IIF(Isnull(nullif(CTE_B_1_7.[Customer No_], ''), 'Leegstand') = Isnull(nullif(CTE_H_1_7.[Customer No_], ''), 'Leegstand'), 'Nee', 'Ja')
	,[Absolute afwijking kaal] = abs(Convert(FLOAT, isnull(CTE_H_kaal.[Totaal Bedrag (LV)], 0)) - Convert(FLOAT, isnull(CTE_B_kaal.[Totaal Bedrag (LV)], 0)))
	,[Absolute afwijking overig] = abs(Convert(FLOAT, isnull(CTE_H_overig.[Totaal Bedrag (LV)], 0)) - Convert(FLOAT, isnull(CTE_B_overig.[Totaal Bedrag (LV)], 0)))
	,[Elementsamenstelling 30-6] = CTE_H_elem_30_6.Elementsamenstelling
	,[Elementsamenstelling 1-7] = CTE_H_elem_1_7.Elementsamenstelling
--	,[Afwijking in elementsamenstelling] = iif(abs(Convert(FLOAT, isnull(CTE_H_elem_30_6.Elementsamenstelling, 0)) - Convert(FLOAT, isnull(CTE_H_elem_1_7.Elementsamenstelling, 0)))=0,'Nee','Ja')
	-- 133 Groenvoorziening is er bewust uitgehaald, vandaar dat die hier wordt uitgezonderd
	,[Afwijking in elementsamenstelling] = iif(coalesce(replace(CTE_H_elem_30_6.Elementsamenstelling, '133|',''), 'X') <> coalesce(replace(CTE_H_elem_1_7.Elementsamenstelling,'133|',''),'Y'),'Ja', 'Nee')
	,[Contractregel 1-7 Aangemaakt op] = CTE_Aangemaakt_1_7.[Aangemaakt op]
	,[Contractregel 30-6 Aangemaakt op] = CTE_Aangemaakt_30_6.[Aangemaakt op]
	,[Verhuurmutatie door] = CTE_VHM.[Ingevoerd door]
	,[Nieuwe huurder vanaf 1-4] = case when coalesce(A.Ingangsdatum,'17530101') >= datefromparts(year(getdate()),4,1) then 'Ja' else 'Nee' end
	,[Hyperlink Klantvenster huurder 1-7] = 'http://klantvenster.staedion.local/_layouts/15/techxx/pages/Huurderskaart.aspx?persoonsnummer='+ KLANT.[Contact No_] 
	,[Hyperink Empire] = empire_staedion_data.empire.fnEmpireLink('Staedion', 11024012, 'Soort=1,Eenheidnr.=' + '''' + E.bk_nr_ + '''', 'view')
	,Laaddatum = convert(NVARCHAR(20), PEIL.Laaddatum)
	,[Opmerking] = CASE 
		WHEN  iif(CTE_B_1_7.Eenheidnr_ IS NULL, 'nee', 'ja') = 'ja'
					AND iif(CTE_H_1_7.Eenheidnr_ IS NULL, 'nee', 'ja') = 'nee'
					THEN '1) 1-7-regel verdwenen (filterend op kolom [Had een bevroren 1-7-regel] = ja en [Heeft nu een 1-7-regel] = nee)'
		END
	,[Opmerking2] = CASE 
		WHEN NOT (
				abs(Convert(FLOAT, isnull(CTE_H_overig.[Totaal Bedrag (LV)], 0)) - Convert(FLOAT, isnull(CTE_B_overig.[Totaal Bedrag (LV)], 0))) <= 0.01
				AND abs(Convert(FLOAT, isnull(CTE_H_kaal.[Totaal Bedrag (LV)], 0)) - Convert(FLOAT, isnull(CTE_B_kaal.[Totaal Bedrag (LV)], 0))) <= 0.01
				)
				and iif(CTE_B_1_7.Eenheidnr_ IS NULL, 'nee', 'ja') = 'ja'
					AND iif(CTE_H_1_7.Eenheidnr_ IS NULL, 'nee', 'ja') = 'ja'
			THEN '2) Wel 1-7-regels maar ander bedragen ten opzichte van hvh-weekend'
		ELSE CASE 
				WHEN iif(CTE_B_1_7.Eenheidnr_ IS NULL, 'nee', 'ja') = 'ja'
					AND iif(CTE_H_1_7.Eenheidnr_ IS NULL, 'nee', 'ja') = 'nee'
					THEN '1) 1-7-regel verdwenen (filterend op kolom [Had een bevroren 1-7-regel] = ja en [Heeft nu een 1-7-regel] = nee)'
				ELSE CASE 
						WHEN iif(coalesce(replace(CTE_H_elem_30_6.Elementsamenstelling,'133|',''), 'X') <> coalesce(replace(CTE_H_elem_1_7.Elementsamenstelling,'133|',''),'Y'),'Ja', 'Nee') = 'Ja'
							THEN '3) Wijziging in samenstelling huur 30-6 tov 1-7'
						ELSE '0) Geen opmerkingen'
						END
				END
		END
FROM empire_dwh.dbo.eenheid AS E
JOIN empire_dwh.dbo.technischtype AS T ON E.fk_technischtype_id = T.id
JOIN empire_dwh.dbo.divisie AS D ON D.id = E.fk_divisie_id
LEFT OUTER JOIN empire_data.dbo.staedion$Additioneel A ON A.Eenheidnr_ = E.bk_nr_
	AND A.Ingangsdatum <= DateFromParts(year(getdate()), 7, 1)
	AND (
		A.Einddatum > DateFromParts(year(getdate()), 7, 1)
		OR A.Einddatum = '17530101'
		)
LEFT OUTER JOIN CTE_BEVROREN_bestaat_1_7_regel AS CTE_B_1_7 ON CTE_B_1_7.Eenheidnr_ = E.bk_nr_
LEFT OUTER JOIN CTE_HUIDIG_bestaat_1_7_regel AS CTE_H_1_7 ON CTE_H_1_7.Eenheidnr_ = E.bk_nr_
LEFT OUTER JOIN CTE_BEVROREN_TOTAAL_KAAL AS CTE_B_kaal ON CTE_B_kaal.Eenheidnr_ = E.bk_nr_
LEFT OUTER JOIN CTE_HUIDIG_TOTAAL_KAAL AS CTE_H_kaal ON CTE_H_kaal.Eenheidnr_ = E.bk_nr_
LEFT OUTER JOIN CTE_BEVROREN_TOTAAL_OVERIG AS CTE_B_overig ON CTE_B_overig.Eenheidnr_ = E.bk_nr_
LEFT OUTER JOIN CTE_HUIDIG_TOTAAL_OVERIG AS CTE_H_overig ON CTE_H_overig.Eenheidnr_ = E.bk_nr_
LEFT OUTER JOIN CTE_Aangemaakt_1_7  ON CTE_Aangemaakt_1_7.Eenheidnr_ = E.bk_nr_
LEFT OUTER JOIN CTE_Aangemaakt_30_6  ON CTE_Aangemaakt_30_6.Eenheidnr_ = E.bk_nr_
LEFT OUTER JOIN CTE_VERHUURMUTATIE AS CTE_VHM ON CTE_VHM.Eenheidnr_ = E.bk_nr_
LEFT OUTER JOIN CTE_HUIDIG_AANTAL_ELEMENTEN_30_6 AS CTE_H_elem_30_6 ON CTE_H_elem_30_6.Eenheidnr_ = E.bk_nr_
LEFT OUTER JOIN CTE_HUIDIG_AANTAL_ELEMENTEN_1_7 AS CTE_H_elem_1_7 ON CTE_H_elem_1_7.Eenheidnr_ = E.bk_nr_
left outer join empire_Data.dbo.customer as KLANT on KLANT.No_ = A.[Customer No_]
JOIN CTE_peildata AS PEIL ON 1 = 1
WHERE (
		E.bk_nr_ = @Eenheidnr
		OR @Eenheidnr IS NULL
		)
	AND E.da_bedrijf = 'Staedion'
	AND T.bk_code <> 'ANT'
	--			 and E.bk_nr_ = 'OGEH-0055942'
	AND E.bk_nr_ NOT LIKE 'ADE%'
	AND E.dt_in_exploitatie <= getdate()
	AND (
		E.dt_uit_exploitatie IS NULL
		OR E.dt_uit_exploitatie > getdate()
		)
	--AND (
	--	abs(Isnull(Convert(DECIMAL(12, 2), CTE_B_kaal.[Totaal Bedrag (LV)]), 0) - isnull(Convert(DECIMAL(12, 2), CTE_H_kaal.[Totaal Bedrag (LV)]), 0)) >= 0.01
	--	OR abs(Isnull(Convert(DECIMAL(12, 2), CTE_B_overig.[Totaal Bedrag (LV)]), 0) - isnull(Convert(DECIMAL(12, 2), CTE_H_overig.[Totaal Bedrag (LV)]), 0)) >= 0.01
	--	)
GO
