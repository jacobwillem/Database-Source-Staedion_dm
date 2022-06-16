SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [Eenheden].[fn_CLusterBouwblok](@Eenheidnr_ nvarchar(50) = null)
RETURNS TABLE 
AS
/* ########################################################################################################################## 
VAN 		  JvdW
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
20210517 Aangemaakt obv oude versie empire_staedion_data.dbo.ITVfnCLusterBouwblok
20220513 conditie toegevoegd in subquery (where Eenheidnr_ ...)
########################################################################################################################## */
RETURN 

--nieuwe opzet op basis van pivot
WITH cluster
AS (
	SELECT Eenheidnr_
		,coalesce([FTCLUSTER], '') AS Clusternr
		,coalesce([BOUWBLOk], '') AS Bouwblok
		,coalesce([HUURVERHOG], '') AS Huurverhogingscluster
		,coalesce([SERVICEKOS], '') AS [SVKN-cluster]
		,coalesce([SERVICEKN], '') AS [SVKI-cluster]
		,coalesce([WATER], '') AS [WATER-cluster]
		,coalesce([VVE], '') [VVE-cluster]
		,coalesce([FINANCIEEL], '') AS [FINC-cluster]
		,coalesce([STOOKKOSTE], '') AS [STKN-cluster]
		,coalesce([COLLOBJ], '') AS [Collectief Object-cluster]
	FROM (
		SELECT eenheidnr_
			,Clusternr_
			--,Clusternaam 
			,Clustersoort
		FROM empire_data.dbo.Staedion$Cluster_OGE
		where (eenheidnr_ = @Eenheidnr_ or @Eenheidnr_ is null)
		) AS a
	pivot(max(clusternr_) FOR clustersoort IN (
				[FTCLUSTER]
				,[BOUWBLOk]
				,[HUURVERHOG]
				,[SERVICEKOS]
				,[SERVICEKN]
				,[WATER]
				,[VVE]
				,[FINANCIEEL]
				,[STOOKKOSTE]
				,[COLLOBJ]
				)) AS pvt
	)
	,clusternaam
AS (
	SELECT Eenheidnr_
		,coalesce([FTCLUSTER], '') AS Clusternaam
		,coalesce([BOUWBLOk], '') AS Bouwbloknaam
		,coalesce([HUURVERHOG], '') AS Huurverhogingsclusternaam
		,coalesce([SERVICEKOS], '') AS [SVKN-clusternaam]
		,coalesce([SERVICEKN], '') AS [SVKI-clusternaam]
		,coalesce([WATER], '') AS [WATER-clusternaam]
		,coalesce([VVE], '') [VVE-clusternaam]
		,coalesce([FINANCIEEL], '') AS [FINC-clusternaam]
		,coalesce([STOOKKOSTE], '') AS [STKN-clusternaam]
		,coalesce([COLLOBJ], '') AS [Collectief Object-clusternaam]
	FROM (
		SELECT eenheidnr_
			--,Clusternr_
			,Clusternaam
			,Clustersoort
		FROM empire_data.dbo.Staedion$Cluster_OGE
		where (eenheidnr_ = @Eenheidnr_ or @Eenheidnr_ is null)
		) AS a
	pivot(max(clusternaam) FOR clustersoort IN (
				[FTCLUSTER]
				,[BOUWBLOk]
				,[HUURVERHOG]
				,[SERVICEKOS]
				,[SERVICEKN]
				,[WATER]
				,[VVE]
				,[FINANCIEEL]
				,[STOOKKOSTE]
				,[COLLOBJ]
				)) AS pvt
	)
SELECT 
     [Soort object] = iif(o.[common area] = 1, 'Collectief Object','Eenheid')
    ,[Type] = o.[type]
	,[Nr] = c.Eenheidnr_
	,[Omschrijving] = o.[Type Description]
	,[FT-Clusternummer]= c.Clusternr
	,c.[Collectief Object-cluster]
	,n.[Collectief Object-clusternaam]
	,c.Bouwblok
	,c.Eenheidnr_
	,c.Clusternr
	,n.Clusternaam
	,n.Bouwbloknaam
	,c.[STKN-cluster]
	,n.[STKN-clusternaam]
	,c.[SVKI-cluster]
	,n.[SVKI-clusternaam]
	,c.[SVKN-cluster]
	,n.[SVKN-clusternaam]
	,c.[WATER-cluster]
	,n.[WATER-clusternaam]
	,c.Huurverhogingscluster
	,n.Huurverhogingsclusternaam
	,c.[VVE-cluster]
	,n.[VVE-clusternaam]
	,c.[FINC-cluster]
	,n.[FINC-clusternaam]
FROM cluster AS c
INNER JOIN clusternaam AS n ON c.Eenheidnr_ = n.Eenheidnr_
inner join empire_data.dbo.staedion$oge as o on o.nr_ = c.eenheidnr_
where (c.Eenheidnr_  = @eenheidnr_
or @Eenheidnr_ is null)





GO
