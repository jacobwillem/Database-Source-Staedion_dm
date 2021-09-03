SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- Bron: staedion_dm 
CREATE VIEW [Eenheden].[Glascontract]
/* ############################################################################################################################################
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Eenheden', 'Glascontract'

-- extended property toevoegen op object-niveau
USE staedion_dm;  
GO  
EXEC sys.sp_updateextendedproperty   
@name = N'MS_Description',   
@value = N'In exploitatie zijnde woningen van Staedion. Aparte kolommen geven aan of er sprake is van element 255 of 256',   
@level0type = N'SCHEMA', @level0name = 'Eenheden',  
@level1type = N'VIEW',  @level1name = 'Glascontract'
;  
EXEC sys.sp_updateextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Eenheden',  
@level1type = N'VIEW',  @level1name = 'Glascontract'
;  
EXEC sys.sp_updateextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'select ''Geen dubbele regels ? '', count(*), count(distinct Eenheidnummer) from staedion_dm.Eenheden.Glascontract ',   
@level0type = N'SCHEMA', @level0name = 'Eenheden',  
@level1type = N'VIEW',  @level1name = 'Glascontract'
;  
EXEC sys.sp_updateextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Deels - maakt gebruik van staedion_dm.Algemeen.Eenheden',   
@level0type = N'SCHEMA', @level0name = 'Eenheden',  
@level1type = N'VIEW',  @level1name = 'Glascontract'

##############################################################################################################################################*/
AS
WITH cte_contractregels_263
AS (
       SELECT Elementnr
              ,[Eenheidnr]
              ,Bedrag = sum([Bedrag])
							,Ingangsdatum = min([Ingangsdatum element])
       FROM [staedion_dm].[Contracten].[ContractRegelsElementIngangsdata]
       WHERE Elementnr = '263'
       GROUP BY Elementnr
              ,[Eenheidnr]
       )
       ,cte_contractregels_264
AS (
       SELECT Elementnr
              ,[Eenheidnr]
              ,Bedrag = sum([Bedrag])
							,Ingangsdatum = min([Ingangsdatum element])
       FROM [staedion_dm].[Contracten].[ContractRegelsElementIngangsdata]
       WHERE Elementnr = '264'
       GROUP BY Elementnr
              ,[Eenheidnr]
       )
SELECT BASIS.[Eenheidnummer]
			 ,BASIS.[Eenheid]
			 ,BASIS.[Plaats]
			 ,BASIS.[Wijk]
			 ,BASIS.[Buurt]
			 ,BASIS.[Straatnaam]
			 ,BASIS.[Huisnummer]
			 ,BASIS.[Toevoegsel]
			 ,BASIS.[Postcode]
			 ,BASIS.[Eenheidtype Corpodata]
			 ,BASIS.[Technische type omschrijving]
			 ,BASIS.[Vastgoedtype]
			 ,BASIS.[Lift]
--			 ,BASIS.[Etages]
			 ,BASIS.[Aantal kamers]
			 ,BASIS.[Huidige labelconditie]
			 ,BASIS.[Datum in exploitatie]
       ,CLUS.Bouwblok
			 ,CLUS.Bouwbloknaam
			 ,CLUS.Clusternr
			 ,CLUS.Clusternaam
			 ,BASIS.[Status VvE]
			 ,CLUS.[VVE-cluster]
			 ,CLUS.[VVE-clusternaam]
			 ,[263: Glascontract] = iif(C_263.Eenheidnr IS NULL, 'Nee', 'Ja')
       ,[263: Glascontract - bedrag] = C_263.Bedrag
			 ,[263: Ingangsdatum] = C_263.Ingangsdatum
       ,[264: Glascontract BTW] = iif(C_264.Eenheidnr IS NULL, 'Nee', 'Ja')
       ,[264: Glascontract BTW - bedrag] = C_264.Bedrag
			 ,[264: Ingangsdatum] = C_264.Ingangsdatum
FROM staedion_dm.Algemeen.Eenheid AS BASIS
LEFT OUTER JOIN cte_contractregels_263 AS C_263
       ON C_263.Eenheidnr = BASIS.[Eenheidnummer]
LEFT OUTER JOIN cte_contractregels_264 AS C_264
       ON C_264.Eenheidnr = BASIS.[Eenheidnummer]
CROSS APPLY empire_staedion_data.dbo.ITVfnCLusterBouwblok (BASIS.Eenheidnummer) as CLUS
WHERE BASIS.[In exploitatie] = 'Ja'
    --   AND BASIS.[Eenheidtype groepering] = 'Woningen'
       AND BASIS.[Bedrijf] = 'Staedion'
       AND BASIS.[Is OGEH] = 'Ja';

GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Eenheden', 'VIEW', N'Glascontract', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Deels - maakt gebruik van staedion_dm.Algemeen.Eenheden', 'SCHEMA', N'Eenheden', 'VIEW', N'Glascontract', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'In exploitatie zijnde woningen van Staedion. Aparte kolommen geven aan of er sprake is van element 255 of 256', 'SCHEMA', N'Eenheden', 'VIEW', N'Glascontract', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'select ''Geen dubbele regels ? '', count(*), count(distinct Eenheidnummer) from staedion_dm.Eenheden.Glascontract ', 'SCHEMA', N'Eenheden', 'VIEW', N'Glascontract', NULL, NULL
GO
