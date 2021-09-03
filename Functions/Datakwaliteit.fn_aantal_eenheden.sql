SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  function [Datakwaliteit].[fn_aantal_eenheden] (@Laaddatum as date = null, @FilterCorpoData as nvarchar(20) = null) 
returns table 
as
/* ###################################################################################################
VAN         : JvdW
BETREFT     : Check of eenheden een contactpersoon hebben voor thuisteam. Gesignaleerd worden eenheden die geen contactpersoon hebben voor Functie CB-THTEAM dan wel eentje die afwijkt van het cluster
ZIE         : 19 02 1255 Afwijkingen contacten eenheid vs cluster (FT-1054)
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
Versie 1
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
SELECT * FROM  staedion_dm.Datakwaliteit.[fn_aantal_eenheden](DEFAULT, DEFAULT)
SELECT * FROM  staedion_dm.Datakwaliteit.[fn_aantal_eenheden](DEFAULT, 'WON ZELF')
SELECT * FROM  staedion_dm.Datakwaliteit.[fn_aantal_eenheden](DEFAULT, 'WON ONZ')
SELECT * FROM  staedion_dm.Datakwaliteit.[fn_aantal_eenheden](DEFAULT, 'WON ONZ,WON ZELF')
SELECT * FROM  staedion_dm.Datakwaliteit.[fn_aantal_eenheden]('20191231', 'WON ONZ,WON ZELF')
SELECT * FROM  staedion_dm.Datakwaliteit.[fn_aantal_eenheden](DEFAULT, 'WON ONZ,WON ZELF')

------------------------------------------------------------------------------------------------------
TEMP
------------------------------------------------------------------------------------------------------
-- Steekproef
Declare @ENr as nvarchar(20) = 'OGEH-0000836'
Declare @F as nvarchar(20) = 'CB-ASSMAN' --null
Declare @Cnr  as nvarchar(20)
select 'Eenheidkaart'as Bron, Eenheidnr_, Contactnr_, Functie from empire_data.dbo.Staedion$Eenheid_contactpersoon where Eenheidnr_ = @ENr  and (Functie = @F or @F is null)
select @Cnr = Clusternr_ from  empire_data.dbo.mg_cluster_oge AS CO WHERE Clustersoort = 'FTCLUSTER' AND [Common Area] = 0 and eenheidnr_ = @ENr 
select 'Functie' as Bron, Clusternr_, Contactnr_, Functie  from empire_data.dbo.Staedion$Cluster_contactpersoon where Clusternr_ = @Cnr  and (Functie = @F or @F is null)


------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'empire_dwh', 'dbo', 'ITVF_check_contactpersonen'

################################################################################################### */	
RETURN
WITH CTE_peildata -- voor tonen periode in dataset
AS (
       SELECT Laaddatum = coalesce(@Laaddatum, (
                            SELECT max(datum_gegenereerd)
                            FROM empire_staedion_data.dbo.els
                            ))
       ),
			 CTE_corpodata as (select ListItem from  empire_staedion_logic.dbo.dlf_ListInTable(',',@FilterCorpoData))
SELECT Aantal = count(DISTINCT BRON.eenheidnr)
-- select distinct Corpodata_type
FROM empire_staedion_data.dbo.els AS BRON
JOIN CTE_peildata AS P
       ON 1 = 1
              AND BRON.datum_gegenereerd = P.Laaddatum
WHERE BRON.datum_in_exploitatie <= P.Laaddatum
       AND (
              BRON.datum_uit_exploitatie >= P.Laaddatum
              OR nullif(BRON.datum_uit_exploitatie, '') IS NULL
              )
       AND (
              BRON.Corpodata_type IN (select ListItem from CTE_corpodata)
              OR @FilterCorpoData IS NULL
              )
GO
