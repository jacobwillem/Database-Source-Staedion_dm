SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Verhuur].[Opzeggingen]
AS
-- DWEX overzicht opzeggingen
SELECT Verhuurteam = E.staedion_verhuurteam
	,CONTR.bk_eenheidnr AS Eenheidnr
	,E.descr AS [Eenheid incl adres]
	,CONTR.fk_klant_id AS Huurdernr
	,K.descr AS Huurdernaam
	,CONTR.dt_ingang AS [Ingangsdatum huurcontract]
	,CONTR.dt_einde AS [Einddatum huurcontract]
	,D.Datum
	,E.[Contactpersoon BOG]
	,E.[nettohuur_incl_btw] AS [Netto huur incl btw]
	,C.descr AS [FT-cluster]
	,TT.descr AS [Technische Type]
	,W.descr AS Wijk
	,E.[M2 VVO]
	,E.Eigenaar
	,[Datum ingang leegstand] = E.dt_ingang_leegstand
	,[Datum ingang laatste contract] = E.dt_laatstecontract
	,[Tbv Vestia-rapportage] = CASE 
		WHEN C.bk_nr_ IN (
				'FT-1563'
				,'FT-1566'
				,'FT-1569'
				,'FT-1570'
				)
			THEN 'Ja (FT-1563+66+98+70)'
		ELSE 'Nee'
		END
	,[Tbv BOG-rapportage] = CASE 
		WHEN E.staedion_verhuurteam = 'Verhuurteam 4 - BOG'
			THEN 'Ja'
		ELSE 'Nee'
		END
FROM backup_empire_Dwh.dbo.d_opzegging AS D
LEFT OUTER JOIN backup_empire_Dwh.dbo.[Contract] AS CONTR ON CONTR.id = D.fk_contract_id
LEFT OUTER JOIN backup_empire_Dwh.dbo.eenheid AS E ON E.id = CONTR.fk_eenheid_id
LEFT OUTER JOIN backup_empire_dwh.dbo.technischtype AS TT ON TT.id = E.fk_technischtype_id
LEFT OUTER JOIN backup_Empire_Dwh.dbo.klant AS K ON K.id = CONTR.fk_klant_id
LEFT OUTER JOIN backup_empire_Dwh.dbo.cluster AS C ON C.id = E.[staedion_fk_ftcluster_id]
LEFT OUTER JOIN backup_Empire_Dwh.dbo.wijk AS W ON W.id = E.fk_wijk_id
WHERE YEAR(D.datum) >= 2019
	-- AND E.staedion_verhuurteam = 'Verhuurteam 4 - BOG'
	-- AND E.bk_nr_ = 'OGEH-0052085'
	;

GO
