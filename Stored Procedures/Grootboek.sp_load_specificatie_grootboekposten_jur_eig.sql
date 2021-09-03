SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Grootboek].[sp_load_specificatie_grootboekposten_jur_eig] (
	@DatumVanaf date = null,
	@DatumTotenMet date = null, 
	@Eigenaar nvarchar(100) =  'Staedion VG Holding BV',
	@Tijdelijk bit = 0
)
as
/* #################################################################################################################
VAN			Jaco
BETREFT		Ophalen grootboekposten dan wel toegerekende posten die betrekking hebben op bepaalde juridisch eigenaar + voorbereiden memoriaalboeking
ZIE			21 06 581 Automatiseren waar mogelijk - afrekening exploitatie WOM en SVGH
NB			Omwille van diverse stappen/controles: stored procedure
----------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
----------------------------------------------------------------------------------------------------------------
20210825 JvdW Script aangemaakt
20210831 JvdW Uitbreidingen
				> Datum begin jaar en einde huidige 
20210902 JvdW Memoriaal boeking toevoegen
				use staedion_dm
				go
				create table rapport.Memoriaal_Jur_Eig 
				(
				Boekdatum			date,
				[Documentnr.]		nvarchar(20),
				Rekeningsoort		nvarchar(50) default 'Grootboekrekening',
				[Rekeningnr.]		nvarchar(20),
				Kostencode			nvarchar(20) default '', 
				Omschrijving		nvarchar(50) default 'Afrekening',
				Bedrag				decimal(12,2),
				[Kostenplaats code] nvarchar(20) default '', 
				[Clusternr.]		nvarchar(20) default '', 
				[Eenheidnr.]		nvarchar(20),
				Opmerking			nvarchar(50)
				)

NOG DOEN: tijdelijk Toegerekende posten toevoegen
NOG DOEN: 1 bestand voor WOM en VG Holding + evt toevoegen
NOG DOEN: als Snapshot ELS niet beschikbaar is per @Datum-variabele, dan gaat het mis
NOG DOEN: functie voor toevoegen cluster zit er nu 2 x in
NOG DOEN: anders oplossen van harde "clusters"
NOG OVERWEGEN: breder trekken - ook bruikbaar voor andere eenheden ? - check waar afwijkingen ?


----------------------------------------------------------------------------------------------------------------
TEST
----------------------------------------------------------------------------------------------------------------
exec staedion_dm.Grootboek.[sp_load_specificatie_grootboekposten_jur_eig]
exec staedion_dm.Grootboek.[sp_load_specificatie_grootboekposten_jur_eig] @DatumVanaf = '20210101',@DatumTotenMet = '20210831' , @Eigenaar = 'Staedion VG Holding BV', @Tijdelijk = 0
exec staedion_dm.Grootboek.[sp_load_specificatie_grootboekposten_jur_eig] @Tijdelijk = 0
exec staedion_dm.Grootboek.[sp_load_specificatie_grootboekposten_jur_eig] @Eigenaar = 'WOM'

select top 100 * from empire_staedion_Data.etl.LogboekMeldingenProcedures order by Begintijd desc
----------------------------------------------------------------------------------------------------------------
PERFORMANCE
----------------------------------------------------------------------------------------------------------------
Missing Index Details from SQLQuery5.sql - s-dwh2012-db.staedion_dm (STAEDION\JVDW)
The Query Processor estimates that implementing the following index could improve the query cost by 69.8558%.
USE [staedion_dm]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Grootboek].[Grootboekposten] ([Boekdatum])
INCLUDE ([Volgnummer],[Rekening_id],[Document nr],[Dimensiewaarde 1_id],[Productboekingsgroep_id]
,[Btwproductboekingsgroep_id],[Bedrag incl. verplichting],[Btw bedrag incl. verplichting],[Gebruiker],[Bron_id],[Eenheidnr])
GO

----------------------------------------------------------------------------------------------------------------
Detailcheck
----------------------------------------------------------------------------------------------------------------
DECLARE @Nr AS BIGINT = 126290315
;
select * from ##posten1 where Volgnummer = @Nr;
select * from ##posten2 where Volgnummer = @Nr
;

with cte_eenheden_juridisch as 
(select  MW.Eenheidnr ,MW.[Administratief eigenaar],cty.Code as [Corpodata type],[FT clusternr], EIG.[FT clusternaam] ,MW.[Juridisch eigenaar], EIG.[Datum uit exploitatie]
	from staedion_dm.eenheden.Meetwaarden as MW
     JOIN staedion_dm.eenheden.Eigenschappen AS EIG ON MW.Eigenschappen_id = EIG.Eigenschappen_id
	 JOIN [staedion_dm].[Eenheden].[Technisch type] typ ON EIG.[Technisch type_id] = typ.[Technisch type_id]
	 JOIN [staedion_dm].[Eenheden].[Corpodatatype] cty ON EIG.[Corpodatatype_id] = cty.Corpodatatype_id 
	where peildatum = '20210831' 
	and [Juridisch eigenaar] =  'Staedion VG Holding BV'
	union
select  MW.Eenheidnr ,MW.[Administratief eigenaar],cty.Code as [Corpodata type],[FT clusternr], EIG.[FT clusternaam] ,MW.[Juridisch eigenaar], EIG.[Datum uit exploitatie]
	from staedion_dm.eenheden.Meetwaarden as MW
     JOIN staedion_dm.eenheden.Eigenschappen AS EIG ON MW.Eigenschappen_id = EIG.Eigenschappen_id
	 JOIN [staedion_dm].[Eenheden].[Technisch type] typ ON EIG.[Technisch type_id] = typ.[Technisch type_id]
	 JOIN [staedion_dm].[Eenheden].[Corpodatatype] cty ON EIG.[Corpodatatype_id] = cty.Corpodatatype_id 
	where peildatum = '20201231' 
	and [Juridisch eigenaar] =  'Staedion VG Holding BV'
	)

select POST.*
FROM staedion_dm.Grootboek.[Toegerekende grootboekposten HANDM]  AS POST
JOIN staedion_dm.Grootboek.Rekening AS REK ON REK.Rekening_id = POST.Rekening_id
--left outer join staedion_dm.Grootboek.Dimensiewaarden1 as DIM on DIM.[Dimensiewaarde 1_id] = POST.[Dimensiewaarde 1_id]
--left outer join staedion_dm.Grootboek.Btwproductboekingsgroep as BTW on BTW.Btwproductboekingsgroep_id = POST.Btwproductboekingsgroep_id
--left outer join staedion_dm.Grootboek.Productboekingsgroep as PROD on PROD.Productboekingsgroep_id = POST.Productboekingsgroep_id
--left outer join staedion_dm.Grootboek.Bronnen as BR on BR.Bron_id = POST.Bron_id
left outer join cte_eenheden_juridisch as CTE on CTE.Eenheidnr = POST.Eenheidnr
OUTER APPLY empire_staedion_Data.dbo.ITVfnCLusterBouwblok(POST.Eenheidnr) AS CL
--OUTER APPLY staedion_dm.[Eenheden].[fn_Eigenschappen](POST.Eenheidnr, GETDATE()) KENM
WHERE 	 POST.Boekdatum BETWEEN '20210101' and '20211231'
	and POST.Regeltype = 'Toerekening'
and [Volgnummer grootboekpost] = @Nr
;
SELECT [G_L Entry No_]
	,[G_L Account No_]
	,[Entry Type]
	,Amount
	,[Allocated Amount]
FROM empire_data.dbo.Staedion$Allocated_G_L_Entries
WHERE [G_L Entry No_] = @Nr
;
SELECT [Entry No_]
	,[G_L Account No_]
	,sum(Amount)
FROM empire_data.dbo.Staedion$G_L_Entry
WHERE [Entry No_] = @Nr
GROUP BY [Entry No_]
	,[G_L Account No_]
;
SELECT [G_L Entry No_]
	,[G_L Account No_]
	,[Entry Type]
	,Amount = sum(Amount)
	,[Allocated Amount] = sum([Allocated Amount])
FROM empire_data.dbo.Staedion$Allocated_G_L_Entries
WHERE [G_L Entry No_] = @Nr
GROUP BY [G_L Entry No_]
	,[G_L Account No_]
	,[Entry Type]
;

################################################################################################################# */


	SET NOCOUNT, XACT_ABORT ON;

BEGIN TRY

BEGIN TRANSACTION;

	-- Diverse variabelen
	declare @start as datetime
	declare @finish as datetime
	DECLARE @LogboekTekst NVARCHAR(255) = ' ### Maatwerk Staedion: ';
	DECLARE @VersieNr NVARCHAR(80) = ' - JvdW Versie 1 20210828'	;
	SET @LogboekTekst = @LogboekTekst + OBJECT_NAME(@@PROCID) + @VersieNr;
    DECLARE @Bericht NVARCHAR(255);
    DECLARE @Onderwerp NVARCHAR(100);
	DECLARE @AantalRecords DECIMAL(12, 0);
	DECLARE @Testversie bit = 1;

		PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - BEGIN (periode: ' + format(@DatumVanaf, 'dd-MM-yyyy') + ' - '+ format(@DatumTotenMet, 'dd-MM-yyyy' + ')');

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Variabelen';
	----------------------------------------------------------------------------------- 
	set	@start = current_timestamp

	-- BEGIN TRAN
	
	If @DatumVanaf is null 
		set @DatumVanaf = datefromparts(year(getdate()),1,1)

	If @DatumTotEnMet is null 
		set @DatumTotEnMet =  eomonth(getdate());

	Truncate table staedion_dm.Grootboek.Output_Specificatie_Grootboekposten_Jur_Eig_WOM;
	
	Drop table if exists ##Posten1;
	Drop table if exists ##Posten2;

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Toegerekende grootboekposten HANDM';
	----------------------------------------------------------------------------------- 
	If @Tijdelijk = 1
		begin
			drop table If Exists staedion_dm.Grootboek.[Toegerekende grootboekposten HANDM];

			SELECT [Regeltype] = CASE [Entry Type]
						WHEN 0
							THEN 'Grootboekpost'
						ELSE 'Toerekening'
						END
					,[Toegerekend bedrag] = convert(FLOAT, [Allocated Amount])
					,[Bedrag] = convert(FLOAT, [Amount])
					,Eenheidnr = [Realty Object No_]
					,Rekeningnr = [G_L Account No_]
					,[Volgnummer grootboekpost] = [G_L Entry No_]
					,[Boekdatum] = [Posting Date]
					,Kostencode = [Cost Code]
					,[Datum toerekening] = [Allocation Date]
					,Toegerekend = [Allocated]
					,[Document Nr] = [Document No_]
					,[Toegerekende postnr] = [Allocation Entry No_]
					,Bedrijf_id = convert(int,null)
					,Rekening_id = convert(int,null)
				INTo staedion_dm.Grootboek.[Toegerekende grootboekposten HANDM]
				FROM empire_data.dbo.[Staedion$Allocated_G_L_Entries]
				--WHERE [G_L Entry No_] = 123495700
				;
				SET @AantalRecords = @@rowcount
				;
				update BASIS
				set Rekening_id = REK.Rekening_id 
					,Bedrijf_id = 1
				from staedion_dm.Grootboek.[Toegerekende grootboekposten HANDM] as BASIS
				join staedion_dm.Grootboek.Rekening as REK
				on REK.Rekeningnr = BASIS.rekeningnr
				;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

		end

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Alle regels uit grootboekposten: ##Posten1';
	----------------------------------------------------------------------------------- 

	-- 1: alle regels uit grootboekposten
	with cte_eenheden_juridisch as 
	(select  MW.Eenheidnr ,MW.[Administratief eigenaar],cty.Code as [Corpodata type],[FT clusternr], EIG.[FT clusternaam] ,MW.[Juridisch eigenaar], EIG.[Datum uit exploitatie]
		from staedion_dm.eenheden.Meetwaarden as MW
		 JOIN staedion_dm.eenheden.Eigenschappen AS EIG ON MW.Eigenschappen_id = EIG.Eigenschappen_id
		 JOIN [staedion_dm].[Eenheden].[Technisch type] typ ON EIG.[Technisch type_id] = typ.[Technisch type_id]
		 JOIN [staedion_dm].[Eenheden].[Corpodatatype] cty ON EIG.[Corpodatatype_id] = cty.Corpodatatype_id 
		where peildatum = @DatumTotenMet
		and [Juridisch eigenaar]  like '%'+ @Eigenaar + '%'
		union
	select  MW.Eenheidnr ,MW.[Administratief eigenaar],cty.Code as [Corpodata type],[FT clusternr], EIG.[FT clusternaam] ,MW.[Juridisch eigenaar], EIG.[Datum uit exploitatie]
		from staedion_dm.eenheden.Meetwaarden as MW
		 JOIN staedion_dm.eenheden.Eigenschappen AS EIG ON MW.Eigenschappen_id = EIG.Eigenschappen_id
		 JOIN [staedion_dm].[Eenheden].[Technisch type] typ ON EIG.[Technisch type_id] = typ.[Technisch type_id]
		 JOIN [staedion_dm].[Eenheden].[Corpodatatype] cty ON EIG.[Corpodatatype_id] = cty.Corpodatatype_id 
		where peildatum = @DatumVanaf
		and [Juridisch eigenaar] like '%'+ @Eigenaar + '%'
		)

	SELECT Rekeningnr = REK.Rekeningnr
		,Rekeningnaam = REK.Grootboekrekening
		,Bedrag = CONVERT(FLOAT, POST.[Bedrag incl. verplichting])
		,Eenheidnr = POST.Eenheidnr
		,Documentnr = POST.[Document nr]
		,Boekdatum = POST.Boekdatum
		,Omschrijving = POST.Omschrijving
		,Kostenplaats = DIM.Code + ' '+ DIM.Dimensiewaarde
		,Volgnummer = POST.Volgnummer
		,[Productboekingsgroep ] = PROD.Productboekingsgroep
		,[Broncode] = BR.[Code]
		,[BTW-poductboekingsgroep] = BTW.Btwproductboekingsgroep
		,[BTW-bedrag] = convert(float,POST.[Btw bedrag incl. verplichting])
	--	,KENM.[Corpodata type]
		,CTE.[Corpodata type]
		,Cluster = CL.Clusternr
	--	,KENM.[Administratief eigenaar]
		,CTE.[Administratief eigenaar]
	--	,KENM.[Juridisch eigenaar]
		,CTE.[Juridisch eigenaar]
		,[Gebruikers-id] = POST.Gebruiker
	into ##Posten1
	FROM staedion_dm.Grootboek.Grootboekposten AS POST
	JOIN staedion_dm.Grootboek.Rekening AS REK ON REK.Rekening_id = POST.Rekening_id
	left outer join staedion_dm.Grootboek.Dimensiewaarden1 as DIM on DIM.[Dimensiewaarde 1_id] = POST.[Dimensiewaarde 1_id]
	left outer join staedion_dm.Grootboek.Btwproductboekingsgroep as BTW on BTW.Btwproductboekingsgroep_id = POST.Btwproductboekingsgroep_id
	left outer join staedion_dm.Grootboek.Productboekingsgroep as PROD on PROD.Productboekingsgroep_id = POST.Productboekingsgroep_id
	left outer join staedion_dm.Grootboek.Bronnen as BR on BR.Bron_id = POST.Bron_id
	left outer join cte_eenheden_juridisch as CTE on CTE.Eenheidnr = POST.Eenheidnr
	OUTER APPLY empire_staedion_Data.dbo.ITVfnCLusterBouwblok(POST.Eenheidnr) AS CL
	--OUTER APPLY staedion_dm.[Eenheden].[fn_Eigenschappen](POST.Eenheidnr, GETDATE()) KENM
	WHERE 	(	CTE.Eenheidnr is not null
					OR (DIM.Code IN (
						'1001'
						,'1002'
						,'1005'
						,'1006'
						,'1007'
						,'1019'
						,'1037'
						,'1173'
						,'1187'
						,'1253'
						,'1257'
						,'1303'
						,'1318'
						,'1636'
						,'1638'
						,'1639'
						,'1642'
						,'1643'
						,'1644'
						,'1645'
						,'1646'
						,'1675'
						,'1684'
						) and  @Eigenaar = 'Staedion VG Holding BV')
					)
		AND POST.Boekdatum BETWEEN @DatumVanaf and @DatumTotenMet
		;
				SET @AantalRecords = @@rowcount
				;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Alle regels uit toegerekende posten: ##Posten2';
	----------------------------------------------------------------------------------- 
	;with cte_eenheden_juridisch as 
	(select  MW.Eenheidnr ,MW.[Administratief eigenaar],cty.Code as [Corpodata type],[FT clusternr], EIG.[FT clusternaam] ,MW.[Juridisch eigenaar], EIG.[Datum uit exploitatie]
		from staedion_dm.eenheden.Meetwaarden as MW
		 JOIN staedion_dm.eenheden.Eigenschappen AS EIG ON MW.Eigenschappen_id = EIG.Eigenschappen_id
		 JOIN [staedion_dm].[Eenheden].[Technisch type] typ ON EIG.[Technisch type_id] = typ.[Technisch type_id]
		 JOIN [staedion_dm].[Eenheden].[Corpodatatype] cty ON EIG.[Corpodatatype_id] = cty.Corpodatatype_id 
		where peildatum =  @DatumTotenMet
		and [Juridisch eigenaar] like '%'+ @Eigenaar + '%'
		union
	select  MW.Eenheidnr ,MW.[Administratief eigenaar],cty.Code as [Corpodata type],[FT clusternr], EIG.[FT clusternaam] ,MW.[Juridisch eigenaar], EIG.[Datum uit exploitatie]
		from staedion_dm.eenheden.Meetwaarden as MW
		 JOIN staedion_dm.eenheden.Eigenschappen AS EIG ON MW.Eigenschappen_id = EIG.Eigenschappen_id
		 JOIN [staedion_dm].[Eenheden].[Technisch type] typ ON EIG.[Technisch type_id] = typ.[Technisch type_id]
		 JOIN [staedion_dm].[Eenheden].[Corpodatatype] cty ON EIG.[Corpodatatype_id] = cty.Corpodatatype_id 
		where peildatum =  @DatumVanaf
		and [Juridisch eigenaar] like '%'+ @Eigenaar + '%'
		)

	SELECT Rekeningnr = REK.Rekeningnr
		,Rekeningnaam = REK.Grootboekrekening
		,[Toegerekend bedrag] = CONVERT(FLOAT, POST.[Toegerekend bedrag])
		,Eenheidnr = POST.Eenheidnr
		,Documentnr = POST.[Document nr]
		,Boekdatum = POST.Boekdatum
		,Volgnummer = POST.[Volgnummer grootboekpost]
		,CTE.[Corpodata type]
		,Cluster = CL.Clusternr
		,CTE.[Administratief eigenaar]
		,CTE.[Juridisch eigenaar]
	into ##Posten2
	FROM staedion_dm.Grootboek.[Toegerekende grootboekposten HANDM]  AS POST
	JOIN staedion_dm.Grootboek.Rekening AS REK ON REK.Rekening_id = POST.Rekening_id
	left outer join cte_eenheden_juridisch as CTE on CTE.Eenheidnr = POST.Eenheidnr
	OUTER APPLY empire_staedion_Data.dbo.ITVfnCLusterBouwblok(POST.Eenheidnr) AS CL
	WHERE 	POST.Boekdatum BETWEEN @DatumVanaf and @DatumTotenMet
		and POST.Regeltype = 'Toerekening'
		and POST.[Volgnummer grootboekpost] in (select Volgnummer from ##Posten1)
	;

				SET @AantalRecords = @@rowcount
				;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Updates ##Posten1';
	----------------------------------------------------------------------------------- 

	-- update tabel om duidelijk te maken waar toerekening volledig is
	alter table ##posten1 add [Toegerekende post] nvarchar(10)
	alter table ##posten1 add [Toegerekende post bedrag] decimal(12,2)
	alter table ##posten1 add [Toegerekende post ok] bit
	;

	update ##posten1 
	set [Toegerekende post] = 'Ja'
	where exists (select 1 from ##posten2 as TOE where TOE.Volgnummer = ##posten1.Volgnummer)
	;
	update ##posten1 
	set [Toegerekende post bedrag] = 
	(select sum([Toegerekend bedrag]) 
	from ##posten2 as TOE where TOE.Volgnummer = ##posten1.Volgnummer)
	where 1=1
	;
	update ##posten1 
	set [Toegerekende post ok] = 1
	where [Toegerekende post bedrag] is not null and [Toegerekende post bedrag] = bedrag
	;
	update ##posten1 
	set [Toegerekende post ok] = 0
	where [Toegerekende post bedrag] is not null and [Toegerekende post bedrag] <> bedrag
	;

				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'staedion_dm.Grootboek.Output_Specificatie_Grootboekposten_Jur_Eig_WOM - zonder toegerekende posten';
	----------------------------------------------------------------------------------- 

	INSERT INTO staedion_dm.Grootboek.Output_Specificatie_Grootboekposten_Jur_Eig_WOM 
			([Rekeningnr], [Rekeningnaam], [Bedrag], [Eenheidnr], [Documentnr], [Boekdatum], [Omschrijving], [Kostenplaats], [Volgnummer], [Productboekingsgroep ]
			, [Broncode], [BTW-poductboekingsgroep], [BTW-bedrag], [Gebruikers-id], [Bron], [Periode]
			, [Toegerekende post], [Toegerekende post bedrag], [Toegerekende post ok])
	select  Rekeningnr
			,Rekeningnaam
			,[Bedrag] 
			,Eenheidnr
			,Documentnr
			,Boekdatum
			,Omschrijving
			,Kostenplaats
			,Volgnummer 
			,[Productboekingsgroep ]
			,[Broncode]
			,[BTW-poductboekingsgroep]
			,[BTW-bedrag]
			,[Gebruikers-id]
			,Bron = 'Grootboekposten'
			,[Periode] = 'Van '
						+ convert(nvarchar(20),@DatumVanaf,105) 
						+ ' tm '
						+ convert(nvarchar(20),@DatumTotenMet,105) 
						+ ' verversdatum: '
						+ CONVERT(NVARCHAR(20), GETDATE(), 105)
			, coalesce([Toegerekende post], 'Nee') 
			, [Toegerekende post bedrag]
			, [Toegerekende post ok]
	-- select count(*) --30.940 vs 27.457
	from	##posten1
	where	[Toegerekende post ok] is NULL
	or		[Toegerekende post ok] = 0
	;

				SET @AantalRecords = @@rowcount
				;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'staedion_dm.Grootboek.Output_Specificatie_Grootboekposten_Jur_Eig_WOM - met toegerekende posten';
	----------------------------------------------------------------------------------- 
	
	INSERT INTO staedion_dm.Grootboek.Output_Specificatie_Grootboekposten_Jur_Eig_WOM 
			([Rekeningnr], [Rekeningnaam], [Bedrag], [Eenheidnr], [Documentnr], [Boekdatum], [Omschrijving], [Kostenplaats], [Volgnummer], [Productboekingsgroep ]
			, [Broncode], [BTW-poductboekingsgroep], [BTW-bedrag], [Gebruikers-id], [Bron], [Periode]
			, [Toegerekende post], [Toegerekende post bedrag], [Toegerekende post ok])		
	select  POST.Rekeningnr
			,POST.Rekeningnaam
			,TOE.[Toegerekend bedrag] 
			,TOE.Eenheidnr
			,POST.Documentnr
			,POST.Boekdatum
			,POST.[Omschrijving]
			,POST.Kostenplaats
			,POST.Volgnummer 
			,POST.[Productboekingsgroep]
			,POST.[Broncode]
			,POST.[BTW-poductboekingsgroep]
			,POST.[BTW-bedrag]
			,POST.[Gebruikers-id]
			,Bron = 'Toegerekende grootboekposten'
			,[Periode] = 'Van '
						+ convert(nvarchar(20),@DatumVanaf,105) 
						+ ' tm '
						+ convert(nvarchar(20),@DatumTotenMet,105) 
						+ ' verversdatum: '
						+ CONVERT(NVARCHAR(20), GETDATE(), 105)
			, [Toegerekende post]
			, [Toegerekende post bedrag]
			, [Toegerekende post ok]

	-- select count(*) --30.940 vs 27.457
	-- select count(distinct POST.Volgnummer) -- 3.483 + 27.457 = 30.940
	from	##posten1 as POST
	inner join ##posten2 as TOE
	on		TOE.Volgnummer = POST.Volgnummer
	--OUTER APPLY staedion_dm.[Eenheden].[fn_Eigenschappen](TOE.Eenheidnr, GETDATE()) as KENM
	where	coalesce(POST.[Toegerekende post ok],0) = 1
	;
	
				SET @AantalRecords = @@rowcount
				;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Update kenmerken + check';
	----------------------------------------------------------------------------------- 

	update  BASIS
	set		[Corpodata type] = KENM.[Corpodata type]
			,[Cluster] = KENM.[FT clusternr]
			,[Administratief eigenaar] = KENM.[Administratief eigenaar]
			,[Juridisch eigenaar] = KENM.[Juridisch eigenaar]
	from	staedion_dm.Grootboek.Output_Specificatie_Grootboekposten_Jur_Eig_WOM  as BASIS
	OUTER APPLY staedion_dm.[Eenheden].[fn_Eigenschappen](BASIS.Eenheidnr, GETDATE()) as KENM
	where	BASIS.[Juridisch eigenaar] is null
	;
	select 'Ter controle totaaltelling: ' + format(sum(Bedrag),'N0') from ##posten1
	select 'Ter controle totaaltelling output-tabel: ' + format(sum([Bedrag]),'N0') from staedion_dm.Grootboek.Output_Specificatie_Grootboekposten_Jur_Eig_WOM
	select 'Posten niet volledig toegerekend: ',* from ##posten1 where [Toegerekende post ok] = 0;
	--select sum(toegerekende_post_bedrag), sum(bedrag) from ##posten1 where toegerekende_post_ok = 1;
	--select sum(toegerekende_post_bedrag), sum(bedrag) from ##posten1 where toegerekende_post_ok = 0;
	--select * from ##posten1 where toegerekende_post_ok = 0;
	--select sum(toegerekende_post_bedrag), sum(bedrag) from ##posten1 where toegerekende_post_ok = 0;

	set	@finish = current_timestamp

	
				SET @AantalRecords = @@rowcount
				;
				SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
				SET @bericht = @Bericht + format(@AantalRecords, 'N0');
				EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;

	insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding, Begintijd,Eindtijd)
		select object_name(@@procid),getdate(),  @start, @finish
	
	COMMIT TRANSACTION;



	SELECT BASIS.[Rekeningnr]
		,BASIS.[Rekeningnaam]
		,BASIS.[Bedrag]
		,BASIS.[Eenheidnr]
		,EIG.Adres
		,BASIS.[Documentnr]
		,BASIS.[Boekdatum]
		,BASIS.[Kostenplaats]
		,BASIS.[Volgnummer]
		,BASIS.[Productboekingsgroep ]
		,BASIS.[Broncode]
		,BASIS.[BTW-poductboekingsgroep]
		,BASIS.[BTW-bedrag]
		,BASIS.[Corpodata type]
		,BASIS.[Cluster]
		,BASIS.[Administratief eigenaar]
		,BASIS.[Juridisch eigenaar]
		,BASIS.[Gebruikers-id]
		,BASIS.[Bron]
		,BASIS.[Periode]
		,BASIS.[Toegerekende post]
		,BASIS.[Toegerekende post bedrag]
		,BASIS.[Toegerekende post ok]
		,BASIS.[Omschrijving]
	FROM Grootboek.Output_Specificatie_Grootboekposten_Jur_Eig_WOM AS BASIS
	LEFT OUTER JOIN staedion_dm.Eenheden.Eigenschappen AS EIG ON EIG.Eenheidnr = BASIS.Eenheidnr
		AND EIG.Einddatum IS NULL
	WHERE BASIS.Rekeningnr LIKE 'A8%'
		OR BASIS.Rekeningnr LIKE 'A9%'
	ORDER BY BASIS.Rekeningnr
		,BASIS.Volgnummer

END TRY
    BEGIN CATCH 

       IF @@TRANCOUNT > 0
       BEGIN
          ROLLBACK TRANSACTION

       END;

		set	@finish = current_timestamp
			insert into empire_staedion_Data.etl.LogboekMeldingenProcedures ([Databaseobject],TijdMelding,ErrorProcedure,ErrorNumber,ErrorLine,ErrorMessage, Begintijd, Eindtijd)
			select error_procedure(), getdate(), error_procedure(), error_number(), error_line(), error_message() , @start, @finish

    END CATCH;

SET NOCOUNT, XACT_ABORT OFF;

GO
