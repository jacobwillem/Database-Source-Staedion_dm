SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Cartotheek].[sp_load_pbi_Openverbrandingstoestellen] 
AS
/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Procedure die ....
	   '
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Cartotheek'
       ,@level1type = N'PROCEDURE'
       ,@level1name = 'sp_load_pbi_Openverbrandingstoestellen';
GO
exec staedion_dm.[DatabaseBeheer].[sp_info_object_en_velden] 'staedion_dm', 'Cartotheek','sp_load_pbi_Openverbrandingstoestellen'
GO
--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20211228 JvdW aangemaakt nav Topdesk + empire_stedion_logic.dbo.dsp_load_f_cartotheek_OVT

--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
exec staedion_dm.[Cartotheek].[sp_load_pbi_Openverbrandingstoestellen]

SELECT count(*),count(distinct Eenheidnr) FROM Cartotheek.Openverbrandingstoestellen;
sELECT count(*),count(distinct Eenheidnr) from ##EenhedenSet;
SELECT count(*),count(distinct Eenheidnr) FROM staedion_dm.Cartotheek.vw_Openverbrandingstoestellen
SELECT count(*),count(distinct Eenheidnr) FROM  [Cartotheek].[vw_Openverbrandingstoestellen_Volledigheid]
select [Categorie OVT], [rekenregel], count(distinct Eenheidnr) from [Cartotheek].[vw_Openverbrandingstoestellen_Volledigheid] group by  [Categorie OVT], [rekenregel] order by  [Categorie OVT], [rekenregel]

SELECT * FROM staedion_dm.Cartotheek.vw_Openverbrandingstoestellen where Eenheidnr = 'OGEH-0062916'
SELECT	[Categorie OVT],count(*) 
-- select *
FROM	staedion_dm.Cartotheek.Openverbrandingstoestellen 
where [cartotheek-item] like '%565651%' 
and  [Categorie OVT] = 'Potentieel OVT'
group by [Categorie OVT]
Warm water niet via ketel of anderszins => Potentieel OVT
511650 Warm water niet via ketel of anderszins => Potentieel OVT
515360 Onbekend type => Potentieel OVT


-- logging van procedures
SELECT * FROM staedion_dm.databasebeheer.LoggingUitvoeringDatabaseObjecten where Databaseobject like '%sp_load_pbi_Openverbrandingstoestelle%' ORDER BY begintijd desc


--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE + TESTEN: zie onderaan
--------------------------------------------------------------------------------------------------------------------------------


############################################################################################################################# */

BEGIN TRY

	SET NOCOUNT ON;
	DECLARE @Onderwerp AS NVARCHAR(255);
	DECLARE @_Bron nvarchar(100) =  OBJECT_NAME(@@PROCID);
	DECLARE @AantalRecords DECIMAL(12, 0);
	declare @start as datetime
	declare @finish as datetime

	set	@start = current_timestamp
	-----------------------------------------------------------------------------------
	set @onderwerp = 'Backup vullen empire_staedion_data.bak.Openverbrandingstoestellen';
	----------------------------------------------------------------------------------- 
	DROP TABLE IF EXISTS empire_staedion_data.bak.Openverbrandingstoestellen;
	SELECT * INTO empire_staedion_data.bak.Openverbrandingstoestellen FROM staedion_dm.Cartotheek.Openverbrandingstoestellen;

	SET @AantalRecords = @@rowcount;
	set @Onderwerp = 'Stap: ' + @Onderwerp + ' - records: ' + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = 'Dataset rapport laden'
					,@DatabaseObject = @_Bron
					,@Variabelen = null
					,@Bericht = @onderwerp
					,@WegschrijvenOfNiet = 1

	-----------------------------------------------------------------------------------
	set @onderwerp = 'Wissen gegevens';
	----------------------------------------------------------------------------------- 
	TRUNCATE TABLE Cartotheek.Openverbrandingstoestellen;

	-----------------------------------------------------------------------------------
	set @onderwerp = 'Welke eenheden nemen we in beschouwing: ##EenhedenSet';
	----------------------------------------------------------------------------------- 
	DROP TABLE IF EXISTS ##EenhedenSet;

	SELECT  eenheidnr , [bouwjaar]
	INTO ##EenhedenSet
	-- select distinct status_eenheidskaart
	FROM empire_Staedion_data.dbo.els
	WHERE datum_gegenereerd = (select max(datum_gegenereerd) from  empire_Staedion_data.dbo.els where datum_gegenereerd < getdate()) 
	AND corpodata_type LIKE '%WON%'
	AND [In Exploitatie] = 'Ja'
	;
	SET @AantalRecords = @@rowcount;
	set @Onderwerp = 'Stap: ' + @Onderwerp + ' - records: ' + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = 'Dataset rapport laden'
					,@DatabaseObject = @_Bron
					,@Variabelen = null
					,@Bericht = @onderwerp
					,@WegschrijvenOfNiet = 1

	CREATE INDEX i_eenhedenset ON ##EenhedenSet (Eenheidnr) 
	;

	-----------------------------------------------------------------------------------
	set @onderwerp = 'Bepaalde clusters eruit halen (data in Collectieve objecten)';
	----------------------------------------------------------------------------------- 
	DROP TABLE IF EXISTS ##ClusterEenhedenSet;

	SELECT  eenheidnr , [bouwjaar]
	INTO ##ClusterEenhedenSet
	-- select distinct status_eenheidskaart
	FROM empire_Staedion_data.dbo.els
	WHERE datum_gegenereerd = (select max(datum_gegenereerd) from  empire_Staedion_data.dbo.els where datum_gegenereerd < getdate()) 
	AND corpodata_type LIKE '%WON%'
	AND [In Exploitatie] = 'Ja'
	AND clusternummer IN ('FT-1486', 'FT-1171')
	;
	SET @AantalRecords = @@rowcount;
	set @Onderwerp = 'Stap: ' + @Onderwerp + ' - records: ' + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = 'Dataset rapport laden'
					,@DatabaseObject = @_Bron
					,@Variabelen = null
					,@Bericht = @onderwerp
					,@WegschrijvenOfNiet = 1

	CREATE INDEX i_eenhedenset ON ##ClusterEenhedenSet (Eenheidnr) 
	;

	-----------------------------------------------------------------------------------
	set @onderwerp = 'Bepaalde clusters eruit halen (recent bouwjaar of nog in ontwikkeling)';
	----------------------------------------------------------------------------------- 
	DROP TABLE IF EXISTS ##BouwjaarEenhedenSet;

	SELECT  eenheidnr , [bouwjaar]
	INTO ##BouwjaarEenhedenSet
	-- select distinct status_eenheidskaart
	FROM empire_Staedion_data.dbo.els
	WHERE datum_gegenereerd = (select max(datum_gegenereerd) from  empire_Staedion_data.dbo.els where datum_gegenereerd < getdate()) 
	AND corpodata_type LIKE '%WON%'
	AND [In Exploitatie] = 'Ja'
	AND (COALESCE(NULLIF([bouwjaar],''),0) > 2014
	OR	status_eenheidskaart = 'In ontwikkeling')
	;
	SET @AantalRecords = @@rowcount;
	set @Onderwerp = 'Stap: ' + @Onderwerp + ' - records: ' + format(@AantalRecords, 'N0');
		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = 'Dataset rapport laden'
					,@DatabaseObject = @_Bron
					,@Variabelen = null
					,@Bericht = @onderwerp
					,@WegschrijvenOfNiet = 1

	CREATE INDEX i_eenhedenset ON ##BouwjaarEenhedenSet (Eenheidnr) 
	;
	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Vullen Cartotheek.Openverbrandingstoestellen - Bouwjaar te recent of eenheid nog in ontwikkeling';
	----------------------------------------------------------------------------------- 
		insert into		Cartotheek.Openverbrandingstoestellen
						(Sleutel
						,Eenheidnr
						,Datum
						,[Cartotheek-item]
						,[Cartotheek-item-omschrijving]
						,[Categorie OVT]
						,[Aanwezig]
						,[Rekenregel])
		select			'OVT|'+E.bk_nr_	
						,E.bk_nr_
						,CAST(GETDATE() AS DATE)
						,CI.bk_code + ' '+ CI.Descr -- F.fk_cartotheekitem_id
						,CIT.descr ---F.fk_cartotheekitemtype_id
						,'Geen OVT' 
						,F.aanwezig		
						,'Geen OVT want bouwjaar na 2014'
		-- select E.bk_nr_
		from			empire_dwh.dbo.f_cartotheek			as F
		join			empire_dwh.dbo.eenheid				as E
		on				E.id = F.fk_eenheid_id
		join			empire_dwh.dbo.cartotheekitem		as CI	
		on				CI.id = F.fk_cartotheekitem_id
		join			empire_dwh.dbo.cartotheekitemtype	as CIT
		on				CIT.id = F.fk_cartotheekitemtype_id
		join			empire_staedion_data.sharepoint.Cartotheek_OVT as DIM
		on				DIM.cartotheekitem_bk_Code = CI.bk_code 
		and				DIM.Hoofdgroep = CI.hoofdgroep
		and				DIM.aanwezig = F.aanwezig 
		where			E.bk_nr_ in (select Eenheidnr from ##BouwjaarEenhedenSet)

		SET @AantalRecords = @@rowcount;
		set @onderwerp = 'Stap: ' + @Onderwerp + ' - records: ' + format(@AantalRecords, 'N0');
			EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
						@Categorie = 'Dataset rapport laden'
						,@DatabaseObject = @_Bron
						,@Variabelen = null
						,@Bericht = @onderwerp
						,@WegschrijvenOfNiet = 1


	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Vullen Cartotheek.Openverbrandingstoestellen - Rekenregel =  Keukengeiser met of zonder aanduiding gesloten => Geen of OVT';
	----------------------------------------------------------------------------------- 
		insert into		Cartotheek.Openverbrandingstoestellen
						(Sleutel
						,Eenheidnr
						,Datum
						,[Cartotheek-item]
						,[Cartotheek-item-omschrijving]
						,[Categorie OVT]
						,[Aanwezig]
						,[Rekenregel])
		select			'OVT|'+E.bk_nr_	
						,E.bk_nr_
						,CAST(GETDATE() AS DATE)
						,CI.bk_code + ' '+ CI.Descr -- F.fk_cartotheekitem_id
						,CIT.descr ---F.fk_cartotheekitemtype_id
						,'Geen OVT' 
						,F.aanwezig		
						,'Geen OVT want dat geeft collectief object aan'
		-- select E.bk_nr_
		from			empire_dwh.dbo.f_cartotheek			as F
		join			empire_dwh.dbo.eenheid				as E
		on				E.id = F.fk_eenheid_id
		join			empire_dwh.dbo.cartotheekitem		as CI	
		on				CI.id = F.fk_cartotheekitem_id
		join			empire_dwh.dbo.cartotheekitemtype	as CIT
		on				CIT.id = F.fk_cartotheekitemtype_id
		join			empire_staedion_data.sharepoint.Cartotheek_OVT as DIM
		on				DIM.cartotheekitem_bk_Code = CI.bk_code 
		and				DIM.Hoofdgroep = CI.hoofdgroep
		and				DIM.aanwezig = F.aanwezig 
		where			E.bk_nr_ in (select Eenheidnr from ##ClusterEenhedenSet)
		and				E.bk_nr_ NOT IN (select Eenheidnr from ##BouwjaarEenhedenSet)

		SET @AantalRecords = @@rowcount;
		set @onderwerp = 'Stap: ' + @Onderwerp + ' - records: ' + format(@AantalRecords, 'N0');
			EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
						@Categorie = 'Dataset rapport laden'
						,@DatabaseObject = @_Bron
						,@Variabelen = null
						,@Bericht = @onderwerp
						,@WegschrijvenOfNiet = 1

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Vullen Cartotheek.Openverbrandingstoestellen - Rekenregel =  Keukengeiser met of zonder aanduiding gesloten => Geen of OVT';
	----------------------------------------------------------------------------------- 
		insert into		Cartotheek.Openverbrandingstoestellen
						(Sleutel
						,Eenheidnr
						,Datum
						,[Cartotheek-item]
						,[Cartotheek-item-omschrijving]
						,[Categorie OVT]
						,[Aanwezig]
						,[Rekenregel])
		select			'OVT|'+E.bk_nr_	
						,E.bk_nr_
						,CAST(GETDATE() AS DATE)
						,CI.bk_code + ' '+ CI.Descr -- F.fk_cartotheekitem_id
						,CIT.descr ---F.fk_cartotheekitemtype_id
						,case when UPPER(CIT.descr) like '%GESLOTE%'			
							then 'Geen OVT' 
							else 'OVT'
						  end							
						,F.aanwezig		
						,REK.rekenregel
		-- select E.bk_nr_
		from			empire_dwh.dbo.f_cartotheek			as F
		join			empire_dwh.dbo.eenheid				as E
		on				E.id = F.fk_eenheid_id
		join			empire_dwh.dbo.cartotheekitem		as CI	
		on				CI.id = F.fk_cartotheekitem_id
		join			empire_dwh.dbo.cartotheekitemtype	as CIT
		on				CIT.id = F.fk_cartotheekitemtype_id
		join			empire_staedion_data.sharepoint.Cartotheek_OVT as DIM
		on				DIM.cartotheekitem_bk_Code = CI.bk_code 
		and				DIM.Hoofdgroep = CI.hoofdgroep
		and				DIM.aanwezig = F.aanwezig 
		join			empire_staedion_Data.sharepoint.cartotheek_OVT_rekenregel as REK
		on				REK.id = DIM.fk_rekenregel_OVT_id
		and				REK.rekenregel = 'Keukengeiser met of zonder aanduiding gesloten => Geen of OVT' 
		where			CI.hoofdgroep in ('Warm Water','Verwarming')
		and				E.bk_nr_ in (select Eenheidnr from ##EenhedenSet)
		AND				E.bk_nr_ NOT IN (select Eenheidnr from ##ClusterEenhedenSet)
		and				E.bk_nr_ NOT IN (select Eenheidnr from ##BouwjaarEenhedenSet)

		SET @AantalRecords = @@rowcount;
		set @onderwerp = 'Stap: ' + @Onderwerp + ' - records: ' + format(@AantalRecords, 'N0');
			EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
						@Categorie = 'Dataset rapport laden'
						,@DatabaseObject = @_Bron
						,@Variabelen = null
						,@Bericht = @onderwerp
						,@WegschrijvenOfNiet = 1

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Vullen Cartotheek.Openverbrandingstoestellen - Rekenregel = Opgegeven item, afhankelijk van omschrijving type => Geen, Potentieel of OVT';
	----------------------------------------------------------------------------------- 
		insert into		Cartotheek.Openverbrandingstoestellen
						(Sleutel
						,Eenheidnr
						,Datum
						,[Cartotheek-item]
						,[Cartotheek-item-omschrijving]
						,[Categorie OVT]
						,[Aanwezig]
						,[Rekenregel])
		select			'OVT|'+E.bk_nr_	
						,E.bk_nr_
						,CAST(GETDATE() AS DATE)
						,CI.bk_code + ' '+ CI.Descr -- F.fk_cartotheekitem_id
						,CIT.descr ---F.fk_cartotheekitemtype_id
						,case when UPPER(CIT.descr) like '%GESLOTE%'			
							then 'Geen OVT' 
						  when upper(CIT.descr) like '%OPEN%'
							then 'OVT'
						  else 'Potentieel OVT'
						  end								
						,F.aanwezig		
						,REK.rekenregel
		from			empire_dwh.dbo.f_cartotheek			as F
		join			empire_dwh.dbo.eenheid				as E
		on				E.id = F.fk_eenheid_id
		join			empire_dwh.dbo.cartotheekitem		as CI	
		on				CI.id = F.fk_cartotheekitem_id
		join			empire_dwh.dbo.cartotheekitemtype	as CIT
		on				CIT.id = F.fk_cartotheekitemtype_id
		join			empire_staedion_data.sharepoint.Cartotheek_OVT as DIM
		on				DIM.cartotheekitem_bk_Code = CI.bk_code 
		and				DIM.Hoofdgroep = CI.hoofdgroep
		and				DIM.aanwezig = F.aanwezig 
		join			empire_staedion_Data.sharepoint.cartotheek_OVT_rekenregel as REK
		on				REK.id = DIM.fk_rekenregel_OVT_id
		and				REK.rekenregel = 'Opgegeven item, afhankelijk van omschrijving type => Geen, Potentieel of OVT'
		where			CI.hoofdgroep in ('Warm Water','Verwarming')
		and				E.bk_nr_ in (select Eenheidnr from ##EenhedenSet)
		AND				E.bk_nr_ NOT IN (select Eenheidnr from ##ClusterEenhedenSet)
		and				E.bk_nr_ NOT IN (select Eenheidnr from ##BouwjaarEenhedenSet)


		SET @AantalRecords = @@rowcount;
		set @onderwerp = 'Stap: ' + @Onderwerp + ' - records: ' + format(@AantalRecords, 'N0');
			EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
						@Categorie = 'Dataset rapport laden'
						,@DatabaseObject = @_Bron
						,@Variabelen = null
						,@Bericht = @onderwerp
						,@WegschrijvenOfNiet = 1

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Vullen Cartotheek.Openverbrandingstoestellen - Rekenregel = Wel keukengeizer maar niet aanwezig => Geen OVT';
	----------------------------------------------------------------------------------- 
		insert into		Cartotheek.Openverbrandingstoestellen
						(Sleutel
						,Eenheidnr
						,Datum
						,[Cartotheek-item]
						,[Cartotheek-item-omschrijving]
						,[Categorie OVT]
						,[Aanwezig]
						,[Rekenregel])
		select			'OVT|'+E.bk_nr_	
						,E.bk_nr_
						,CAST(GETDATE() AS DATE)
						,CI.bk_code + ' '+ CI.Descr -- F.fk_cartotheekitem_id
						,CIT.descr ---F.fk_cartotheekitemtype_id
						,'Geen OVT' 						
						,F.aanwezig		
						,REK.rekenregel
		-- select count(*)
		from			empire_dwh.dbo.f_cartotheek			as F
		join			empire_dwh.dbo.eenheid				as E
		on				E.id = F.fk_eenheid_id
		join			empire_dwh.dbo.cartotheekitem		as CI	
		on				CI.id = F.fk_cartotheekitem_id
		join			empire_dwh.dbo.cartotheekitemtype	as CIT
		on				CIT.id = F.fk_cartotheekitemtype_id
		join			empire_staedion_data.sharepoint.Cartotheek_OVT as DIM
		on				DIM.cartotheekitem_bk_Code = CI.bk_code 
		and				DIM.Hoofdgroep = CI.hoofdgroep
		and				DIM.aanwezig = F.aanwezig 
		join			empire_staedion_Data.sharepoint.cartotheek_OVT_rekenregel as REK
		on				REK.id = DIM.fk_rekenregel_OVT_id
		and				REK.rekenregel = 'Wel keukengeizer maar niet aanwezig => Geen OVT'
		where			CI.hoofdgroep in ('Warm Water','Verwarming')
		and				E.bk_nr_ in (select Eenheidnr from ##EenhedenSet)
		AND				E.bk_nr_ NOT IN (select Eenheidnr from ##ClusterEenhedenSet)
		and				E.bk_nr_ NOT IN (select Eenheidnr from ##BouwjaarEenhedenSet)


			SET @AantalRecords = @@rowcount;
			set @onderwerp = 'Stap: ' + @Onderwerp + ' - records: ' + format(@AantalRecords, 'N0');
				EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
							@Categorie = 'Dataset rapport laden'
							,@DatabaseObject = @_Bron
							,@Variabelen = null
							,@Bericht = @onderwerp
							,@WegschrijvenOfNiet = 1

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Vullen Cartotheek.Openverbrandingstoestellen - Rekenregel = Opgegeven item => Geen OVT';
	----------------------------------------------------------------------------------- 
		insert into		Cartotheek.Openverbrandingstoestellen
						(Sleutel
						,Eenheidnr
						,Datum
						,[Cartotheek-item]
						,[Cartotheek-item-omschrijving]
						,[Categorie OVT]
						,[Aanwezig]
						,[Rekenregel])
		select			'OVT|'+E.bk_nr_	
						,E.bk_nr_
						,CAST(GETDATE() AS DATE)
						,CI.bk_code + ' '+ CI.Descr -- F.fk_cartotheekitem_id
						,CIT.descr ---F.fk_cartotheekitemtype_id
						,'Geen OVT' 						
						,F.aanwezig		
						,REK.rekenregel
		from			empire_dwh.dbo.f_cartotheek			as F
		join			empire_dwh.dbo.eenheid				as E
		on				E.id = F.fk_eenheid_id
		join			empire_dwh.dbo.cartotheekitem		as CI	
		on				CI.id = F.fk_cartotheekitem_id
		join			empire_dwh.dbo.cartotheekitemtype	as CIT
		on				CIT.id = F.fk_cartotheekitemtype_id
		join			empire_staedion_data.sharepoint.Cartotheek_OVT as DIM
		on				DIM.cartotheekitem_bk_Code = CI.bk_code 
		and				DIM.Hoofdgroep = CI.hoofdgroep
		and				DIM.aanwezig = F.aanwezig 
		join			empire_staedion_Data.sharepoint.cartotheek_OVT_rekenregel as REK
		on				REK.id = DIM.fk_rekenregel_OVT_id
		and				REK.rekenregel = 'Opgegeven item => Geen OVT'
		where			CI.hoofdgroep in ('Warm Water','Verwarming')
		and				E.bk_nr_ in (select Eenheidnr from ##EenhedenSet)
		AND				E.bk_nr_ NOT IN (select Eenheidnr from ##ClusterEenhedenSet)
		and				E.bk_nr_ NOT IN (select Eenheidnr from ##BouwjaarEenhedenSet)


			SET @AantalRecords = @@rowcount;
			set @onderwerp = 'Stap: ' + @Onderwerp + ' - records: ' + format(@AantalRecords, 'N0');
				EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
							@Categorie = 'Dataset rapport laden'
							,@DatabaseObject = @_Bron
							,@Variabelen = null
							,@Bericht = @onderwerp
							,@WegschrijvenOfNiet = 1

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Vullen Cartotheek.Openverbrandingstoestellen - Rekenregel = Onbekend type => Potentieel OVT';
	----------------------------------------------------------------------------------- 
		insert into		Cartotheek.Openverbrandingstoestellen
						(Sleutel
						,Eenheidnr
						,Datum
						,[Cartotheek-item]
						,[Cartotheek-item-omschrijving]
						,[Categorie OVT]
						,[Aanwezig]
						,[Rekenregel])
		select			'OVT|'+E.bk_nr_	
						,E.bk_nr_
						,CAST(GETDATE() AS DATE)
						,CI.bk_code + ' '+ CI.Descr -- F.fk_cartotheekitem_id
						,CIT.descr ---F.fk_cartotheekitemtype_id
						,'Potentieel OVT'						
						,F.aanwezig		
						,REK.rekenregel
		from			empire_dwh.dbo.f_cartotheek			as F
		join			empire_dwh.dbo.eenheid				as E
		on				E.id = F.fk_eenheid_id
		join			empire_dwh.dbo.cartotheekitem		as CI	
		on				CI.id = F.fk_cartotheekitem_id
		join			empire_dwh.dbo.cartotheekitemtype	as CIT
		on				CIT.id = F.fk_cartotheekitemtype_id
		join			empire_staedion_data.sharepoint.Cartotheek_OVT as DIM
		on				DIM.cartotheekitem_bk_Code = CI.bk_code 
		and				DIM.Hoofdgroep = CI.hoofdgroep
		and				DIM.aanwezig = F.aanwezig 
		join			empire_staedion_Data.sharepoint.cartotheek_OVT_rekenregel as REK
		on				REK.id = DIM.fk_rekenregel_OVT_id
		and				(REK.rekenregel = 'Onbekend type => Potentieel OVT'
		or				REK.rekenregel = ''	
		or				REK.rekenregel is null)
		where			CI.hoofdgroep in ('Warm Water','Verwarming')
		and				E.bk_nr_ in (select Eenheidnr from ##EenhedenSet)
		AND				E.bk_nr_ NOT IN (select Eenheidnr from ##ClusterEenhedenSet)
		and				E.bk_nr_ NOT IN (select Eenheidnr from ##BouwjaarEenhedenSet)


			SET @AantalRecords = @@rowcount;
			set @onderwerp = 'Stap: ' + @Onderwerp + ' - records: ' + format(@AantalRecords, 'N0');
				EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
							@Categorie = 'Dataset rapport laden'
							,@DatabaseObject = @_Bron
							,@Variabelen = null
							,@Bericht = @onderwerp
							,@WegschrijvenOfNiet = 1

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Vullen Cartotheek.Openverbrandingstoestellen - Rekenregel: Warm water via ketel => Geen OVT';
	----------------------------------------------------------------------------------- 
		insert into		Cartotheek.Openverbrandingstoestellen
						(Sleutel
						,Eenheidnr
						,Datum
						,[Cartotheek-item]
						,[Cartotheek-item-omschrijving]
						,[Categorie OVT]
						,[Aanwezig]
						,[Rekenregel])
		select			'OVT|'+E.bk_nr_	
						,E.bk_nr_
						,CAST(GETDATE() AS DATE)
						,CI.bk_code + ' '+ CI.Descr -- F.fk_cartotheekitem_id
						,CIT.descr ---F.fk_cartotheekitemtype_id
						,'Geen OVT'						
						,F.aanwezig		
						,'Warm water via ketel => Geen OVT'
		-- select count(*)
		from			empire_dwh.dbo.f_cartotheek			as F
		join			empire_dwh.dbo.eenheid				as E
		on				E.id = F.fk_eenheid_id
		join			empire_dwh.dbo.cartotheekitem		as CI	
		on				CI.id = F.fk_cartotheekitem_id
		join			empire_dwh.dbo.cartotheekitemtype	as CIT
		on				CIT.id = F.fk_cartotheekitemtype_id
		where			E.id <> -1
		and				CI.hoofdgroep = 'Verwarming'
		and				F.gebruikersveld_2 = 'Ja'						-- Warm water via Ketel = Ja
		and				F.aanwezig = 'Aanwezig'
		and				E.bk_nr_ in (select Eenheidnr from ##EenhedenSet)
		AND				E.bk_nr_ NOT IN (select Eenheidnr from ##ClusterEenhedenSet)
		and				E.bk_nr_ NOT IN (select Eenheidnr from ##BouwjaarEenhedenSet)
		--AND				E.bk_nr_ = 'OGEH-0051677'


			SET @AantalRecords = @@rowcount;
			set @onderwerp = 'Stap: ' + @Onderwerp + ' - records: ' + format(@AantalRecords, 'N0');
				EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
							@Categorie = 'Dataset rapport laden'
							,@DatabaseObject = @_Bron
							,@Variabelen = null
							,@Bericht = @onderwerp
							,@WegschrijvenOfNiet = 1

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Vullen Cartotheek.Openverbrandingstoestellen - Opgegeven type = OVT';
	----------------------------------------------------------------------------------- 
		insert into		Cartotheek.Openverbrandingstoestellen
						(Sleutel
						,Eenheidnr
						,Datum
						,[Cartotheek-item]
						,[Cartotheek-item-omschrijving]
						,[Categorie OVT]
						,[Aanwezig]
						,[Rekenregel])
		select			'OVT|'+E.bk_nr_	
						,E.bk_nr_
						,CAST(GETDATE() AS DATE)
						,CI.bk_code + ' '+ CI.Descr -- F.fk_cartotheekitem_id
						,CIT.descr ---F.fk_cartotheekitemtype_id
						,'OVT'						
						,F.aanwezig		
						,REK.rekenregel
		from			empire_dwh.dbo.f_cartotheek			as F
		join			empire_dwh.dbo.eenheid				as E
		on				E.id = F.fk_eenheid_id
		join			empire_dwh.dbo.cartotheekitem		as CI	
		on				CI.id = F.fk_cartotheekitem_id
		join			empire_dwh.dbo.cartotheekitemtype	as CIT
		on				CIT.id = F.fk_cartotheekitemtype_id
		join			empire_staedion_data.sharepoint.Cartotheek_OVT as DIM
		on				DIM.cartotheekitem_bk_Code = CI.bk_code 
		and				DIM.Hoofdgroep = CI.hoofdgroep
		and				DIM.aanwezig = F.aanwezig 
		join			empire_staedion_Data.sharepoint.cartotheek_OVT_rekenregel as REK
		on				REK.id = DIM.fk_rekenregel_OVT_id
		and				REK.rekenregel = 'Opgegeven type = OVT'
		where			CI.hoofdgroep in ('Warm Water','Verwarming')
		and				E.bk_nr_ in (select Eenheidnr from ##EenhedenSet)
		AND				E.bk_nr_ NOT IN (select Eenheidnr from ##ClusterEenhedenSet)
		and				E.bk_nr_ NOT IN (select Eenheidnr from ##BouwjaarEenhedenSet)


			SET @AantalRecords = @@rowcount;
			set @onderwerp = 'Stap: ' + @Onderwerp + ' - records: ' + format(@AantalRecords, 'N0');
				EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
							@Categorie = 'Dataset rapport laden'
							,@DatabaseObject = @_Bron
							,@Variabelen = null
							,@Bericht = @onderwerp
							,@WegschrijvenOfNiet = 1

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Vullen Cartotheek.Openverbrandingstoestellen - Rekenregel: Warm water niet via ketel of anderszins => Potentieel OVT';
	----------------------------------------------------------------------------------- 
	--  = Stel eenheden hebben geen regel voor warm-water maar wel bij verwarming "geen vinkje bij warm water via ketel" dan is dat potentieel OVT
		insert into		Cartotheek.Openverbrandingstoestellen
						(Sleutel
						,Eenheidnr
						,Datum
						,[Cartotheek-item]
						,[Cartotheek-item-omschrijving]
						,[Categorie OVT]
						,[Aanwezig]
						,[Rekenregel])
		select			'OVT|'+E.bk_nr_	
						,E.bk_nr_
						,CAST(GETDATE() AS DATE)
						,CI.bk_code + ' '+ CI.Descr -- F.fk_cartotheekitem_id
						,CIT.descr ---F.fk_cartotheekitemtype_id
						,'Potentieel OVT'						
						,F.aanwezig		
						,'Warm water niet via ketel of anderszins => Potentieel OVT' 
		-- select distinct CI.bk_code, REK.rekenregel
		from			empire_dwh.dbo.f_cartotheek			as F
		join			empire_dwh.dbo.eenheid				as E
		on				E.id = F.fk_eenheid_id
		join			empire_dwh.dbo.cartotheekitem		as CI	
		on				CI.id = F.fk_cartotheekitem_id
		join			empire_dwh.dbo.cartotheekitemtype	as CIT
		on				CIT.id = F.fk_cartotheekitemtype_id
		join			empire_staedion_data.sharepoint.Cartotheek_OVT as DIM
		on				DIM.cartotheekitem_bk_Code = CI.bk_code 
		and				DIM.Hoofdgroep = CI.hoofdgroep
		and				DIM.aanwezig = F.aanwezig 
		join			empire_staedion_Data.sharepoint.cartotheek_OVT_rekenregel as REK
		on				REK.id = DIM.fk_rekenregel_OVT_id
		where			E.id <> -1
		and				CI.hoofdgroep = 'Verwarming'
		and				(F.gebruikersveld_2 = 'Nee'								-- Warm water via Ketel = Nee, soms niet ingevuld
		or				F.gebruikersveld_2 = '')
		and				CI.bk_code <> '510000'									-- JvdW 20200210 Catharinaland 88 is niet van toepassing via mail
		and				F.aanwezig = 'Aanwezig'
		AND				REK.Rekenregel <> 'Opgegeven item => Geen OVT'			-- JvdW 20211229 Bepaalde types zijn nu uitgesloten van deze rekenregel
		and				E.bk_nr_ in (select Eenheidnr from ##EenhedenSet)
		AND				E.bk_nr_ NOT IN (select Eenheidnr from ##ClusterEenhedenSet)
		and				E.bk_nr_ NOT IN (select Eenheidnr from ##BouwjaarEenhedenSet)
		and				E.id  not in (
							select	F1.fk_eenheid_id
							from	empire_dwh.dbo.f_cartotheek			as F1	
							join	empire_dwh.dbo.cartotheekitem		as CI1	
							on		CI1.id = F1.fk_cartotheekitem_id
							where	CI1.hoofdgroep = 'Warm water'
							and		F1.fk_eenheid_id <> -1)
		and				E.id not in (										-- Als een andere aanwezige voorziening wel warm water via ketel heeft, dan niet meenemen
							select	F3.fk_eenheid_id
							from	empire_dwh.dbo.f_cartotheek			as F3	
							join	empire_dwh.dbo.cartotheekitem		as CI3	
							on		CI3.id = F3.fk_cartotheekitem_id
							where	CI3.hoofdgroep = 'Verwarming'
							and		F3.gebruikersveld_2 = 'Ja'	
							and		F3.fk_eenheid_id <> -1
								)

			SET @AantalRecords = @@rowcount;
			set @onderwerp = 'Stap: ' + @Onderwerp + ' - records: ' + format(@AantalRecords, 'N0');
				EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
							@Categorie = 'Dataset rapport laden'
							,@DatabaseObject = @_Bron
							,@Variabelen = null
							,@Bericht = @onderwerp
							,@WegschrijvenOfNiet = 1

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Vullen Cartotheek.Openverbrandingstoestellen - Regel toevoegen voor oges met te weinig info ("Rekenregel te weinig info")';
	----------------------------------------------------------------------------------- 
		insert into		Cartotheek.Openverbrandingstoestellen
						(Sleutel
						,Eenheidnr
						,Datum
						,[Cartotheek-item]
						,[Cartotheek-item-omschrijving]
						,[Categorie OVT]
						,[Aanwezig]
						,[Rekenregel])
		select			'OVT|'+E.bk_nr_	
						,E.bk_nr_
						,CAST(GETDATE() AS DATE)
						,'Onbekend'
						,'Onbekend'
						,'Potentieel OVT'						
						,'Niet aanwezig'	
						,'Te weinig info => Potentieel OVT'
		from			empire_dwh.dbo.eenheid				as E
		where			E.id <> -1
		and				E.id not in (
							select	F1.fk_eenheid_id
							from	empire_dwh.dbo.f_cartotheek			as F1	
							join	empire_dwh.dbo.cartotheekitem		as CI	
							on		CI.id = F1.fk_cartotheekitem_id
							where	F1.fk_eenheid_id <> -1
							and		CI.hoofdgroep in ('Verwarming','Warm water')
							)
		-- JvdW 20180108 Versie 10
		and				E.bk_nr_ in (select Eenheidnr from ##EenhedenSet)
		AND				E.bk_nr_ NOT IN (select Eenheidnr from ##ClusterEenhedenSet)
		and				E.bk_nr_ NOT IN (select Eenheidnr from ##BouwjaarEenhedenSet)
		AND				E.bk_nr_ NOT IN (SELECT distinct Eenheidnr FROM Cartotheek.OpenVerbrandingsToestellen WHERE [Categorie OVT] = 'Geen OVT')


	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Vullen Cartotheek.Openverbrandingstoestellen - Staat wel in de ELS lijst, niet aangelopen in rapportage ?';
	----------------------------------------------------------------------------------- 
		insert into		Cartotheek.Openverbrandingstoestellen
						(Sleutel
						,Eenheidnr
						,Datum
						,[Cartotheek-item]
						,[Cartotheek-item-omschrijving]
						,[Categorie OVT]
						,[Aanwezig]
						,[Rekenregel])
		select			'OVT|'+E.bk_nr_	
						,E.bk_nr_
						,CAST(GETDATE() AS DATE)
						,'Onbekend'
						,'Onbekend'
						,'Potentieel OVT'						
						,'Niet aanwezig'	
						,'Staat wel in de ELS lijst, niet aangelopen in rapportage ?'
		from			empire_dwh.dbo.eenheid				as E
		where			E.id <> -1
		and				E.bk_nr_ in (select Eenheidnr from ##EenhedenSet)
		AND				E.bk_nr_ NOT IN (SELECT distinct Eenheidnr FROM Cartotheek.OpenVerbrandingsToestellen)



			SET @AantalRecords = @@rowcount;
			set @onderwerp = 'Stap: ' + @Onderwerp + ' - records: ' + format(@AantalRecords, 'N0');
				EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
							@Categorie = 'Dataset rapport laden'
							,@DatabaseObject = @_Bron
							,@Variabelen = null
							,@Bericht = @onderwerp
							,@WegschrijvenOfNiet = 1

  	PRINT convert(VARCHAR(20), getdate(), 121) + @onderwerp + ' - aantal records: ' + FORMAT(@AantalRecords,'N0')

	set	@finish = CURRENT_TIMESTAMP

		EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = 'Dataset rapport laden'
					,@Begintijd = @start
					,@Eindtijd = @finish
					,@DatabaseObject = @_Bron
					,@Variabelen = null
					,@Bericht = null
					,@WegschrijvenOfNiet = 1

END TRY
BEGIN CATCH

	set	@finish = CURRENT_TIMESTAMP
		DECLARE @_ErrorProcedure AS NVARCHAR(255) = ERROR_PROCEDURE()
		DECLARE @_ErrorLine AS INT = ERROR_LINE()
		DECLARE @_ErrorNumber AS INT = ERROR_NUMBER()
		DECLARE @_ErrorMessage AS NVARCHAR(255) = LEFT(ERROR_MESSAGE(),255)

	EXEC staedion_dm.[DatabaseBeheer].[sp_loggen_uitvoering_database_objecten]  
					@Categorie = 'Dataset rapport laden'
					,@DatabaseObject = @_Bron
					, @Variabelen = null
					, @Begintijd = @start
					, @Eindtijd = @finish
					, @ErrorProcedure =  @_ErrorProcedure
					, @ErrorLine = @_ErrorLine
					, @ErrorNumber = @_ErrorNumber
					, @ErrorMessage = @_ErrorMessage

END CATCH

;




/* ##################################################################################################################

-----------------------------------------------------------------------------------------------------------------
TESTEN
-----------------------------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------------------------
TESTEN: Detailcheck
-----------------------------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------------------------
DDL
-----------------------------------------------------------------------------------------------------------------



################################################################################################################## */
GO
