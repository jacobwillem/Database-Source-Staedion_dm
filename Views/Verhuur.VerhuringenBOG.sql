SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Verhuur].[VerhuringenBOG]
as
SELECT DISTINCT 
	   Verhuurteam = E.staedion_verhuurteam,
       CONTR.bk_eenheidnr AS Eenheidnr,
	   E.descr AS [Eenheid incl adres],
       CONTR.fk_klant_id AS Huurdernr,
	   K.descr AS Klantnaam,
       CONTR.dt_ingang AS [Ingangsdatum huurcontract],
--       CONTR.dt_einde AS [Einddatum huurcontract],
	   F.Datum,
	   E.[Contactpersoon BOG],
	   TT.descr AS [Technische Type],
	   E.[M2 VVO],
	   E.Eigenaar
-- select distinct E.staedion_verhuurteam
-- select F.*
FROM backup_empire_Dwh.dbo.f_verhuringen AS F
    LEFT OUTER JOIN backup_empire_Dwh.dbo.[Contract] AS CONTR
        ON CONTR.id = F.fk_contract_id
    LEFT OUTER JOIN backup_empire_Dwh.dbo.eenheid AS E
        ON E.id = CONTR.fk_eenheid_id
	LEFT OUTER JOIN backup_empire_dwh.dbo.technischtype AS TT
		ON TT.id = E.fk_technischtype_id
	LEFT OUTER JOIN backup_empire_dwh.dbo.juridischeeigenaar AS JUR
		ON JUR.id = E.fk_juridischeeigenaar_id
	LEFT OUTER JOIN backup_Empire_Dwh.dbo.klant AS K
		ON K.id = CONTR.fk_klant_id
WHERE YEAR(F.datum) >= 2019
--and month(F.datum) = 1
      AND E.staedion_verhuurteam = 'Verhuurteam 4 - BOG';

GO
