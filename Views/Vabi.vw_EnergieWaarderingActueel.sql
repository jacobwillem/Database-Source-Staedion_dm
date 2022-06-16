SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Vabi].[vw_EnergieWaarderingActueel] as
WITH cte_meest_recente_regel AS 
(SELECT vhe,
       energie_index_afgemeld,
       ep2_fossielenergiegebruik,
       ep1_energiebehoefte,
       co2_uitstoot,
       opnemer,
       deelvoorraad,
       energielabel_afgemeld,
       afgemelde_opnamedatum,
       afmeldnummer,
       ROW_NUMBER() OVER (PARTITION BY vhe ORDER BY afmelddatum DESC) AS Volgnr
FROM TS_data.[dbo].[vabi_onroerendgoed_energie_waardering])
SELECT vhe AS Eenheidnr,
       energie_index_afgemeld,
       ep2_fossielenergiegebruik,
       ep1_energiebehoefte,
       co2_uitstoot,
       opnemer,
       deelvoorraad,
       energielabel_afgemeld,
       afgemelde_opnamedatum,
       afmeldnummer
FROM cte_meest_recente_regel 
WHERE Volgnr = 1
GO
