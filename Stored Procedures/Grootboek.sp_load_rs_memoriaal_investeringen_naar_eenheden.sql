SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Grootboek].[sp_load_rs_memoriaal_investeringen_naar_eenheden] 
			( @Boekjaar AS INT = NULL , @UitsluitenPOGO AS SMALLINT = 1) 
AS
/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Genereren bedragen investeringen per eenheid op basis van aantal gekozen grootboekrekeningen.
Dat kan vervolgens worden gebruikt om in de activa-module op te nemen.
Data wordt verwerkt in volgende tabellen
* staedion_dm.Rapport.InvesteringenToegerekend_Clusterverdeelsleutels
* staedion_dm.Rapport.InvesteringenToegerekend_Clusters
* staedion_dm.Rapport.InvesteringenToegerekend_Eenheid
Zie SSRS: [Specificatie investeringen grootboekrekening naar eenheden.rdl]
Rekeningen: 
* A021300 investeringen vastgoed verbeteringen
* A021302 Investeringen duurzaamheid zonnepanelen
* A021306 Investeringen achterstallig onderhoud
* A021308 Investeringen energetische verbeteringen
NB: uitgegaan wordt van lineaire verdeelsleutels 
NB: alternatief voor deze werkwijze: voeg deze rekeningen toe aan [Toe te rekenen aan oges] en neem ze op in de toerekening. Wel performance issues met deze functionaliteit in Empire. Vandaar in 2021 niet toegepast.
'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Grootboek'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_rs_memoriaal_investeringen_naar_eenheden';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220119 JvdW Topdesk 21 12 905 Memoriaal klaarzetten obv data grootboek investeringen
20220126 JvdW Nancy gaf aan dat verdeel niet helemaal sloot - aanpassing in berekening + visuele check in rapport toegevoegd
TO DO: check verdeling met die op shrek obv toegerekende posten 
--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
exec staedion_dm.Grootboek.[sp_load_rs_memoriaal_investeringen_naar_eenheden]  @Boekjaar = 2021
select count(*) from staedion_dm.Rapport.InvesteringenToegerekend_Clusterverdeelsleutels
select count(*) from staedion_dm.Rapport.InvesteringenToegerekend_Clusters
select count(*) from staedion_dm.Rapport.InvesteringenToegerekend_Eenheden

-- Check
SELECT SUM([Bedrag toegerekend per eenheid]) FROM staedion_dm.bak.InvesteringenToegerekend_Eenheden
WHERE Opmerking1 = 'Te verdelen obv specifieke project-clusterverdeelsleutel'
SELECT SUM(Bedrag) FROM staedion_dm.bak.InvesteringenToegerekend_Clusters
WHERE Opmerking1 = 'Te verdelen obv specifieke project-clusterverdeelsleutel'

-- Eventuele afwijkingen
SELECT	BASIS.Cluster, BASIS.[Empire projectnr] 
	, ABS( Bedrag -  (SELECT SUM([Bedrag toegerekend per eenheid]) FROM 	##InvesteringenToegerekend_Eenheid AS VERDEEL 
						WHERE VERDEEL.Cluster = BASIS.Cluster  
									AND VERDEEL.[Empire projectnr] = BASIS.[Empire projectnr] 
									AND VERDEEL.[Empire werksoort] = BASIS.[Empire werksoort] 
									) ) AS CheckEenheid,BASIS.*

FROM	staedion_dm.Rapport.InvesteringenToegerekend_Clusters AS BASIS
ORDER BY 3 desc
############################################################################################################################# */


BEGIN TRY
		SET NOCOUNT ON
		DECLARE @Onderwerp NVARCHAR(100);

-----------------------------------------------------------------------------------
SET @Onderwerp = 'Variabelen definieren';
----------------------------------------------------------------------------------- 
		DECLARE @Bron NVARCHAR(255) =  OBJECT_NAME(@@PROCID),								
				@Variabelen NVARCHAR(255),													
				@Categorie AS NVARCHAR(255) = 	COALESCE(OBJECT_SCHEMA_NAME(@@PROCID),'Overig'),	
				@AantalRecords DECIMAL(12, 0),												
				@Bericht NVARCHAR(255),														
				@Start as DATETIME,															
				@Finish as DATETIME															

		IF @Boekjaar IS NULL 
			SET @Boekjaar = YEAR(GETDATE())-1

		SET @Variabelen = '@Boekjaar = ' + format(@Boekjaar,'N0') + ' ; ' +
								'@UitsluitenPOGO = ' + FORMAT(@UitsluitenPOGO,'N0') ;									

		SET	@Start = CURRENT_TIMESTAMP;

-----------------------------------------------------------------------------------
SET @Onderwerp = 'BEGIN';
----------------------------------------------------------------------------------- 
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Onderwerp
					,@Variabelen = @Variabelen

-----------------------------------------------------------------------------------
SET @Onderwerp = 'staedion_dm.Rapport.InvesteringenToegerekend_Clusterverdeelsleutels';
----------------------------------------------------------------------------------- 
		DROP TABLE IF EXISTS staedion_dm.Rapport.InvesteringenToegerekend_Clusterverdeelsleutels
		;
		DECLARE @Peildatum AS DATE = NULL;
		WITH CTE_BASISPROJECT ([Cluster No_], [Project No_], [Distribution Key Type], [Start Date], [End Date], [Status],
							   [Version No_], [Budget Line No_], Volgnr
							  )
		AS (SELECT [Cluster No_],
				   [Project No_],
				   [Distribution Key Type],
				   [Start Date],
				   [End Date],
				   [Status],
				   [Version No_],
				   [Budget Line No_],
				   ROW_NUMBER() OVER (PARTITION BY [Project No_],
												   [Cluster No_],
												   [Distribution Key Type],
												   [Start Date]
									  ORDER BY [Version No_] DESC
									 )
			-- select *
			FROM empire_data.dbo.[Staedion$Cluster_Distrn_Keys_Header]
			WHERE [Distribution Key Type] = 'LINEAIR'
				  AND [Status] = 1 --Geactiveerd (er zijn op een peildata soms meerdere regels actief (0 = voorlopig)
				  AND [Start date] <= ISNULL(@Peildatum, GETDATE())
				  AND ([End Date] >= ISNULL(@Peildatum, GETDATE()) OR [End Date] = '17530101'
					 )
				  ),
			 CTE_PROJECT ([Cluster No_], [Project No_], [Distribution Key Type], [Start Date], [End Date], [Status],
						  [Version No_], [Budget Line No_], [Realty Unit No_], Numerator, Volgnr
						 )
		AS (SELECT BASIS.[Cluster No_],
				   BASIS.[Project No_],
				   BASIS.[Distribution Key Type],
				   BASIS.[Start Date],
				   BASIS.[End Date],
				   BASIS.[Status],
				   BASIS.[Version No_],
				   BASIS.[Budget Line No_],
				   LINE.[Realty Unit No_],
				   LINE.Numerator,
				   Volgnr = ROW_NUMBER() OVER (PARTITION BY [Realty Unit No_],
															CLUS.Clustersoort
											   ORDER BY BASIS.[Cluster No_]
											  )
			FROM CTE_BASISPROJECT AS BASIS
				JOIN empire_data.dbo.[Staedion$Cluster_Distrn_Keys_Line] AS LINE
					ON BASIS.[Cluster No_] = LINE.[Cluster No_]
					   AND BASIS.[Distribution Key Type] = LINE.[Distribution Key Type]
					   AND BASIS.[Version No_] = LINE.[Version No_]
				JOIN empire_data.dbo.[Staedion$Cluster] AS CLUS
					ON CLUS.Nr_ = BASIS.[Cluster No_]
			WHERE BASIS.[Start date] <= ISNULL(@Peildatum, GETDATE())
				  AND
				  (
					  BASIS.[End Date] >= ISNULL(@Peildatum, GETDATE())
					  OR BASIS.[End Date] = '17530101'
				  )
				  AND BASIS.Volgnr = 1
			 --and( BASIS.[Cluster No_] = @Clusternr or @Clusternr  is null)
			 )
		SELECT *
		INTO	staedion_dm.Rapport.InvesteringenToegerekend_Clusterverdeelsleutels
		FROM CTE_PROJECT
		WHERE Numerator <> 0
		ORDER BY [Project No_],
				 [Cluster No_],
				 [Realty Unit No_];

		SET @AantalRecords = @@rowcount;
		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Bericht
					
-----------------------------------------------------------------------------------
SET @Onderwerp = 'staedion_dm.Rapport.InvesteringenToegerekend_Clusters';
----------------------------------------------------------------------------------- 
		DROP TABLE IF EXISTS staedion_dm.Rapport.InvesteringenToegerekend_Clusters
		;
		select GP.Bedrijf, GP.Rekening, GP.[Empire projectnr], GP.[Empire werksoort],GP.[Empire Projecttype],GP.Cluster
				,MAX(GP.[Omschrijving]) AS [Laatste omschrijving]
				,CONVERT(FLOAT,SUM(GP.[Bedrag incl. verplichting])) AS Bedrag
				,(select SUM(Numerator) from staedion_dm.Rapport.InvesteringenToegerekend_Clusterverdeelsleutels where [Cluster No_] = GP.Cluster) AS [Clusterverdeelsleutels obv cluster]
				,(select SUM(Numerator) from staedion_dm.Rapport.InvesteringenToegerekend_Clusterverdeelsleutels where [Cluster No_] = GP.Cluster AND COALESCE(NULLIF([Project No_],''),'X') = COALESCE(NULLIF(GP.[Empire projectnr],''),'Y')) AS [Clusterverdeelsleutels obv cluster+project]
				,CAST(IIF(NULLIF(GP.[Empire projectnr],'') IS NULL AND NULLIF(GP.cluster,'') IS NULL,'Onduidelijk', 'Te verdelen') AS NVARCHAR(100)) AS Opmerking1
		INTO  staedion_dm.Rapport.InvesteringenToegerekend_Clusters
		FROM Grootboek.vw_GrootboekPosten AS GP
		--    OUTER APPLY [staedion_dm].[Eenheden].[fn_CLusterBouwblok](GP.[Eenheidnr]) AS COLL
		WHERE YEAR(Boekdatum) = @Boekjaar
			  AND Rekeningnr IN ('A021300','A021302','A021304', 'A021306','A021308')			  
		--GROUP BY GP.Cluster,  GP.[Empire projectnr]
		GROUP BY GP.Bedrijf, GP.Rekening, GP.[Empire projectnr], GP.[Empire werksoort],GP.[Empire Projecttype],GP.Cluster
		;
		SET @AantalRecords = @@rowcount;

		DELETE FROM staedion_dm.Rapport.InvesteringenToegerekend_Clusters
		WHERE [Empire projectnr] LIKE 'POGO%' AND @UitsluitenPOGO = 1
		;

		UPDATE BASIS
		SET Opmerking1 = 'Te verdelen obv specifieke project-clusterverdeelsleutel'
		FROM  staedion_dm.Rapport.InvesteringenToegerekend_Clusters AS BASIS
		WHERE COALESCE([Clusterverdeelsleutels obv cluster+project],0) > 0
		;
		UPDATE BASIS
		SET Opmerking1 = 'Te verdelen obv specifieke clusterverdeelsleutel'
		FROM  staedion_dm.Rapport.InvesteringenToegerekend_Clusters AS BASIS
		WHERE [Clusterverdeelsleutels obv cluster] > 0
		AND COALESCE([Clusterverdeelsleutels obv cluster+project],0) = 0
		;
		UPDATE BASIS
		SET Opmerking1 = 'Hoe te verdelen ?'
		FROM  staedion_dm.Rapport.InvesteringenToegerekend_Clusters AS BASIS
		WHERE COALESCE([Clusterverdeelsleutels obv cluster],0) = 0
		AND COALESCE([Clusterverdeelsleutels obv cluster+project],0) = 0
		;

		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Bericht

-----------------------------------------------------------------------------------
SET @Onderwerp = '##InvesteringenToegerekend_Eenheid';
----------------------------------------------------------------------------------- 
		DROP TABLE IF Exists ##InvesteringenToegerekend_Eenheid
		;
		SELECT BASIS.Bedrijf, BASIS.[Rekening], BASIS.[Empire projectnr], BASIS.Cluster, [Empire Projecttype], BASIS.[Empire werksoort],
				VERDEEL.[Realty Unit No_] AS Eenheidnr,
				--VERDEEL.[Numerator]/BASIS.[Clusterverdeelsleutels obv cluster+project]*Bedrag AS [Bedrag toegerekend per eenheid]
				Bedrag/BASIS.[Clusterverdeelsleutels obv cluster+project]*VERDEEL.[Numerator] AS [Bedrag toegerekend per eenheid]
		INTO ##InvesteringenToegerekend_Eenheid
		FROM staedion_dm.Rapport.InvesteringenToegerekend_Clusters AS BASIS
		JOIN staedion_dm.Rapport.InvesteringenToegerekend_Clusterverdeelsleutels AS VERDEEL
		ON VERDEEL.[Cluster No_] = BASIS.Cluster 
		AND VERDEEL.[Project No_] = BASIS.[Empire projectnr]
		WHERE BASIS.Opmerking1 = 'Te verdelen obv specifieke project-clusterverdeelsleutel'
		;
		SET @AantalRecords = @@rowcount;

		SELECT SUM(Bedrag) FROM  staedion_dm.Rapport.InvesteringenToegerekend_Clusters WHERE Opmerking1 = 'Te verdelen obv specifieke project-clusterverdeelsleutel'
		SELECT SUM([Bedrag toegerekend per eenheid]) FROM ##InvesteringenToegerekend_Eenheid
		
		INSERT INTO ##InvesteringenToegerekend_Eenheid ([Bedrijf], [Rekening],[Empire projectnr], [Cluster], [Empire Projecttype], [Empire werksoort],
					Eenheidnr,
					[Bedrag toegerekend per eenheid])
		SELECT	BASIS.Bedrijf, BASIS.[Rekening], BASIS.[Empire projectnr], BASIS.Cluster, BASIS.[Empire Projecttype], BASIS.[Empire werksoort],
				VERDEEL.[Realty Unit No_] AS Eenheidnr
				,Bedrag/BASIS.[Clusterverdeelsleutels obv cluster]*VERDEEL.[Numerator] AS [Bedrag toegerekend per eenheid]
				--, VERDEEL.[Numerator]/BASIS.[Clusterverdeelsleutels obv cluster]*Bedrag AS [Bedrag toegerekend per eenheid]
		FROM staedion_dm.Rapport.InvesteringenToegerekend_Clusters AS BASIS
		JOIN staedion_dm.Rapport.InvesteringenToegerekend_Clusterverdeelsleutels AS VERDEEL
		ON VERDEEL.[Cluster No_] = BASIS.Cluster 
		WHERE Opmerking1 = 'Te verdelen obv specifieke clusterverdeelsleutel'
		;
		SET @AantalRecords = @AantalRecords + @@rowcount;

		SELECT SUM(Bedrag) FROM  staedion_dm.Rapport.InvesteringenToegerekend_Clusters WHERE Opmerking1 = 'Te verdelen obv specifieke clusterverdeelsleutel'
		SELECT SUM([Bedrag toegerekend per eenheid]) FROM ##InvesteringenToegerekend_Eenheid

		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Bericht
-----------------------------------------------------------------------------------
SET @Onderwerp = 'Vullen per eenheid + updates - staedion_dm.Rapport.InvesteringenToegerekend_Eenheid';
----------------------------------------------------------------------------------- 

		DROP TABLE IF EXISTS ##Hulp;
		DROP TABLE IF Exists staedion_dm.Rapport.InvesteringenToegerekend_Eenheid;
		;
		SELECT [Bedrijf], [Rekening],Eenheidnr, SUM([Bedrag toegerekend per eenheid]) AS [Bedrag toegerekend per eenheid],
					CONVERT(DATE,NULL) AS [Datum uit exploitatie],
					CONVERT(nvarchar(40),NULL) AS [FT cluster],
					CONVERT(nvarchar(40),NULL) AS [Technisch type],
					CONVERT(nvarchar(70),NULL) AS [Adres],
					CONVERT(nvarchar(40),NULL) AS [Administratief eigenaar],
					CONVERT(NVARCHAR(max),STRING_AGG(NULLIF([Empire projectnr],''),',')) AS [Projectnrs]
		INTO ##Hulp
		FROM ##InvesteringenToegerekend_Eenheid
		GROUP BY [Bedrijf], [Rekening],	Eenheidnr
		;
		/* 20220204 JvdW: bleek onvolledig te zijn
		UPDATE BASIS
		SET Adres = EIG.adres,
			[Technisch type] = TT.[Technisch type],
			[Datum uit exploitatie] = EIG.[Datum uit exploitatie]
		FROM ##Hulp AS BASIS
			JOIN staedion_dm.Eenheden.Eigenschappen AS EIG
				ON EIG.Eenheidnr = BASIS.Eenheidnr
				   AND EIG.Einddatum IS NULL
			JOIN staedion_dm.Eenheden.[Technisch type] AS TT
				ON TT.[Technisch type_id] = EIG.[Technisch type_id]
		;
		*/
		UPDATE BASIS
		SET Adres = CONCAT(OGE.[Straatnaam],' ',OGE.Huisnr_,' ',OGE.Toevoegsel),
			[Technisch type] = TT.[Omschrijving],
			[Datum uit exploitatie] = OGE.[einde exploitatie],
			[FT cluster] = COLL.[FT-Clusternummer]
		FROM ##Hulp AS BASIS
			JOIN empire_data.dbo.staedion$oge AS OGE
				ON OGE.Nr_ = BASIS.Eenheidnr
				LEFT OUTER JOIN empire_Data.dbo.staedion$Type AS TT
				ON TT.[Code] = OGE.[Type]
				   AND TT.[Soort] <> 2
				   OUTER APPLY [staedion_dm].[Eenheden].[fn_CLusterBouwblok](OGE.Nr_) AS COLL
		;
		WITH cte_adm
		AS (SELECT Eenheidnr,
				   [Administratief eigenaar],
				   ROW_NUMBER() OVER (PARTITION BY Eenheidnr ORDER BY Peildatum DESC) AS Volgnr
			FROM staedion_dm.Eenheden.Meetwaarden)
		UPDATE BASIS
		SET [Administratief eigenaar] = CTE.[Administratief eigenaar]
		FROM ##Hulp AS BASIS
			JOIN cte_adm AS CTE
				ON CTE.Eenheidnr = BASIS.Eenheidnr
				   AND CTE.Volgnr = 1
		;
		SELECT Bedrijf, eenheidnr, Adres, [Technisch Type], [Administratief eigenaar], NULLIF([Datum uit exploitatie], '17530101') AS [Datum uit exploitatie]
							,[Projectnrs],[FT cluster],
							piv.[A021300 investeringen vastgoed verbeteringen],piv.[A021302 Investeringen duurzaamheid zonnepanelen],
							piv.[A021304 Investeringen duurzaamheid aardgasloos],
							piv.[A021306 Investeringen achterstallig onderhoud],piv.[A021308 Investeringen energetische verbeteringen]
		INTO staedion_dm.Rapport.InvesteringenToegerekend_Eenheid
		FROM ##Hulp  AS BASIS
		PIVOT 
		(SUM([Bedrag toegerekend per eenheid]) 
		FOR [Rekening] IN  ([A021300 investeringen vastgoed verbeteringen],[A021302 Investeringen duurzaamheid zonnepanelen],
							[A021304 Investeringen duurzaamheid aardgasloos],
							[A021306 Investeringen achterstallig onderhoud],[A021308 Investeringen energetische verbeteringen])
		) AS piv

		SET @AantalRecords = @@rowcount;
		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Bericht

	SET		@Finish = CURRENT_TIMESTAMP
	
-----------------------------------------------------------------------------------
SET @Onderwerp = 'EINDE';
----------------------------------------------------------------------------------- 
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@Begintijd = @Start
					,@Eindtijd = @Finish
					,@DatabaseObject = @Bron
					,@Variabelen = @Variabelen
					,@Bericht = @Onderwerp

			
END TRY

BEGIN CATCH

	SET		@Finish = CURRENT_TIMESTAMP

	DECLARE @ErrorProcedure AS NVARCHAR(255) = ERROR_PROCEDURE()
	DECLARE @ErrorLine AS INT = ERROR_LINE()
	DECLARE @ErrorNumber AS INT = ERROR_NUMBER()
	DECLARE @ErrorMessage AS NVARCHAR(255) = LEFT(ERROR_MESSAGE(),255)

	EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					, @DatabaseObject = @Bron
					, @Variabelen = @Variabelen
					, @Begintijd = @start
					, @Eindtijd = @finish
					, @ErrorProcedure =  @ErrorProcedure
					, @ErrorLine = @ErrorLine
					, @ErrorNumber = @ErrorNumber
					, @ErrorMessage = @ErrorMessage

END CATCH



GO
GRANT EXECUTE ON  [Grootboek].[sp_load_rs_memoriaal_investeringen_naar_eenheden] TO [public]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Genereren bedragen investeringen per eenheid op basis van aantal gekozen grootboekrekeningen.
Dat kan vervolgens worden gebruikt om in de activa-module op te nemen.
Data wordt verwerkt in volgende tabellen
* staedion_dm.Rapport.InvesteringenToegerekend_Clusterverdeelsleutels
* staedion_dm.Rapport.InvesteringenToegerekend_Clusters
* staedion_dm.Rapport.InvesteringenToegerekend_Eenheid
Zie SSRS: [Specificatie investeringen grootboekrekening naar eenheden.rdl]
Rekeningen: 
* A021300 investeringen vastgoed verbeteringen
* A021302 Investeringen duurzaamheid zonnepanelen
* A021306 Investeringen achterstallig onderhoud
* A021308 Investeringen energetische verbeteringen
NB: uitgegaan wordt van lineaire verdeelsleutels 
NB: alternatief voor deze werkwijze: voeg deze rekeningen toe aan [Toe te rekenen aan oges] en neem ze op in de toerekening. Wel performance issues met deze functionaliteit in Empire. Vandaar in 2021 niet toegepast.
', 'SCHEMA', N'Grootboek', 'PROCEDURE', N'sp_load_rs_memoriaal_investeringen_naar_eenheden', NULL, NULL
GO
