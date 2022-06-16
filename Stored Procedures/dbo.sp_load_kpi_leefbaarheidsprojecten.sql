SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE[dbo].[sp_load_kpi_leefbaarheidsprojecten](
  @peildatum date = '20220118'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_leefbaarheidsprojecten] '20220118'

select * from empire_staedion_Data.etl.LogboekMeldingenProcedures where Databaseobject like '%leefbaarheidsprojecten%' order by Begintijd desc

################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
	declare @start as datetime;
	declare @finish as datetime;
	declare @fk_indicator_id smallint;

	set	@start = current_timestamp;

	
	select [Clusternummer]
		  ,[AantalWoningen]
		  ,[TeamscoreCijfer] = format(FLOOR([TeamscoreCijfer]), 'G') + '+' 
		  ,[BIKkleurClusterKCMopCluster]
		  ,[BIKkleurBuurt]
	into #TempTable1
	from [staedion_dm].[Leefbaarheid].[BIKOpCluster]
	where Jaar = year(@peildatum) - 1;

	select   [Clusternummer] = CLS.[Clusternr_]
			,[Bewonersconsulent] = CON.[Name]
	into #TempTable2
	from empire_data.dbo.Staedion$Cluster_contactpersoon as CLS
	inner join empire_data.dbo.Contact as CON
		on CLS.Contactnr_ = CON.No_
	where Functie = 'CB-BWCON';

	select	 Projectnummer = JLE.[Job No_]
			,Cluster = JLE.Cluster
			,Budgetregelnummer = JLE.[Budgetline No_]
			,Datum = eomonth(max(JLE.[Document Date]))
			,Omschrijving = max(iif(JLE.Cluster <> 'KVS000001', JLE.[Description], 'Diverse uitgaven zonder FT-cluster'))
			,Bedrag = sum(JLE.[Total Cost])
	into #TempTable3
	from empire_data.dbo.Staedion$Empire_Job_Ledger_Entry as JLE
	left outer join empire_data.dbo.Staedion$Empire_Werksoort as WSC
		on [Work Type Code] = [Code]
	where [Job Type] in ('LFB', 'LFO', 'LTB')
			and WSC.Omschrijving = 'LFO stimuleren ontmoeting/betrokkenheid bewoners'
			and JLE.[Document Date] between DATEFROMPARTS(YEAR(@peildatum), 1, 1) and EOMONTH(@peildatum)
	group by	 JLE.[Job No_]
				,JLE.Cluster
				,JLE.[Budgetline No_];

	select	 [Teller] = iif(BSM.[Status] in (20,25), 1, 0)
			,[Noemer] = 1
			,[Omschrijving] =  'Status: '
								+ case BSM.[Status]
									when 10 then 'Doorloop'
									when 15 then 'Vervallen'
									when 20 then 'Technisch Gereed'
									when 25 then 'Afgehandeld'
									when 30 then 'Uitstel'
									else 'Onbekend/NVT'
								end
								+ '; '
								+ 'Besteding: '
								+ FORMAT(CAST(coalesce(REA.Bedrag, 0) as float) / CAST(BGR.[Bedrag incl_ BTW] as float), 'P0')
								+ '; '
								+ 'Budget: '
								+ format(CAST(coalesce(BGR.[Bedrag incl_ BTW], 0) as float), 'C0', 'nl-nl')
								+ '; '
								+ 'Budget per woning: '
								+ format(CAST(coalesce(BGR.[Bedrag incl_ BTW], 0) as float) / CAST(coalesce(BIK.[AantalWoningen], 0) as float), 'C0', 'nl-nl')
								+ '; '
								+ 'Project: '
								+ PRJ.Nr_ 
								+ '; '
								+ 'Cluster: '
								+ BGR.Cluster
								+ iif(PBR.Omschrijving is not null,'; Omschrijving: ' + PBR.Omschrijving, '')
								+ iif(COM.Opmerking is not null, '; Budgetopmerking: ' + COM.Opmerking, '')
			,[Detail_01] = coalesce(BCO.Bewonersconsulent, 'Onbekend/NVT')
			,[Detail_02] = coalesce(LOC.Deelgebied, 'Onbekend/NVT') 
			,[Detail_03] = coalesce(LOC.Gemeente, 'Onbekend/NVT')
			,[Detail_04] = coalesce(LOC.Buurt, 'Onbekend/NVT')
			,[Detail_05] = coalesce(LOC.Clusternummer, 'Onbekend/NVT')
			,[Detail_06] = coalesce(LOC.Clusternaam, 'Onbekend/NVT')
			,[Detail_07] = coalesce(BIK.TeamscoreCijfer, 'Onbekend/NVT')
			,[Detail_08] = coalesce(BIK.BIKkleurClusterKCMopCluster, 'Onbekend/NVT')
			,[Detail_09] = coalesce(BIK.BIKkleurBuurt, 'Onbekend/NVT')
			,[clusternummer] = BGR.Cluster
			,[projectnummer] = PRJ.Nr_
	into #TempTable	
	FROM [empire_data].[dbo].[Staedion$Empire_Project] as PRJ
	inner join empire_data.dbo.Staedion$Empire_projectbegrootpost as BGR
		on PRJ.Nr_ = BGR.Projectnr_
	inner join empire_data.dbo.Staedion$Empire_Werksoort as WSC
		on BGR.[Werksoortcode] = WSC.[Code]
	left outer join empire_data.dbo.staedion$Projectopmerking as COM
		on PRJ.Nr_ = COM.Code and BGR.Budgetregelnr_ = COM.Regelnr_
	left outer join [empire_data].[dbo].[Staedion$Budgetstatusmutatie] as BSM
			on BGR.Projectnr_ = BSM.Projectnr_ and BGR.Budgetregelnr_ = BSM.Budgetregelnr_
	left outer join [empire_data].[dbo].[Staedion$Empire_Projectbudgetregel] as PBR
			on PRJ.Nr_ = PBR.Projectnr_ and BGR.Budgetregelnr_ = PBR.Regelnr_ 
	left outer join #TempTable3 as REA
		on PRJ.Nr_ = REA.Projectnummer and BGR.Cluster = REA.Cluster and BGR.Budgetregelnr_ = REA.Budgetregelnummer
	left outer join [staedion_dm].[Dashboard].[vw_Clusterlocatie] as LOC
		on BGR.Cluster = LOC.Clusternummer
	left outer join #TempTable2 as BCO
		on BGR.Cluster = BCO.Clusternummer
	--left outer join cteVOO as VOO
	--	on BGR.Cluster = VOO.Clusternummer
	left outer join #TempTable1 as BIK
		on BGR.Cluster = BIK.Clusternummer
	where PRJ.[Type] in ('LFO', 'LTB', 'LFB')
			and PRJ.Jaar = year(@peildatum)
			and WSC.Omschrijving = 'LFO stimuleren ontmoeting/betrokkenheid bewoners';

	drop table #TempTable1;
	drop table #TempTable2;
	drop table #TempTable3;

-----------------------------------------------------------------------------------------------------------
	-- 2900 Dekkingsgraad jaarlijks georganiseerde ontmoetingsactiviteiten in de buurt

		set @fk_indicator_id = 2900;

			delete from [Dashboard].[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into [Dashboard].[RealisatieDetails]( [fk_indicator_id]
														,[Datum]
														,[Laaddatum]
														--,[Waarde]
														,[Teller]
														,[Noemer]
														,[Omschrijving]
														,[Detail_01]
														,[Detail_02]
														,[Detail_03]
														,[Detail_04]
														,[Detail_05]
														,[Detail_06]
														,[Detail_07]
														,[Detail_08]
														,[Detail_09]
														--,[Detail_10]
														--,[eenheidnummer]
														--,[bouwbloknummer]
														,[clusternummer]
														--,[klantnummer]
														--,[volgnummer]
														--,[relatienummer]
														--,[dossiernummer]
														--,[betalingsregelingnummer]
														--,[rekeningnummer]
														--,[documentnummer]
														--,[leveranciernummer]
														--,[werknemernummer]
														,[projectnummer]
														--,[verzoeknummer]
														--,[ordernummer]
														--,[taaknummer]
														--,[overig]
														)
			SELECT	 [fk_indicator_id] = @fk_indicator_id
					,[Datum] = eomonth(@peildatum)
					,[Laaddatum] = getdate()
					--,[Waarde]
					,[Teller]
					,[Noemer]
					,[Omschrijving]
					,[Detail_01]
					,[Detail_02]
					,[Detail_03]
					,[Detail_04]
					,[Detail_05]
					,[Detail_06]
					,[Detail_07]
					,[Detail_08]
					,[Detail_09]
					--,[Detail_10]
					--,[eenheidnummer]
					--,[bouwbloknummer]
					,[clusternummer]
					--,[klantnummer]
					--,[volgnummer]
					--,[relatienummer]
					--,[dossiernummer]
					--,[betalingsregelingnummer]
					--,[rekeningnummer]
					--,[documentnummer]
					--,[leveranciernummer]
					--,[werknemernummer]
					,[projectnummer]
					--,[verzoeknummer]
					--,[ordernummer]
					--,[taaknummer]
					--,[overig]
			FROM #TempTable;

			drop table #TempTable;


		set	@finish = current_timestamp;
	
	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd)
	SELECT	OBJECT_NAME(@@PROCID)
					,@start
					,@finish;
				
END TRY

BEGIN CATCH

	set	@finish = current_timestamp;

	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding,ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage)
	SELECT	ERROR_PROCEDURE() 
					,getdate()
					,ERROR_PROCEDURE() 
					,ERROR_NUMBER()
					,ERROR_LINE()
				  ,ERROR_MESSAGE();
END CATCH

GO
