SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [Datakwaliteit].[sp_vve-cluster] (@fk_indicatordimensie_id as int = null)   
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
		DECLARE @fk_indicator_id as int = 2190
		DECLARE @Entiteit as nvarchar(50) = 'Eenheid'
	    DECLARE @Attribuut as nvarchar(255) = 'VVE-cluster'

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
				if @fk_indicatordimensie_id = 18 -- voldoet het VVE cluster aan het format VVEC-####.#
					begin
							insert into Datakwaliteit.RealisatieDetails (Eenheidnr
																		,Omschrijving
																		,Bevinding
																		,Laaddatum
																		,fk_indicator_id
																		,fk_indicatordimensie_id)

								select distinct  Eenheidnr = co_vve.Eenheidnr_
												,Omschrijving = 'VVE-cluster = ' + c_vve.Nr_
												,Bevinding = 'VVE-clusternummer voldoet niet aan het format VVEC-####.#'
												,Laaddatum = @Laaddatum
												,fk_indicator_id = @fk_indicator_id
												,fk_indicatordimensie_id = @fk_indicatordimensie_id
								from empire_data.dbo.Staedion$Cluster c_vve
								left join empire_data.dbo.Staedion$Cluster_OGE co_vve on co_vve.Clusternr_ = c_vve.Nr_
								where c_vve.Clustersoort = 'VVE' and
										case when iif(left(c_vve.Nr_, 5) = 'VVEC-', 1, 0) = 0 then 0
											 when ISNUMERIC(RIGHT(c_vve.Nr_, LEN(c_vve.Nr_) - 5)) = 0 then 0
											 when iif(RIGHT(c_vve.Nr_, LEN(c_vve.Nr_) - 5) < 10000.0, 1, 0) = 0 then 0 
											 else 1
											 end = 0
								SET @AantalRecords = @@ROWCOUNT

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords,  @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									
								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
					end

--------------------------------------------------------------------------------------------------------------
				if @fk_indicatordimensie_id = 20 -- zijn de vier cijfers van het VVE cluster gelijk aan het bouwblok
					begin
							insert into Datakwaliteit.RealisatieDetails (Eenheidnr
																		,Omschrijving
																		,Bevinding
																		,Laaddatum
																		,fk_indicator_id
																		,fk_indicatordimensie_id)

								select distinct	 Eenheidnr = co_vve.Eenheidnr_
												,Omschrijving = 'VVE-cluster = ' + c_vve.Nr_ + '; Bouwbloknummer = ' + co_bb.Clusternr_
												,Bevinding = 'Vier-cijferig VVE-clusternummer is niet gelijk aan vier-cijferig bouwbloknummer'
												,Laaddatum = @Laaddatum
												,fk_indicator_id = @fk_indicator_id
												,fk_indicatordimensie_id = @fk_indicatordimensie_id
									from empire_data.dbo.Staedion$Cluster c_vve
									left join empire_data.dbo.Staedion$Cluster_OGE co_vve on co_vve.Clusternr_ = c_vve.Nr_
									left join empire_data.dbo.Staedion$Cluster_OGE co_bb on co_bb.Eenheidnr_ = co_vve.Eenheidnr_
									where c_vve.Clustersoort = 'VVE'
									and co_bb.Clustersoort = 'BOUWBLOK'
									and c_vve.Nr_ not like 'VVEC-' + SUBSTRING(co_bb.Clusternr_, PATINDEX('%[0-9]%',co_bb.Clusternr_), 
																				PATINDEX('%[^0-9]%',SUBSTRING(co_bb.Clusternr_,
																					PATINDEX('%[0-9]%',co_bb.Clusternr_), LEN(co_bb.Clusternr_)))-1) + '.%'
									  

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
