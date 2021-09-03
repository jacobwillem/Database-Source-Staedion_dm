SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [Datakwaliteit].[CheckContractenLeegstandAangemaaktOp]
AS
/*
-- Mail Marieke 4-1-2021

Filter: toekomstige leegstandsregels waarbij contractregel [Aangemaakt op] minder recent is dan de huidige [Aangemaakt op]-regel van de huidige huurder
=> Dan is een toekomstige leegstandsregel ten onrechte niet weggehaald

select * from [Datakwaliteit].[CheckContractenLeegstandAangemaaktOp]

*/
WITH cte_leegstaande_eenheden
AS (
	SELECT Eenheidnr_
		,[Customer No_]
		,Ingangsdatum
		,[Aangemaakt op]
		,Volgnr_
		,Hulp_volgnr = row_number() OVER (
			PARTITION BY Eenheidnr_
			,[Customer No_] ORDER BY Volgnr_ DESC
			)
	FROM empire_Data.dbo.Staedion$Contract AS C
	WHERE [Dummy Contract] = 0
		AND [Ingangsdatum] > getdate()
		AND [Customer No_] = ''
	)
	,cte_huidige_huurders
AS (
	SELECT Eenheidnr_
		,[Customer No_]
		,Ingangsdatum
		,[Aangemaakt op]
		,Volgnr_
		,Hulp_volgnr = row_number() OVER (
			PARTITION BY Eenheidnr_
			,[Customer No_] ORDER BY Volgnr_ DESC
			)
	FROM empire_Data.dbo.Staedion$Contract AS C
	WHERE [Dummy Contract] = 0
		AND [Ingangsdatum] <= getdate()
		AND coalesce(nullif([Einddatum], '17530101'), '20990101') > getdate()
		AND [Customer No_] <> ''
	)
SELECT Eenheidnr = BRON.Nr_
	,[Toekomstige leegstandsregel aangemaakt op] = LST.[Aangemaakt op]
	,[Toekomstige leegstandsregel ingangsdatum] = LST.Ingangsdatum
	,[Huidige huurder] = HUID.[Customer No_]
	,[Huidige contractregel aangemaakt op] = HUID.[Aangemaakt op]
	,[Huidige contractregel ingangsdatum] = LST.Ingangsdatum
	,CLUS.Clusternr 
	,CLUS.Clusternaam 
	--Assetmanager = coalesce(CONT.Assetmanager, 'Onbekend')
	,[Huurder] = coalesce(HRD.huurder1, 'Leegstand')
	--   ,[Kalehuur] = coalesce(HPR.kalehuur, 0)
	--   ,[Korting] = coalesce(HPR.nettohuur_incl_korting_btw, 0)
	--,[Soort eenheid (corpodata)] = TT.[Analysis Group Code]
	--   ,[Type eenheid] = TT.Omschrijving
	--   ,CONTR.Ingangsdatum
	--   ,CONTR.Einddatum
	,[Controle-bevinding] = NULL
FROM empire_data.dbo.staedion$oge AS BRON
JOIN cte_leegstaande_eenheden AS LST ON LST.Eenheidnr_ = BRON.Nr_
LEFT OUTER JOIN empire_Data.dbo.staedion$type AS TT ON TT.[Code] = BRON.[Type]
	AND TT.Soort <> 2
LEFT OUTER JOIN cte_huidige_huurders AS HUID ON BRON.Nr_ = HUID.Eenheidnr_
--OUTER APPLY empire_staedion_data.[dbo].[ITVFnContactbeheerInclNaam](BRON.Nr_) AS CONT
OUTER APPLY empire_staedion_data.[dbo].ITVfnCLusterBouwblok(BRON.Nr_) AS CLUS
--OUTER APPLY empire_staedion_data.[dbo].[ITVfnHuurprijs](BRON.Nr_, CONTR.Ingangsdatum) AS HPR
OUTER APPLY empire_staedion_data.[dbo].ITVfnContractaanhef(HUID.[Customer No_]) AS HRD
WHERE BRON.[Common Area] = 0
and LST.[Aangemaakt op] < HUID.[Aangemaakt op]
	--AND TT.[Analysis Group Code] = 'WON ZELF'
	--   AND BRON.[Begin exploitatie] <> '17530101'
	--   AND BRON.[Einde exploitatie] = '17530101'
	--   AND BRON.[Status] IN (
	--          0
	--          ,3              ) -- =Leegstand,Uit beheer,Renovatie,Verhuurd,Administratief,Verkocht,In ontwikkeling
	--and BRON.Nr_ = 'OGEH-0061514'
GO
