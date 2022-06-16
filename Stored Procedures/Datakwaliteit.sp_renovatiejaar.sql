SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [Datakwaliteit].[sp_renovatiejaar] (@fk_indicatordimensie_id as int = null)   
AS
/* ###################################################################################################
BETREFT     : Procedure die door attributen in Datakwaliteit.Indicator aangeroepen kan worden om [atakwaliteit].Details mee te vullen
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
20200610 JvdW Aangemaakt
20200707 JvdW Toevoeging: fka
20200720 JvdW Toevoeging: 
	exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Laaddatum  = '20200718', @Attribuut =  'Medewerker uit dienst + lopend leefbaarheidsdossier'
	exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Medewerker uit dienst + lopend leefbaarheidsdossier'
	select * from [staedion_dm].[Datakwaliteit].[Indicator] where id in (5001)
	select * from [staedion_dm].[Datakwaliteit].[RealisatieDetails] where fk_indicator_id in (5001)
	select * from [staedion_dm].[Datakwaliteit].[Realisatie] where fk_indicator_id in (5001)
	select * from empire_staedion_Data.etl.LogboekMeldingenProcedures order by TijdMelding desc
20200720 JvdW Toevoeging: 
	exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Laaddatum  = '20200718', @Attribuut =  'Medewerker uit dienst + vermelding contactkaart'
	exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Medewerker uit dienst + vermelding contactkaart'
	select * from [staedion_dm].[Datakwaliteit].[Indicator] where id in (5002)
	select * from [staedion_dm].[Datakwaliteit].[RealisatieDetails] where fk_indicator_id in (5002)
	select * from [staedion_dm].[Datakwaliteit].[Realisatie] where fk_indicator_id in (5002)
	select * from empire_staedion_Data.etl.LogboekMeldingenProcedures order by TijdMelding desc
20201202 Versie 5 JvdW Minder overbodige code door gebruik te maken van @@RowCount: dan ook registereren wanneer teller = 0 
20201209 Versie 6 JvdW
	exec [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut = 'Controle verdeelsleutel woningen'	
	exec [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut = 'Controle verdeelsleutel parkeerplaatsen'
	exec [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut = 'Controle verdeelsleutel overig'
20201223 Versie 7 JvdW
	exec  [staedion_dm].[Datakwaliteit].[sp_overig]  @Attribuut = 'Ontbrekende datum in exploitatie wel prolongatie' 
	exec  [staedion_dm].[Datakwaliteit].[sp_overig]  @Attribuut = 'Ontbrekende datum in exploitatie wel contractregel'
	exec  [staedion_dm].[Datakwaliteit].[sp_overig]  @Attribuut = 'Ontbrekende kale huur'
20210127 Versie 8 JvdW
	exec  [staedion_dm].[Datakwaliteit].[sp_overig]  @Attribuut = 'Afwijking in aanvangsdatum huurcontract'	
20210203 Versie 9 JvdW
	exec  [staedion_dm].[Datakwaliteit].[sp_overig]  @Attribuut = 'Vinkje geliberaliseerd aan en uit op 1 contract ?'	
20210210 Versie 10 JvdW verfijning 
	exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Eenheid niet opgenomen in KVS-cluster of juist wel terwijl Staedion niet eigenaar is'
20210310 Versie 11 JvdW 
	exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Contact geslacht = aanhef ?'		-- 6015
	exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Huishouden geslacht = aanhef ?'	-- 6016
	exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Klant geslacht = aanhef ?'		-- 6017
	exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Contact initialen ok ?'			-- 6018	
	exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Huishouden initialen ok ?'		-- 6019
	exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Contact achternaam ok ?'			-- 6020	
	exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Huishouden achternaam ok ?'		-- 6021
20210324 Versie 12 JvdW 
	exec [Datakwaliteit].[sp_overig] null, 'Relaties','Correspondentietype'							-- 6022
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
exec [Datakwaliteit].[sp_overig]
select * from staedion_dm.Datakwaliteit.RealisatieDetails where fk_indicator_id = 3001

exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Medewerker uit dienst + vermelding contactkaart'
exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Vinkje beeindigd contractregel'
exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Ontbrekende datum in exploitatie'
exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Afwijkende prijzen service-abonnement'
exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Klantkaart met meerdere "Toon als eerste"'
exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Medewerker uit dienst + lopend leefbaarheidsdossier'
exec  [staedion_dm].[Datakwaliteit].[sp_overig] @Attribuut =  'Eenheid niet opgenomen in KVS-cluster'
------------------------------------------------------------------------------------------------------
TEMP
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Datakwaliteit', 'sp_overig'

################################################################################################### */	
BEGIN TRY

  -- Diverse variabelen
		set nocount on;

		declare @start as datetime;
		declare @finish as datetime;
		declare @Teller bigint;
		declare @Noemer bigint;
		declare @LogboekTekst NVARCHAR(255) = ' ### Maatwerk Staedion: staedion_dm..';
		declare @VersieNr NVARCHAR(80) = ' - Versie 5 20201202 JvdW - gebruik maken @@RowCount'	;
		set @LogboekTekst = @LogboekTekst + OBJECT_NAME(@@PROCID) + @VersieNr;
		declare @Bericht NVARCHAR(255)
		declare @parent_id int;
		
		DECLARE @AantalRecords int;

		DECLARE @Laaddatum as date
		DECLARE @fk_indicator_id as int = 2000
		DECLARE @Entiteit as nvarchar(50) = 'Eenheid'
	    DECLARE @Attribuut as nvarchar(255) = 'Renovatiejaar'

		select @parent_id = id from staedion_Dm.Datakwaliteit.Indicator where Omschrijving = @Entiteit;
		--select @fk_indicator_id = id from staedion_Dm.Datakwaliteit.Indicator WHERE parent_id = @parent_id and Omschrijving = @Attribuut; 
		--select @fk_indicatordimensie_id = fk_indicatordimensie_id from staedion_Dm.Datakwaliteit.Indicator where parent_id = @parent_id and Omschrijving = @Attribuut; 

		PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - BEGIN';
		PRINT convert(VARCHAR(20), getdate(), 121) + ' @Entiteit = '+@Entiteit + ' -  attribuut = ' + @attribuut;
		PRINT convert(VARCHAR(20), getdate(), 121) + ' @parent_id = '+coalesce(format(@parent_id,'N0' ),'GEEN !');
		PRINT convert(VARCHAR(20), getdate(), 121) + ' @fk_indicator = '+coalesce(format(@fk_indicator_id,'N0' ),'GEEN !');
		PRINT convert(VARCHAR(20), getdate(), 121) + ' @fk_indicatordimensie_id = '+coalesce(format(@fk_indicatordimensie_id,'N0' ),'GEEN !');

		set	@start =current_timestamp;
	
		select @Laaddatum = datum from empire_Dwh.dbo.tijd where last_loading_day =1;

		PRINT convert(VARCHAR(20), getdate(), 121) + + ' @Laaddatum = '+format(@Laaddatum,'dd-MM-yy' );


		if @fk_indicator_id is null	
			select Attribuut = @attribuut, Teller = @Teller, Noemer = @Noemer, Laaddatum = @Laaddatum 

		if @fk_indicator_id is not null	and @fk_indicatordimensie_id is not null and @fk_indicatordimensie_id <> 15
			begin 
				delete from [Datakwaliteit].[RealisatieDetails] where convert(date,Laaddatum) = convert(date,@Laaddatum) and fk_indicator_id = @fk_indicator_id and (fk_indicatordimensie_id = @fk_indicatordimensie_id OR @fk_indicatordimensie_id IS NULL);
								;
				SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails verwijderd: ' + format(@@ROWCOUNT, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

				delete from [Datakwaliteit].[Realisatie] where convert(date,Laaddatum) = convert(date,@Laaddatum) and fk_indicator_id = @fk_indicator_id and (fk_indicatordimensie_id = @fk_indicatordimensie_id OR @fk_indicatordimensie_id IS NULL);
								;
				SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie verwijderd: ' + format(@@ROWCOUNT, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
--------------------------------------------------------------------------------------------------------------
				--if @fk_indicatordimensie_id = 15
				--	begin
				--			insert into Datakwaliteit.RealisatieDetails (Eenheidnr
				--														,Omschrijving
				--														,Bevinding
				--														,Laaddatum
				--														,fk_indicator_id
				--														,fk_indicatordimensie_id)

				--				select Eenheidnr = [Nr_]
				--					  ,Omschrijving = 'Bouwjaar: ' + cast([Construction Year] as nvarchar) + '; Renovatiejaar: ' + cast([Renovation Year] as nvarchar)
				--					  ,Bevinding = 'Het renovatiejaar is leeg en het bouwjaar is meer dan 30 jaar oud of het renovatiejaar is meer dan 30 jaar oud'
				--					  ,Laaddatum = @Laaddatum
				--					  ,fk_indicator_id = @fk_indicator_id
				--					  ,fk_indicatordimensie_id = @fk_indicatordimensie_id
				--				FROM [backup_empire_data].[dbo].[Staedion$OGE]
				--				where [Nr_] like 'OGEH%'
				--					  and (([Renovation Year] <> 0 and [Renovation Year] < (year(getdate()) - 30))
				--						   or ([Construction Year] <> 0 and [Renovation Year] = 0 and [Construction Year] < (year(getdate()) - 30))
				--						   )

				--				SET @AantalRecords = @@ROWCOUNT

				--				SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
				--				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

				--			insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
				--				select @AantalRecords,  @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									
				--				SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
				--				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
				--	end
--------------------------------------------------------------------------------------------------------------
				if @fk_indicatordimensie_id = 17
					begin
							insert into Datakwaliteit.RealisatieDetails (Eenheidnr
																		,Omschrijving
																		,Bevinding
																		,Laaddatum
																		,fk_indicator_id
																		,fk_indicatordimensie_id)

								select Eenheidnr = [Nr_]
									  ,'Renovatiejaar: ' + cast([Renovation Year] as nvarchar)
									  ,Bevinding = 'Het renovatiejaar is gelijk aan het huidige jaar op de laaddatum'
									  ,Laaddatum = @Laaddatum
									  ,fk_indicator_id = @fk_indicator_id
									  ,fk_indicatordimensie_id = @fk_indicatordimensie_id
								FROM [backup_empire_data].[dbo].[Staedion$OGE]
								  where [Nr_] like 'OGEH%'
										and [Renovation Year] = year(getdate())

								SET @AantalRecords = @@ROWCOUNT

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords,  @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									
								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
					end

--------------------------------------------------------------------------------------------------------------
				if @fk_indicatordimensie_id = 18
					begin
							insert into Datakwaliteit.RealisatieDetails (Eenheidnr
																		,Omschrijving
																		,Bevinding
																		,Laaddatum
																		,fk_indicator_id
																		,fk_indicatordimensie_id)

								select Eenheidnr = [Nr_]
									  ,Omschrijving = 'Bouwjaar: ' + cast([Construction Year] as nvarchar) + '; Renovatiejaar: ' + cast([Renovation Year] as nvarchar)
									  ,Bevinding = 'Renovatiejaar voldoet niet aan de basisvereisten; geheel getal, vier cijfers, groter dan 1500 of groter dan bouwjaar'
									  ,Laaddatum = @Laaddatum
									  ,fk_indicator_id = @fk_indicator_id
									  ,fk_indicatordimensie_id = @fk_indicatordimensie_id
								FROM [backup_empire_data].[dbo].[Staedion$OGE]
								where [Nr_] like 'OGEH%'
										and [Renovation Year] <> 0
										and (ISNUMERIC([Renovation Year]) = 0 -- controle of renovatie jaar numeric is (1 is numeric, 0 is geen numeric)
											 or floor(floor(abs([Renovation Year])) / abs([Renovation Year])) = 0 -- controle of renovatie jaar een integer is (1 is integer, 0 is geen integer)
											 or [Renovation Year] <= 1500 -- controle of renovatie jaar groter dan 1500 is
											 or [Renovation Year] >= 10000 -- controle of renovatie jaar maximaal 4 cijfers bevat
											 or ([Construction Year] <> 0 and [Renovation Year] <> 0 and [Construction Year] >= [Renovation Year]) -- controle of renovatiejaar ten minste groter is dan het bouwjaar
											 )

								SET @AantalRecords = @@ROWCOUNT

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords,  @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									
								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
					end
--------------------------------------------------------------------------------------------------------------
				if @fk_indicatordimensie_id = 20
					begin
						insert into Datakwaliteit.RealisatieDetails (Eenheidnr
																	,Omschrijving
																	,Bevinding
																	,Laaddatum
																	,fk_indicator_id
																	,fk_indicatordimensie_id)

							select Eenheidnr = [Nr_]
									,Omschrijving = 'Reden in exploitatie: ' + EXPL.[Description] + '; Renovatiejaar: ' + cast(oge.[Renovation Year] as nvarchar) + '; Bouwjaar: ' + cast(oge.[Construction Year] as nvarchar)
									,Bevinding = '1) Renovatiejaar moet gelijk zijn aan bouwjaar bij eenheden waarbij reden in exploitatie is Functiewijziging/Transformatie'
									,Laaddatum = @Laaddatum
									,fk_indicator_id = @fk_indicator_id
									,fk_indicatordimensie_id = @fk_indicatordimensie_id
							FROM [backup_empire_data].[dbo].[Staedion$OGE] AS OGE
								inner join [backup_empire_data].[dbo].[Staedion$Exploitation_Reason_Code] AS EXPL
									on OGE.[Reden in exploitatie] = EXPL.Code
								where EXPL.[Description] = 'Functiewijziging/Transformatie' and
								oge.[Begin exploitatie] >= '2015-01-01' and
								oge.[Renovation Year] <> oge.[Construction Year]
							union
							select Eenheidnr = [Nr_]
									,Omschrijving = 'Renovatiejaar: ' + cast(oge.[Renovation Year] as nvarchar) + '; Bouwjaar: ' + cast(oge.[Construction Year] as nvarchar)
									,Bevinding = '2) Renovatiejaar moet groter zijn dan bouwjaar.'
									,Laaddatum = @Laaddatum
									,fk_indicator_id = @fk_indicator_id
									,fk_indicatordimensie_id = @fk_indicatordimensie_id
							FROM [backup_empire_data].[dbo].[Staedion$OGE] AS OGE
							where oge.[Common Area] = 0 and
							OGE.[Reden in exploitatie] <> '07' and
							oge.[Begin exploitatie] >= getdate() and
							(oge.[Einde exploitatie] = '1753-01-01' or oge.[Einde exploitatie] >= convert(date, getdate())) and
							oge.[Renovation Year] < oge.[Construction Year]


							SET @AantalRecords = @@ROWCOUNT

							SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
							EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

						insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
							select @AantalRecords,  @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									
							SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
							EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
					end
--------------------------------------------------------------------------------------------------------------
			end

		set		@finish = current_timestamp

		
		INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd,TijdMelding)
			SELECT	coalesce(OBJECT_NAME(@@PROCID),'?') + ' - ' + coalesce(@Attribuut,'?' )
							,@start
							,@finish
							,getdate()
					

		PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - EINDE';

		INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd,TijdMelding)
			SELECT	coalesce(OBJECT_NAME(@@PROCID),'?') + ' - ' + coalesce(@Attribuut,'?' )
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
		
	END CATCH
GO
