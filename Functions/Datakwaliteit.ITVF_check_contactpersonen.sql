SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE  function [Datakwaliteit].[ITVF_check_contactpersonen] (@Clusternr as nvarchar(20) = null, @Functie as nvarchar(20),@AlleenFouteData smallint = 1 ) 
returns table 
as
/* ###################################################################################################
VAN         : JvdW
BETREFT     : Check of eenheden een contactpersoon hebben voor thuisteam. Gesignaleerd worden eenheden die geen contactpersoon hebben voor Functie CB-THTEAM dan wel eentje die afwijkt van het cluster
ZIE         : 19 02 1255 Afwijkingen contacten eenheid vs cluster (FT-1054)
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
Versie 1: [20190510 Nav Topdesk]
Versie 3: [20190813 Nav Topdesk]
						Onderwerp: 19 02 1255 - afwijkingen contacten eenheid vs cluster (FT-1054)
						14-05-2019 07:49 Peeters, Marieke:
						Hoi Anneke,

						De aanpassing van gisteren heeft zo te zien geholpen; ik zie in het rapport nu ook de Preludestraat adressen.
						Jouw deel van de melding is hiermee opgelost. Ik zet de melding wel door naar Jaco; ik denk nl. dat er een controlerapport moet komen (van 
						clusters/eenheden zonder bepaalde contactpersonen; in elk geval de/het thuisteam) om dit soort vervelende missing-adressen zoveel mogelijk zien te 
						voorkomen.
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
-- Welke eenheden hebben afwijking (geen einde exploitatiedatum)
SELECT *
FROM backup_empire_Dwh.dbo.[ITVF_check_contactpersonen](DEFAULT, DEFAULT, 1)
WHERE (nullif([Einde exploitatie], '17530101') IS NULL
              OR year([Einde exploitatie]) >= year(getdate())
              )
			---- check of query goed is opgesteld
   --    AND Eenheid IN (
   --           SELECT Eenheidnr_
   --           FROM empire_data.dbo.Staedion$Eenheid_contactpersoon AS CE
   --           WHERE Functie = 'CB-THTEAM'
   --           )
-- dubbele ?
SELECT count(*), count(distinct Eenheid)
FROM  empire_Dwh.dbo.[ITVF_check_contactpersonen](DEFAULT, DEFAULT, 0)

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
       SELECT datum AS Laaddatum
       FROM empire_dwh.dbo.tijd
       WHERE [last_loading_day] = 1
       )
       ,CTE_cluster_oge_ft
AS (
       SELECT CO.Clusternr_
              ,CO.Eenheidnr_
							,TT.Code
							,TT.Omschrijving
              ,OGE.[Begin exploitatie]
              ,OGE.[Einde exploitatie]
							,[Corpodata-type] = TT.[Analysis Group Code]
       FROM [S-SQL-LOGSH].Empire.dbo.[Staedion$Cluster-OGE-kruistabel] AS CO
       JOIN [S-SQL-LOGSH].Empire.dbo.Staedion$OGE AS OGE
              ON OGE.Nr_ = CO.Eenheidnr_
       LEFT outer join [S-SQL-LOGSH].Empire.dbo.staedion$Type as TT
			 ON TT.[Code] = OGE.[Type]
       WHERE Clustersoort = 'FTCLUSTER'
              AND OGE.[Common Area] = 0
              --and CO.Clusternr_ = 'FT-1341'
       ),
			 CTE_verhuurteam
									 as (SELECT Eenheidnr_
									 ,Verhuurteam = CE_R.NAME
									 ,Volgnr = row_number() OVER (
													PARTITION BY Eenheidnr_ ORDER BY CE.Contactnr_
													)
						FROM [S-SQL-LOGSH].Empire.dbo.[Staedion$Eenheid contactpersoon] AS CE
						LEFT OUTER JOIN [S-SQL-LOGSH].Empire.dbo.contact AS CE_R
									 ON CE_R.No_ = CE.Contactnr_
						WHERE CE.Functie = 'CB-VHTEAM')


SELECT  Cluster = coalesce(CTE.Clusternr_, CC.Clusternr_)
       ,Functie = coalesce(CC.Functie, CE.Functie)
       ,Eenheid = CTE.Eenheidnr_
			 ,[Eenheid-type] = CTE.Code
			 ,[Eenheid-type omschrijving] = CTE.Omschrijving
			 ,[Corpodata-type] = CTE.[Corpodata-type]
			 ,[Verhuurteam] = CTE_V.Verhuurteam
       ,[Begin exploitatie] = nullif(CTE.[Begin exploitatie],'17530101') -- CONVERT(NVARCHAR(20), CTE.[Begin exploitatie], 105)
       ,[Einde exploitatie] = nullif(CTE.[Einde exploitatie],'17530101') --iif([Einde exploitatie] = '17530101', '', CONVERT(NVARCHAR(20), CTE.[Einde exploitatie], 105))
       ,ClusterContact = coalesce(CC.Contactnr_ + '-' + CC_R.NAME, '')
       ,ClusterFunctie = coalesce(CC.Functie, '')
       ,EenheidFunctie = coalesce(CE.Functie, '')
       ,EenheidContact = coalesce(CE.Contactnr_  + '-' + CE_R.NAME, '')
       ,[Gegenereerd] = convert(NVARCHAR(20), P.Laaddatum)
FROM CTE_cluster_oge_ft AS CTE
LEFT OUTER JOIN CTE_peildata AS P
       ON 1 = 1
LEFT OUTER JOIN [S-SQL-LOGSH].Empire.dbo.[Staedion$Cluster contactpersoon]AS CC
       ON CTE.Clusternr_ = CC.Clusternr_
              AND CC.Functie =  coalesce (@Functie, 'CB-THTEAM')
LEFT OUTER JOIN [S-SQL-LOGSH].Empire.dbo.contact AS CC_R
       ON CC_R.No_ = CC.Contactnr_
left outer join CTE_verhuurteam as CTE_V
on CTE_V.Eenheidnr_ = CTE.Eenheidnr_
and CTE_V.Volgnr = 1 -- voorkomen dat er dubbele rijen ontstaan
FULL OUTER JOIN [S-SQL-LOGSH].Empire.dbo.[Staedion$Eenheid contactpersoon] AS CE
       ON CTE.Eenheidnr_ = CE.Eenheidnr_
              AND (
                     CC.Functie = CE.Functie
                     OR (
                            CC.Functie IS NULL
                            AND CE.Functie IS NOT NULL
                            )
                     OR (
                            CC.Functie IS NOT NULL
                            AND CE.Functie IS NULL
                            )
                     )
              AND CE.Functie = coalesce (@Functie, 'CB-THTEAM')

LEFT OUTER JOIN [S-SQL-LOGSH].Empire.dbo.contact AS CE_R
       ON CE_R.No_ = CE.Contactnr_


WHERE 1 = 1
       AND CTE.Eenheidnr_ NOT LIKE 'CO%'
       AND (
              CTE.Clusternr_ = @Clusternr
              OR @Clusternr IS NULL
              )
       AND (
              (
                     @AlleenFouteData = 1
                     AND isnull(CC.Functie, 'cc') <> isnull(CE.Functie, 'ce')
                     OR (
                            isnull(CC.Functie, 'cc') = isnull(CE.Functie, 'ce')
                            AND isnull(CC.Contactnr_, 'cc') <> isnull(CE.Contactnr_, 'ce')
                            )
                     )
              OR @AlleenFouteData = 0
              )


--select * from empire_data.dbo.Staedion$Eenheid_contactpersoon
GO
