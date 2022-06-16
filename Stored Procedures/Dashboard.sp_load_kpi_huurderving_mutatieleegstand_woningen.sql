SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Dashboard].[sp_load_kpi_huurderving_mutatieleegstand_woningen] 
			( @Peildatum AS DATE = NULL
			, @IndicatorID AS INT = NULL
			, @LoggingWegschrijvenOfNiet AS BIT = 1) 
AS
/* #############################################################################################################################
<Bedoeling database vastleggen of in metadata van object, als je dat via onderstaand commando opvoert, is dat terug te vinden in de extended properties van het object en kun je het ook genereren in de database-documentatie>
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'<Sjabloon voor opvoeren kpi in dashboard. Dit sjabloon kan gebruikt worden voor nieuwe procedures of het omzetten van oude procedures. Tbv uniformiteit + logging + kans op fouten verminderen.>'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'DatabaseBeheer'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_kpi_sjabloon VOORSTEL';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
<JJJJMMDD> <Initialen> <Toelichting>
20211207 JvdW Opzet nav overleg met Martijn en Pepijn
			> zie aantekeningen Teams - data engineers - te ontsluiten databronnen - Stored Procedure.docs
			> oude verwijzingen naar functies/procedures andere database vervangen door verwijzing naar procedures binnen deze database
20211208 JvdW
			> @VerversenVanaf niet gebruiken 
			> Toegevoegd DatabaseBeheer.[sp_load_master VOORSTEL], vergelijk [dbo].[sp_load_kpi], incl:
			> Aldaar verwijzen naar extra kolom(men) indicator-tabel: verversen_vanaf_1_1 | aantal_maanden_te_verversen

Attentiepunten
> check snippet
> check databasebeheer-documentatie
> check kpi-queries die meerdere indicatoren omvatten: bedrijfslasten + sp_load_kpi_energie 
> schaduwdraaien fk_indicator_id 110
> Syntax Postgresql DB proef ?
> Syntax Azure DB proef ?

--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
<validatietest: indien relevant vermeld hier bijvoorbeeld een query die checkt op dubbele waarden>
EXEC staedion_dm.[DatabaseBeheer].[<databaseobject>] @IndicatorID  = 0, @Peildatum = null, @VerversenVanaf = null, @LoggingWegschrijvenOfNiet =1

-- logging van procedures
SELECT * FROM staedion_dm.databasebeheer.LoggingUitvoeringDatabaseObjecten where Databaseobject like '%<objectnaam>%' ORDER BY begintijd desc

-- compileertest
EXEC empire_staedion_logic.dbo.dsp_controle_Database_objecten 'staedion_dm'

EXEC staedion_dm.[DatabaseBeheer].[sp_load_kpi_sjabloon VOORSTEL]  @IndicatorID  = 0, @Peildatum = null, @VerversenVanaf = null, @LoggingWegschrijvenOfNiet = 1
SELECT * FROM staedion_dm.databasebeheer.LoggingUitvoeringDatabaseObjecten where Databaseobject like '%sp_load_kpi_sjabloon VOORSTEL%' ORDER BY begintijd desc
delete FROM staedion_dm.databasebeheer.LoggingUitvoeringDatabaseObjecten where Databaseobject like '%sp_load_kpi_sjabloon VOORSTEL%' 
select * from staedion_dm.dashboard.realisatiedetails where fk_indicator_id = 0

--------------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------------
-- Toevoeging info over tabel/view
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'<Bedoeling databaseobject .....>'
       ,@level0type = N'SCHEMA'
       ,@level0name = '<schemanaam>'
       ,@level1type = N'PROCEDURE'
       ,@level1name = '<databaseobject>';
GO

exec staedion_dm.[DatabaseBeheer].[sp_info_object_en_velden] 'staedion_dm', 'DatabaseBeheer','sp_load_kpi_sjabloon VOORSTEL'

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------
<voeg desgewenst handige queries toe die je gebruikt hebt bij het bouwen en die je bij beheer wellicht nodig kunt hebben>

############################################################################################################################# */


BEGIN TRY
		SET NOCOUNT on
		DECLARE @onderwerp NVARCHAR(100);

-----------------------------------------------------------------------------------
SET @onderwerp = 'Variabelen definieren';
----------------------------------------------------------------------------------- 
		DECLARE @_Bron NVARCHAR(255) =  OBJECT_NAME(@@PROCID),										-- om mee te geven bij loggen
				@_Variabelen NVARCHAR(255),															-- om eenmalig mee te geven bij loggen
				@_Categorie AS NVARCHAR(255) = 	COALESCE(OBJECT_SCHEMA_NAME(@@PROCID),'?'),			-- om eenmalig mee te geven bij loggen: schema-naam om aan te geven dat het om dashboard-, datakwaliteit-procedures gaat of bijv PowerAutomate
				@_AantalRecords DECIMAL(12, 0),														-- om in uitvoerscherm te kunnen zien hoeveel regels er gewist/toegevoegd zijn
				@_Bericht NVARCHAR(255),															-- om tussenstappen te loggen
				@start as DATETIME,																	-- om duur procedure te kunnen loggen
				@finish as DATETIME																	-- om duur procedure te kunnen loggen

		IF @Peildatum IS NULL
			SET @Peildatum = EOMONTH(DATEADD(m, - 1, GETDATE()));

		SET @_Variabelen = '@IndicatorID = ' + COALESCE(CAST(@IndicatorID AS NVARCHAR(4)),'null') + ' ; ' 
											+ '@Peildatum = ' + COALESCE(format(@Peildatum,'dd-MM-yyyy','nl-NL'),'null') + ' ; ' 
											+ '@LoggingWegschrijvenOfNiet = ' + COALESCE(CAST(@LoggingWegschrijvenOfNiet AS NVARCHAR(1)),'null')													

		SET	@start = CURRENT_TIMESTAMP;

-----------------------------------------------------------------------------------
SET @onderwerp = 'BEGIN';
----------------------------------------------------------------------------------- 
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					,@DatabaseObject = @_Bron
					,@Bericht = @onderwerp
					,@WegschrijvenOfNiet = @LoggingWegschrijvenOfNiet

-----------------------------------------------------------------------------------
SET @onderwerp = 'Ophalen details';
----------------------------------------------------------------------------------- 
		-- declare @IndicatorID int = 2641, @peildatum date = '2022-01-31'

		drop table if exists #sel

		select [fk_indicator_id] = @IndicatorID,
			[Datum] = @Peildatum, 
			[Laaddatum] = getdate(), 
			[Ingangsdatum leegstand] = dateadd(d, 1 - lst.[Dagen totaal tm], lst.Einddatum),
			[Waarde] = lst.[Derving netto] / 1000.0,
			[Omschrijving] = concat_ws(';', lst.Eenheidnr, replace(eig.Straatnaam + ' ' + eig.Huisnummer + ' ' + eig.[Huisnummer toevoeging], '  ', ' '), eig.Postcode, eig.Plaats,
				format(dateadd(d, 1 - lst.[Dagen boekingsgroep tm], lst.Einddatum), 'dd-MM-yyyy'), lbg.Leegstandsreden, format(lst.[Derving netto boekingsgroep tm], 'C', 'nl-NL'), 
			Format(lst.[Dagen boekingsgroep tm], '#,##0', 'nl-NL')),
			[Detail_01] = eig.[FT clusternr],
			[Detail_02] = tet.[Technisch type],
			[Detail_03] = dateadd(d, 1 - lst.[Dagen boekingsgroep tm], lst.Einddatum),
			[Detail_04] = lbg.Leegstandsreden,
			[Detail_05] = format(lst.[Derving netto boekingsgroep tm], '€#00000.00', 'nl-NL'),
			[Detail_06] = format(lst.[Dagen boekingsgroep tm], '#0000'), 
			[Detail_07] = lst.[Leegstandsduur boekingsgroep], --lst.[Leegstandsduur],
			[Detail_08] = iif(lst.[Volgende eenheidstatus] = 3, 'Nee', 'Ja'),
			[Detail_09] = eig.Verhuurteam,
			[eenheidnummer] = lst.Eenheidnr,
			[clusternummer] = eig.[FT clusternr]
		into #sel
		from staedion_dm.Leegstand.Leegstanden lst inner join staedion_dm.Leegstand.Leegstandsboekingsgroep lbg
		on lst.Boekingsgroep = lbg.Boekingsgroep
		inner join staedion_dm.Eenheden.Meetwaarden mwd
		on lst.Meetwaarden_id = mwd.id
		inner join staedion_dm.Eenheden.Eigenschappen eig
		on mwd.Eigenschappen_id = eig.Eigenschappen_id
		inner join staedion_dm.Eenheden.Corpodatatype cdt
		on eig.Corpodatatype_id = cdt.Corpodatatype_id
		inner join staedion_dm.Eenheden.[Technisch type] tet
		on eig.[Technisch type_id] = tet.[Technisch type_id]
		--where lst.[peildatum] = '2022-01-31' and
		where eomonth(lst.[peildatum]) = eomonth(@Peildatum) and
		cdt.[Code] in ('WON ZELF', 'WON ONZ') and
		((@IndicatorID = 2641 and lbg.Leegstandsreden in ('Marktleegstand', 'Nieuwbouw', 'Markt met bruikleen', 'Technische leegstand', 'Asbestsanering', 'Verkoop', 'Bewuste leegstand')) or
		 (@IndicatorID = 2642 and lbg.Leegstandsreden in ('Renovatie', 'Sloop', 'Project leegstand', 'Project met bruikleen', 'Calamiteiten leegstand', 'Brandschade')))
		-- and lst.Eenheidnr = 'OGEH-0029081'

		drop table if exists #det

		; with dat (eenheidnummer, [Ingangsdatum leegstand])
		as (select sel.eenheidnummer, sel.[Ingangsdatum leegstand]
			from #sel sel
			group by sel.eenheidnummer, sel.[Ingangsdatum leegstand]),
		ohv (eenheidnummer, [Ingangsdatum leegstand], [Onderhoudsverzoek])
		as (select dat.eenheidnummer, dat.[Ingangsdatum leegstand], max(ohv.[Onderhoudsverzoek]) [Onderhoudsverzoek]
			from staedion_dm.Onderhoud.Onderhoudsverzoek ohv inner join dat 
			on ohv.Bedrijf_id = 1 and
			ohv.Onderhoudssoort_id = 7 and -- mutatieonderhoud
			ohv.Eenheidnr = dat.eenheidnummer and
			ohv.Melddatum between dateadd(m, -2, dat.[Ingangsdatum leegstand]) and dateadd(m, 1, dat.[Ingangsdatum leegstand]) 
			group by dat.eenheidnummer, dat.[Ingangsdatum leegstand]),
		-- taak met Verhuurgereed Type 1% 
		lv1 ([Onderhoudsverzoek], [Leveranciernr], [Volgnr])
		as (select tel.[Onderhoudsverzoek], tel.[Leveranciernr], row_number() over (partition by [Onderhoudsverzoek] order by [Aantal] desc)
			from (select oht.[Onderhoudsverzoek], oht.[Leveranciernr], count(*) [Aantal]
				from staedion_dm.Onderhoud.Onderhoudstaak oht inner join ohv
				on oht.[Onderhoudsverzoek] = ohv.[Onderhoudsverzoek]
				where oht.[Uitgevoerd door] = 'Leverancier' and
				oht.Omschrijving like '%Verhuurgereed Type 1%'
				group by oht.[Onderhoudsverzoek], oht.[Leveranciernr]) tel),
		-- lijst ketenpartners --> tabel
		lv2 ([Onderhoudsverzoek], [Leveranciernr], [Volgnr])
		as (select tel.[Onderhoudsverzoek], tel.[Leveranciernr], row_number() over (partition by [Onderhoudsverzoek] order by [Aantal] desc)
			from (select oht.[Onderhoudsverzoek], oht.[Leveranciernr], count(*) [Aantal]
				from staedion_dm.Onderhoud.Onderhoudstaak oht inner join ohv
				on oht.[Onderhoudsverzoek] = ohv.[Onderhoudsverzoek]
				where oht.[Uitgevoerd door] = 'Leverancier' and
				oht.[Leveranciernr] in (select [Leveranciernr] 
					from [backup_empire_dwh].[dbo].[tmv_npo_leverancier]
					where [Soort leverancier] = 'Ketenpartner A')
				group by oht.[Onderhoudsverzoek], oht.[Leveranciernr]) tel),
		-- hoogste kosten
		lv3 ([Onderhoudsverzoek], [Leveranciernr], [Volgnr])
		as (select tel.[Onderhoudsverzoek], tel.[Leveranciernr], row_number() over (partition by [Onderhoudsverzoek] order by [Bedrag] desc)
			from (select oht.[Onderhoudsverzoek], oht.[Leveranciernr], sum(oht.[Bedrag incl. btw]) [Bedrag]
				from staedion_dm.Onderhoud.Onderhoudstaak oht inner join ohv
				on oht.[Onderhoudsverzoek] = ohv.[Onderhoudsverzoek]
				where oht.[Uitgevoerd door] = 'Leverancier'
				group by oht.[Onderhoudsverzoek], oht.[Leveranciernr]) tel),
		-- meeste taken
		lv4 ([Onderhoudsverzoek], [Leveranciernr], [Volgnr])
		as (select tel.[Onderhoudsverzoek], tel.[Leveranciernr], row_number() over (partition by [Onderhoudsverzoek] order by [Aantal] desc)
			from (select oht.[Onderhoudsverzoek], oht.[Leveranciernr], count(*) [Aantal]
				from staedion_dm.Onderhoud.Onderhoudstaak oht inner join ohv
				on oht.[Onderhoudsverzoek] = ohv.[Onderhoudsverzoek]
				where oht.[Uitgevoerd door] = 'Leverancier'
				group by oht.[Onderhoudsverzoek], oht.[Leveranciernr]) tel)
		select sel.fk_indicator_id,
			sel.Datum,
			getdate() [Laaddatum], 
			sel.[Omschrijving],
			sel.[Waarde],
			sel.[Detail_01],
			sel.[Detail_02],
			sel.[Detail_03],
			sel.[Detail_04],
			sel.[Detail_05],
			sel.[Detail_06], 
			sel.[Detail_07],
			sel.[Detail_08],
			sel.[Detail_09],
			coalesce(lv1.[Leveranciernr], lv2.[Leveranciernr], lv3.[Leveranciernr], lv4.[Leveranciernr], '') [Detail_10],
			sel.[eenheidnummer],
			sel.[clusternummer],
			coalesce(lv1.[Onderhoudsverzoek], lv2.[Onderhoudsverzoek], lv3.[Onderhoudsverzoek], lv4.[Onderhoudsverzoek], '') [Verzoeknummer]
		into #det
		from #sel sel left outer join ohv 
		on sel.eenheidnummer = ohv.eenheidnummer and sel.[Ingangsdatum leegstand] = ohv.[Ingangsdatum leegstand]
		left outer join lv1
		on ohv.[Onderhoudsverzoek] = lv1.[Onderhoudsverzoek] and lv1.Volgnr = 1
		left outer join lv2
		on ohv.[Onderhoudsverzoek] = lv2.[Onderhoudsverzoek] and lv2.Volgnr = 1
		left outer join lv3
		on ohv.[Onderhoudsverzoek] = lv3.[Onderhoudsverzoek] and lv3.Volgnr = 1
		left outer join lv4
		on ohv.[Onderhoudsverzoek] = lv4.[Onderhoudsverzoek] and lv4.Volgnr = 1

		SET @_AantalRecords = @@rowcount;
		SET @_Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @_Bericht = @_Bericht + format(@_AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					,@DatabaseObject = @_Bron
					,@Bericht = @_Bericht
					,@WegschrijvenOfNiet = @LoggingWegschrijvenOfNiet

-----------------------------------------------------------------------------------
SET @onderwerp = 'Wissen regels';
----------------------------------------------------------------------------------- 
		DELETE	
		FROM	staedion_dm.dashboard.realisatiedetails  
		WHERE	fk_indicator_id  = @IndicatorID
		AND		EOMONTH(Datum) = EOMONTH(@Peildatum);

		SET @_AantalRecords = @@rowcount;
		SET @_Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @_Bericht = @_Bericht + format(@_AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					,@DatabaseObject = @_Bron
					,@Bericht = @_Bericht
					,@WegschrijvenOfNiet = @LoggingWegschrijvenOfNiet

-----------------------------------------------------------------------------------
SET @onderwerp = 'Toevoegen detailregels';
----------------------------------------------------------------------------------- 
		insert into staedion_dm.dashboard.realisatiedetails (fk_indicator_id,
			Datum,
			[Laaddatum], 
			[Omschrijving],
			[Waarde],
			[Detail_01],
			[Detail_02],
			[Detail_03],
			[Detail_04],
			[Detail_05],
			[Detail_06], 
			[Detail_07],
			[Detail_08],
			[Detail_09],
			[Detail_10],
			[eenheidnummer],
			[clusternummer],
			[Verzoeknummer])
		select det.fk_indicator_id,
			det.Datum,
			det.[Laaddatum], 
			det.[Omschrijving] + iif(det.Detail_10 <> '', ';' + concat_ws(';', det.[Detail_10], lev.[Leveranciersnaam]), ';;'),
			det.[Waarde],
			det.[Detail_01],
			det.[Detail_02],
			det.[Detail_03],
			det.[Detail_04],
			det.[Detail_05],
			det.[Detail_06], 
			det.[Detail_07],
			det.[Detail_08],
			det.[Detail_09],
			isnull(lev.[Leveranciersnaam], ''),
			det.[eenheidnummer],
			det.[clusternummer],
			isnull(det.[Verzoeknummer], '')
		from #det det left outer join [backup_empire_dwh].[dbo].[tmv_npo_leverancier] lev
		on det.[Detail_10] = lev.[Leveranciersnr] and det.Detail_10 <> ''

		SET @_AantalRecords = @@rowcount;
		SET @_Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
		SET @_Bericht = @_Bericht + format(@_AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					,@DatabaseObject = @_Bron
					,@Bericht = @_Bericht
					,@WegschrijvenOfNiet = @LoggingWegschrijvenOfNiet


	SET		@finish = CURRENT_TIMESTAMP
	
	--SELECT 1/0
-----------------------------------------------------------------------------------
SET @onderwerp = 'EINDE';
----------------------------------------------------------------------------------- 
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					,@DatabaseObject = @_Bron
					,@Variabelen = @_Variabelen
					,@Bericht = @onderwerp
					,@WegschrijvenOfNiet = @LoggingWegschrijvenOfNiet

					
END TRY

BEGIN CATCH

	SET		@finish = CURRENT_TIMESTAMP

	DECLARE @_ErrorProcedure AS NVARCHAR(255) = ERROR_PROCEDURE()
	DECLARE @_ErrorLine AS INT = ERROR_LINE()
	DECLARE @_ErrorNumber AS INT = ERROR_NUMBER()
	DECLARE @_ErrorMessage AS NVARCHAR(255) = LEFT(ERROR_PROCEDURE(),255)

	EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = @_Categorie
					, @DatabaseObject = @_Bron
					, @Variabelen = @_Variabelen
					--, @Bericht = 'Nvt' 		
					, @Begintijd = @start
					, @Eindtijd = @finish
					, @ErrorProcedure =  @_ErrorProcedure
					, @ErrorLine = @_ErrorLine
					, @ErrorNumber = @_ErrorNumber
					, @ErrorMessage = @_ErrorMessage

END CATCH
GO
