SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  procedure [Datakwaliteit].[sp_consistency] 
				(@Laaddatum as date = null, 
				 @Entiteit as nvarchar(50) = 'Relaties',
				 @Attribuut as nvarchar(255) = 'Customer.[E-mail 1] | Contact.[Email 1]',
				 @FilterActieveHuurder AS nvarchar(10) = 'Ja',
				 @fk_indicatordimensie_id as int = 20)  -- consistency  

				 
as
/* ###################################################################################################
BETREFT     : Procedure die door attributen in Datakwaliteit.Indicator aangeroepen kan worden om te checken of waarde op plek 1 in database gelijk is aan plek 2
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
20201104 JvdW Aangemaakt
20201125 JvdW Toegevoegd
EXEC [Datakwaliteit].[sp_consistency] @Attribuut = 'Aanhef persoonskaart wijkt af van geslacht persoonskaart',  @FilterActieveHuurder = 'Ja'
20201202 Versie 3 JvdW Minder overbodige code door gebruik te maken van @@RowCount: dan ook registereren wanneer teller = 0 
	
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
EXEC [Datakwaliteit].[sp_consistency] @Laaddatum = '20201104', @Entiteit = 'Relaties', @Attribuut = 'Is [email 1] van huishoudkaart gelijk aan [email 1] van klantkaart',  @FilterActieveHuurder = 'Ja'
EXEC [Datakwaliteit].[sp_consistency] @Laaddatum = '20201104', @Entiteit = 'Relaties', @Attribuut = 'Customer.[E-mail 1] | Contact.[Email 1] (alles)',  @FilterActieveHuurder = 'Nee'
select * from staedion_dm.Datakwaliteit.Indicator where id >= 6000
select * from staedion_dm.Datakwaliteit.RealisatieDetails where fk_indicator_id = 6011

EXEC [Datakwaliteit].[sp_consistency] @Entiteit = 'Relaties', @Attribuut = 'Customer.[E-mail 1] | Contact.[Email 1]',  @FilterActieveHuurder = 'Ja'
EXEC [Datakwaliteit].[sp_consistency] @Entiteit = 'Relaties', @Attribuut = 'Customer.[E-mail 1] | Contact.[Email 1] (alles)',  @FilterActieveHuurder = 'Nee'
EXEC [Datakwaliteit].[sp_consistency] @Attribuut = '%Customer%mail%Contact%Email%',  @FilterActieveHuurder = 'Ja'
EXEC [Datakwaliteit].[sp_consistency] @Attribuut = 'Aanhef persoonskaart wijkt af van geslacht persoonskaart',  @FilterActieveHuurder = 'Nee'



------------------------------------------------------------------------------------------------------
TEMP
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Datakwaliteit', 'sp_accuratesse'

################################################################################################### */	
BEGIN TRY

  -- Diverse variabelen
		set nocount on;

		declare @start as datetime;
		declare @finish as datetime;
		declare @Teller bigint;
		declare @Noemer bigint;
		declare @LogboekTekst NVARCHAR(255) = ' ### Maatwerk Staedion: staedion_dm..';
		declare @VersieNr NVARCHAR(80) = ' - Versie 3 20201202 JvdW - gebruik maken van @AantalRecords'	;
		set @LogboekTekst = @LogboekTekst + OBJECT_NAME(@@PROCID) + @VersieNr;
		declare @Bericht NVARCHAR(255)
		declare @parent_id int;
		declare @fk_indicator_id int;
		DECLARE @AantalRecords int;

		select @parent_id = id from staedion_Dm.Datakwaliteit.Indicator where Omschrijving = @Entiteit;
		select @fk_indicator_id = id from staedion_Dm.Datakwaliteit.Indicator where parent_id = @parent_id and  @Attribuut = coalesce(bron_database,omschrijving); 

		PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - BEGIN';
		PRINT convert(VARCHAR(20), getdate(), 121) + ' @fk_indicator = '+coalesce(format(@fk_indicator_id,'N0' ),'GEEN !') +  ' - @fkparent_id = ' + coalesce(format(@parent_id,'N0'),'GEEN !');

		set	@start =current_timestamp;
	
		if @Laaddatum is null
			select @Laaddatum = datum from empire_Dwh.dbo.tijd where last_loading_day =1;

		PRINT convert(VARCHAR(20), getdate(), 121) + ' @Laaddatum = '+format(@Laaddatum,'dd-MM-yy' );

		if @Attribuut like  '%Customer%mail%Contact%Email%' 
			begin 
				delete from [Datakwaliteit].[RealisatieDetails] where convert(date,Laaddatum) = convert(date,@Laaddatum) and fk_indicator_id = @fk_indicator_id and fk_indicatordimensie_id = @fk_indicatordimensie_id;
								;
				SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails verwijderd: ' + format(@@ROWCOUNT, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

				delete from [Datakwaliteit].[Realisatie] where convert(date,Laaddatum) = convert(date,@Laaddatum) and fk_indicator_id = @fk_indicator_id and fk_indicatordimensie_id = @fk_indicatordimensie_id;
								;
				SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie verwijderd: ' + format(@@ROWCOUNT, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

						insert into Datakwaliteit.RealisatieDetails ( Klantnr, Laaddatum, fk_indicator_id , fk_indicatordimensie_id, Omschrijving)
									SELECT distinct Klantnr = CUS.[No_]
												,@Laaddatum
												,@fk_indicator_id
												,@fk_indicatordimensie_id
												 ,Omschrijving = 'Afwijkende email:  klant = '+CUS.[E-Mail] + ' - huishoudkaart = ' +  HH_KAART.[E-mail]
										-- select CUS.No_, CUS.[Contact No_], HH_KAART.[E-mail] , CUS.[E-Mail], ROL.*
										FROM empire_data.dbo.Customer AS CUS
												LEFT OUTER JOIN empire_data.dbo.[contact_role] AS ROL
												 ON CUS.[Contact No_] = ROL.[Related Contact No_]
										--LEFT OUTER JOIN empire_data.dbo.[contact] AS P_KAART
										--	   ON P_KAART.No_ = ROL.[Contact No_]
										LEFT OUTER JOIN empire_data.dbo.[contact] AS HH_KAART
												 ON HH_KAART.No_ = CUS.[Contact No_]
										WHERE ( CUS.No_ IN (SELECT Klantnr FROM staedion_dm.[Datakwaliteit].[SetHuurdersTeChecken] ) or @FilterActieveHuurder = 'Nee')
										and HH_KAART.[E-mail] <> CUS.[E-Mail]
										;

								SET @AantalRecords = @@ROWCOUNT

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords,  @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									
								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

			 end

			if @Attribuut like 'Aanhef persoonskaart wijkt af van geslacht persoonskaart%'
					begin
						delete from [Datakwaliteit].[RealisatieDetails] where convert(date,Laaddatum) = convert(date,@Laaddatum) and fk_indicator_id = @fk_indicator_id and fk_indicatordimensie_id = @fk_indicatordimensie_id;
								;
							SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails verwijderd: ' + format(@@ROWCOUNT, 'N0');
							EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

						delete from [Datakwaliteit].[Realisatie] where convert(date,Laaddatum) = convert(date,@Laaddatum) and fk_indicator_id = @fk_indicator_id and fk_indicatordimensie_id = @fk_indicatordimensie_id;
								;
							SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie verwijderd: ' + format(@@ROWCOUNT, 'N0');
							EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

						insert into Datakwaliteit.RealisatieDetails ( Klantnr, Laaddatum, fk_indicator_id , fk_indicatordimensie_id, Omschrijving)
								SELECT Klantnr = CUS.[No_]			
										  ,@Laaddatum
										  ,@fk_indicator_id
										  ,@fk_indicatordimensie_id
											,[Opmerking] = [staedion_dm].[Datakwaliteit].[fn_check_aanhef](HH_KAART.No_ ) 
											--,[Huishoudenkaart] = CUS.[Contact No_] 
											--,[Persoonskaart] =  P_KAART.No_
											--,[Rolcode persoonskaart] = ROL.[Role Code]
								FROM empire_data.dbo.Customer AS CUS
										LEFT OUTER JOIN empire_data.dbo.[contact_role] AS ROL
											ON CUS.[Contact No_] = ROL.[Related Contact No_]
								LEFT OUTER JOIN empire_data.dbo.[contact] AS P_KAART
											ON P_KAART.No_ = ROL.[Contact No_]
								LEFT OUTER JOIN empire_data.dbo.[contact] AS HH_KAART
											ON HH_KAART.No_ = CUS.[Contact No_]
								WHERE [staedion_dm].[Datakwaliteit].[fn_check_aanhef](HH_KAART.No_ ) is not null
								and ( CUS.No_ IN (SELECT Klantnr FROM staedion_dm.[Datakwaliteit].[SetHuurdersTeChecken] ) 
								--or  @FilterActieveHuurder = 'Nee'
								)
								;

								SET @AantalRecords = @@ROWCOUNT

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords,  @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									
								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

					end

		set		@finish = current_timestamp


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
