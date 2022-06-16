SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [RekeningCourant].[vw_Deurwaardersdossiers] AS

WITH cte_contract_zittend ([Customer No_])
	AS (SELECT adi.[Customer No_]
	FROM empire_data.[dbo].[Staedion$Additioneel] adi
	WHERE adi.Ingangsdatum <= GETDATE() AND (adi.Einddatum = '1753-01-01' OR adi.Ingangsdatum >=  GETDATE())
	GROUP BY adi.[Customer No_])

-- toevoegen huidige status huurder ?
SELECT DISTINCT
	DWZ.Peildatum
   ,FORMAT(DWZ.peildatum, 'yyyy MMMM', 'nl-NL') AS Rapportagemaand
   ,DWZ.Dossiernr
   ,DWZ.[Dossiernr deurwaarder]
   ,DWZ.[Deurwaardernr]
   ,DWZ.[Deurwaarder]
   ,DWZ.[Klantnr]
   ,Klantnaam = DWZ.[Klant naam]
   ,DWZ.Ingangsdatum
   ,DWZ.Afgesloten
   ,[Initieel overgedragen] = SUM(DWZ.[Initieel overgedragen])
   ,DWZ.[Klant status]
   ,DWZ.Rapportagestatus_id
   ,COALESCE(NULLIF(DWZ.[Status],''),'Nvt') AS [Status (Wel of geen schuldbewaking)] 
   ,[Huidige status klant] = IIF(CONTR.[Customer No_] IS NULL, 'Vertrokken', 'Zittend') 
   ,Beginstand = IIF(MAX(DWZ.Rapportagestatus_id) IN (2, 3), 1, 0)
   ,Aangemaakt = IIF(MAX(DWZ.Rapportagestatus_id) IN (1, 4), 1, 0)
   ,Afgerond = IIF(MAX(DWZ.Rapportagestatus_id) IN (3, 4), 1, 0)
   ,Eindstand = IIF(MAX(DWZ.Rapportagestatus_id) IN (1, 2), 1, 0)
-- select distinct [Status]
FROM [staedion_dm].[RekeningCourant].[Deurwaarderszaken] AS DWZ
LEFT OUTER JOIN  cte_contract_zittend AS CONTR
		ON DWZ.Klantnr = CONTR.[Customer No_]
--WHERE Peildatum = '20210131'
GROUP BY DWZ.Peildatum
		,FORMAT(DWZ.peildatum, 'yyyy MMMM', 'nl-NL')
		,DWZ.Dossiernr
		,DWZ.[Dossiernr deurwaarder]
		,DWZ.[Deurwaardernr]
		,DWZ.[Deurwaarder]
		,DWZ.[Klant naam]
		,DWZ.[Klantnr]
		,DWZ.Ingangsdatum
		,DWZ.Afgesloten
		,DWZ.[Klant status]
		,DWZ.Rapportagestatus_id
		,CONTR.[Customer No_]
		,DWZ.[Status]






GO
