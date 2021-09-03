SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE function [Elementen].[fn_Details] (@Eenheidnr NVARCHAR(20), @Peildatum date) 
returns table 
as
/* ###################################################################################################
VAN         : JvdW
BETREFT     : Contracten van nog lopende huurcontracten (tabel Additioneel) met gevulde datum [Datum geprolongeerd tot] die niet overeenkomt met einddatum+1d en met Einddatum contractregel ook gevuld

----------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
Versie 1: 20200527 JvdW, ovv Marieke
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
SELECT count(distinct Eenheidnr),sum(Bedrag) 
-- select Eenheidnr,Bedrag,*
from staedion_dm.Datakwaliteit.[fn_ElementenDetails]('20210228')
WHERE Elementnr = '137'
and Eenheidnr in ( 'OGEH-0009181')
order by 1
';
SELECT count(distinct Eenheidnr),sum(Bedrag) 
-- select Eenheidnr,Bedrag,*
from staedion_dm.Datakwaliteit.[fn_ElementenDetails]('20210228')
WHERE Elementnr = '504'
and year([Ingangsdatum contract]) =  2021
and month([Ingangsdatum contract]) =  2
and Eenheidnr in ( 'OGEH-0009226')

order by 1

------------------------------------------------------------------------------------------------------
TEMP
------------------------------------------------------------------------------------------------------
select CONTR.Eenheidnr_, CONTR.[Ingangsdatum], CONTR.[Einddatum], E.Nr_, E.* , E.eenmalig
     FROM empire_data.dbo.[staedion$contract] AS CONTR
INNER JOIN empire_data.dbo.[Staedion$Element] AS E
       ON CONTR.[Eenheidnr_] = E.[Eenheidnr_]
              AND CONTR.[Volgnr_] = E.[Volgnummer]
WHERE CONTR.[Ingangsdatum] <= getdate()
       AND (
              CONTR.[Einddatum] = '1753-01-01'
              OR CONTR.[Einddatum] >= getdate()
              )
       AND CONTR.[Dummy Contract] = 0 -- JvdW 20200526 toe
and CONTR.Eenheidnr_ = 'OGEH-0007826'
################################################################################################### */	
RETURN
WITH CTE_peildata -- voor tonen periode in dataset
AS (
	SELECT coalesce(@Peildatum, datum) AS Laaddatum
	FROM empire_dwh.dbo.tijd
	WHERE [last_loading_day] = 1
	)
	,CTE_Eenheidkaart
AS (
	SELECT oge.Nr_
		,[Statuscode] = oge.[status]
		,[Status] = CASE oge.[status]
			WHEN 0
				THEN 'Leegstand'
			WHEN 1
				THEN 'Uit beheer'
			WHEN 2
				THEN 'Renovatie'
			WHEN 3
				THEN 'Verhuurd'
			WHEN 4
				THEN 'Administratief'
			WHEN 5
				THEN 'Verkocht'
			WHEN 6
				THEN 'In ontwikkeling'
			ELSE CONVERT(NVARCHAR(4), oge.[status])
			END
	FROM empire_data.dbo.[staedion$oge] AS oge
	where oge.[Common Area] = 0
	)
	,cte_additioneel
AS (
	SELECT [Customer No_]
		,[Eenheidnr_]
		,Ingangsdatum
		,Einddatum
	FROM empire_data.dbo.[Staedion$Additioneel]
	WHERE Ingangsdatum <= (
			SELECT Laaddatum
			FROM CTE_peildata
			)
		AND (
			Einddatum >= (
				SELECT Laaddatum
				FROM CTE_peildata
				)
			OR Einddatum = '17530101'
			)
	)
SELECT Eenheidnr = CONTR.Eenheidnr_
	,Volgnummer = CONTR.Volgnr_
	,[Ingangsdatum contractregel] = CONTR.Ingangsdatum
	,[Geprolongeerd tot] = CONTR.[Geprolongeerd tot]
	,[Einddatum contractregel] = NULLIF(CONTR.Einddatum, '17530101')
	,[Ingangsdatum contract] = CTE_A.Ingangsdatum
	,[Einddatum contract] = NULLIF(CTE_A.Einddatum, '17530101')
	,Huurdernr = CONTR.[Customer No_]
	,Huurdernaam = CONTR.Naam
	,[Vinkje beeindigd] = IIF(CONTR.[Beëindigd] = 1, 'Ja', 'Nee')
	,[Status contractregel] = CASE CONTR.[Status]
		WHEN 0
			THEN 'Nieuw'
		WHEN 1
			THEN 'Huidig'
		WHEN 2
			THEN 'Oud'
		ELSE CONVERT(NVARCHAR(4), CONTR.[Status])
		END
	,[Status volgens huidige contractregel] = CASE CONTR.[Exploitation State Type]
		WHEN 0
			THEN 'Leegstand'
		WHEN 1
			THEN 'Uit beheer'
		WHEN 2
			THEN 'Renovatie'
		WHEN 3
			THEN 'Verhuurd'
		WHEN 4
			THEN 'Administratief'
		WHEN 5
			THEN 'Verkocht'
		WHEN 6
			THEN 'In ontwikkeling'
		ELSE CONVERT(NVARCHAR(4), CONTR.[Exploitation State Type])
		END
	,[Status ogekaart] = OGE.[Status]
	,[Gegenereerd] = P.Laaddatum
	,datIngang = CTE_A.Ingangsdatum
	,datEinde = NULLIF(CTE_A.Einddatum, '17530101')
	,Omschrijving = 'Vinkje beeindigd: ' + IIF(CONTR.[Beëindigd] = 1, 'Ja', 'Nee')
	,Elementnr = E.[Nr_]
	,Bedrag = E.[Bedrag (LV)]
	,[Bedrag incl. BTW] = round( E.[bedrag (lv)] * (100.0 + isnull(VPS.[Vat %], 0)) / (100.0 * 1), 2) 
    ,[Bedrag niet afgerond] = E.[Bedrag (LV)]  -- select * from empire.empire.dbo.[Staedion$Element] where Eenheidnr_ = 'OGEH-0055183'
	,E.[BTW-productboekingsgroep]
	,Eenmalig = E.Eenmalig
	,[Omschrijving element] = E.omschrijving
	,E.[Op huurverhoging afdrukken]
FROM empire_data.dbo.[staedion$contract] AS CONTR
JOIN cte_additioneel AS CTE_A ON CTE_A.Eenheidnr_ collate database_default= CONTR.Eenheidnr_ collate database_default
	AND CTE_A.[Customer No_] collate database_default= CONTR.[Customer No_] collate database_default
INNER JOIN empire_data.dbo.[Staedion$Element] AS E ON CONTR.[Eenheidnr_] = E.[Eenheidnr_]
	AND CONTR.[Volgnr_] = E.[Volgnummer]
JOIN CTE_peildata AS P ON 1 = 1
LEFT OUTER JOIN empire_data.dbo.[Staedion$VAT_Posting_Setup] as VPS ON VPS.[VAT Bus_ Posting Group] = 'NL'
			AND VPS.[VAT Prod_ Posting Group] = E.[btw-productboekingsgroep]
FULL OUTER JOIN CTE_Eenheidkaart AS OGE ON OGE.Nr_ = CONTR.Eenheidnr_
WHERE CONTR.[Ingangsdatum] <= (
		SELECT Laaddatum
		FROM CTE_peildata
		)
	AND (
		CONTR.[Einddatum] = '1753-01-01'
		OR CONTR.[Einddatum] >= (
			SELECT Laaddatum
			FROM CTE_peildata
			)
		)
	AND CONTR.[Dummy Contract] = 0 -- JvdW 20200526 toegevoegd
	AND (CONTR.Eenheidnr_ = @Eenheidnr OR @Eenheidnr IS NULL)
GO
