SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[sp_load_kpi]
as
/* ###############################################################################################################################
20211110 JvdW Welke statements worden uitgevoerd ?
20220202 JvdW in procedurenaam kun je nu ook ander schemanaam opgeven - [] moet je dan zelf in procedure_naam opnemen - in dit script weggehaald

exec dbo.[sp_load_kpi_leefbaarheidsprojecten] '2021-12-31'
exec dbo.[sp_load_kpi_leefbaarheidsprojecten] '2022-01-31'
exec dbo.[sp_load_kpi_leefbaarheidsprojecten] '2022-02-28'
exec dbo.[sp_load_kpi_huurderving_mutatieleegstand_woningen] '2021-12-31'
exec dbo.[sp_load_kpi_huurderving_mutatieleegstand_woningen] '2022-01-31'
exec dbo.[sp_load_kpi_huurderving_mutatieleegstand_woningen] '2022-02-02'
exec dbo.[sp_load_kpi_huurderving] '2021-12-31'
exec dbo.[sp_load_kpi_huurderving] '2022-01-31'
exec dbo.[sp_load_kpi_huurderving] '2022-02-02'
exec dbo.[sp_load_kpi_cashflow] '2021-12-31'
exec dbo.[sp_load_kpi_cashflow] '2022-01-31'
exec dbo.[sp_load_kpi_cashflow] '2022-02-02'
exec dbo.[sp_load_kpi_debiteuren] '2021-12-31', @fk_indicator_id = 2629
exec dbo.[sp_load_kpi_debiteuren] '2022-01-31', @fk_indicator_id = 2629
exec dbo.[sp_load_kpi_debiteuren] '2022-02-02', @fk_indicator_id = 2629
exec dbo.[sp_load_kpi_debiteuren] '2021-12-31', @fk_indicator_id = 2626
exec dbo.[sp_load_kpi_debiteuren] '2022-01-31', @fk_indicator_id = 2626
exec dbo.[sp_load_kpi_debiteuren] '2022-02-02', @fk_indicator_id = 2626
exec dbo.[sp_load_kpi_debiteuren] '2021-12-31', @fk_indicator_id = 2620
exec dbo.[sp_load_kpi_debiteuren] '2022-01-31', @fk_indicator_id = 2620
exec dbo.[sp_load_kpi_debiteuren] '2022-02-02', @fk_indicator_id = 2620
exec dbo.[sp_load_kpi_crediteuren] '2021-12-31', @fk_indicator_id = 2619
exec dbo.[sp_load_kpi_crediteuren] '2022-01-31', @fk_indicator_id = 2619
exec dbo.[sp_load_kpi_crediteuren] '2022-02-02', @fk_indicator_id = 2619
exec dbo.[sp_load_kpi_crediteuren] '2021-12-31', @fk_indicator_id = 2616
exec dbo.[sp_load_kpi_crediteuren] '2022-01-31', @fk_indicator_id = 2616
exec dbo.[sp_load_kpi_crediteuren] '2022-02-02', @fk_indicator_id = 2616
exec dbo.[sp_load_kpi_crediteuren] '2021-12-31', @fk_indicator_id = 2610
exec dbo.[sp_load_kpi_crediteuren] '2022-01-31', @fk_indicator_id = 2610
exec dbo.[sp_load_kpi_crediteuren] '2022-02-02', @fk_indicator_id = 2610
exec dbo.[sp_load_kpi_verzuimpercentage] '2021-12-31'
exec dbo.[sp_load_kpi_verzuimpercentage] '2022-01-31'
exec dbo.[sp_load_kpi_verzuimpercentage] '2022-02-02'
exec dbo.[sp_load_kpi_verzuimfrequentie] '2021-12-31'
exec dbo.[sp_load_kpi_verzuimfrequentie] '2022-01-31'
exec dbo.[sp_load_kpi_verzuimfrequentie] '2022-02-02'
exec dbo.[sp_load_kpi_personeelsverloop] '2021-12-31'
exec dbo.[sp_load_kpi_personeelsverloop] '2022-01-31'
exec dbo.[sp_load_kpi_personeelsverloop] '2022-02-02'
exec dbo.[sp_load_kpi_personeelsinhuur] '2021-12-31'
exec dbo.[sp_load_kpi_personeelsinhuur] '2022-01-31'
exec dbo.[sp_load_kpi_personeelsinhuur] '2022-02-02'
exec dbo.[sp_load_kpi_personeelsbezetting] '2021-12-31'
exec dbo.[sp_load_kpi_personeelsbezetting] '2022-01-31'
exec dbo.[sp_load_kpi_personeelsbezetting] '2022-02-02'
exec dbo.[sp_load_kpi_fte] '2021-12-31'
exec dbo.[sp_load_kpi_fte] '2022-01-31'
exec dbo.[sp_load_kpi_bedrijfslasten] '2021-12-31'
exec dbo.[sp_load_kpi_bedrijfslasten] '2022-01-31'
exec dbo.[sp_load_kpi_bedrijfslasten] '2022-02-02'
exec dbo.[sp_load_kpi_automatische_incasso] '2021-12-31'
exec dbo.[sp_load_kpi_automatische_incasso] '2022-01-31'
exec dbo.[sp_load_kpi_huurachterstand] '2021-12-31'
exec dbo.[sp_load_kpi_huurachterstand] '2022-01-31'
exec dbo.[sp_load_kpi_huurachterstand_ontruimingen] '2021-12-31'
exec dbo.[sp_load_kpi_huurachterstand_ontruimingen] '2022-01-31'
exec dbo.[sp_load_kpi_huurachterstand_ontruimingen] '2022-02-02'
exec dbo.[sp_load_kpi_huurachterstand_betalingsregelingen] '2021-12-31'
exec dbo.[sp_load_kpi_huurachterstand_betalingsregelingen] '2022-01-31'
exec dbo.[sp_load_kpi_verhuringen_huurtoeslag] '2021-12-31', @eenzijdig_wijk=nee
exec dbo.[sp_load_kpi_verhuringen_huurtoeslag] '2022-01-31', @eenzijdig_wijk=nee
exec dbo.[sp_load_kpi_verhuringen_huurtoeslag] '2022-02-02', @eenzijdig_wijk=nee
exec dbo.[sp_load_kpi_verhuringen_huurtoeslag] '2021-12-31', @eenzijdig_wijk=ja
exec dbo.[sp_load_kpi_verhuringen_huurtoeslag] '2022-01-31', @eenzijdig_wijk=ja
exec dbo.[sp_load_kpi_verhuringen_huurtoeslag] '2022-02-02', @eenzijdig_wijk=ja
exec dbo.[sp_load_kpi_kcm_overige_processen] '2021-12-31'
exec dbo.[sp_load_kpi_kcm_overige_processen] '2022-01-31'
exec dbo.[sp_load_kpi_aantal_klachten_handmatig] '2021-12-31'
exec dbo.[sp_load_kpi_aantal_klachten_handmatig] '2022-01-31'
exec dbo.[sp_load_kpi_aantal_klachten_handmatig] '2022-02-02'
exec dbo.[sp_load_kpi_kcm_klacht] '2021-12-31'
exec dbo.[sp_load_kpi_kcm_klacht] '2022-01-31'
exec dbo.[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '2021-12-31', '%derden%EKG%', 'Extern'
exec dbo.[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '2022-01-31', '%derden%EKG%', 'Extern'
exec dbo.[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2021-12-31', '%derden%tevredenh%', 'Extern'
exec dbo.[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2022-01-31', '%derden%tevredenh%', 'Extern'
exec dbo.[sp_load_kpi_npo_doorlooptijd] '2021-12-31'
exec dbo.[sp_load_kpi_npo_doorlooptijd] '2022-01-31'
exec dbo.[sp_load_kpi_npo_doorlooptijd] '2022-02-02'
exec dbo.[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '2021-12-31', '%eigen%dienst%EKG%', 'Eigen dienst'
exec dbo.[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig_ekg] '2022-01-31', '%eigen%dienst%EKG%', 'Eigen dienst'
exec dbo.[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2021-12-31', '%eigen%dienst%tevredenh%', 'Eigen dienst'
exec dbo.[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2022-01-31', '%eigen%dienst%tevredenh%', 'Eigen dienst'
exec dbo.[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2021-12-31', '%tevred%reparatieverzoek%', ''
exec dbo.[sp_load_kpi_kcm_dagelijks_onderhoud_handmatig] '2022-01-31', '%tevred%reparatieverzoek%', ''
exec dbo.[sp_load_kpi_kcm_nieuwe_huurder_handmatig] '2021-12-31'
exec dbo.[sp_load_kpi_kcm_nieuwe_huurder_handmatig] '2022-01-31'
exec dbo.[sp_load_kpi_kcm_vertrokken_huurder] '2021-12-31'
exec dbo.[sp_load_kpi_kcm_vertrokken_huurder] '2022-01-31'
exec dbo.[sp_load_kpi_kcm_thuisgevoel_in_woonomgeving_handmatig] '2021-12-31'
exec dbo.[sp_load_kpi_kcm_thuisgevoel_in_woonomgeving_handmatig] '2022-01-31'
exec dbo.[sp_load_kpi_kcm_thuisgevoel_handmatig] '2021-12-31'
exec dbo.[sp_load_kpi_kcm_thuisgevoel_handmatig] '2022-01-31'
exec dbo.[sp_load_kpi_zelfst_DAEB_eenheden] '2021-12-31'
exec dbo.[sp_load_kpi_zelfst_DAEB_eenheden] '2022-01-31'
exec [Dashboard].[sp_load_kpis_energie] '2021-12-31', N'[{"IndicatorID": 510, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 520, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 530, "UitvoerenJaNee": "Ja"}]'
exec [Dashboard].[sp_load_kpis_energie] '2022-01-31', N'[{"IndicatorID": 510, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 520, "UitvoerenJaNee": "Ja"}, {"IndicatorID": 530, "UitvoerenJaNee": "Ja"}]'
exec dbo.[sp_load_kpi_projecten_microsoft_list] '2021-12-31','Renovatie', 'Start'
exec dbo.[sp_load_kpi_projecten_microsoft_list] '2022-01-31','Renovatie', 'Start'
exec dbo.[sp_load_kpi_rookmelder_percentage_aanwezig] '2021-12-31'
exec dbo.[sp_load_kpi_rookmelder_percentage_aanwezig] '2022-01-31'
exec dbo.[sp_load_kpi_rookmelder_percentage_aanwezig] '2022-02-02'
exec dbo.[sp_load_kpi_rookmelder_aantal_geplaatst] '2021-12-31'
exec dbo.[sp_load_kpi_rookmelder_aantal_geplaatst] '2022-01-31'
exec dbo.[sp_load_kpi_rookmelder_aantal_geplaatst] '2022-02-02'
exec dbo.[sp_load_kpi_onderhoudsuren_portieken] '2021-12-31'
exec dbo.[sp_load_kpi_onderhoudsuren_portieken] '2022-01-31'
exec dbo.[sp_load_kpi_onderhoudsuren_portieken] '2022-02-02'
exec dbo.[sp_load_kpi_bkt_renovaties] '2021-12-31'
exec dbo.[sp_load_kpi_bkt_renovaties] '2022-01-31'
exec dbo.[sp_load_kpi_bkt_renovaties] '2022-02-02'
exec dbo.[sp_load_kpi_kcm_woonkwaliteit_hoger_dan_handmatig] '2021-12-31'
exec dbo.[sp_load_kpi_kcm_woonkwaliteit_hoger_dan_handmatig] '2022-01-31'
exec dbo.[sp_load_kpi_kcm_woonkwaliteit_lager_dan_handmatig] '2021-12-31'
exec dbo.[sp_load_kpi_kcm_woonkwaliteit_lager_dan_handmatig] '2022-01-31'
exec dbo.[sp_load_kpi_kcm_woonkwaliteit_handmatig] '2021-12-31'
exec dbo.[sp_load_kpi_kcm_woonkwaliteit_handmatig] '2022-01-31'
exec dbo.[sp_load_kpi_projecten_microsoft_list] '2021-12-31', 'Nieuwbouw', 'Start'
exec dbo.[sp_load_kpi_projecten_microsoft_list] '2022-01-31', 'Nieuwbouw', 'Start'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2021-12-31'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2022-01-31'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2022-02-02'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2021-12-31'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2022-01-31'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2022-02-02'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2021-12-31'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2022-01-31'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2022-02-02'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2021-12-31'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2022-01-31'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2022-02-02'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2021-12-31'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2022-01-31'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2022-02-02'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2021-12-31'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2022-01-31'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2022-02-02'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2021-12-31'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2022-01-31'
exec dbo.[sp_load_kpi_verhuringen_doelgroep] '2022-02-02'
exec dbo.[sp_load_kpi_aantal_leegstaande_woningen] '2021-12-31'
exec dbo.[sp_load_kpi_aantal_leegstaande_woningen] '2022-01-31'
exec dbo.[sp_load_kpi_aantal_leegstaande_woningen] '2022-02-02'
exec dbo.[sp_load_kpi_huuropzeggingen] '2021-12-31'
exec dbo.[sp_load_kpi_huuropzeggingen] '2022-01-31'
exec dbo.[sp_load_kpi_huuropzeggingen] '2022-02-02'
exec dbo.[sp_load_kpi_woonfraudebestrijding] '2021-12-31'
exec dbo.[sp_load_kpi_woonfraudebestrijding] '2022-01-31'
exec dbo.[sp_load_kpi_woonfraudebestrijding] '2022-02-28'
exec dbo.[sp_load_kpi_beeindigde_fraude] '2021-12-31'
exec dbo.[sp_load_kpi_beeindigde_fraude] '2022-01-31'
exec dbo.[sp_load_kpi_beeindigde_fraude] '2022-02-28'
exec dbo.[sp_load_kpi_verhuringen_regulier] '2021-12-31'
exec dbo.[sp_load_kpi_verhuringen_regulier] '2022-01-31'
exec dbo.[sp_load_kpi_verhuringen_regulier] '2022-02-28'
exec dbo.[sp_load_kpi_verhuringen_tijdelijk] '2021-12-31'
exec dbo.[sp_load_kpi_verhuringen_tijdelijk] '2022-01-31'
exec dbo.[sp_load_kpi_verhuringen_tijdelijk] '2022-02-28'
exec dbo.[sp_load_kpi_verhuringen_woningruil] '2021-12-31'
exec dbo.[sp_load_kpi_verhuringen_woningruil] '2022-01-31'
exec dbo.[sp_load_kpi_verhuringen_woningruil] '2022-02-28'
exec dbo.[sp_load_kpi_verhuringen_doorstroom] '2021-12-31'
exec dbo.[sp_load_kpi_verhuringen_doorstroom] '2022-01-31'
exec dbo.[sp_load_kpi_verhuringen_doorstroom] '2022-02-28'
exec dbo.[sp_load_kpi_verhuringen_fraude] '2021-12-31'
exec dbo.[sp_load_kpi_verhuringen_fraude] '2022-01-31'
exec dbo.[sp_load_kpi_verhuringen_fraude] '2022-02-28'
exec dbo.[sp_load_kpi_verhuringen] '2021-12-31'
exec dbo.[sp_load_kpi_verhuringen] '2022-01-31'
exec dbo.[sp_load_kpi_verhuringen] '2022-02-28'



############################################################################################################################### */
begin
	declare @indicatorid int, @frequentie int, @berekeningswijze int, @procedure nvarchar(1000), @argument varchar(1000), @sql nvarchar(4000), @peildatum date

	set nocount on
		
	-- ophalen peildata, nu ingesteld op lopende maand en 2 voorgaande maanden
	drop table if exists #dat 
  drop table if exists #dat_sp_load_kpi

	; with dat (peildatum)
	as (select iif(mnd.i = 0, convert(date, dateadd(m, -mnd.i, getdate())), eomonth(convert(date, dateadd(m, -mnd.i, getdate()))))
		from (values (0), (1), (2)) mnd(i))
	select dat.peildatum, iif(dat.peildatum = eomonth(dat.peildatum), 1, 0) volledig
	into #dat_sp_load_kpi
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
			from #dat_sp_load_kpi dat
			where dat.volledig = 1 or @frequentie < 3
			order by dat.peildatum

		open peildatum

		fetch next from peildatum into @peildatum

		while @@fetch_status = 0
		begin
			-- als @berekeningwijze = 2, dan peildatum altijd wijzigen in laatste van de maand, anders peildatum ongewijzigd doorgeven aan procedure
			--set @sql = 'exec [' + @procedure + '] ''' + convert(varchar(10), iif(@berekeningswijze = 2, eomonth(@peildatum), @peildatum), 120) + '''' + isnull(@argument, '')
			set @sql = 'exec ' + @procedure + ' @peildatum = ''' + convert(varchar(10), iif(@berekeningswijze = 2, eomonth(@peildatum), @peildatum), 120) + '''' + isnull(@argument, '')
		
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
