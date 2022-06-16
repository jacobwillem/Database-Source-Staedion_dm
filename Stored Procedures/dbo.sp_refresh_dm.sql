SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_refresh_dm]
as
/* ##################################################################################################
----------------------------------------------------------------------------------------------------
JvdW 
Met deze procedure wordt de data verzameld die achter het jaarplan-dashboard hangt, als ook een aantal procedures afgevuurd die sommige zware queries materialiseren voor de Power BI-rapportages van met name O&V Vastgoed
----------------------------------------------------------------------------------------------------
20210429 Commentaar toegevoegd + logging 
20210831 Procedure toegevoegd
20220525 JvdW - logging op hoofdlijnen verplaatst van etl.LogboekMeldingenProcedures naar staedion_dm.DatabaseBeheer.
----------------------------------------------------------------------------------------------------
TEST
----------------------------------------------------------------------------------------------------


################################################################################################## */
begin
/*  Als je wilt weten welke queries sp_load_kpi uitvoert: in betreffende procedure print(@sql)
  		Voert onderstaande onderdelen uit:
			select ind.id, fk_frequentie_id frequentie, ind.fk_berekeningswijze_id, ind.procedure_naam [procedure], ind.procedure_argument
			from [Dashboard].[Indicator] ind
			where isnull(ind.procedure_naam, '') <> '' and
			ind.procedure_actief = 1 */

		Declare @Starttijd datetime;
		Set @Starttijd = getdate();
		Declare @Eindtijd datetime;
	
	exec dbo.sp_load_algemeen_eenheid					-- Updaten: staedion_dm.algemeen.eenheid - Tbv oa PBI Vastgoed O&V 

		print OBJECT_NAME(@@PROCID)

		Set @Eindtijd = getdate();	
		Insert into staedion_dm.DatabaseBeheer.LoggingUitvoeringDatabaseObjecten  (Categorie, DatabaseObject, Begintijd, Eindtijd, TijdMelding)
		values ('sp_refresh_dm', 'staedion_dm.dbo.sp_load_algemeen_eenheid',@Starttijd, @Eindtijd, getdate());
		Set @Starttijd = getdate();

	exec dbo.sp_load_eenheden_kernvoorraad			-- Updaten: Eenheden.Kernvoorraad - Tbv oa PBI Vastgoed O&V 

		Set @Eindtijd = getdate();	
		Insert into staedion_dm.DatabaseBeheer.LoggingUitvoeringDatabaseObjecten  (Categorie, DatabaseObject, Begintijd, Eindtijd, TijdMelding)
		values ('sp_refresh_dm','staedion_dm.dbo.sp_load_eenheden_kernvoorraad',@Starttijd, @Eindtijd, getdate());
		Set @Starttijd = getdate();

    exec dbo.sp_load_algemeen_mutatiehuur				-- Tbv oa PBI Vastgoed O&V 

		Set @Eindtijd = getdate();	
		Insert into staedion_dm.DatabaseBeheer.LoggingUitvoeringDatabaseObjecten  (Categorie, DatabaseObject, Begintijd, Eindtijd, TijdMelding)
		values ('sp_refresh_dm','staedion_dm.dbo.sp_load_algemeen_mutatiehuur',@Starttijd, @Eindtijd, getdate());
		Set @Starttijd = getdate();

	exec dbo.sp_load_kpi					-- jaarplan dashboard					

		print OBJECT_NAME(@@PROCID)

		Set @Eindtijd = getdate();	
		Insert into staedion_dm.DatabaseBeheer.LoggingUitvoeringDatabaseObjecten (Categorie, DatabaseObject, Begintijd, Eindtijd, TijdMelding)
		values ('sp_refresh_dm','staedion_dm.dbo.sp_load_kpi',@Starttijd, @Eindtijd, getdate());
		Set @Starttijd = getdate();

	   	-- rst 05-11-2021 toegevoegd
		-- Vullen van detailvelden op basis van het omschrijvingsveld, indien detailveld 01 niet gevuld is.
		Set @Starttijd = getdate();
		exec staedion_dm.[Dashboard].[sp_update_business_keys_in_realisatiedetails] 
		Set @Eindtijd = getdate();	
		Insert into staedion_dm.DatabaseBeheer.LoggingUitvoeringDatabaseObjecten (Categorie, DatabaseObject, Begintijd, Eindtijd, TijdMelding)
		values ('sp_refresh_dm','staedion_dm.Dashboard.sp_update_business_keys_in_realisatiedetails',@Starttijd, @Eindtijd, getdate());

		-- mv 29-04-2021 toegevoegd
		-- Kopieren van prognoses naar de nieuwe maand.
		Set @Starttijd = getdate();
		exec staedion_dm.[Dashboard].[sp_update_prognose]
		Set @Eindtijd = getdate();	
		Insert into staedion_dm.DatabaseBeheer.LoggingUitvoeringDatabaseObjecten  (Categorie, DatabaseObject, Begintijd, Eindtijd, TijdMelding)
		values ('sp_refresh_dm','staedion_dm.Dashboard.sp_update_prognose',@Starttijd, @Eindtijd, getdate());

		-- mv 15-06-2022 toegevoegd
		-- Medewerkers verwijderen van handmatige autorisatietabel bij uitdiensttreding.
		Set @Starttijd = getdate();
		exec staedion_dm.[Dashboard].[sp_update_autorisatie]
		Set @Eindtijd = getdate();	
		Insert into staedion_dm.DatabaseBeheer.LoggingUitvoeringDatabaseObjecten  (Categorie, DatabaseObject, Begintijd, Eindtijd, TijdMelding)
		values ('sp_refresh_dm','staedion_dm.Dashboard.sp_update_autorisatie',@Starttijd, @Eindtijd, getdate());

	
end
GO
