SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [RekeningCourant].[Ontruiming TE VERWIJDEREN] as 
/* ##########################################################################################
Van: JvdW
Betreft: view op ontruimingen - te gebruiken bij omzetten dwex-rapportages naar PBI
---------------------------------------------------------------------------------------------
WIJZIGINGEN
---------------------------------------------------------------------------------------------
20210717 Aangemaakt
20210824 Uitgebreid met afgelast / reden afgelast
---------------------------------------------------------------------------------------------
TEST
---------------------------------------------------------------------------------------------
SELECT AANZ.[Datum ontruiming]
	,[Aanvullende info] = DD.Dossiernr_ + ' ; ' + DD.[Customer No_] + iif(EIG.Eigenschappen_id IS NOT NULL, ' ; ' + EIG.[Eenheid + adres],'')
--	,CONTR.id
	,[Code ontruiming] = AANZ.[Cause of Eviction Code]
	,[Omschrijving ontruimingsreden] = OORZ.[Description]
	,[Deurwaarderdossiernr] = DD.Dossiernr_ 
	,Klantnr = DD.[Customer No_]
	,[Eenheidnr + adres] = EIG.[Eenheid + adres]
	,[Status ontruiming] = convert(nvarchar(50), 'Uitgevoerd')
FROM empire_data.dbo.Staedion$Aanzegging_ontruiming AANZ
INNER JOIN empire_data.dbo.Staedion$Deurwaarderdossier AS DD ON AANZ.Dossiernr_ = DD.Dossiernr_
LEFT OUTER JOIN staedion_dm.Eenheden.Eigenschappen as EIG on DD.[Eenheidnr_] = EIG.Eenheidnr and EIG.Einddatum is null
--LEFT OUTER JOIN empire_dwh.dbo.[contract] AS CONTR ON DD.[Customer No_] = CONTR.fk_klant_id
--	AND DD.Eenheidnr_ = CONTR.bk_eenheidnr
LEFT OUTER JOIN empire_data.dbo.Staedion$Cause_of_Eviction AS OORZ ON OORZ.[Code] = AANZ.[Cause of Eviction Code]
-- Lookup("Cause of Eviction".Description WHERE (Code=FIELD(Cause of Eviction Code)))
WHERE year(AANZ.[Datum ontruiming]) >= 2019
	AND AANZ.[Datum afgelasting] = '1753-01-01'
	--and aan.[Cause of Eviction Code]  in ('ONTRUIM11', 'ONTRUIM12', 'ONTRUIM13')

########################################################################################## */
SELECT AANZ.[Datum ontruiming]
	,[Aanvullende info] = DD.Dossiernr_ + ' ; ' + DD.[Customer No_] + iif(EIG.Eigenschappen_id IS NOT NULL, ' ; ' + EIG.[Eenheid + adres], '')
	--	,CONTR.id
	,[Code ontruiming] = AANZ.[Cause of Eviction Code]
	,[Omschrijving ontruimingsreden] = OORZ.[Description]
	,[Deurwaarderdossiernr] = DD.Dossiernr_
	,Klantnr = DD.[Customer No_]
	,[Eenheidnr + adres] = EIG.[Eenheid + adres]
	,[EIG].[FT clusternr]
	,[EIG].[FT clusternaam]
	,[Ontruiming afgelast] = CASE 
		WHEN AANZ.[Datum afgelasting] <> '1753-01-01'
			THEN 'Ja'
		ELSE 'Nee'
		END
	,[Reden afgelasting] = AFG.Omschrijving
	,[Code reden afgelasting] = AANZ.[Reden afgelasting]
FROM empire_data.dbo.Staedion$Aanzegging_ontruiming AANZ
INNER JOIN empire_data.dbo.Staedion$Deurwaarderdossier AS DD ON AANZ.Dossiernr_ = DD.Dossiernr_
LEFT OUTER JOIN staedion_dm.Eenheden.Eigenschappen AS EIG ON DD.[Eenheidnr_] = EIG.Eenheidnr
	AND EIG.Einddatum IS NULL
--LEFT OUTER JOIN empire_dwh.dbo.[contract] AS CONTR ON DD.[Customer No_] = CONTR.fk_klant_id
--	AND DD.Eenheidnr_ = CONTR.bk_eenheidnr

-- Lookup("Cause of Eviction".Description WHERE (Code=FIELD(Cause of Eviction Code)))
LEFT OUTER JOIN empire_data.dbo.Staedion$Cause_of_Eviction AS OORZ ON OORZ.[Code] = AANZ.[Cause of Eviction Code]
-- Lookup("Reden afgelasting ontruiming".Omschrijving WHERE (Code=FIELD(Reden afgelasting)))
LEFT OUTER JOIN empire_data.dbo.[staedion$Reden_afgelasting_ontruiming] AS AFG ON AFG.[Code] = AANZ.[Reden afgelasting]
WHERE year(AANZ.[Datum ontruiming]) >= 2019
	--AND AANZ.[Datum afgelasting] <> '1753-01-01'
	--and aan.[Cause of Eviction Code]  in ('ONTRUIM11', 'ONTRUIM12', 'ONTRUIM13')
	--AND DD.Dossiernr_ = 'DRWD-2100584'
--ORDER BY AANZ.[Datum ontruiming] DESC
GO
