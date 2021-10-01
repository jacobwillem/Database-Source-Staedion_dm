SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  procedure [Datakwaliteit].[sp_genereer_set_actieve_huurders] @Laaddatum AS datetime = null
as
/* ###################################################################################################
BETREFT     : Procedure die bepaalt welke huurders in aanmerking komen voor check data
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
20201028 JvdW Aangemaakt

------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
exec [Datakwaliteit].[sp_genereer_set_actieve_huurders]
------------------------------------------------------------------------------------------------------
TEMP
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Datakwaliteit', 'sp_genereer_set_actieve_huurders'

################################################################################################### */	
BEGIN TRY

  -- Diverse variabelen
		set nocount on;

		declare @start as datetime;
		declare @finish as datetime;
		declare @Teller bigint;
		declare @Noemer bigint;
		DECLARE @AantalRecords int;
		declare @LogboekTekst NVARCHAR(255) = ' ### Maatwerk Staedion: staedion_dm..';
		declare @VersieNr NVARCHAR(80) = ' - Versie 4 20200720 JvdW'	;
		set @LogboekTekst = @LogboekTekst + OBJECT_NAME(@@PROCID) + @VersieNr;
		declare @Bericht NVARCHAR(255)

		PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - BEGIN';
		set	@start =current_timestamp;
	
		if @Laaddatum is null
			select @Laaddatum = datum from empire_Dwh.dbo.tijd where last_loading_day =1;

		PRINT convert(VARCHAR(20), getdate(), 121) + + ' @Laaddatum = '+format(@Laaddatum,'dd-MM-yy' );

		-- Datakwaliteit van welke huurders:
		DROP TABLE IF EXISTS Datakwaliteit.SetHuurdersTeChecken
		;
		SELECT   Klantnr, Peildatum, [Huishoudnr], [Actief huurcontract], Laaddatum = @Laaddatum
		into	 Datakwaliteit.SetHuurdersTeChecken
		FROM	[Datakwaliteit].[fn_HuurderFilter](@Laaddatum, DEFAULT)
		where	 Klantboekingsgroep = 'HUURDERS'
		and		 ([Actief huurcontract] = 1
		or		 [Saldo rekening courant] <> 0)
		;

		SET @AantalRecords = @@ROWCOUNT	
		PRINT convert(VARCHAR(20), getdate(), 121) + + ' Aantal records = '+format(@AantalRecords,'N0' );
		set		@finish = current_timestamp

		PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - EINDE';

		INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],Begintijd,Eindtijd)
			SELECT	OBJECT_NAME(@@PROCID)
							,@start
							,@finish
					
	END TRY

	BEGIN CATCH

		set		@finish = current_timestamp

		INSERT INTO empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding,ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage)
		SELECT	ERROR_PROCEDURE() 
						,getdate()
						,ERROR_PROCEDURE() 
						,ERROR_NUMBER()
						,ERROR_LINE()
						,ERROR_MESSAGE() 
		
	END CATCH


GO
