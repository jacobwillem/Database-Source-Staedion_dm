SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [Datakwaliteit].[sp_overig] 
				(@Laaddatum as date = null, 
				 @Entiteit as nvarchar(50) = 'Proces Huuraanpassing',
				 @Attribuut as nvarchar(255) = 'Vinkje beeindigd contractregel',
				 @fk_indicatordimensie_id as int = 21)  -- overig  
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
20210623 Versie 16 JvdW 
	exec [Datakwaliteit].[sp_overig] null, 'Contracten','Leegstandsregel ten onrechte niet verwijderd?'	-- 3008
20210818 Versie 17 JvdW - aanpassing
	exec  [staedion_dm].[Datakwaliteit].[sp_overig]  @Attribuut = 'Afwijking in aanvangsdatum huurcontract'	 -- 3006
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
		declare @fk_indicator_id int;
		DECLARE @AantalRecords int;

		select @parent_id = id from staedion_Dm.Datakwaliteit.Indicator where Omschrijving = @Entiteit;
		select @fk_indicator_id = id from staedion_Dm.Datakwaliteit.Indicator WHERE parent_id = @parent_id and Omschrijving = @Attribuut; 
		select @fk_indicatordimensie_id = fk_indicatordimensie_id from staedion_Dm.Datakwaliteit.Indicator where parent_id = @parent_id and Omschrijving = @Attribuut; 

		PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - BEGIN';
		PRINT convert(VARCHAR(20), getdate(), 121) + ' @Entiteit = '+@Entiteit + ' -  attribuut = ' + @attribuut;
		PRINT convert(VARCHAR(20), getdate(), 121) + ' @parent_id = '+coalesce(format(@parent_id,'N0' ),'GEEN !');
		PRINT convert(VARCHAR(20), getdate(), 121) + ' @fk_indicator = '+coalesce(format(@fk_indicator_id,'N0' ),'GEEN !');
		PRINT convert(VARCHAR(20), getdate(), 121) + ' @fk_indicatordimensie_id = '+coalesce(format(@fk_indicatordimensie_id,'N0' ),'GEEN !');

		set	@start =current_timestamp;
	
		if @Laaddatum is null
			select @Laaddatum = datum from empire_Dwh.dbo.tijd where last_loading_day =1;

		PRINT convert(VARCHAR(20), getdate(), 121) + + ' @Laaddatum = '+format(@Laaddatum,'dd-MM-yy' );


		if @fk_indicator_id is null	
			select Attribuut = @attribuut, Teller = @Teller, Noemer = @Noemer, Laaddatum = @Laaddatum 

		if @fk_indicator_id is not null	
			begin 
				delete from [Datakwaliteit].[RealisatieDetails] where convert(date,Laaddatum) = convert(date,@Laaddatum) and fk_indicator_id = @fk_indicator_id ;--and (fk_indicatordimensie_id = @fk_indicatordimensie_id OR @fk_indicatordimensie_id IS NULL);
								;
				SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails verwijderd: ' + format(@@ROWCOUNT, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

				delete from [Datakwaliteit].[Realisatie] where convert(date,Laaddatum) = convert(date,@Laaddatum) and fk_indicator_id = @fk_indicator_id ;--and (fk_indicatordimensie_id = @fk_indicatordimensie_id OR @fk_indicatordimensie_id IS NULL);
								;
				SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie verwijderd: ' + format(@@ROWCOUNT, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
--------------------------------------------------------------------------------------------------------------
				if @Attribuut = 'Vinkje beeindigd contractregel'
					begin
							insert into Datakwaliteit.RealisatieDetails (Eenheidnr, Klantnr, Omschrijving, datIngang, datEinde, Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select Eenheidnr, Klantnr, Omschrijving, datIngang, datEinde ,@Laaddatum, @fk_indicator_id, @fk_indicatordimensie_id
								FROM staedion_dm.[Datakwaliteit].[ITVF_check_status_contracten_datum_geprolongeerd TEST] () 
								WHERE [Einddatum contractregel] IS NOT NULL

								SET @AantalRecords = @@ROWCOUNT

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords,  @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									
								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
					end
--------------------------------------------------------------------------------------------------------------
				if @Attribuut = 'Ontbrekende datum in exploitatie wel contractregel'
					begin
							insert into Datakwaliteit.RealisatieDetails (Eenheidnr, Teller, Waarde, Omschrijving,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select Eenheidnr,  1,1, Opmerking,  @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									FROM staedion_dm.[Datakwaliteit].[OntbrekendeDatumInExploitatie]

								SET @AantalRecords = @@ROWCOUNT

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords,  @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									
								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

					end
--------------------------------------------------------------------------------------------------------------
				if @Attribuut = 'Ontbrekende datum in exploitatie wel prolongatie'
					begin
							insert into Datakwaliteit.RealisatieDetails (Eenheidnr, Teller, Waarde, Omschrijving,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select Eenheidnr,  1,1, 
											  Omschrijving = 'Datum eerste nota: '+ format([Datum eerste nota], 'd') + ' - Assetmanager = '+ Assetmanager + ' - Huurder = ' + Huurder
												,  @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									FROM staedion_dm.Datakwaliteit.ProlongatieZonderExploitatiedatum

								SET @AantalRecords = @@ROWCOUNT

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords,  @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									
								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

					end

--------------------------------------------------------------------------------------------------------------
				if @Attribuut = 'Ontbrekende kale huur'	

					begin
							insert into Datakwaliteit.RealisatieDetails (Eenheidnr,  Klantnr, Teller, Waarde, Omschrijving,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select Eenheidnr,  Huurdernr,
												1,1, 
											  Omschrijving = 'Brutohuur: '+ format(Brutohuur, 'N2') + ' - korting: '+ format(Korting, 'N2') + ' - Assetmanager = '+ Assetmanager 
																				+ ' - type eenheid = ' + [Type eenheid] + '- hvhbeleid: ' + Huurverhogingsbeleidstype + ' - huurder: '+ Huurder
												,  @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									-- select distinct [Type eenheid] 
									-- select *
									FROM staedion_dm.[Datakwaliteit].OntbrekendeKalehuur
									where [Type eenheid]  not in ('Uitgegeven grond','Scootmobielstalling')

								SET @AantalRecords = @@ROWCOUNT

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords,  @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									
								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

					end

--------------------------------------------------------------------------------------------------------------
				if @Attribuut = 'Afwijkende prijzen service-abonnement'
					begin
							insert into Datakwaliteit.RealisatieDetails (Eenheidnr, Teller, Waarde, Klantnr,  Omschrijving ,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								SELECT Eenheidnr
											 ,1 
											 ,2
											 ,Huurdernr
											 ,Omschrijving = Toelichting 
															+ ' - elementnr: ' +  Elementnr 
															+ ' - bedrag: '  + format([Bedrag],'N2' ) 
															+ ' - ingangsdatum: '+ format(Ingangsdatum, 'dd-MM-yyyy')

											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
											 -- select  *
								FROM staedion_dm.Datakwaliteit.vw_CheckServiceAbonnementPrijzen
								-- Toevoeging ovv Marieke 23-12-2020
								where not ( Elementnr in ('413','415') and Bedrag = 0)
								;
								SET @AantalRecords = @@ROWCOUNT

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords,  @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									
								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
																	
					end
--------------------------------------------------------------------------------------------------------------
				if @Attribuut = 'Klantkaart met meerdere "Toon als eerste"'
					begin
							insert into Datakwaliteit.RealisatieDetails ( Klantnr, Teller, Waarde, Omschrijving ,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id, Hyperlink)
								SELECT Klantnr
											 ,1
											 ,1
											 ,Omschrijving = Onderwerp
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
											 ,Hyperlink
								FROM staedion_dm.[Datakwaliteit].[FoutieveKlantkaartToonAlsEerste]
								;
								SET @AantalRecords = @@ROWCount;

								insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
								;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;		
																					
					end
--------------------------------------------------------------------------------------------------------------
				if @Attribuut = 'Medewerker uit dienst + lopend leefbaarheidsdossier'
					begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving , Teller, Waarde, Laaddatum, fk_indicator_id , fk_indicatordimensie_id, fk_leefbaarheidsdossier_id, fk_medewerker_id, Hyperlink)
								SELECT Omschrijving = BRON.Leefbaarheidsdossier + '; ' + coalesce(BRON.[Naam behandelend medewerker],'?') + '; '+ coalesce(BRON.Omschrijving,'?')
											 ,1
											 ,1
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
											 ,Leefbaarheidsdossier
											 ,[Behandelend medewerker]
											 ,null -- eventueel later toe te voegen
								FROM empire_dwh.dbo.ITVF_check_medewerkers_leefbaarheid () as BRON;

								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;																	
					end
--------------------------------------------------------------------------------------------------------------
		if @Attribuut = 'Medewerker uit dienst + vermelding contactkaart'
					begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id, Hyperlink)
								SELECT Omschrijving = BRON.[Cluster/Eenheidnr] + '; ' + coalesce(BRON.[Naam medewerker],'?') + '; '+ coalesce(BRON.Functienaam,'?')
											 ,1
											 ,1
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
											 ,null -- eventueel later toe te voegen
											 -- select *
								FROM empire_Dwh.dbo.[ITVF_check_medewerkers_contactbeheer_uit_dienst] () as BRON;

								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;	

					end
--------------------------------------------------------------------------------------------------------------
			if @Attribuut = 'Eenheid niet opgenomen in KVS-cluster of juist wel terwijl Staedion niet eigenaar is'
					begin
							; with cte_jur as (select JUR.[Realty Object No_] as eenheidnr, iif(JUR.[Type] = 0, 'Beheerder', 'Eigenaar') functie, Eigenaar =  NAAM.[Name], JUR.[Start Date], volgnr =  row_number() OVER (PARTITION BY JUR.[Realty Object No_] ORDER BY JUR.[Start Date] desc)
								from empire_data.dbo.Staedion$Realty_Object_Owner_Supervisor AS JUR
								left outer join empire_data.dbo.Contact AS NAAM
								on JUR.[Owner] = NAAM.[No_]
								where JUR.[Type] in (1)
								AND JUR.[Start Date] <=getdate()
								) 
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id, Hyperlink,Eenheidnr)
								SELECT Omschrijving =  'Eenheid wel opgenomen in KVS-cluster maar juridisch eigenaar = ' + JUR.Eigenaar 
										+ ' ; corpodatatype = ' + BASIS.[Corpodatatype] + ' ; exploitatiedatum = ' + format(BASIS.[Datum in exploitatie],'dd-MM-yyyy')
											 ,1
											 ,1
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
											 ,null -- eventueel later toe te voegen
											 ,BASIS.Eenheidnr
											 -- select *
								FROM   empire_dwh.dbo.[ITVF_verdeelsleutels](DEFAULT, 'GEWOGEN') AS BASIS
								JOIN   cte_jur AS JUR
								ON     JUR.eenheidnr = BASIS.Eenheidnr
								AND    JUR.volgnr = 1
								where  BASIS.[Corpodatatype] like '%WON%'
								and	   BASIS.[KVS_Cluster] is not NULL
								UNION
								SELECT Omschrijving = 'Eenheid niet opgenomen in KVS-cluster en juridisch eigenaar = Staedion' 
										+ ' ; corpodatatype = ' + BASIS.[Corpodatatype] + ' ; exploitatiedatum = '  + format(BASIS.[Datum in exploitatie],'dd-MM-yyyy')
											 ,1
											 ,1
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
											 ,null -- eventueel later toe te voegen
											 ,BASIS.Eenheidnr
											 -- select *
								FROM   empire_dwh.dbo.[ITVF_verdeelsleutels](DEFAULT, 'GEWOGEN') AS BASIS
								where  BASIS.[Corpodatatype] like '%WON%'
								and	   BASIS.[KVS_Cluster] is NULL
								AND     BASIS.Eenheidnr NOT  IN (SELECT eenheidnr FROM cte_jur AS JUR WHERE volgnr = 1)
								;
								
								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
					end
--------------------------------------------------------------------------------------------------------------
			if @Attribuut = 'Controle verdeelsleutel woningen'
					begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id, Eenheidnr, Hyperlink)
								SELECT Omschrijving = 'Corpodatatype = ' + [Corpodatatype] +
															case when coalesce(Verdeelsleutel_FT_cluster,0) > 2 then ' Verdeelsleutel FT: ' + format(coalesce(Verdeelsleutel_FT_cluster,0),'N1') else '' end +
															case when coalesce(Verdeelsleutel_BB_cluster,0) > 2 then ' Verdeelsleutel BB: ' + format(coalesce(Verdeelsleutel_BB_cluster,0),'N1') else '' end +
															case when coalesce(Verdeelsleutel_KVS_cluster,0) > 2 then ' Verdeelsleutel KVS ' + format(coalesce(Verdeelsleutel_KVS_cluster,0),'N1') else ''  end
											 ,1
											 ,1
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
											 ,Eenheidnr
											 ,null -- eventueel later toe te voegen
											 -- select top 10 [Corpodatatype], 
								FROM    backup_empire_dwh.dbo.[ITVF_verdeelsleutels](DEFAULT, 'GEWOGEN') as BASIS
								where  [Corpodatatype] like '%WON%'
								and		 (coalesce(Verdeelsleutel_KVS_cluster,0) > 2
														OR coalesce(Verdeelsleutel_FT_cluster,0) > 2
														OR coalesce(Verdeelsleutel_BB_cluster,0) > 2
														)
								
								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
					end
--------------------------------------------------------------------------------------------------------------
			if @Attribuut = 'Controle verdeelsleutel parkeerplaatsen'
					begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id,Eenheidnr, Hyperlink)
								SELECT Omschrijving = 'Corpodatatype = ' + [Corpodatatype] +
															case when coalesce(Verdeelsleutel_FT_cluster,0) > 0.1 then ' Verdeelsleutel FT: ' + format(BASIS.Verdeelsleutel_FT_cluster,'N1') else '' end +
															case when coalesce(Verdeelsleutel_BB_cluster,0) > 0.1 then ' Verdeelsleutel BB: ' + format(BASIS.Verdeelsleutel_BB_cluster,'N1') else '' end +
															case when coalesce(Verdeelsleutel_KVS_cluster,0) > 0.1 then ' Verdeelsleutel KVS ' + format(BASIS.Verdeelsleutel_KVS_cluster,'N1') else '' end
											 ,1
											 ,1
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
											 ,Eenheidnr
											 ,null -- eventueel later toe te voegen
											 -- select top 10 *
								FROM    backup_empire_dwh.dbo.[ITVF_verdeelsleutels](DEFAULT, 'GEWOGEN') as BASIS
								where  [Corpodatatype] = 'PP'
								and		 (coalesce(Verdeelsleutel_KVS_cluster,0) > 0.1
														OR coalesce(Verdeelsleutel_FT_cluster,0) > 0.1
														OR coalesce(Verdeelsleutel_BB_cluster,0) > 0.1
														)
								
								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
					end
--------------------------------------------------------------------------------------------------------------
			if @Attribuut = 'Controle verdeelsleutel overig'
					begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id, Eenheidnr, Hyperlink)
								SELECT Omschrijving = 'Corpodatatype = ' + [Corpodatatype] +  ' - ' + TechnischType +
															case when coalesce(Verdeelsleutel_FT_cluster,0) <> 0 then ' Verdeelsleutel FT: ' + format(BASIS.Verdeelsleutel_FT_cluster,'N1') else '' end +
															case when coalesce(Verdeelsleutel_BB_cluster,0) <> 0 then ' Verdeelsleutel BB: ' + format(BASIS.Verdeelsleutel_BB_cluster,'N1') else '' end +
															case when coalesce(Verdeelsleutel_KVS_cluster,0) <> 0 then ' Verdeelsleutel KVS ' + format(BASIS.Verdeelsleutel_KVS_cluster,'N1') else '' end
											 ,1
											 ,1
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
											 ,Eenheidnr
											 ,null -- eventueel later toe te voegen
											 -- select top 10 *
								FROM    backup_empire_dwh.dbo.[ITVF_verdeelsleutels](DEFAULT, 'GEWOGEN') as BASIS
								where  [Corpodatatype]= 'OVERIG'
												AND (
															 TechnischType = 'Telefonieruimte'
															 OR TechnischType = 'Algemene ruimte'
															 OR TechnischType = 'Scootmobielstalling'
															 )
								and		 (coalesce(Verdeelsleutel_KVS_cluster,0) <> 0
														OR coalesce(Verdeelsleutel_BB_cluster,0) <> 0
														OR coalesce(Verdeelsleutel_FT_cluster,0) <> 0
														)
								
		
								
								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
					end
--------------------------------------------------------------------------------------------------------------
			if @Attribuut = 'Wellicht toch een geliberaliseerd contract ?'
					begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id, Eenheidnr, Hyperlink)
								SELECT Omschrijving =  ' Ingangsdatum: ' + format(Ingangsdatum,'dd-MM-yyyy') +
															' Kalehuur ingangsdatum: ' + format([Kalehuur ingangsdatum],'N1') +
															' Huurprijsliberalisatie Empire: ' + format(Geliberaliseerd,'N0') +
															' Liberalisatiegrens: ' + format([Grenswaarde liberalisatie],'N1') + 
															' Huurverhogingsbeleidstype: ' + [Huurverhogingsbeleidstype] + 
															' Indexcode contractregel: ' + [Indexcode contractregel] 
											 ,1
											 ,1
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
											 ,Eenheidnr
											 ,null -- eventueel later toe te voegen
											 -- select top 1000 *
									from [Datakwaliteit].[CheckGeliberaliseerdeContracten]
								where  (Geliberaliseerd = 0
								AND [Kalehuur ingangsdatum] > [Grenswaarde liberalisatie])
								or [Controle-bevinding] = 'Afwijkend'
		
								
								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
					end
--------------------------------------------------------------------------------------------------------------
			if @Attribuut = 'Afwijking in aanvangsdatum huurcontract'
					begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id, Eenheidnr, Klantnr)
								--SELECT Omschrijving =  ' Ingangsdatum huurcontractgeg.: ' + format([Ingangsdatum tabel huurcontractgegevens],'dd-MM-yyyy') +
								--							' Eerste ingangsdatum contractregels.: ' + format([Eerste ingangsdatum tabel contract],'dd-MM-yyyy') 
								--			 ,1
								--			 ,1
								--			 ,@Laaddatum
								--			 ,@fk_indicator_id
								--			 ,@fk_indicatordimensie_id
								--			 ,Eenheidnr
								--			 ,[Huurder tabel contract]								-- select *
								--from empire_Dwh.dbo.[ITVF_check_ingangsdata_huurcontract] (null,null, 1) 
								--where [Einddatum tabel huurcontractgegevens] is null 
								--and [Conversie-eenheid] is null
								--;
									SELECT Omschrijving =  ' Ingangsdatum huurcontractgeg.: ' + format(BASIS.[Ingangsdatum tabel huurcontractgegevens],'dd-MM-yyyy') 
																+ ';' + 
																' Eerste ingangsdatum contractregels.: ' + format(BASIS.[Eerste ingangsdatum tabel contract],'dd-MM-yyyy') 
																+ ';' + 
																' Cluster: ' + CLUS.Clusternr 
																+ ';' + 							
																' Generieke kenmerk: '+ coalesce(BASIS.[Reden afwijking],'nvt')
													 ,1
													 ,1
													 ,@Laaddatum
													 ,@fk_indicator_id
													 ,@fk_indicatordimensie_id
													,BASIS.Eenheidnr
													,BASIS.[Huurder tabel contract]
									from	staedion_dm.Contracten.[fn_ControleIngangsdataHuurcontract] (null,null,1) as BASIS
									outer apply empire_Staedion_data.dbo.ITVfnCLusterBouwblok(BASIS.Eenheidnr) as CLUS
									where [Einddatum tabel huurcontractgegevens] is null 
									--and [Conversie-eenheid] is null

								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
					end
--------------------------------------------------------------------------------------------------------------
			if @Attribuut = 'Vinkje geliberaliseerd aan en uit op 1 contract ?'	
					begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id, Eenheidnr, Klantnr)
								SELECT Omschrijving =  ' Eenheidnr = ' + Eenheidnr +
															' Huurdernr = ' + Huurdernr +
															' (Einddatum contract: ' + convert(nvarchar(20), [einddatum contract] ,105) + ')'
											 ,1
											 ,1
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
											 ,Eenheidnr
											 ,Huurdernr
								-- select *
								from staedion_dm.Datakwaliteit.CheckVinkjeGeliberaliseerdDubbel
								order by coalesce([einddatum contract], '20990101') desc
								;

								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
					end
--------------------------------------------------------------------------------------------------------------
			if @Attribuut = 'Contact geslacht = aanhef ?'	 -- 6015

					begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Klantnr,Laaddatum,fk_indicator_id,fk_indicatordimensie_id)
								SELECT Omschrijving =  ' Aanhefcode contact = ' + BASIS.[Contact Aanhefcode] +
															' Geslacht contact = ' + BASIS.[Contact Geslacht]  + 
															' Contactkaart = ' + BASIS.[Contact Nummer]   
											 ,1
											 ,1
											 ,BASIS.[Klant Nummer]
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
					from		staedion_dm.Datakwaliteit.fnContactGegevens() as BASIS
					-- 	,[Contact Afwijking] = IIF(IIF(contact.No_ IS NULL, NULL, IIF(contact.[Salutation Code] = 'DHR', IIF(contact.[Geslacht] = 1, 0, 1), 0) + IIF(contact.[Salutation Code] = 'MEVR', IIF(contact.[Geslacht] = 2, 0, 1), 0) + IIF(contact.[Salutation Code] NOT IN ('DHR','MEVR'), IIF(contact.[Geslacht] = 0, 0, 1), 0)) > 0, 'Ja', 'Nee')
					where BASIS.[Contact Afwijking] = 'Ja' and BASIS.[Contract Actief] = 'Ja'
								;

								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
					end
--------------------------------------------------------------------------------------------------------------
			if @Attribuut = 'Huishouden geslacht = aanhef ?' -- 6016

					begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Klantnr,Laaddatum,fk_indicator_id,fk_indicatordimensie_id)
								SELECT Omschrijving =  ' Aanhefcode huishouden = ' + BASIS.[Huishouden Aanhefcode] +
															' Geslacht contact = ' + BASIS.[Huishouden Geslacht]  + 
															' Huishoudkaart = ' + BASIS.[Huishouden Nummer]   
											 ,1
											 ,1
											 ,BASIS.[Klant Nummer]
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
					from		staedion_dm.Datakwaliteit.fnContactGegevens() as BASIS
					-- 	[Huishouden Afwijking] = IIF(IIF(huishouden.No_ IS NULL, NULL, IIF(huishouden.[Salutation Code] = 'DHR', IIF(huishouden.[Geslacht] = 1, 0, 1), 0) + IIF(huishouden.[Salutation Code] = 'MEVR', IIF(huishouden.[Geslacht] = 2, 0, 1), 0) + IIF(huishouden.[Salutation Code] NOT IN ('DHR','MEVR'), IIF(huishouden.[Geslacht] = 0, 0, 1), 0)) > 0, 'Ja', 'Nee')
					where BASIS.[Huishouden Afwijking] = 'Ja' and BASIS.[Contract Actief] = 'Ja'
								;

								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

							insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
					end
--------------------------------------------------------------------------------------------------------------
			if @Attribuut = 'Contact initialen ok ?'		 -- 6018	

					begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Klantnr,Laaddatum,fk_indicator_id,fk_indicatordimensie_id)
								SELECT Omschrijving =  ' Initialen contactkaart = ' + BASIS.[Contact Initialen]  + 
															' Contactkaart = ' + BASIS.[Contact Nummer]   
											 ,1
											 ,1
											 ,BASIS.[Klant Nummer]
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
					from		staedion_dm.Datakwaliteit.fnContactGegevens() as BASIS
					/*			[Contact Initialen Afwijking] =IIF(
									contact.Initials NOT LIKE '%Th%' 
								AND contact.Initials NOT LIKE '%Ch%'
								AND contact.Initials NOT LIKE '%IJ%'
								AND contact.Initials NOT LIKE '%Ph%',

								IIF(
									LEN(contact.Initials)-(LEN(contact.Initials) - 
									LEN(REPLACE(contact.Initials, '.', ''))
								) <>
									LEN(contact.Initials) - LEN(REPLACE(contact.Initials, '.', '')),
								'Ja', 
								IIF(contact.Initials COLLATE Latin1_General_CS_AI <> UPPER(contact.Initials), 'Ja', 'Nee')
								),
								'Nee'
								)
								*/
					where BASIS.[Contact Initialen Afwijking] = 'Ja' and BASIS.[Contract Actief] = 'Ja'
								;

								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

								insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
					end

--------------------------------------------------------------------------------------------------------------
			if @Attribuut = 'Huishouden initialen ok ?'		 -- 6019

					begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Klantnr,Laaddatum,fk_indicator_id,fk_indicatordimensie_id)
								SELECT Omschrijving =  ' Initialen contactkaart = ' + BASIS.[Huishouden Initialen]  + 
															' Huishoudkaart = ' + BASIS.[Huishouden Nummer]   
											 ,1
											 ,1
											 ,BASIS.[Klant Nummer]
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
					from		staedion_dm.Datakwaliteit.fnContactGegevens() as BASIS
								/*[Huishouden Initialen Afwijking] =IIF(
											huishouden.Initials NOT LIKE '%Th%' 
										AND huishouden.Initials NOT LIKE '%Ch%'
										AND huishouden.Initials NOT LIKE '%IJ%'
										AND huishouden.Initials NOT LIKE '%Ph%',

										IIF(
											LEN(huishouden.Initials)-(LEN(huishouden.Initials) - 
											LEN(REPLACE(huishouden.Initials, '.', ''))
										) <>
											LEN(huishouden.Initials) - LEN(REPLACE(huishouden.Initials, '.', '')),
										'Ja', 
										IIF(huishouden.Initials COLLATE Latin1_General_CS_AI <> UPPER(huishouden.Initials), 'Ja', 'Nee')
										),
										'Nee'
										)
								*/
					where BASIS.[Huishouden Initialen Afwijking] = 'Ja' and BASIS.[Contract Actief] = 'Ja'
								;

								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

								insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
					end

--------------------------------------------------------------------------------------------------------------
			if @Attribuut = 'Contact achternaam ok ?'		 -- 6020	

					begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Klantnr,Laaddatum,fk_indicator_id,fk_indicatordimensie_id)
								SELECT Omschrijving =  ' Voorletters contactkaart = ' + BASIS.[Contact Initialen]  + 
															' Tussenvoegsels contactkaart = ' + BASIS.[Contact Tussenvoegsels] +  
															' Achternaam contactkaart = ' + BASIS.[Contact Achternaam] +  															
															' Naam contactkaart = ' + BASIS.[Contact Naam] +
															' Contactkaart = ' + BASIS.[Contact Nummer]   
											 ,1
											 ,1
											 ,BASIS.[Klant Nummer]
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
					from		staedion_dm.Datakwaliteit.fnContactGegevens() as BASIS
					where		(BASIS.[Contact Achternaam Hoofdletter Afwijking] = 'Ja' or BASIS.[Contact Achternaam Naam Afwijking] = 'Ja') and BASIS.[Contract Actief] = 'Ja'
								;

								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

								insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
					end

--------------------------------------------------------------------------------------------------------------
			if @Attribuut = 'Huishouden achternaam ok ?'	 -- 6021

					begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Klantnr,Laaddatum,fk_indicator_id,fk_indicatordimensie_id)
								SELECT Omschrijving =  ' Voorletters contactkaart = ' + BASIS.[Huishouden Initialen]  + 
															' Tussenvoegsels contactkaart = ' + BASIS.[Huishouden Tussenvoegsels] +  
															' Achternaam contactkaart = ' + BASIS.[Huishouden Achternaam] +  															
															' Naam contactkaart = ' + BASIS.[Huishouden Naam] +
															' Contactkaart = ' + BASIS.[Huishouden Nummer]   
											 ,1
											 ,1
											 ,BASIS.[Klant Nummer]
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
					from		staedion_dm.Datakwaliteit.fnContactGegevens() as BASIS
					where		(BASIS.[Huishouden Achternaam Hoofdletter Afwijking] = 'Ja' or BASIS.[Huishouden Achternaam Naam Afwijking] = 'Ja') and BASIS.[Contract Actief] = 'Ja'
				
								;

								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

								insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
					end
--------------------------------------------------------------------------------------------------------------
			if @Attribuut ='Correspondentietype'	 -- 6022
			   begin

					EXEC staedion_dm.[Datakwaliteit].[sp_genereer_set_actieve_huurders] -- verwijst naar [fn_HuurderFilter]
					-- 38.828
					;WITH cte_actieve_huurderset
					AS (
						SELECT *
						FROM staedion_dm.Datakwaliteit.SetHuurdersTeChecken
						)
					SELECT CTE.*
						,Correspondentietype = CASE CONT.[correspondence type]
						WHEN 0 THEN 'Leeg'
						WHEN 1 THEN 'Afdruk'
						WHEN 2 THEN 'E-mail'
						WHEN 3 THEN 'Fax' end
 						,[Emailadressen] = [E-mail] + '|'+[E-mail 2] --+ '|'+[E-mail 3]+ '|'+[E-mail 4]+ '|'+[E-mail 5]
						,[Fout emailadres Ja/Nee] = CASE WHEN CONT.[E-mail] <> '' AND staedion_dm.[Datakwaliteit].[fn_check_emailadres] (CONT.[E-mail])= 0 THEN 'Ja' 
													ELSE CASE WHEN CONT.[E-mail 2] <> '' AND staedion_dm.[Datakwaliteit].[fn_check_emailadres] (CONT.[E-mail 2])= 0 THEN 'Ja' 
													---ELSE CASE WHEN CONT.[E-mail 3] <> '' AND staedion_dm.[Datakwaliteit].[fn_check_emailadres] (CONT.[E-mail 3])= 0 THEN 'Ja' 
													--ELSE CASE WHEN CONT.[E-mail 4] <> '' AND staedion_dm.[Datakwaliteit].[fn_check_emailadres] (CONT.[E-mail 4])= 0 THEN 'Ja' 
													--ELSE CASE WHEN CONT.[E-mail 5] <> '' AND staedion_dm.[Datakwaliteit].[fn_check_emailadres] (CONT.[E-mail 5])= 0 THEN 'Ja' 
														ELSE 'Nee' END END 			
					INTO #Details6022
					FROM cte_actieve_huurderset  AS CTE
					LEFT OUTER JOIN  empire_data.dbo.Contact AS CONT 
					ON CTE.Huishoudnr = CONT.No_
					;

						begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Klantnr,Laaddatum,fk_indicator_id,fk_indicatordimensie_id)
								SELECT Omschrijving =  ' Klantnr = ' + BASIS.Klantnr  + 
															' Huishoudnr = ' + BASIS.Huishoudnr +  
															' Correspondentietype = ' + BASIS.Correspondentietype +  															
															' Email(adressen) = ' + BASIS.[Emailadressen]    
											 ,1
											 ,1
											 ,BASIS.Klantnr
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,19 -- @fk_indicatordimensie_id = accuratesse
								from	#Details6022 AS BASIS
								WHERE	Correspondentietype = 'E-mail' AND [Fout emailadres Ja/Nee] = 'Ja'
								;
								SET @AantalRecords = @@ROWCount
								;
								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

								insert into Datakwaliteit.Realisatie (Waarde, Teller, Noemer, Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @AantalRecords, (select count(*) from #Details6022), @Laaddatum , @fk_indicator_id, 19 -- @fk_indicatordimensie_id = accuratesse
								;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
						END
	
						begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Klantnr,Laaddatum,fk_indicator_id,fk_indicatordimensie_id)
								SELECT Omschrijving =  ' Klantnr = ' + BASIS.Klantnr  + 
															' Huishoudnr = ' + BASIS.Huishoudnr +  
															' Correspondentietype = ' + BASIS.Correspondentietype +  															
															' Email(adressen) = ' + BASIS.[Emailadressen]    
											 ,1
											 ,1
											 ,BASIS.Klantnr
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,20 -- @fk_indicatordimensie_id = consistentie
								from	#Details6022 AS BASIS
								WHERE Correspondentietype = 'E-mail' AND [Emailadressen] = '|'
								;
								SET @AantalRecords = @@ROWCount
								;
								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

								insert into Datakwaliteit.Realisatie (Waarde,  Teller, Noemer, Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords,@AantalRecords,(select count(*) from #Details6022), @Laaddatum , @fk_indicator_id, 20 -- @fk_indicatordimensie_id = consistentie
								;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
						END

						begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Noemer,Klantnr,  Laaddatum,fk_indicator_id,fk_indicatordimensie_id)
								SELECT Omschrijving =  ' Klantnr = ' + BASIS.Klantnr  + 
															' Huishoudnr = ' + BASIS.Huishoudnr +  
															' Correspondentietype = ' + BASIS.Correspondentietype +  															
															' Email(adressen) = ' + BASIS.[Emailadressen]    
											 ,1
											 ,1
											 ,BASIS.Klantnr
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,15 -- @fk_indicatordimensie_id = volledigheid
								from	#Details6022 AS BASIS
								WHERE Correspondentietype = 'Leeg'
								;
								SET @AantalRecords = @@ROWCount
								;
								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

								insert into Datakwaliteit.Realisatie (Waarde, teller, noemer, Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select SUM(IIF(Correspondentietype = 'Leeg',1,0)),SUM(IIF(Correspondentietype = 'Leeg',1,0)), COUNT(*) 
											,@Laaddatum , @fk_indicator_id, 15 -- @fk_indicatordimensie_id = volledigheid
								from	#Details6022 AS BASIS
								;

								SET @bericht = 'Attribuut '+ @Attribuut + ' - Realisatie toegevoegd: ' + format(@@ROWCOUNT, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;													
						END
				 end
--------------------------------------------------------------------------------------------------------------
			if @Attribuut ='Leegstandsregel ten onrechte niet verwijderd?'	 -- 3008

					begin
							insert into Datakwaliteit.RealisatieDetails ( Omschrijving ,Teller, Waarde,  Klantnr,Laaddatum,fk_indicator_id,fk_indicatordimensie_id)
								SELECT Omschrijving =  ' Eenheidnr = ' + BASIS.Eenheidnr  + 
															' Toekomstige leegstandsregel aangemaakt op = ' + convert(nvarchar(20),BASIS.[Toekomstige leegstandsregel aangemaakt op],105) +  
															' Toekomstige leegstandsregel ingangsdatum = ' + convert(nvarchar(20),BASIS.[Toekomstige leegstandsregel ingangsdatum],105) +  	
															' Huidige huuurder = ' + BASIS.[Huidige huurder]   
											 ,1
											 ,1
											 ,BASIS.[Huidige huurder]
											 ,@Laaddatum
											 ,@fk_indicator_id
											 ,@fk_indicatordimensie_id
								-- select top 10 *
								from		staedion_dm.Datakwaliteit.CheckContractenLeegstandAangemaaktOp as BASIS
				
								;

								SET @AantalRecords = @@ROWCount

								SET @bericht = 'Attribuut '+ @Attribuut + ' - RealisatieDetails toegevoegd: ' + format(@AantalRecords, 'N0');
								EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

								insert into Datakwaliteit.Realisatie (Waarde,  Laaddatum, fk_indicator_id , fk_indicatordimensie_id)
								select @AantalRecords, @Laaddatum , @fk_indicator_id, @fk_indicatordimensie_id
									;

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
