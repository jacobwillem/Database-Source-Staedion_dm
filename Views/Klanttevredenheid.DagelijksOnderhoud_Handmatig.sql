SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










CREATE VIEW [Klanttevredenheid].[DagelijksOnderhoud_Handmatig] AS
/* #########################################################################################
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Klanttevredenheid', 'DagelijksOnderhoud_Handmatig'
JvdW 20200311 Mogelijk maken te rapporteren naar soort leverancier
> select * from empire_staedion_data.kcm.Leverancier 
> select Begindatum = min(Datum)
				,Einddatum = max(Datum) 
				,Bron = case Bron 
									when 'Eigen dienst' then 'Eigen dienst' 
									when  'Breman/Sens/Zegwaard'	 then 'Breman/Sens/Zegwaard' 
									else [Soort leverancier] end  
				,count(*)
				,avg(Score)
				-- select avg(Score)
	from staedion_dm.[Klanttevredenheid].[DagelijksOnderhoud_Handmatig]
	where year(Datum) = 2020
	and month(Datum) <3
	and Bron = 'Breman/Sens/Zegwaard'	
	group by case Bron 
									when 'Eigen dienst' then 'Eigen dienst' 
									when 'Comaker'  then 'Breman/Sens/Zegwaard' 
									else [Soort leverancier] end  

select Begindatum = min(Datum)
				,Einddatum = max(Datum) 
				,count(*)
				,avg(Score)
	from staedion_dm.[Klanttevredenheid].[DagelijksOnderhoud_Handmatig]

######################################################################################### */    
WITH CTE
AS (
	SELECT [Datum] = CONVERT(DATE, kcm.[Ingevulde gegevens])
		,[Tijdstip] = CONVERT(TIME, kcm.[Ingevulde gegevens])
		,[Postcode] = kcm.postcode
		,[Sleutel eenheid] = oge.lt_id
		,[Eenheidnr] = kcm.eenheidnr
		,[Sleutel cluster] = cluster.lt_id
		,[Clusternr] = kcm.Clusternr
		,[Score] = CAST(COALESCE(NULLIF(kcm.[Welk rapportcijfer geeft u voor de dienstverlening van Staedion ],'')
						, NULLIF(kcm.[Welk rapportcijfer geeft u voor de dienstverlening van de aannem],'')
						, NULLIF(kcm.[Welk rapportcijfer geeft u voor de dienstverlening van Staedion1],'')) AS DECIMAL(6,2))
		,[Suggesties] = NULL -- kcm.[Uw tip(s):]  -- 20210105 blijkbaar vervallen
		,[Aantal benodigde bezoeken volgens klant] = NULL --kcm.[Hoe vaak is er een medewerker langs geweest bij u voordat de rep]
		,[Medewerker] = kcm.[Naam behandelend medewerker Staedion]
		,Reparatieverzoeknr = kcm.reparatieverzoeknr
		,[Omschrijving onderhoudssjabloon] = kcm.omschrijving
		,Onderhoudssjabloon = kcm.onderhoudssjabloon
		,Leveranciersnr = kcm.leveranciersnr
		,Leverancier = kcm.leveranciersnaam
		,Bron = IIF(kcm.[ProcesInfo Staedion] = 'Eigen dienst', 'Eigen dienst', 'Extern')
		,[Soort leverancier] = COALESCE(LEV.[Soort leverancier], 'Niet uitvragen')
		,volgnummer = ROW_NUMBER() OVER (
			PARTITION BY kcm.reparatieverzoeknr ORDER BY CONVERT(DATE, kcm.[Ingevulde gegevens]) DESC
			)
	-- select * 
	FROM empire_Staedion_Data.kcm.STN658_Ingevulde_gegevens AS kcm
	-- from Staging.kcm as kcm
	LEFT JOIN empire_logic.dbo.lt_mg_oge AS oge ON oge.mg_bedrijf = 'Staedion'
		AND oge.Nr_ = kcm.eenheidnr
	LEFT JOIN empire_logic.dbo.lt_mg_cluster AS cluster ON oge.mg_bedrijf = 'Staedion'
		AND cluster.Nr_ = kcm.clusternr
	LEFT JOIN empire_staedion_data.kcm.STN658_Leveranciers AS LEV ON LEV.leveranciersnr = kcm.Leveranciersnr
	)
SELECT *
FROM CTE
WHERE Reparatieverzoeknr = ''
	OR (
		Reparatieverzoeknr <> ''
		AND volgnummer = 1
		)
GO
