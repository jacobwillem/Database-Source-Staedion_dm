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
----------------------------------------------------------------------------------------------------
TEST
----------------------------------------------------------------------------------------------------
output van load kpi
	exec [sp_load_kpi_fte] '2021-02-28'
	exec [sp_load_kpi_fte] '2021-03-31'
	exec [sp_load_kpi_bedrijfslasten] '2021-02-28'
	exec [sp_load_kpi_bedrijfslasten] '2021-03-31'
	exec [sp_load_kpi_bedrijfslasten] '2021-04-29'
	exec [sp_load_kpi_automatische_incasso] '2021-02-28'
	exec [sp_load_kpi_automatische_incasso] '2021-03-31'
	exec [sp_load_kpi_huurachterstand] '2021-02-28'
	exec [sp_load_kpi_huurachterstand] '2021-03-31'[dbo].[sp_load_kpi_zelfst_DAEB_eenheden]
	exec [sp_load_kpi_huurachterstand_ontruimingen] '2021-02-28'
	exec [sp_load_kpi_huurachterstand_ontruimingen] '2021-03-31'
	exec [sp_load_kpi_huurachterstand_ontruimingen] '2021-04-29'
	exec [sp_load_kpi_huurachterstand_betalingsregelingen] '2021-02-28'
	exec [sp_load_kpi_huurachterstand_betalingsregelingen] '2021-03-31'
	exec [sp_load_kpi_verhuringen_huurtoeslag] '2021-02-28', @eenzijdig_wijk=nee
	exec [sp_load_kpi_verhuringen_huurtoeslag] '2021-03-31', @eenzijdig_wijk=nee
	exec [sp_load_kpi_verhuringen_huurtoeslag] '2021-04-29', @eenzijdig_wijk=nee
	exec [sp_load_kpi_verhuringen_huurtoeslag] '2021-02-28', @eenzijdig_wijk=ja
	exec [sp_load_kpi_verhuringen_huurtoeslag] '2021-03-31', @eenzijdig_wijk=ja
	exec [sp_load_kpi_verhuringen_huurtoeslag] '2021-04-29', @eenzijdig_wijk=ja
	exec [sp_load_kpi_kcm_overige_processen] '2021-02-28'
	exec [sp_load_kpi_kcm_overige_processen] '2021-03-31'
	exec [sp_load_kpi_kcm_klacht] '2021-02-28'
	exec [sp_load_kpi_kcm_klacht] '2021-03-31'
	exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '2021-02-28', '%derden%EKG%', 'Extern'
	exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '2021-03-31', '%derden%EKG%', 'Extern'
	exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2021-02-28', '%derden%tevredenh%', 'Extern'
	exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2021-03-31', '%derden%tevredenh%', 'Extern'
	exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '2021-02-28', '%eigen%dienst%EKG%', 'Eigen dienst'
	exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '2021-03-31', '%eigen%dienst%EKG%', 'Eigen dienst'
	exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2021-02-28', '%eigen%dienst%tevredenh%', 'Eigen dienst'
	exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2021-03-31', '%eigen%dienst%tevredenh%', 'Eigen dienst'
	exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2021-02-28', '%tevred%reparatieverzoek%', ''
	exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2021-03-31', '%tevred%reparatieverzoek%', ''
	exec [sp_load_kpi_kcm_nieuwe_huurder_handmatig] '2021-02-28'
	exec [sp_load_kpi_kcm_nieuwe_huurder_handmatig] '2021-03-31'
	exec [sp_load_kpi_kcm_vertrokken_huurder] '2021-02-28'
	exec [sp_load_kpi_kcm_vertrokken_huurder] '2021-03-31'
	exec [sp_load_kpi_kcm_thuisgevoel_in_woonomgeving_handmatig] '2021-02-28'
	exec [sp_load_kpi_kcm_thuisgevoel_in_woonomgeving_handmatig] '2021-03-31'
	exec [sp_load_kpi_kcm_thuisgevoel_handmatig] '2021-02-28'
	exec [sp_load_kpi_kcm_thuisgevoel_handmatig] '2021-03-31'
	exec [sp_load_kpi_zelfst_DAEB_eenheden] '2021-02-28'
	exec [sp_load_kpi_zelfst_DAEB_eenheden] '2021-03-31'
	exec [sp_load_kpi_energie_vernieuwde_labels] '2021-02-28'
	exec [sp_load_kpi_energie_vernieuwde_labels] '2021-03-31'
	exec [sp_load_kpi_energie_vernieuwde_labels] '2021-04-29'
	exec [sp_load_kpi_energie_vernieuwde_labels_energetische_verbetering] '2021-02-28'
	exec [sp_load_kpi_energie_vernieuwde_labels_energetische_verbetering] '2021-03-31'
	exec [sp_load_kpi_energie_vernieuwde_labels_energetische_verbetering] '2021-04-29'
	exec [sp_load_kpi_energie_vernieuwde_labels_geldigheid_verlopen] '2021-02-28'
	exec [sp_load_kpi_energie_vernieuwde_labels_geldigheid_verlopen] '2021-03-31'
	exec [sp_load_kpi_energie_vernieuwde_labels_geldigheid_verlopen] '2021-04-29'
	exec [sp_load_kpi_projecten_renovaties_opgeleverd_tijdelijk] '2021-02-28'
	exec [sp_load_kpi_projecten_renovaties_opgeleverd_tijdelijk] '2021-03-31'
	exec [sp_load_kpi_projecten_renovaties_gestart_tijdelijk] '2021-02-28'
	exec [sp_load_kpi_projecten_renovaties_gestart_tijdelijk] '2021-03-31'
	exec [sp_load_kpi_onderhoudsuren_portieken] '2021-02-28'
	exec [sp_load_kpi_onderhoudsuren_portieken] '2021-03-31'
	exec [sp_load_kpi_onderhoudsuren_portieken] '2021-04-29'
	exec [sp_load_kpi_bkt_renovaties] '2021-02-28'
	exec [sp_load_kpi_bkt_renovaties] '2021-03-31'
	exec [sp_load_kpi_bkt_renovaties] '2021-04-29'
	exec [sp_load_kpi_kcm_woonkwaliteit_hoger_dan_handmatig] '2021-02-28'
	exec [sp_load_kpi_kcm_woonkwaliteit_hoger_dan_handmatig] '2021-03-31'
	exec [sp_load_kpi_kcm_woonkwaliteit_lager_dan_handmatig] '2021-02-28'
	exec [sp_load_kpi_kcm_woonkwaliteit_lager_dan_handmatig] '2021-03-31'
	exec [sp_load_kpi_kcm_woonkwaliteit_handmatig] '2021-02-28'
	exec [sp_load_kpi_kcm_woonkwaliteit_handmatig] '2021-03-31'
	exec [sp_load_kpi_projecten_nieuwbouw_tijdelijk] '2021-02-28'
	exec [sp_load_kpi_projecten_nieuwbouw_tijdelijk] '2021-03-31'
	exec [sp_load_kpi_beeindigde_fraude] '2021-02-28'
	exec [sp_load_kpi_beeindigde_fraude] '2021-03-31'
	exec [sp_load_kpi_beeindigde_fraude] '2021-04-30'
	exec [sp_load_kpi_verhuringen_regulier] '2021-02-28'
	exec [sp_load_kpi_verhuringen_regulier] '2021-03-31'
	exec [sp_load_kpi_verhuringen_regulier] '2021-04-30'
	exec [sp_load_kpi_verhuringen_tijdelijk] '2021-02-28'
	exec [sp_load_kpi_verhuringen_tijdelijk] '2021-03-31'
	exec [sp_load_kpi_verhuringen_tijdelijk] '2021-04-30'
	exec [sp_load_kpi_verhuringen_woningruil] '2021-02-28'
	exec [sp_load_kpi_verhuringen_woningruil] '2021-03-31'
	exec [sp_load_kpi_verhuringen_woningruil] '2021-04-30'
	exec [sp_load_kpi_verhuringen_doorstroom] '2021-02-28'
	exec [sp_load_kpi_verhuringen_doorstroom] '2021-03-31'
	exec [sp_load_kpi_verhuringen_doorstroom] '2021-04-30'
	exec [sp_load_kpi_verhuringen_fraude] '2021-02-28'
	exec [sp_load_kpi_verhuringen_fraude] '2021-03-31'
	exec [sp_load_kpi_verhuringen_fraude] '2021-04-30'
	exec [sp_load_kpi_verhuringen] '2021-02-28'
	exec [sp_load_kpi_verhuringen] '2021-03-31'
	exec [sp_load_kpi_verhuringen] '2021-04-30'

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
		Insert into empire_staedion_Data.etl.LogboekMeldingenProcedures (DatabaseObject, Begintijd, Eindtijd, TijdMelding)
		values ('staedion_dm.dbo.dbo.sp_load_algemeen_eenheid',@Starttijd, @Eindtijd, getdate());
		Set @Starttijd = getdate();

	exec dbo.sp_load_eenheden_kernvoorraad			-- Updaten: Eenheden.Kernvoorraad - Tbv oa PBI Vastgoed O&V 

		Set @Eindtijd = getdate();	
		Insert into empire_staedion_Data.etl.LogboekMeldingenProcedures (DatabaseObject, Begintijd, Eindtijd, TijdMelding)
		values ('staedion_dm.dbo.dbo.sp_load_eenheden_kernvoorraad',@Starttijd, @Eindtijd, getdate());
		Set @Starttijd = getdate();

    exec dbo.sp_load_algemeen_mutatiehuur				-- Tbv oa PBI Vastgoed O&V 

		Set @Eindtijd = getdate();	
		Insert into empire_staedion_Data.etl.LogboekMeldingenProcedures (DatabaseObject, Begintijd, Eindtijd, TijdMelding)
		values ('staedion_dm.dbo.dbo.sp_load_algemeen_mutatiehuur',@Starttijd, @Eindtijd, getdate());

	exec dbo.sp_load_kpi					-- jaarplan dashboard					

		print OBJECT_NAME(@@PROCID)

		Set @Eindtijd = getdate();	
		Insert into empire_staedion_Data.etl.LogboekMeldingenProcedures (DatabaseObject, Begintijd, Eindtijd, TijdMelding)
		values ('staedion_dm.dbo.dbo.sp_load_kpi',@Starttijd, @Eindtijd, getdate());
		Set @Starttijd = getdate();

	-- JvdW 31-08-2021 toegevoegd, update staedion_dm.Dashboard.RealisatiePrognose + staedion_dm.[Dashboard].[DimensieJoin]
	-- JvdW 11-11-2021 uitgecommentarieerd, opzet is gewijzigd, niet mee van belang 
	--exec staedion_dm.[dbo].[dsp_load_dashboard_diverse] -- Tbv oa PBI Staedion dashboard (views werden te langzaam)

	--	Set @Eindtijd = getdate();	
	--	Insert into empire_staedion_Data.etl.LogboekMeldingenProcedures (DatabaseObject, Begintijd, Eindtijd, TijdMelding)
	--	values ('staedion_dm.dbo.dbo.dsp_load_dashboard_diverse',@Starttijd, @Eindtijd, getdate());

    	-- rst 05-11-2021 toegevoegd
		Set @Starttijd = getdate();
	  exec staedion_dm.[dbo].[sp_update_business_keys_in_realisatiedetails] 
		Set @Eindtijd = getdate();	
		Insert into empire_staedion_Data.etl.LogboekMeldingenProcedures (DatabaseObject, Begintijd, Eindtijd, TijdMelding)
		values ('staedion_dm.dbo.dbo.sp_update_business_keys_in_realisatiedetails',@Starttijd, @Eindtijd, getdate());

	
end
GO
