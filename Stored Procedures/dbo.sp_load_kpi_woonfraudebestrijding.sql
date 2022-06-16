SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


















CREATE PROCEDURE[dbo].[sp_load_kpi_woonfraudebestrijding](
  @peildatum date = '20211231'
)
as
/* #################################################################################################################

exec staedion_dm.[dbo].[sp_load_kpi_woonfraudebestrijding] '20211130'

select * from empire_staedion_Data.etl.LogboekMeldingenProcedures where Databaseobject like '%woonfraudebestrijding%' order by Begintijd desc

################################################################################################################# */
BEGIN TRY

  -- Diverse variabelen
	declare @start as datetime;
	declare @finish as datetime;
	declare @fk_indicator_id smallint;

	set	@start = current_timestamp;


	with cteA as(	select	 [Dossiernummer] = lda.DossierNo_
							,[Datum Aangifte doen] = cast(lda.[Date] as date)
					from empire_data.dbo.Staedion$Livability_DossierAction_Line as lda
					where lda.Actie in ('AANGIFTE')
				 )

		,cteG as(	select   [Dossiernummer] = lda.DossierNo_
							,[Datum Brief in gebrekestelling] = cast(lda.[Date] as date)
					from empire_data.dbo.Staedion$Livability_DossierAction_Line as lda
					where lda.Actie in ('GEBREKE')
				 )

		,cteJ as(	select   [Dossiernummer] = lda.DossierNo_
							,[Datum Juridische procedure starten] = cast(lda.[Date] as date)
					from empire_data.dbo.Staedion$Livability_DossierAction_Line as lda
					where lda.Actie in ('JURPROC')
				 )

		,cteL as(	select	 [Eenheidnr_]
							,[Customer No_]
							,[Laatste contractvolgnummer] = min(Volgnr_)
					from [empire_data].[dbo].[Staedion$Contract]
					where Ingangsdatum <= getdate() and (Ingangsdatum <= Einddatum or Einddatum = '17530101') and [Customer No_] <> ''
					group by [Eenheidnr_], [Customer No_]
				 )

		,cteC as(	select	 cteL.[Eenheidnr_]
							,cteL.[Customer No_]
							,con.Einddatum
					from cteL
					left outer join [empire_data].[dbo].[Staedion$Contract] as con
						on cteL.[Eenheidnr_] = con.[Eenheidnr_]
							and cteL.[Customer No_] = con.[Customer No_]
							and cteL.[Laatste contractvolgnummer] = con.Volgnr_
				 )
	,CTE_OGE AS (
		select	 Eenheidnummer = [Staedion$OGE].Nr_
				,Eenheidtype = [Staedion$Type].Omschrijving
				,Straatnaam = [Staedion$OGE].Straatnaam
				,Huisnummer = [Staedion$OGE].Huisnr_
				,Toevoegsel = [Staedion$OGE].Toevoegsel
				,Plaats = [Staedion$OGE].Plaats
		from empire_data.dbo.[Staedion$OGE]
		left outer join empire_data.dbo.[Staedion$Type] on Staedion$OGE.[Type] = [Staedion$Type].Code
				)
	,CTE_FT AS (
		select	 Eenheidnummer = [Staedion$OGE].Nr_
				,Clusternummer = Clusternr_
		from empire_data.dbo.[Staedion$OGE]
		left outer join empire_data.dbo.[Staedion$Cluster_OGE] on Staedion$OGE.Nr_ = Staedion$Cluster_OGE.Eenheidnr_
		where Clustersoort = 'FTCLUSTER'
				)
	,CTE_BB AS (
		select	 Eenheidnummer = [Staedion$OGE].Nr_
				,Bouwbloknummer = Clusternr_
		from empire_data.dbo.[Staedion$OGE]
		left outer join empire_data.dbo.[Staedion$Cluster_OGE] on Staedion$OGE.Nr_ = Staedion$Cluster_OGE.Eenheidnr_
		where Clustersoort = 'BOUWBLOK'
				)

	select   [Dossiernummer] = ldo.[No_]
			,[Dossiertype] = ldt.[Description]
			,[Dossieromschrijving] = ldo.[Description]
			,[Dossiersoort] = coalesce(ldc.[Description], 'Onbekend/NVT')
			,[Dossierstatus] = ldo.Dossierstatus
			,[Dossier startdatum] = cast(ldo.Datum as date) 
			,[Datum Aangifte doen] = cteA.[Datum Aangifte doen]
			,[Datum Brief in gebrekestelling] = cteG.[Datum Brief in gebrekestelling]
			,[Datum Juridische procedure starten] = cteJ.[Datum Juridische procedure starten]
			,[Afhandelingsreden] = lcr.[Description]
			,[Afhandelingsdatum] = iif(ldo.[Afgehandeld per] <> '17530101', cast(ldo.[Afgehandeld per] as date), null)
			,[Doorlooptijd] = datediff(d, ldo.Datum, iif(ldo.[Afgehandeld per] <> '17530101', cast(ldo.[Afgehandeld per] as date), cast(getdate() as date))) 
			,[Eenheidnummer] = ldo.Eenheidnr_
			,[Clusternummer] = FT.Clusternummer
			,[Bouwbloknummer] = BB.Bouwbloknummer
			,[Eenheidtype] = OGE.Eenheidtype
			,[Straatnaam] = OGE.Straatnaam
			,[Huisnummer] = OGE.Huisnummer
			,[Toevoegsel] = OGE.Toevoegsel
			,[Plaats] = OGE.Plaats
			,[Buurt] = LOC.Buurt
			,[Deelgebied]
			,[Woonfraudebestrijder]
			,[Contractvolgnummer] = con.Volgnr_
			,[Contract ingangsdatum] = cast(con.Ingangsdatum as date)
			,[Contract einddatum] = iif(cteC.Einddatum <> '17530101', cast(cteC.Einddatum as date), null) 
			,[Klantnummer] = con.[Customer No_]
			,[Werknemernummer] = ldo.[Assigned Person Code] 
			into #TempTable
			from empire_data.dbo.Staedion$Livability_Dossier as ldo
	LEFT OUTER JOIN empire_data.dbo.Staedion$Liv__Dossier_Closing_Reason lcr
		ON ldo.Afhandelingsreden = lcr.Code
	LEFT OUTER JOIN empire_data.dbo.Staedion$Liv__Dossier_Type ldt
		ON ldo.Dossiertype = ldt.Code
	LEFT OUTER JOIN empire_data.dbo.Staedion$Liv__Dossier_Specification spc
		ON ldo.No_ = spc.[Dossier No_] and spc.[Show on Form] = 1
	LEFT OUTER JOIN empire_data.dbo.Staedion$Liv__Dossier_Complaint_Type ldc
		ON spc.Code = ldc.Code
	LEFT OUTER JOIN cteA
		ON ldo.No_ = cteA.Dossiernummer
	LEFT OUTER JOIN cteG
		ON ldo.No_ = cteG.Dossiernummer
	LEFT OUTER JOIN cteJ
		ON ldo.No_ = cteJ.Dossiernummer
	LEFT OUTER JOIN [empire_data].[dbo].[Staedion$Contract] as con
		ON ldo.Eenheidnr_ = con.Eenheidnr_ and con.Ingangsdatum <= ldo.[Datum] and (con.Einddatum = '17530101' or con.Einddatum >= ldo.Datum)
	LEFT OUTER JOIN cteC
		ON con.Eenheidnr_ = cteC.Eenheidnr_ and con.[Customer No_] = cteC.[Customer No_]
	LEFT OUTER JOIN CTE_OGE as OGE
		ON ldo.Eenheidnr_ = OGE.Eenheidnummer
	LEFT OUTER JOIN CTE_FT as FT
		ON ldo.Eenheidnr_ = FT.Eenheidnummer
	LEFT OUTER JOIN CTE_BB as BB
		ON ldo.Eenheidnr_ = BB.Eenheidnummer
	LEFT OUTER JOIN staedion_dm.Dashboard.vw_Clusterlocatie as LOC
		ON FT.Clusternummer = LOC.Clusternummer

	where ldo.Eenheidnr_ <> '' -- leefbaarheidsdossiers aangemaakt zonder verwijzing naar een eenheid worden niet meegenomen
			and con.[Customer No_] <> '' -- leefbaarheidsdossiers aangemaakt op een datum waarop er geen klant een contract heeft op die eenheid worden niet meegenomen
			and FT.Clusternummer <> 'FT-1998' -- leefbaarheidsdossiers op eenheden die in het uit beheer cluster zitten worden niet meegenomen
			and (ldt.[Description] = 'Onrechtmatig gebruik' or ldc.[Description] in ('Woonfraude', 'Hennep'));

-----------------------------------------------------------------------------------------------------------
	-- 111 Aantal opgeloste woonfraudedossiers

		set @fk_indicator_id = 111;

			delete from [Dashboard].[RealisatieDetails] where fk_indicator_id = @fk_indicator_id and datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum);

			insert into [Dashboard].[RealisatieDetails]( [fk_indicator_id]
														,[Datum]
														,[Laaddatum]
														,[Waarde]
														--,[Teller]
														--,[Noemer]
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
														,[Detail_10]
														,[eenheidnummer]
														,[bouwbloknummer]
														,[clusternummer]
														,[klantnummer]
														,[volgnummer]
														--,[relatienummer]
														,[dossiernummer]
														--,[betalingsregelingnummer]
														--,[rekeningnummer]
														--,[documentnummer]
														--,[leveranciernummer]
														,[werknemernummer]
														--,[projectnummer]
														--,[verzoeknummer]
														--,[ordernummer]
														--,[taaknummer]
														--,[overig]
														)
			SELECT	 [fk_indicator_id] = @fk_indicator_id
					,[Datum] = iif(Afhandelingsreden = 'Gedragsaanwijzing', [Afhandelingsdatum], [Contract einddatum])
					,[Laaddatum] = getdate()
					,[Waarde] = iif(row_number() OVER (partition by Eenheidnummer, Klantnummer order by [Dossier startdatum] asc, [Afhandelingsdatum] desc) = 1, 1, 0)
					--,[Teller]
					--,[Noemer]
					,[Omschrijving] =	  'Leefbaarheidsdossier: '
										+ [Dossiernummer]
										+ '; '
										+ 'Type: '
										+ [Dossiertype]
										+ '; '
										+ 'Soort: '
										+ [Dossiersoort]
										+ '; '
										+ 'Afhandelingsreden: '
										+ [Afhandelingsreden]
										+ '; '
										+ 'Invoerdatum: '
										+ format([Dossier startdatum], 'yyyy-MM-dd')
										+ '; '
										+ 'Adres: '
										+ iif([Eenheidtype] = '', '', [Eenheidtype] + ' ')
										+ iif([Straatnaam] = '', '', [Straatnaam] + ' ')
										+ iif([Huisnummer] = '', '', [Huisnummer] + ' ')
										+ iif([Toevoegsel] = '', '', [Toevoegsel] + ' ') 
										+ iif([Plaats] = '', '', [Plaats]) 
										+ '; '
										+ 'Doorloopdagen: '
										+ format(Doorlooptijd, 'G')
					,[Detail_01] = [Dossier startdatum]
					,[Detail_02] = [Dossiertype]
					,[Detail_03] = [Dossiersoort]
					,[Detail_04] = [Afhandelingsreden]
					,[Detail_05] = [Deelgebied]
					,[Detail_06] = [Buurt]
					,[Detail_07] = [Woonfraudebestrijder]
					,[Detail_08] = iif([Datum Aangifte doen] is not null, 'Ja', 'Nee')
					,[Detail_09] = iif([Datum Brief in gebrekestelling] is not null, 'Ja', 'Nee')
					,[Detail_10] = iif([Datum Juridische procedure starten] is not null, 'Ja', 'Nee')
					,[eenheidnummer] = Eenheidnummer
					,[bouwbloknummer] = Bouwbloknummer
					,[clusternummer] = Clusternummer
					,[klantnummer] = Klantnummer
					,[volgnummer] = Contractvolgnummer
					--,[relatienummer]
					,[dossiernummer] = Dossiernummer
					--,[betalingsregelingnummer]
					--,[rekeningnummer]
					--,[documentnummer]
					--,[leveranciernummer]
					,[werknemernummer] = Werknemernummer
					--,[projectnummer]
					--,[verzoeknummer]
					--,[ordernummer]
					--,[taaknummer]
					--,[overig]
			FROM #TempTable
			WHERE Dossierstatus = 'VOLTOOID'
					and (Dossiertype = 'Onrechtmatig gebruik'
						 or [Dossiersoort] in ('Woonfraude', 'Hennep'))
					and (	(Afhandelingsreden in ('Huuropzegging', 'Ontruiming')
							 and year([Contract einddatum]) = year(@peildatum)
							 and month([Contract einddatum]) = month(@peildatum)
							 )
						 or (Afhandelingsreden = 'Gedragsaanwijzing'
							 and year([Afhandelingsdatum]) = year(@peildatum)
							 and month([Afhandelingsdatum]) = month(@peildatum)
							 )
						 )

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
