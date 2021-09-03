SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_load_kpi_TE_VERWIJDEREN]
as
begin

  declare @peildatum date

  declare cursor_snapshots cursor local fast_forward for
  select 
    datum 
  from empire_dwh.dbo.tijd
  cross join empire_logic.dbo.vw_dates
  where datum between dateadd(mm,-1, last_of_prev_month) and dateadd(mm, 1, last_of_prev_month)
  and day(dateadd(dd,1,datum)) = 1
  and year(datum) = year(getdate())

  open cursor_snapshots

  fetch next from cursor_snapshots into @peildatum

  while @@fetch_status = 0
  begin
    
    select @peildatum

    exec sp_load_kpi_verhuringen @peildatum													--100
		exec sp_load_kpi_verhuringen_fraude @peildatum										--101
		exec sp_load_kpi_verhuringen_doorstroom @peildatum									--102
		exec sp_load_kpi_verhuringen_woningruil @peildatum									--103
		exec sp_load_kpi_verhuringen_tijdelijk @peildatum									--104
		exec sp_load_kpi_verhuringen_regulier @peildatum									--105

		--20200211 JvdW: Toegevoegd
	exec sp_load_kpi_projecten_nieuwbouw_tijdelijk  @peildatum								--200		

	--20200210 JvdW: Gekoppeld aan A-BI-PROD, is niet bijgwerkt
	--exec sp_load_kpi_kcm_woonkwaliteit @peildatum											--300	proces kpi 301 & 302 hierin verwerken of een aparte sp?
	--20200210 JvdW: Toegevoegd
	exec [sp_load_kpi_kcm_woonkwaliteit_handmatig] @peildatum 
	exec [sp_load_kpi_kcm_woonkwaliteit_lager_dan_handmatig] @peildatum 
	exec [sp_load_kpi_kcm_woonkwaliteit_lager_dan_handmatig] @peildatum 

	--20200211 JvdW: Toegevoegd
	exec sp_load_kpi_projecten_renovaties_tijdelijk  @peildatum								--400

	--exec sp_load_kpi_gemiddelde_energieindex @peildatum									--500	afwijkende berekening dan CNS, procedure aanpassen
	-- 2020210 JvdW: Toegevoegd
	exec [sp_load_kpi_gemiddelde_energieindex_alternatief] @peildatum 
		--exec sp_load_kpi_hr++glas_zelfregulerende_roosters @peildatum						--501	nog te ontwikkelen
		--exec sp_load_kpi_opgeleverde_renovaties @peildatum								--502	nog te ontwikkelen
		--exec sp_load_kpi_vr_ketels_vervangen_door_hr_ketels @peildatum					--503	nog te ontwikkelen
		--exec sp_load_kpi_pv_panelen @peildatum											--504	nog te ontwikkelen
		--exec sp_load_kpi_vernieuwde energielabels_verlopen @peildatum						--505	nog te ontwikkelen
		--exec sp_load_kpi_vernieuwde energielabels_verbetering @peildatum					--506	nog te ontwikkelen

	exec sp_load_kpi_zelfst_DAEB_eenheden @peildatum										--600
	
	--20200210 JvdW: Gekoppeld aan A-BI-PROD, is niet bijgwerkt
	--exec sp_load_kpi_kcm_thuisgevoel @peildatum											--700
	--20200210 JvdW: Toegevoegd
	exec sp_load_kpi_kcm_thuisgevoel_handmatig @peildatum	

	exec sp_load_kpi_kcm_vertrokken_huurder @peildatum										--800
	
	exec sp_load_kpi_kcm_nieuwe_huurder_handmatig @peildatum								--900

	--20200211 JvdW: Toegevoegd	
	exec sp_load_kpi_kcm_dagelijks_onderhoud_handmatig @peildatum							--1000 + 1001 + 1002 + 1004 + 1005 (tevredenh + ekg totaal + eigendienst /derden)
		--exec sp_load_kpi_kcm_dagelijks_onderhoud_delta_tijd @peildatum, @dienst=eigen		--1003	nog te ontwikkelen
		--exec sp_load_kpi_kcm_dagelijks_onderhoud_delta_tijd @peildatum, @dienst=derden	--1006	nog te ontwikkelen
	
	exec sp_load_kpi_kcm_klacht @peildatum													--1100

	--exec sp_load_kpi_kcm_overige_processen @peildatum										--1200	nog te ontwikkelen
		--exec sp_load_kpi_kcm_overige_processen_bkt_renovaties @peildatum					--1201	nog te ontwikkelen
		--exec sp_load_kpi_kcm_overige_processen_planmatig_onderhoud @peildatum				--1202	nog te ontwikkelen
		--exec sp_load_kpi_kcm_overige_processen_projecten_renovaties @peildatum			--1203	nog te ontwikkelen
	
	--exec sp_load_kpi_verhuringen_huurtoeslag @peildatum, @eenzijdig_wijk=ja				--1300	nog te ontwikkelen
	
	--exec sp_load_kpi_verhuringen_huurtoeslag @peildatum, @eenzijdig_wijk=nee				--1400	nog te ontwikkelen

	exec sp_load_kpi_huurachterstand @peildatum												--1500
		--exec sp_load_kpi_auto_incasso @peildatum											--1501	nog te ontwikkelen
		exec sp_load_kpi_huurachterstand_betalingsregelingen @peildatum						--1502	nog te valideren
		--exec sp_load_kpi_ontruimingen @peildatum											--1503	nog te ontwikkelen

	--exec sp_load_kpi_gptw_geloofwaardigheid @peildatum									--1600	nog te ontwikkelen
		--exec sp_load_kpi_gptw_geloofwaardigheid @peildatum, @directie=financien			--1601	nog te ontwikkelen
		--exec sp_load_kpi_gptw_geloofwaardigheid @peildatum, @directie=onderhoud_vastgoed	--1602	nog te ontwikkelen
		--exec sp_load_kpi_gptw_geloofwaardigheid @peildatum, @directie=woonservice			--1603	nog te ontwikkelen

	--exec sp_load_kpi_bedrijfslasten @peildatum											--1700	nog te ontwikkelen

	--exec sp_load_kpi_vaste_fte @peildatum													--1800	nog te ontwikkelen

    fetch next from cursor_snapshots into @peildatum

  end
    
  close cursor_snapshots
  deallocate cursor_snapshots


	-- EVENTUEEL TOT SLOT: [Dashboard].[Realisatie] vullen [Dashboard].[RealisatieDetails]




end



GO
