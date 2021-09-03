SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  procedure [Datakwaliteit].[sp_accuratesse] 
				(@Laaddatum as date = null, 
				 @Entiteit as nvarchar(50) = 'Relaties',
				 @Attribuut as nvarchar(255) = 'Huishoudenkaart.email 1',
				 @FilterActieveHuurder AS nvarchar(10) = 'Nee',
				 @fk_indicatordimensie_id as int = 19)  -- accuratesse  

				 
as
/* ###################################################################################################
BETREFT     : Procedure die door attributen in Datakwaliteit.Indicator aangeroepen kan worden om [Datakwaliteit].Details mee te vullen mbt check op accuratesse (emailadressen)
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
20201028 JvdW Aangemaakt

------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
EXEC [Datakwaliteit].[sp_accuratesse] @Laaddatum = '20201028', @Entiteit = 'Relaties', @Attribuut = 'Huishoudenkaart.email 1',  @FilterActieveHuurder = 'Ja'
select * from staedion_dm.Datakwaliteit.RealisatieDetails where fk_indicator_id = 6001
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
		declare @VersieNr NVARCHAR(80) = ' - Versie 1 20201028 JvdW'	;
		set @LogboekTekst = @LogboekTekst + OBJECT_NAME(@@PROCID) + @VersieNr;
		declare @Bericht NVARCHAR(255)
		declare @parent_id int;
		declare @fk_indicator_id int;

		select @parent_id = id from staedion_Dm.Datakwaliteit.Indicator where Omschrijving = @Entiteit;
		select @fk_indicator_id = id from staedion_Dm.Datakwaliteit.Indicator where parent_id = @parent_id and  bron_database = @Attribuut; 

		PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - BEGIN';
		PRINT convert(VARCHAR(20), getdate(), 121) + ' @fk_indicator = '+coalesce(format(@fk_indicator_id,'N0' ),'GEEN !') +  ' - @fkparent_id = ' + coalesce(format(@parent_id,'N0'),'GEEN !');

		set	@start =current_timestamp;
	
		if @Laaddatum is null
			select @Laaddatum = datum from empire_Dwh.dbo.tijd where last_loading_day =1;

		PRINT convert(VARCHAR(20), getdate(), 121) + + ' @Laaddatum = '+format(@Laaddatum,'dd-MM-yy' );


		if @fk_indicator_id is null	
			select Attribuut = @attribuut, Teller = @Teller, Noemer = @Noemer, Laaddatum = @Laaddatum 

		if @fk_indicator_id is not null	
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
							   ,Omschrijving = 'Foutief email - '+ CUS.[Contact No_] + ' - ' + 
									CASE @Attribuut 
										WHEN 'Huishoudenkaart.email 1' THEN + CUS.[Contact No_] + ' - ' + HH_KAART.[E-mail]
										WHEN 'Huishoudenkaart.email 2' THEN + CUS.[Contact No_] + ' - ' + HH_KAART.[E-mail 2]
										WHEN 'Huishoudenkaart.email 3' THEN + CUS.[Contact No_] + ' - ' + HH_KAART.[E-mail 3]
										WHEN 'Huishoudenkaart.email 4' THEN + CUS.[Contact No_] + ' - ' + HH_KAART.[E-mail 4]
										WHEN 'Huishoudenkaart.email 5' THEN + CUS.[Contact No_] + ' - ' + HH_KAART.[E-mail 5]
										WHEN 'Persoonskaart.email 1' THEN + CUS.[Contact No_] + ' - ' + P_KAART.[E-mail]
										WHEN 'Persoonskaart.email 2' THEN + CUS.[Contact No_] + ' - ' + P_KAART.[E-mail 2]
										WHEN 'Persoonskaart.email 3' THEN + CUS.[Contact No_] + ' - ' + P_KAART.[E-mail 3]
										WHEN 'Persoonskaart.email 4' THEN + CUS.[Contact No_] + ' - ' + P_KAART.[E-mail 4]
										WHEN 'Persoonskaart.email 5' THEN + CUS.[Contact No_] + ' - ' + P_KAART.[E-mail 5] end
						FROM empire_data.dbo.Customer AS CUS
								LEFT OUTER JOIN empire_data.dbo.[contact_role] AS ROL
							   ON CUS.[Contact No_] = ROL.[Related Contact No_]
						LEFT OUTER JOIN empire_data.dbo.[contact] AS P_KAART
							   ON P_KAART.No_ = ROL.[Contact No_]
						LEFT OUTER JOIN empire_data.dbo.[contact] AS HH_KAART
							   ON HH_KAART.No_ = CUS.[Contact No_]
						WHERE ( CUS.No_ IN (SELECT Klantnr FROM staedion_dm.[Datakwaliteit].[SetHuurdersTeChecken] )
									OR nullif(@FilterActieveHuurder,'Nee') IS null
								)
						and		(
								 (staedion_dm.[Datakwaliteit].[fn_check_emailadres] (HH_KAART.[E-mail]) = 0 AND @Attribuut =  'Huishoudenkaart.email 1' ) --  HH_KAART.[E-mail]
						OR		 (staedion_dm.[Datakwaliteit].[fn_check_emailadres] (HH_KAART.[E-mail 2]) = 0 AND @Attribuut =  'Huishoudenkaart.email 2' ) --  HH_KAART.[E-mail 2]
						OR		 (staedion_dm.[Datakwaliteit].[fn_check_emailadres] (HH_KAART.[E-mail 3]) = 0 AND @Attribuut =  'Huishoudenkaart.email 3' ) --  HH_KAART.[E-mail 3]
						OR		 (staedion_dm.[Datakwaliteit].[fn_check_emailadres] (HH_KAART.[E-mail 4]) = 0 AND @Attribuut =  'Huishoudenkaart.email 4' ) --  HH_KAART.[E-mail 4]
						OR		 (staedion_dm.[Datakwaliteit].[fn_check_emailadres] (HH_KAART.[E-mail 5]) = 0 AND @Attribuut =  'Huishoudenkaart.email 5' ) --  HH_KAART.[E-mail 5]
						OR		 (staedion_dm.[Datakwaliteit].[fn_check_emailadres] (P_KAART.[E-mail]) = 0 AND @Attribuut =  'Persoonskaart.email 1' ) --  P_KAART.[E-mail]
						OR		 (staedion_dm.[Datakwaliteit].[fn_check_emailadres] (P_KAART.[E-mail 2]) = 0 AND @Attribuut =  'Persoonskaart.email 2' ) --  P_KAART.[E-mail 2]
						OR		 (staedion_dm.[Datakwaliteit].[fn_check_emailadres] (P_KAART.[E-mail 3]) = 0 AND @Attribuut =  'Persoonskaart.email 3' ) --  P_KAART.[E-mail 3]
						OR		 (staedion_dm.[Datakwaliteit].[fn_check_emailadres] (P_KAART.[E-mail 4]) = 0 AND @Attribuut =  'Persoonskaart.email 4' ) --  P_KAART.[E-mail 4]
						OR		 (staedion_dm.[Datakwaliteit].[fn_check_emailadres] (P_KAART.[E-mail 5]) = 0 AND @Attribuut =  'Persoonskaart.email 5' ) --  P_KAART.[E-mail 5]	
								)

						SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatiedetails toegevoegd: ' + format(@@ROWCOUNT, 'N0');
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
