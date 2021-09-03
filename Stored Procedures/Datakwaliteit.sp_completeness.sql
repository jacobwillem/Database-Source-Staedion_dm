SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  procedure [Datakwaliteit].[sp_completeness] 
				(@Laaddatum as date = null, 
				 @Attribuut as nvarchar(50) = 'Bouwjaar', 
				 @FilterCorpoData as nvarchar(50) = null, 
				 @fk_indicator_id as int = null, 
				 @fk_indicatordimensie_id as int = null ) 
as
/* ###################################################################################################
BETREFT     : Procedure die adhv [Datakwaliteit].[tfn_els_completeness] en aan de hand van parameter datum voor een attribuut van ELS-lijst kan bepalen voor hoeveel records die een waarde heeft
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
20200520 JvdW Aangemaakt
20210623 JvdW Gewijzigd: soms Noemer is 0 als er geen regels zijn in de ELS-lijst met dezelfde laaddatum

------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
EXEC [Datakwaliteit].[sp_completeness] @Laaddatum = '20200517', @Attribuut = 'Bouwjaar', @FilterCorpoData = 'WON ZELF', @fk_indicator_id = 1020, @fk_indicatordimensie_id = 15
EXEC [Datakwaliteit].[sp_completeness] @Laaddatum = '20200517', @Attribuut = 'Thuisteam', @FilterCorpoData = 'WON ZELF', @fk_indicator_id = 1010, @fk_indicatordimensie_id = 15
EXEC [Datakwaliteit].[sp_completeness] @Laaddatum = '20190517', @Attribuut = 'Bouwjaar', @FilterCorpoData = 'WON ZELF', @fk_indicator_id = 1020, @fk_indicatordimensie_id = 15
EXEC [Datakwaliteit].[sp_completeness] @Laaddatum = '20190517', @Attribuut = 'Thuisteam', @FilterCorpoData = 'WON ZELF', @fk_indicator_id = 1010, @fk_indicatordimensie_id = 15

EXEC [Datakwaliteit].[sp_completeness] @Laaddatum = '20200517', @Attribuut = 'contactpersoon_CB_VHTEAM', @FilterCorpoData = 'WON ZELF', @fk_indicator_id = 1030, @fk_indicatordimensie_id = 15
EXEC [Datakwaliteit].[sp_completeness] @Laaddatum = '20190517', @Attribuut = 'contactpersoon_CB_VHTEAM', @FilterCorpoData = 'WON ZELF', @fk_indicator_id = 1030, @fk_indicatordimensie_id = 15
EXEC [Datakwaliteit].[sp_completeness] @Laaddatum = '20200517', @Attribuut = 'oppervlakte', @FilterCorpoData = 'WON ZELF', @fk_indicator_id = 1050, @fk_indicatordimensie_id = 15
EXEC [Datakwaliteit].[sp_completeness] @Laaddatum = '20190517', @Attribuut = 'oppervlakte', @FilterCorpoData = 'WON ZELF', @fk_indicator_id = 1050, @fk_indicatordimensie_id = 15
EXEC [Datakwaliteit].[sp_completeness] @Laaddatum = '20200517', @Attribuut = 'brutohuur', @FilterCorpoData = 'WON ZELF', @fk_indicator_id = 1040, @fk_indicatordimensie_id = 15
EXEC [Datakwaliteit].[sp_completeness] @Laaddatum = '20190517', @Attribuut = 'brutohuur', @FilterCorpoData = 'WON ZELF', @fk_indicator_id = 1040, @fk_indicatordimensie_id = 15
EXEC [Datakwaliteit].[sp_completeness] @Laaddatum = '20200517', @Attribuut = 'datum_in_exploitatie', @FilterCorpoData = 'WON ZELF', @fk_indicator_id = 1060, @fk_indicatordimensie_id = 15
EXEC [Datakwaliteit].[sp_completeness] @Laaddatum = '20190517', @Attribuut = 'datum_in_exploitatie', @FilterCorpoData = 'WON ZELF', @fk_indicator_id = 1060, @fk_indicatordimensie_id = 15

-- ontbrekende oppervlaktes
select * from [Datakwaliteit].[tfn_els_completeness] ('20200517','oppervlakte','WON ZELF') 
		where not ((nullif(intWaarde,0) is not null and strWaarde is null and decWaarde is null and datWaarde is null)
			or (nullif(strWaarde,'') is not null and intWaarde is null and decWaarde is null and datWaarde is null)
			or (nullif(decWaarde,0) is not null and intWaarde is null and strWaarde is null and datWaarde is null)
			or (nullif(datWaarde,'17530101') is not null and intWaarde is null and strWaarde is null and decWaarde is null))
			 
select * from [Datakwaliteit].[tfn_els_completeness] ('20200517','brutohuur','WON ZELF') 
		where not ((nullif(intWaarde,0) is not null and strWaarde is null and decWaarde is null and datWaarde is null)
			or (nullif(strWaarde,'') is not null and intWaarde is null and decWaarde is null and datWaarde is null)
			or (nullif(decWaarde,0) is not null and intWaarde is null and strWaarde is null and datWaarde is null)
			or (nullif(datWaarde,'17530101') is not null and intWaarde is null and strWaarde is null and decWaarde is null))

contactpersoon_CB_VHTEAM
EXEC [Datakwaliteit].[sp_completeness] @Laaddatum = '20200517', @Attribuut = 'brutohuur', @FilterCorpoData = 'WON ZELF', @fk_indicator_id = 1020, @fk_indicatordimensie_id = 15
EXEC [Datakwaliteit].[sp_completeness] @Laaddatum = '20200517', @Attribuut = 'oppervlakte', @FilterCorpoData = 'WON ZELF', @fk_indicator_id = 1010, @fk_indicatordimensie_id = 15

select * from empire_staedion_Data.etl.LogboekMeldingenProcedures  order by TijdMelding desc
Conversion failed when converting the nvarchar value 'Thuisteam Zuid-Oost' to data type int.

	select *
		FROM [Datakwaliteit].[tfn_els_completeness] ('20200517','Thuisteam','WON ZELF')
		where (nullif(intWaarde,0) is not null and strWaarde is null and decWaarde is null and datWaarde is null)
			or (nullif(strWaarde,'') is not null and intWaarde is null and decWaarde is null and datWaarde is null)
			or (nullif(decWaarde,0) is not null and intWaarde is null and strWaarde is null and datWaarde is null)
			or (nullif(datWaarde,'17530101') is not null and intWaarde is null and strWaarde is null and decWaarde is null)

------------------------------------------------------------------------------------------------------
TEMP
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'empire_staedion_data', 'dbo', 'ELS'
select top 10 * from empire_staedion_data.dbo.ELS
################################################################################################### */	
BEGIN TRY

  -- Diverse variabelen
		set nocount on;

		declare @start as datetime;
		declare @finish as datetime;
		declare @Teller bigint;
		declare @Noemer bigint;
		declare @LogboekTekst NVARCHAR(255) = ' ### Maatwerk Staedion: empire_staedion_logic..';
		declare @VersieNr NVARCHAR(80) = ' - Versie 2 20200520 JvdW'	;
		declare @DetailsWegschrijven bit;
		set @LogboekTekst = @LogboekTekst + OBJECT_NAME(@@PROCID) + @VersieNr;
		declare @Bericht NVARCHAR(255);


		PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - BEGIN';

		set	@start =current_timestamp;

		select @DetailsWegschrijven = coalesce(Details_toevoegen,0) from staedion_dm.datakwaliteit.indicator where id = @fk_indicator_id;

		-- Geen Laaddatum: dan niet die van 1-7
		If @Laaddatum is null
			begin
				select @Laaddatum = max(datum_gegenereerd)
						from		empire_staedion_data.dbo.els
						where datum_gegenereerd <= coalesce(@Laaddatum,'20990101')
						and datum_gegenereerd <= SYSDATETIME()
						;
			end

		-- Wel Laaddatum opgegeven: dan de laaddatum van Els nemen die er het dichtst bij zit
		If @Laaddatum is null
			begin
				select @Laaddatum = max(datum_gegenereerd)
						from		empire_staedion_data.dbo.els
						where datum_gegenereerd <= @Laaddatum
						;
			end

		select ListItem 
			into #FilterCorpoData
			from  empire_staedion_logic.dbo.dlf_ListInTable(',',@FilterCorpoData)
		;

		SELECT @Noemer = count(DISTINCT BRON.eenheidnr)
		FROM empire_staedion_data.dbo.els AS BRON
		where BRON.datum_gegenereerd = (select max(datum_gegenereerd) from empire_staedion_data.dbo.els where datum_gegenereerd <=@Laaddatum)
		--where BRON.datum_gegenereerd = @Laaddatum				-- JvdW 23-06-2021 - als leeg dan null
		and BRON.datum_in_exploitatie <= @Laaddatum
					 AND (
									BRON.datum_uit_exploitatie >= @Laaddatum
									OR nullif(BRON.datum_uit_exploitatie, '') IS NULL
									)
					 AND (
									BRON.Corpodata_type IN (select ListItem from #FilterCorpoData)
									OR @FilterCorpoData IS NULL or @FilterCorpoData = ''
									)
			;

		SET @bericht = 'Attribuut '+ @Attribuut + ' - noemer: ' + format(@Noemer, 'N0') + ' - laaddatum: '+ format(@Laaddatum, 'dd-MM-yyyy') 
		EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht

		SELECT @Teller = count(DISTINCT eenheidnr)
		FROM [Datakwaliteit].[tfn_els_completeness] (@Laaddatum,@Attribuut,@FilterCorpoData)
		where (nullif(intWaarde,0) is not null and strWaarde is null and decWaarde is null and datWaarde is null)
			or (nullif(strWaarde,'') is not null and intWaarde is null and decWaarde is null and datWaarde is null)
			or (nullif(decWaarde,0) is not null and intWaarde is null and strWaarde is null and datWaarde is null)
			or (nullif(datWaarde,'17530101') is not null and intWaarde is null and strWaarde is null and decWaarde is null)
		
		SET @bericht = 'Attribuut '+ @Attribuut + ' - teller: ' + format(@Teller, 'N0')
		EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht
		
		if @fk_indicator_id is null	
			select Attribuut = @attribuut, Teller = @Teller, Noemer = @Noemer, Laaddatum = @Laaddatum 

		if @fk_indicator_id is not null	
			begin 
				delete from [Datakwaliteit].[Realisatie] where Laaddatum = @Laaddatum and fk_indicator_id = @fk_indicator_id and fk_indicatordimensie_id = @fk_indicatordimensie_id
					;
					SET @bericht = 'Verwijderd [Datakwaliteit].[Realisatie] - '+ @Attribuut + ' - records: ' + format(@@ROWCOUNT, 'N0');
					EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht
					;
				insert into [Datakwaliteit].[Realisatie] (Laaddatum,fk_indicator_id, fk_indicatordimensie_id, Teller, Noemer)
					select @Laaddatum, @fk_indicator_id, @fk_indicatordimensie_id, @Teller, @Noemer
					;
					SET @bericht = 'Toegevoegd [Datakwaliteit].[Realisatie] - '+ @Attribuut + ' - records: ' + format(@@ROWCOUNT, 'N0');
					EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht
					;
			end
	
		if @DetailsWegschrijven = 1
			begin
				delete from [Datakwaliteit].[RealisatieDetails] where Laaddatum = @Laaddatum and fk_indicator_id = @fk_indicator_id and fk_indicatordimensie_id = @fk_indicatordimensie_id
					;
					SET @bericht = 'Verwijderd [Datakwaliteit].[RealisatieDetails] - '+ @Attribuut + ' - records: ' + format(@@ROWCOUNT, 'N0');
					EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht
					;

				insert into Datakwaliteit.[RealisatieDetails] (Waarde, Laaddatum, fk_indicator_id, Eenheidnr,fk_indicatordimensie_id, Omschrijving)
						--SELECT 1, @Laaddatum, @fk_indicator_id, Eenheidnr,@fk_indicatordimensie_id 
						SELECT 1, @Laaddatum, @fk_indicator_id, Eenheidnr,@fk_indicatordimensie_id , Omschrijving = 'Attribuut: '+@Attribuut + ';'+'Filter: '+@FilterCorpoData
						FROM [Datakwaliteit].[tfn_els_completeness] (@Laaddatum,@Attribuut,@FilterCorpoData)
						where nullif(intWaarde,0) is null and nullif(strWaarde,'') is null and nullif(decWaarde,0) is null and nullif(datWaarde,'17530101') is null
						;
					SET @bericht = 'Toegevoegd [Datakwaliteit].[RealisatieDetails] - '+ @Attribuut + ' - records: ' + format(@@ROWCOUNT, 'N0');
					EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht
					;
			end
		
		set		@finish = current_timestamp

		PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - EINDE';

		INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd, TijdMelding)
			SELECT	OBJECT_NAME(@@PROCID) 
									+ coalesce(' - attribuut: '+ @Attribuut,' - geen attribuut') 
									+ coalesce(' - laaddatum: '+ convert(nvarchar(20), @Laaddatum, 105), ' - geen laaddatum')
							,@start
							,@finish
							,getdate()
					
	END TRY

	BEGIN CATCH

		set		@finish = current_timestamp

		INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding,ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage)
		SELECT	coalesce(ERROR_PROCEDURE(),'?' ) + ' - ' + coalesce(@Attribuut,'?' )
						,getdate()
						,ERROR_PROCEDURE() 
						,ERROR_NUMBER()
						,ERROR_LINE()
						,ERROR_MESSAGE() 
									+ coalesce(' - attribuut: '+ @Attribuut,' - geen attribuut') 
									+ coalesce(' - laaddatum: '+ convert(nvarchar(20), @Laaddatum, 105), ' - geen laaddatum')
		
	END CATCH


GO
