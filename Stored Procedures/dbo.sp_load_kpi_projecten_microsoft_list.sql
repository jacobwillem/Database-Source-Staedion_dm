SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[sp_load_kpi_projecten_microsoft_list] 
		(@Peildatum as date = null, @SoortProject as nvarchar(50) = 'Nieuwbouw' , @SoortWerkzaamheden as nvarchar(50) = 'Start') 
as
/* #############################################################################################################################
Data van Microsoft List wordt via Power Automate overgehaald naar staedion_dm.sharepoint
Deze procedure verwerkt dat in het dashboard, met behulp van de parameters zijn meerdere indicatoren met deze procedure te vullen. Inclusief prognose voor restend deel jaar
> Nieuwbouw + start: indicator gestarte nieuwebouw
> <> Nieuwbouw + start: indicator gestarte renovatie
> <> Nieuwbouw + oplevering: indicator opleverde renovatie

NB: afspraak met Youness: voorlopig voor hele jaar nieuwe cijfers invoeren van januari tot en met lopende maand
> later op aangeven, zou je stand van vorige periode kunnen bevriezen
NB: prognose IN 1 totaal opvoeren

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------------
20211110 JvdW Aangemaakt nav opgeleverde Microsoft Lists
> ter vervanging voor Indicator = 200, sp_load_kpi_projecten_nieuwbouw_tijdelijk
> ter vervanging voor Indicator = 400, sp_load_kpi_projecten_renovaties_gestart_tijdelijk
20211115 JvdW bk_clusternummer verwijderd
20211208 JvdW Transformatie = nieuwbouw
> zie mail Astrid/Youness 7-12-2021: "1-	Transformatie laten vallen onder nieuwbouw (zoals dat tot nu toe in het dashboard ook is gedaan)"
--------------------------------------------------------------------------------------------------------------------------------
TESTEN
--------------------------------------------------------------------------------------------------------------------------------
exec staedion_dm.[dbo].[sp_load_kpi_projecten_microsoft_list] '20211031', 'Nieuwbouw', 'Start'
exec staedion_dm.[dbo].[sp_load_kpi_projecten_microsoft_list] '20211031', 'Renovatie', 'Start'
exec staedion_dm.[dbo].[sp_load_kpi_projecten_microsoft_list] '20211031', 'Renovatie', 'Oplevering'
exec staedion_dm.[dbo].[sp_load_kpi_projecten_microsoft_list] '20211031', 'Nieuwbouw', 'Oplevering'
exec staedion_dm.[dbo].[sp_load_kpi_projecten_microsoft_list] null, 'Nieuwbouw', 'Start'
exec staedion_dm.[dbo].[sp_load_kpi_projecten_microsoft_list] null, 'Renovatie', 'Start'

select top 100 * from empire_staedion_Data.etl.LogboekMeldingenProcedures order by Begintijd desc

select * into staedion_dm.bak.realisatiedetails_20211110_nieuwbouw_renovatie from staedion_dm.dashboard.realisatiedetails  
select * into staedion_dm.bak.prognose_20211110_nieuwbouw_renovatie from staedion_dm.dashboard.Prognose  
--------------------------------------------------------------------------------------------------------------------------------
TESTEN OP ACCEPTATIE
select * into staedion_dm.Sharepoint.AantallenStartBouwOplevering from [s-dwh2012-db].'staedion_dm.Sharepoint.AantallenStartBouwOplevering
--------------------------------------------------------------------------------------------------------------------------------

-- VIEW [Dashboard].[vw_Prognose]
SELECT	P.[fk_indicator_id]
		,P.[Datum]
		,P.[Waarde]
		,P.[Laaddatum]
		,I.[Omschrijving] AS indicator
		,P.[Omschrijving]
-- select *
FROM Dashboard.Prognose AS P 
JOIN [Dashboard].[vw_Indicator] AS I
	ON I.[id] = P.[fk_indicator_id]
	AND I.[Jaargang] = YEAR(P.[Datum])
	AND P.fk_indicator_id IN (200,400,502)			-- 200 = 329 + 400 = 652
	AND P.Datum = '20211031'
GO


select		'Totaal deze maand', DET.Datum, I.omschrijving, DET.fk_indicator_id, Realisatie = sum(DET.Waarde) 
-- select *
from		staedion_dm.dashboard.realisatiedetails  as DET
join		staedion_dm.dashboard.indicator as I
on I.id = DET.fk_indicator_id
where		fk_indicator_id in (200,400,502)
and			DET.Datum = '20211031'
and year(DET.Datum) = 2021
group by DET.Datum, I.omschrijving, DET.fk_indicator_id
UNION 
select		'Totaal realisatie tot aan deze maand', MAX(DET.Datum), I.omschrijving, DET.fk_indicator_id, Realisatie = sum(DET.Waarde) 
-- select *
from		staedion_dm.dashboard.realisatiedetails  as DET
join		staedion_dm.dashboard.indicator as I
on I.id = DET.fk_indicator_id
where		fk_indicator_id in (200,400,502)
and			DET.Datum <= '20211031'
and year(DET.Datum) = 2021
group by  I.omschrijving, DET.fk_indicator_id;
############################################################################################################################# */


BEGIN TRY

		-- Variabelen definieren
		DECLARE @Maandnummer AS SMALLINT 
		DECLARE @Teller AS SMALLINT = 1
		declare @start as datetime
		declare @finish as datetime
		declare @fk_indicator_id as int

		-- Waarde variabelen toekennen
		set	@start = current_timestamp
		;
		SELECT @fk_indicator_id = min(id) 
		FROM  [Dashboard].[Indicator] 
		WHERE lower([Omschrijving]) like '%'+ LOWER(@SoortWerkzaamheden) + '%' 
		AND  lower([Omschrijving]) like '%'+ LOWER(@SoortProject) + '%'
		;
		IF @Peildatum is NULL
			SET @Peildatum = eomonth(dateadd(m, - 1, getdate()));
		SELECT @Maandnummer = MONTH(@Peildatum)

		-- Wissen gehele jaar !
		delete
		from	staedion_dm.dashboard.realisatiedetails  
		WHERE	fk_indicator_id  = @fk_indicator_id
		and		year(Datum) =YEAR(@Peildatum)
		;
	
		-- Realisatie hele jaar
		WHILE @Teller <= @Maandnummer
			begin
				INSERT INTO [Dashboard].[RealisatieDetails]
							([Laaddatum]
							,[Waarde]
							,Datum
							,[Omschrijving]
							,fk_indicator_id
							,clusternummer
							,detail_01
							,detail_02
							,detail_03
							)
					SELECT	[Laaddatum] = CONVERT(date,GETDATE())
								,[Waarde] = CASE @Teller 
												WHEN 1 THEN COALESCE([Jan], 0)
												WHEN 2 THEN COALESCE([Feb], 0)
												WHEN 3 THEN COALESCE([Mrt], 0)
												WHEN 4 THEN COALESCE([Apr], 0)
												WHEN 5 THEN COALESCE([Mei], 0)
												WHEN 6 THEN COALESCE([Jun], 0)
												WHEN 7 THEN COALESCE([Jul], 0)
												WHEN 8 THEN COALESCE([Aug], 0)
												WHEN 9 THEN COALESCE([Sept], 0)
												WHEN 10 THEN COALESCE([Okt], 0)
												WHEN 11 THEN COALESCE([Nov], 0)
												WHEN 12 THEN COALESCE([Dec], 0) END
								,[Datum] = EOMONTH(DATEFROMPARTS(YEAR(@Peildatum),@Teller,1))
								,[Omschrijving] = CONCAT(BASIS.Title,' ; ',Projectnummer,' ; ',Projectmanager)
								,@fk_indicator_id
                                ,clusternummer = case when left([FT-cluster],7) like 'FT-[0-9][0-9][0-9][0-9]%' then left([FT-cluster],7) else '' end                                
								,Projectnummer
								,Projectmanager
								,BASIS.TypeProject
					-- select top 10 *
					from	staedion_dm.Sharepoint.AantallenStartBouwOplevering as BASIS
					WHERE	(
								(BASIS.[TypeProject] in ('Nieuwbouw', 'Transformatie') and  @SoortProject = 'Nieuwbouw')
								OR	(BASIS.[TypeProject] NOT IN ('Nieuwbouw','Transformatie') and  @SoortProject = 'Renovatie')
							)
					and		BASIS.Jaar = YEAR(@Peildatum)
					and		BASIS.Peildatum = @Peildatum			-- data ophalen van de laatste peildatum uit Microsoft Lists (deze tabel wordt gesnapshot)
					and		BASIS.StartOplevering = @SoortWerkzaamheden
					AND		0 <> CASE @Teller 
												WHEN 1 THEN COALESCE([Jan], 0)
												WHEN 2 THEN COALESCE([Feb], 0)
												WHEN 3 THEN COALESCE([Mrt], 0)
												WHEN 4 THEN COALESCE([Apr], 0)
												WHEN 5 THEN COALESCE([Mei], 0)
												WHEN 6 THEN COALESCE([Jun], 0)
												WHEN 7 THEN COALESCE([Jul], 0)
												WHEN 8 THEN COALESCE([Aug], 0)
												WHEN 9 THEN COALESCE([Sept], 0)
												WHEN 10 THEN COALESCE([Okt], 0)
												WHEN 11 THEN COALESCE([Nov], 0)
												WHEN 12 THEN COALESCE([Dec], 0) end
					;
					SET @Teller = @Teller + 1

		END

		-- Prognose wissen
		delete
		FROM Dashboard.Prognose 
		WHERE fk_indicator_id = @fk_indicator_id 
		AND Datum = @Peildatum
		;

		INSERT INTO Dashboard.Prognose (fk_indicator_id,datum, waarde,laaddatum, omschrijving)
		SELECT	@fk_indicator_id
				,BASIS.Peildatum
				,Waarde = sum(coalesce([Jan], 0) + coalesce([Feb], 0) + coalesce([Mrt], 0) + coalesce([Apr], 0) + coalesce([Mei], 0) 
									+ coalesce([Jun], 0) + coalesce([Jul], 0) + coalesce([Aug], 0) + coalesce([Sept], 0) + coalesce([Okt], 0) + coalesce([Nov], 0) + coalesce([Dec], 0))
				,Laaddatum = CONVERT(DATE,GETDATE())
				,'Ontleend aan Aantallen Start Bouw & Oplevering'	
		FROM	staedion_dm.Sharepoint.AantallenStartBouwOplevering AS BASIS
		WHERE	(	(BASIS.[TypeProject] in ('Nieuwbouw', 'Transformatie') AND  @SoortProject = 'Nieuwbouw')
							OR	(BASIS.[TypeProject] NOT IN('Nieuwbouw', 'Transformatie') and  @SoortProject = 'Renovatie')
							)
				and		BASIS.Jaar = YEAR(@Peildatum)
				and		BASIS.Peildatum = @Peildatum
				and		BASIS.StartOplevering = @SoortWerkzaamheden
		GROUP BY BASIS.Peildatum
		;


	set		@finish = current_timestamp
	
 
	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd)
	SELECT	OBJECT_NAME(@@PROCID) + 'parameters: '+ CONVERT(NVARCHAR(20),@Peildatum,105) + ' - ' + COALESCE(FORMAT(@fk_indicator_id, 'N0'),'Indicator id ?') + ' - '+ COALESCE(@SoortProject, 'Soort project ?') + ' - ' + COALESCE(@SoortWerkzaamheden, 'Soort werkzaamheden ?')
					,@start
					,@finish
					
END TRY

BEGIN CATCH

	set		@finish = current_timestamp
	
	DECLARE @Melding AS NVARCHAR(1000)
	SET @Melding = ERROR_PROCEDURE() + 'parameters: '+ CONVERT(NVARCHAR(20),@Peildatum,105) + ' - ' + COALESCE(FORMAT(@fk_indicator_id, 'N0'),'Indicator id ?') + ' - '+ COALESCE(@SoortProject, 'Soort project ?') + ' - ' + COALESCE(@SoortWerkzaamheden, 'Soort werkzaamheden ?')

	INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd, Eindtijd, TijdMelding,ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage)
	SELECT		@Melding
					,@start
					,@finish
					,getdate()
					,ERROR_PROCEDURE() 
					,ERROR_NUMBER()
					,ERROR_LINE()
				  ,ERROR_MESSAGE() 
		


END CATCH
GO
