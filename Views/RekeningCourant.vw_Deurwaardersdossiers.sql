SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [RekeningCourant].[vw_Deurwaardersdossiers] AS

WITH cte_contract_zittend ([Customer No_])
	as (select adi.[Customer No_]
	from empire_data.[dbo].[Staedion$Additioneel] adi
	WHERE adi.Ingangsdatum <= GETDATE() and (adi.Einddatum = '1753-01-01' or adi.Ingangsdatum >=  GETDATE())
	group by adi.[Customer No_])

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
   ,[Huidige status klant] = iif(CONTR.[Customer No_] is null, 'Vertrokken', 'Zittend') 
   ,Beginstand = IIF(MAX(DWZ.Rapportagestatus_id) IN (2, 3), 1, 0)
   ,Aangemaakt = IIF(MAX(DWZ.Rapportagestatus_id) IN (1, 4), 1, 0)
   ,Afgerond = IIF(MAX(DWZ.Rapportagestatus_id) IN (3, 4), 1, 0)
   ,Eindstand = IIF(MAX(DWZ.Rapportagestatus_id) IN (1, 2), 1, 0)
-- select top 10 *
FROM [staedion_dm].[RekeningCourant].[Deurwaarderszaken] AS DWZ
LEFT OUTER JOIN  cte_contract_zittend as CONTR
		on DWZ.Klantnr = CONTR.[Customer No_]
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






GO
