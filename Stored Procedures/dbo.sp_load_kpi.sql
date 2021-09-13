SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[sp_load_kpi]
as
/* ###############################################################################################################################
20210913 JvdW Welke statements worden uitgevoerd ?
exec [sp_load_kpi_huurderving] '2021-07-31'
exec [sp_load_kpi_huurderving] '2021-08-31'
exec [sp_load_kpi_huurderving] '2021-09-13'
exec [sp_load_kpi_cashflow] '2021-07-31'
exec [sp_load_kpi_cashflow] '2021-08-31'
exec [sp_load_kpi_cashflow] '2021-09-13'
exec [sp_load_kpi_debiteuren] '2021-07-31', @fk_indicator_id = 2629
exec [sp_load_kpi_debiteuren] '2021-08-31', @fk_indicator_id = 2629
exec [sp_load_kpi_debiteuren] '2021-09-13', @fk_indicator_id = 2629
exec [sp_load_kpi_debiteuren] '2021-07-31', @fk_indicator_id = 2626
exec [sp_load_kpi_debiteuren] '2021-08-31', @fk_indicator_id = 2626
exec [sp_load_kpi_debiteuren] '2021-09-13', @fk_indicator_id = 2626
exec [sp_load_kpi_debiteuren] '2021-07-31', @fk_indicator_id = 2620
exec [sp_load_kpi_debiteuren] '2021-08-31', @fk_indicator_id = 2620
exec [sp_load_kpi_debiteuren] '2021-09-13', @fk_indicator_id = 2620
exec [sp_load_kpi_crediteuren] '2021-07-31', @fk_indicator_id = 2619
exec [sp_load_kpi_crediteuren] '2021-08-31', @fk_indicator_id = 2619
exec [sp_load_kpi_crediteuren] '2021-09-13', @fk_indicator_id = 2619
exec [sp_load_kpi_crediteuren] '2021-07-31', @fk_indicator_id = 2616
exec [sp_load_kpi_crediteuren] '2021-08-31', @fk_indicator_id = 2616
exec [sp_load_kpi_crediteuren] '2021-09-13', @fk_indicator_id = 2616
exec [sp_load_kpi_crediteuren] '2021-07-31', @fk_indicator_id = 2610
exec [sp_load_kpi_crediteuren] '2021-08-31', @fk_indicator_id = 2610
exec [sp_load_kpi_crediteuren] '2021-09-13', @fk_indicator_id = 2610
exec [sp_load_kpi_fte] '2021-07-31'
exec [sp_load_kpi_fte] '2021-08-31'
exec [sp_load_kpi_bedrijfslasten] '2021-07-31'
exec [sp_load_kpi_bedrijfslasten] '2021-08-31'
exec [sp_load_kpi_bedrijfslasten] '2021-09-13'
exec [sp_load_kpi_automatische_incasso] '2021-07-31'
exec [sp_load_kpi_automatische_incasso] '2021-08-31'
exec [sp_load_kpi_huurachterstand] '2021-07-31'
exec [sp_load_kpi_huurachterstand] '2021-08-31'
exec [sp_load_kpi_huurachterstand_ontruimingen] '2021-07-31'
exec [sp_load_kpi_huurachterstand_ontruimingen] '2021-08-31'
exec [sp_load_kpi_huurachterstand_ontruimingen] '2021-09-13'
exec [sp_load_kpi_huurachterstand_betalingsregelingen] '2021-07-31'
exec [sp_load_kpi_huurachterstand_betalingsregelingen] '2021-08-31'
exec [sp_load_kpi_verhuringen_huurtoeslag] '2021-07-31', @eenzijdig_wijk=nee
exec [sp_load_kpi_verhuringen_huurtoeslag] '2021-08-31', @eenzijdig_wijk=nee
exec [sp_load_kpi_verhuringen_huurtoeslag] '2021-09-13', @eenzijdig_wijk=nee
exec [sp_load_kpi_verhuringen_huurtoeslag] '2021-07-31', @eenzijdig_wijk=ja
exec [sp_load_kpi_verhuringen_huurtoeslag] '2021-08-31', @eenzijdig_wijk=ja
exec [sp_load_kpi_verhuringen_huurtoeslag] '2021-09-13', @eenzijdig_wijk=ja
exec [sp_load_kpi_kcm_overige_processen] '2021-07-31'
exec [sp_load_kpi_kcm_overige_processen] '2021-08-31'
exec [sp_load_kpi_aantal_klachten_handmatig] '2021-07-31'
exec [sp_load_kpi_aantal_klachten_handmatig] '2021-08-31'
exec [sp_load_kpi_aantal_klachten_handmatig] '2021-09-13'
exec [sp_load_kpi_kcm_klacht] '2021-07-31'
exec [sp_load_kpi_kcm_klacht] '2021-08-31'
exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '2021-07-31', '%derden%EKG%', 'Extern'
exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '2021-08-31', '%derden%EKG%', 'Extern'
exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2021-07-31', '%derden%tevredenh%', 'Extern'
exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2021-08-31', '%derden%tevredenh%', 'Extern'
exec [sp_load_kpi_npo_doorlooptijd] '2021-07-31'
exec [sp_load_kpi_npo_doorlooptijd] '2021-08-31'
exec [sp_load_kpi_npo_doorlooptijd] '2021-09-13'
exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '2021-07-31', '%eigen%dienst%EKG%', 'Eigen dienst'
exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '2021-08-31', '%eigen%dienst%EKG%', 'Eigen dienst'
exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2021-07-31', '%eigen%dienst%tevredenh%', 'Eigen dienst'
exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2021-08-31', '%eigen%dienst%tevredenh%', 'Eigen dienst'
exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2021-07-31', '%tevred%reparatieverzoek%', ''
exec [sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2021-08-31', '%tevred%reparatieverzoek%', ''
exec [sp_load_kpi_kcm_nieuwe_huurder_handmatig] '2021-07-31'
exec [sp_load_kpi_kcm_nieuwe_huurder_handmatig] '2021-08-31'
exec [sp_load_kpi_kcm_vertrokken_huurder] '2021-07-31'
exec [sp_load_kpi_kcm_vertrokken_huurder] '2021-08-31'
exec [sp_load_kpi_kcm_thuisgevoel_in_woonomgeving_handmatig] '2021-07-31'
exec [sp_load_kpi_kcm_thuisgevoel_in_woonomgeving_handmatig] '2021-08-31'
exec [sp_load_kpi_kcm_thuisgevoel_handmatig] '2021-07-31'
exec [sp_load_kpi_kcm_thuisgevoel_handmatig] '2021-08-31'
exec [sp_load_kpi_zelfst_DAEB_eenheden] '2021-07-31'
exec [sp_load_kpi_zelfst_DAEB_eenheden] '2021-08-31'
exec [sp_load_kpi_energie] '2021-07-31', '%CO2%', 'CO2 uitstoot'
exec [sp_load_kpi_energie] '2021-08-31', '%CO2%', 'CO2 uitstoot'
exec [sp_load_kpi_energie] '2021-07-31', '%energievraag%', 'EP2 fossielenergiegebruik'
exec [sp_load_kpi_energie] '2021-08-31', '%energievraag%', 'EP2 fossielenergiegebruik'
exec [sp_load_kpi_energie] '2021-07-31', '%warmtevraag%', 'EP1 energiebehoefte'
exec [sp_load_kpi_energie] '2021-08-31', '%warmtevraag%', 'EP1 energiebehoefte'
exec [sp_load_kpi_energie_vernieuwde_labels] '2021-07-31'
exec [sp_load_kpi_energie_vernieuwde_labels] '2021-08-31'
exec [sp_load_kpi_energie_vernieuwde_labels] '2021-09-13'
exec [sp_load_kpi_energie_vernieuwde_labels_energetische_verbetering] '2021-07-31'
exec [sp_load_kpi_energie_vernieuwde_labels_energetische_verbetering] '2021-08-31'
exec [sp_load_kpi_energie_vernieuwde_labels_energetische_verbetering] '2021-09-13'
exec [sp_load_kpi_energie_vernieuwde_labels_geldigheid_verlopen] '2021-07-31'
exec [sp_load_kpi_energie_vernieuwde_labels_geldigheid_verlopen] '2021-08-31'
exec [sp_load_kpi_energie_vernieuwde_labels_geldigheid_verlopen] '2021-09-13'
exec [sp_load_kpi_projecten_renovaties_opgeleverd_tijdelijk] '2021-07-31'
exec [sp_load_kpi_projecten_renovaties_opgeleverd_tijdelijk] '2021-08-31'
exec [sp_load_kpi_projecten_renovaties_gestart_tijdelijk] '2021-07-31'
exec [sp_load_kpi_projecten_renovaties_gestart_tijdelijk] '2021-08-31'
exec [sp_load_kpi_onderhoudsuren_portieken] '2021-07-31'
exec [sp_load_kpi_onderhoudsuren_portieken] '2021-08-31'
exec [sp_load_kpi_onderhoudsuren_portieken] '2021-09-13'
exec [sp_load_kpi_bkt_renovaties] '2021-07-31'
exec [sp_load_kpi_bkt_renovaties] '2021-08-31'
exec [sp_load_kpi_bkt_renovaties] '2021-09-13'
exec [sp_load_kpi_kcm_woonkwaliteit_hoger_dan_handmatig] '2021-07-31'
exec [sp_load_kpi_kcm_woonkwaliteit_hoger_dan_handmatig] '2021-08-31'
exec [sp_load_kpi_kcm_woonkwaliteit_lager_dan_handmatig] '2021-07-31'
exec [sp_load_kpi_kcm_woonkwaliteit_lager_dan_handmatig] '2021-08-31'
exec [sp_load_kpi_kcm_woonkwaliteit_handmatig] '2021-07-31'
exec [sp_load_kpi_kcm_woonkwaliteit_handmatig] '2021-08-31'
exec [sp_load_kpi_projecten_nieuwbouw_tijdelijk] '2021-07-31'
exec [sp_load_kpi_projecten_nieuwbouw_tijdelijk] '2021-08-31'
exec [sp_load_kpi_aantal_leegstaande_woningen] '2021-07-31'
exec [sp_load_kpi_aantal_leegstaande_woningen] '2021-08-31'
exec [sp_load_kpi_aantal_leegstaande_woningen] '2021-09-13'
exec [sp_load_kpi_huuropzeggingen] '2021-07-31'
exec [sp_load_kpi_huuropzeggingen] '2021-08-31'
exec [sp_load_kpi_huuropzeggingen] '2021-09-13'
exec [sp_load_kpi_beeindigde_fraude] '2021-07-31'
exec [sp_load_kpi_beeindigde_fraude] '2021-08-31'
exec [sp_load_kpi_beeindigde_fraude] '2021-09-30'
exec [sp_load_kpi_verhuringen_regulier] '2021-07-31'
exec [sp_load_kpi_verhuringen_regulier] '2021-08-31'
exec [sp_load_kpi_verhuringen_regulier] '2021-09-30'
exec [sp_load_kpi_verhuringen_tijdelijk] '2021-07-31'
exec [sp_load_kpi_verhuringen_tijdelijk] '2021-08-31'
exec [sp_load_kpi_verhuringen_tijdelijk] '2021-09-30'
exec [sp_load_kpi_verhuringen_woningruil] '2021-07-31'
exec [sp_load_kpi_verhuringen_woningruil] '2021-08-31'
exec [sp_load_kpi_verhuringen_woningruil] '2021-09-30'
exec [sp_load_kpi_verhuringen_doorstroom] '2021-07-31'
exec [sp_load_kpi_verhuringen_doorstroom] '2021-08-31'
exec [sp_load_kpi_verhuringen_doorstroom] '2021-09-30'
exec [sp_load_kpi_verhuringen_fraude] '2021-07-31'
exec [sp_load_kpi_verhuringen_fraude] '2021-08-31'
exec [sp_load_kpi_verhuringen_fraude] '2021-09-30'
exec [sp_load_kpi_verhuringen] '2021-07-31'
exec [sp_load_kpi_verhuringen] '2021-08-31'
exec [sp_load_kpi_verhuringen] '2021-09-30'

############################################################################################################################### */
begin
	declare @indicatorid int, @frequentie int, @berekeningswijze int, @procedure nvarchar(128), @argument varchar(200), @sql nvarchar(1000), @peildatum date

	set nocount on
		
	-- ophalen peildata, nu ingesteld op lopende maand en 2 voorgaande maanden
	drop table if exists #dat 

	; with dat (peildatum)
	as (select iif(mnd.i = 0, convert(date, dateadd(m, -mnd.i, getdate())), eomonth(convert(date, dateadd(m, -mnd.i, getdate()))))
		from (values (0), (1), (2)) mnd(i))
	select dat.peildatum, iif(dat.peildatum = eomonth(dat.peildatum), 1, 0) volledig
	into #dat
	from dat

	-- cursor voor indicatoren 
	declare kpi cursor for
		select ind.id, fk_frequentie_id frequentie, ind.fk_berekeningswijze_id, ind.procedure_naam [procedure], ind.procedure_argument
		from [Dashboard].[Indicator] ind
		where isnull(ind.procedure_naam, '') <> '' and
		ind.procedure_actief = 1
		-- TEST
		-- AND ind.id = 1300


		order by ind.id desc

	open kpi

	fetch next from kpi into @indicatorid, @frequentie, @berekeningswijze, @procedure, @argument
	
	while @@fetch_status = 0
	begin
		
		-- cursor voor peildata
		declare peildatum cursor for
			select dat.peildatum
			from #dat dat
			where dat.volledig = 1 or @frequentie < 3
			order by dat.peildatum

		open peildatum

		fetch next from peildatum into @peildatum

		while @@fetch_status = 0
		begin
			-- als @berekeningwijze = 2, dan peildatum altijd wijzigen in laatste van de maand, anders peildatum ongewijzigd doorgeven aan procedure
			set @sql = 'exec [' + @procedure + '] ''' + convert(varchar(10), iif(@berekeningswijze = 2, eomonth(@peildatum), @peildatum), 120) + '''' + isnull(@argument, '')
		
			--print @sql 
			exec (@sql)

			fetch next from peildatum into @peildatum
		end

		close peildatum

		deallocate peildatum

		fetch next from kpi into @indicatorid, @frequentie, @berekeningswijze, @procedure, @argument

	end

	close kpi

	deallocate kpi
end
GO
