SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [Eenheden].[fn_CLusterBouwblok TEST](@Eenheidnr_ nvarchar(50) = null)
RETURNS TABLE 
AS
/* ########################################################################################################################## 
VAN 		 JvdW
Betreft		Algemene functie te gebruiken op data van clusters en eenheden
--------------------------------------------------------------------------------------------------------------------------
TEST
--------------------------------------------------------------------------------------------------------------------------
-- performance
select * from staedion_dm.Eenheden.[fn_CLusterBouwblok] (default)
select * from staedion_dm.Eenheden.[fn_CLusterBouwblok] (default) where [Collectief Object-cluster] = 'COC-1001A'
select * from staedion_dm.Eenheden.[fn_CLusterBouwblok]('CO-00015392')
select [Collectief Object] = Nr, [Type], [FT-Clusternummer], Bouwblok, [Collectief Object-cluster], [collectief Object-clusternaam] , [Gegenereerd] = getdate()
from staedion_dm.Eenheden.[fn_CLusterBouwblok](default) 
where [Soort object] = 'Collectief Object'
order by 1


-- check dubbele regels
select count(*), count(distinct Nr) from staedion_dm.Eenheden.[fn_CLusterBouwblok](default)
select count(*), count(distinct Eenheidnr) from staedion_dm.Eenheden.[fn_CLusterBouwblok](default) where [Collectief Object-cluster] = 'COC-1001A'

select * from staedion_dm.Eenheden.[fn_CLusterBouwblok](default) where 
select * from empire_data.dbo.staedion$cluster where nr_ = 'COC-1001A'
select * from empire_data.dbo.staedion$cluster_oge where clusternR_ = 'COC-1001A'
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden]  staedion_dm, 'Eenheden', 'fn_CLusterBouwblok'


--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------
20210517 Aangemaakt obv oude versie empire_staedion_data.dbo.ITVfnCLusterBouwblok van Eric Reitsma
20220513 In combinatie met grootboek bijv was opzet te traag - aangepast - data wel vergeleken met oude versie
########################################################################################################################## */
RETURN 


SELECT pvt.Eenheidnr_ as [Nr]
     ,[Soort object] = iif(pvt.[Common Area] = 1, 'Collectief Object','Eenheid')
     ,pvt.[Type] as [Type]
	 ,pvt.[Type Description] as [Omschrijving] 
	--,[Omschrijving] = o.[Type Description]
	,coalesce(pvt.[FTCLUSTER], '') as [FT-Clusternummer]
	,coalesce(pvt.[COLLOBJ], '') as [Collectief Object-cluster]
	--,[Eenheden].[fn_ClusterNaam] (pvt.[COLLOBJ]) as [Collectief Object-clusternaam]
	,coalesce(pvt.[FTCLUSTER], '') as Clusternr
	--,[Eenheden].[fn_ClusterNaam] (pvt.[FTCLUSTER]) as Clusternaam
	,coalesce(pvt.[BOUWBLOK], '') as Bouwblok
	--,[Eenheden].[fn_ClusterNaam] (pvt.[BOUWBLOK]) as Bouwbloknaam
	,coalesce(pvt.[STOOKKOSTE], '') as [STKN-cluster]
	--,[Eenheden].[fn_ClusterNaam] (pvt.[STOOKKOSTE]) as [STKN-clusternaam]
	,coalesce(pvt.[SERVICEKN], '') as [SVKI-cluster]
	--,[Eenheden].[fn_ClusterNaam] (pvt.[SERVICEKN]) as [SVKI-clusternaam]
	,coalesce(pvt.[SERVICEKOS], '') as [SVKN-cluster]
	--,[Eenheden].[fn_ClusterNaam] (pvt.[SERVICEKOS]) as [SVKN-clusternaam]
	,coalesce(pvt.[WATER], '') as [WATER-cluster]
	--,[Eenheden].[fn_ClusterNaam] (pvt.[WATER]) as [WATER-clusternaam]
	,coalesce(pvt.[HUURVERHOG], '') as Huurverhogingscluster
	--,[Eenheden].[fn_ClusterNaam] (pvt.[HUURVERHOG]) as Huurverhogingsclusternaam
	,coalesce(pvt.[VVE], '') as [VVE-cluster]
	--,[Eenheden].[fn_ClusterNaam] (pvt.[VVE]) as [VVE-clusternaam]
	,coalesce(pvt.[FINANCIEEL], '') as [FINC-cluster]
	--,[Eenheden].[fn_ClusterNaam] (pvt.[FINANCIEEL]) as [FINC-clusternaam]
FROM 

		(	SELECT CO.eenheidnr_ 
					,CO.Clusternr_
					,CO.Clustersoort
					,O.[Common Area]
					,O.[Type]
					,O.[Type Description]
			FROM empire_data.dbo.Staedion$Cluster_OGE as CO
			join empire_data.dbo.staedion$oge as O on o.nr_ = CO.eenheidnr_
			where (CO.eenheidnr_ = @Eenheidnr_ or @Eenheidnr_ is null)
			) AS src
			pivot(max(src.clusternr_) FOR src.clustersoort IN (
						 [FTCLUSTER]
						,[BOUWBLOK]
						,[HUURVERHOG]
						,[SERVICEKOS]
						,[SERVICEKN]
						,[WATER]
						,[VVE]
						,[FINANCIEEL]
						,[STOOKKOSTE]
						,[COLLOBJ]
					)
			) AS pvt







GO
