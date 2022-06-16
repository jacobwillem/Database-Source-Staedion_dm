SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Grootboek].[sp_load_rapport_GrootboekpostenWMO] 
			(  @Peildatum AS DATE = '20190101') 
AS

/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Tbv proces WMO facturering en doorberekening is een rapport opgesteld op basis van datamart grootboek en onderhoud.
Er is echter nog wat business-logica vereist, vandaar deze procedure, om de Power BI rapportage te kunnen opstellen.
Opzet is namelijk om per adres (kan ook collectief object) zijn te groeperen wat er aan kosten is geboekt en wat er is doorbelast.
Niet altijd is eenheidnr opgevoerd, soms wel te achterhalen via onderhoudsorder wat op grootboekpost is terug te vinden
Zie view Grootboek.vw_GrootboekpostenWMO (bouwt voort op vw_Grootboekposten - zou voldoende zijn als er perfect wordt geboekt)
Zie PBI WMO'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Grootboek'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_rapport_GrootboekpostenWMO';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220516 JvdW aangemaakt


--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
----------------------------------------------------------------------------------------------------------------------------------
exec [Grootboek].[sp_load_rapport_GrootboekpostenWMO] 

-- saldo rekeningen moet natuurlijk overeenkomen met financieel perspectief
select sum([Kosten A815160]),sum([Opbrengst A850250]), sum([Saldo A815160 + A850250])
from rapport.GrootboekpostenWMO
where year(Boekdatum) = 2022
and month(Boekdatum) < 5

SELECT * FROM staedion_dm.DatabaseBeheer.vw_LoggingUitvoeringDatabaseObjecten 
WHERE Begintijd >= dateadd(d,-2,getdate()) 
and Databaseobject like '%oad_rapport_Grootboekposten%'
order by Begintijd desc
--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------

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

		IF @Peildatum IS NULL
			SET @Peildatum = datefromparts(year(getdate())-1,1,1);

		SET @Variabelen = '@Peildatum = ' + COALESCE(format(@Peildatum,'dd-MM-yyyy','nl-NL'),'null') + ' ; ' 

		SET	@Start = CURRENT_TIMESTAMP;

-----------------------------------------------------------------------------------
SET @Onderwerp = 'BEGIN';
----------------------------------------------------------------------------------- 
		drop table if exists rapport.GrootboekpostenWMO
		;

		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Variabelen = @Variabelen
					,@Bericht = @Onderwerp

-----------------------------------------------------------------------------------
SET @Onderwerp = 'Ophalen grootboekposten WMO';
----------------------------------------------------------------------------------- 
	/* had dit eerst in aparte view staan - maar nu logica van deze view in de procedure gestopt en view verwijderd
	select	*
			,convert(nvarchar(100),null) as Opmerking
			,getdate() as Gegenereerd
	into	rapport.GrootboekpostenWMO
	from	Grootboek.vw_GrootboekpostenWMO
	where	Boekdatum >= @Peildatum
	;
	*/
	; 
	WITH cte_alle_regels
	AS (
		SELECT GP.Volgnummer
			,GP.[Eenheid + adres] AS [Eenheid/collectief object + adres]
			,GP.[Bedrijf]
			,GP.[Boekdatum]
			,GP.[Rekeningnr]
			,GP.[Grootboekrekening]
			,GP.[Rekening]
			,GP.[Document nr]
			,GP.[Omschrijving]
			,GP.[Tegenrekening Leverancier]
			,GP.[Bedrag incl. verplichting]
			,GP.[Gebruiker]
			,GP.[Bron Klant]
			,GP.[Code]
			,GP.[Eenheidnr]
			,GP.[Broncode]
			,GP.[Productboekingsgroep]
			,GP.[Soort-boekingen]
			,GP.[Referentie onderhoud]
		-- select GP.*
		FROM Grootboek.vw_GrootboekPosten AS GP
		WHERE GP.Boekdatum >= @Peildatum
		and GP.[Bedrijf] = 'Staedion'
			AND Rekeningnr IN (
				'A815150'
				,'A850260'
				,'A815160'
				,'A815170'
				,'A850250'
				,'A850260'
				)
			AND GP.[Soort-boekingen] = 'Saldo grootboek'		-- daeb boekingen ed niet meenemen
	
		UNION
	
		SELECT DISTINCT NULL AS Volgnummer
			,NULL AS [Eenheid/collectief object + adres]
			,'Staedion' AS [Bedrijf]
			,@Peildatum AS [Boekdatum]
			,R.rekeningnr AS Rekeningnr
			,R.[Grootboekrekening]
			,R.rekeningnr + ' ' + R.Grootboekrekening AS Rekening
			,NULL AS [Document nr]
			,NULL AS [Omschrijving]
			,NULL AS [Tegenrekening Leverancier]
			,NULL AS [Bedrag incl. verplichting]
			,NULL AS [Gebruiker]
			,NULL AS [Bron Klant]
			,NULL AS [Code]
			,--BR.[Code] AS[Code],
			NULL AS [Eenheidnr]
			,NULL AS Broncode
			,--PG.Code AS [Broncode],
			NULL AS Productboekingsgroep
			,--PG.Productboekingsgroep AS [Productboekingsgroep],
			'Saldo grootboek' AS [Soort-boekingen]
			,NULL as [Referentie onderhoud]
		FROM [Grootboek].[Rekening] AS R
		LEFT OUTER JOIN [Grootboek].[Grootboekposten] AS GP ON R.rekening_id = GP.Rekening_id
		LEFT OUTER JOIN [Grootboek].[Bronnen] AS BR ON BR.Bron_id = GP.Bron_id
		LEFT OUTER JOIN [Grootboek].[Productboekingsgroep] AS PG ON PG.Productboekingsgroep_id = GP.Productboekingsgroep_id
		LEFT OUTER JOIN [Algemeen].[Bedrijven] AS BEDR ON BEDR.bedrijf_id = GP.Bedrijf_id
		LEFT OUTER JOIN [Eenheden].[Eigenschappen] AS EIG ON EIG.Eenheidnr = GP.Eenheidnr
			AND EIG.Einddatum IS NULL
		WHERE Rekeningnr IN (
				'A815150'
				,'A850260'
				,'A815160'
				,'A815170'
				,'A850250'
				,'A850260'
				)
		)
	SELECT REG.[Eenheidnr]
		,REG.[Eenheid/collectief object + adres]
		,left(REG.[Referentie onderhoud],15) as [Referentie onderhoud]
		,REG.Boekdatum as Boekdatum
		,sum(iif(REG.Rekeningnr IN ('A815160'), REG.[Bedrag incl. verplichting], 0)) AS [Kosten A815160]
		,sum(iif(REG.Rekeningnr IN ('A850250'), REG.[Bedrag incl. verplichting], 0)) AS [Opbrengst A850250]
		,sum(iif(REG.Rekeningnr IN ('A815160','A850250'), REG.[Bedrag incl. verplichting], 0)) AS [Saldo A815160 + A850250]
		,sum(iif(REG.Rekeningnr IN ('A850260'), REG.[Bedrag incl. verplichting], 0)) AS [Opslag A850260]
		,max(iif(REG.Rekeningnr IN ('A815160'), REG.[Document nr], NULL)) AS [Factuurnr kosten A815160]
		,max(iif(REG.Rekeningnr IN ('A850250'), REG.[Document nr], NULL)) AS [Factuurnr opbrengst A850250]
		--,min(REG.[Referentie onderhoud]) as [Referentie onderhoud]
		,CASE 
			WHEN sum(iif(REG.Rekeningnr IN ('A850250'), REG.[Bedrag incl. verplichting], 0)) <> 0
				THEN 1
			ELSE 0
			END AS [Teller Doorberekend]
		,CASE 
			WHEN sum(iif(REG.Rekeningnr IN ('A815160'), REG.[Bedrag incl. verplichting], 0)) <> 0
				THEN 1
			ELSE 0
			END AS [Teller WMO beschikking]
		,max(iif(REG.Rekeningnr IN ('A815160'), 
		--			'https://staedion.xtendis.nl/web/weblauncher.aspx?archiefnaam=Centraal&Doc_Leveranciernummer='
					'https://staedion.xtendis.nl/web/weblauncher.aspx?archiefnaam=Centraal&Interne referentie='
					+ REG.[Document nr]
					,null)) AS HyperlinkFactuur
		,'<a href="'
			+staedion_dm.algemeen.fn_EmpireLink('Staedion', 11031240, 'No.=' 
					+ left(min(REG.[Referentie onderhoud]),15)
					+ '', 'view') 
					+ '">'+ left(min(REG.[Referentie onderhoud]),15)
					+ '</a>'				
					AS HyperlinkEmpire
		,'Van '+ min(REG.[Document nr]) + ' t/m ' + max(REG.[Document nr]) as Documenten
		,convert(nvarchar(100),null) as Opmerking
		,getdate() AS gegenereerd
	into rapport.GrootboekpostenWMO
	FROM cte_alle_regels AS REG
	GROUP BY REG.[Eenheidnr]
		,REG.[Eenheid/collectief object + adres]
		,left(REG.[Referentie onderhoud],15)
		,REG.Boekdatum
	;

		SET @AantalRecords = @@rowcount;
		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Bericht

-----------------------------------------------------------------------------------
SET @Onderwerp = 'Update info eenheidnr waar dit ontbreekt';
----------------------------------------------------------------------------------- 
	-- [Referentie onderhoud] soms taak / order / verzoek
	update	BASIS
	set		[Eenheidnr] = coalesce(nullif(VERZ.Eenheidnr,''),VERZ.Collectiefnr)
	--		,Opmerking =  'Geen eenheidnr opgevoerd in grootboekposten'
	from	rapport.GrootboekpostenWMO as BASIS
	join	staedion_dm.onderhoud.Onderhoudsverzoek as VERZ
	on		BASIS.[Referentie onderhoud] = VERZ.Onderhoudsverzoek
	and		VERZ.[Geldig tot] is null
	where	nullif(BASIS.Eenheidnr,'') is null
	--and		BASIS.[Referentie onderhoud] = 'OND00000200-000'
	;
	SET @AantalRecords = @@rowcount
	;
	update	BASIS
	set		[Eenheidnr] = coalesce(nullif(TAAK.Eenheidnr,''),TAAK.Collectiefnr) 
	--		,Opmerking =   'Geen eenheidnr opgevoerd in grootboekposten'
	from	rapport.GrootboekpostenWMO as BASIS
	join	staedion_dm.onderhoud.Onderhoudstaak as TAAK
	on		BASIS.[Referentie onderhoud] = TAAK.Onderhoudstaak
	where	nullif(BASIS.Eenheidnr,'') is null
	;
	SET @AantalRecords =coalesce(@AantalRecords,0) + coalesce( @@rowcount,0)
	;
	update	BASIS
	set		BASIS.[Eenheid/collectief object + adres] = coalesce(EIG.[Eenheid + adres],COLL.[Collectief object] + ' '+ COLL.Omschrijving) 
	from	rapport.GrootboekpostenWMO as BASIS
	left outer JOIN	[Eenheden].[Eigenschappen] AS EIG
	ON		EIG.Eenheidnr = BASIS.Eenheidnr
	AND		EIG.Einddatum IS NULL
	LEFT OUTER JOIN [Eenheden].[Collectieve objecten] AS COLL
	ON		COLL.[Collectief object] = BASIS.Eenheidnr
	AND		COLL.Einddatum IS NULL
	where	nullif(BASIS.[Eenheid/collectief object + adres],'') is null
	;
	update	BASIS
	set		[Eenheidnr] = 'Nvt'
			,[Eenheid/collectief object + adres] = 'Geen reguliere boeking met adres'
			,Opmerking =  'Bijv correctieboeking / memoriaalboeking'
			,[Referentie onderhoud] = 'Nvt' 
	from	rapport.GrootboekpostenWMO as BASIS
	where	nullif(BASIS.Eenheidnr,'') is null
	or		nullif(BASIS.[Referentie onderhoud],'') is null
	;
	SET @AantalRecords =coalesce(@AantalRecords,0) + coalesce( @@rowcount,0)
	;
	--SELECT 1/0
		SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @Bericht = @Bericht + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @Categorie
					,@DatabaseObject = @Bron
					,@Bericht = @Bericht

	select * from rapport.GrootboekpostenWMO
	;

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
GRANT EXECUTE ON  [Grootboek].[sp_load_rapport_GrootboekpostenWMO] TO [public]
GO
