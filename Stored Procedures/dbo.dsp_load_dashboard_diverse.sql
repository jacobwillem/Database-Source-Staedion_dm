SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROCEDURE [dbo].[dsp_load_dashboard_diverse] 
@Begindatum datetime = null
as
/* ##################################################################################################################
---------------------------------------------------------------------------------------------------------------------
METADATA
---------------------------------------------------------------------------------------------------------------------
VAN			JvdW
BETREFT		Vullen feitentabellen met betrekking tot creditmanagement: storno's, specifieke betalingen
			> staedion_dm.RekeningCourant.KlantpostenDetails
			> staedion_dm.RekeningCourant.BankmutatiesDetails
			> 
ZIE			Ontvangstverwerking huuradministratie.pbix

---------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN		
---------------------------------------------------------------------------------------------------------------------
20210828


exec staedion_dm.[dbo].[dsp_load_dashboard_diverse] 

-------------------------------------------------------------------------------------------------------------------------------------
PERFORMANCE
-------------------------------------------------------------------------------------------------------------------------------------

--create index PrognoseDetails_i1 on [Dashboard].[PrognoseDetails] (fk_indicator_id,datum)
--create index RealisatieDetails_i1 on [Dashboard].RealisatieDetails (fk_indicator_id,datum)

2021-08-28 02:03:51. ### Maatwerk Staedion: dsp_load_dashboard_diverse - JvdW Versie 1 20210828 - BEGIN (vanaf:01-01-2018)
 
2021-08-28 02:06:27: Stap: RealisatieDetails mbv functie SamengesteldeKolomNaarRijen omschrijving omzetten naar rijen - records: 17,913,411
2021-08-28 02:06:49: Stap: Index hulptabel - records: 0
2021-08-28 02:33:04: Stap: Dashboard.[DimensieJoin] vullen adhv voorgaande hulptabel - records: 75,247,256
2021-08-28 02:36:12: Stap: Dashboard.[RealisatiePrognose] - prognose 0 - vullen adhv voorgaande hulptabel - records: 6,197,067
2021-08-28 02:36:13: Stap: Hulptabel tbv Dashboard.[RealisatiePrognose] - prognose 1 - records: 73,840
2021-08-28 02:36:13: Stap: Index Hulptabel tbv Dashboard.[RealisatiePrognose] - prognose 1 - records: 0
2021-08-28 02:36:30: Stap: Vullen Dashboard.[RealisatiePrognose] - prognose 1 - records: 17,874
2021-08-28 02:36:30. ### Maatwerk Staedion: dsp_load_dashboard_diverse - JvdW Versie 1 20210828 - EINDE

Completion time: 2021-08-28T02:36:30.5527404+02:00


################################################################################################################## */

BEGIN	

	set nocount on
 
	-----------------------------------------------------------------------------------
	-- Parameters
	----------------------------------------------------------------------------------- 
	DECLARE @LogboekTekst NVARCHAR(255) = ' ### Maatwerk Staedion: ';
	DECLARE @VersieNr NVARCHAR(80) = ' - JvdW Versie 1 20210828'	;
	SET @LogboekTekst = @LogboekTekst + OBJECT_NAME(@@PROCID) + @VersieNr;
    DECLARE @Bericht NVARCHAR(255);
    DECLARE @Onderwerp NVARCHAR(100);
	DECLARE @AantalRecords DECIMAL(12, 0);
	DECLARE @Testversie bit = 1;

	if @Begindatum is null 
		select @Begindatum = '20180101'
		;
		PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - BEGIN (vanaf:' + format(@Begindatum, 'dd-MM-yyyy') + ')';

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Hulptabellen verwijderen';
	----------------------------------------------------------------------------------- 
	DROP TABLE IF EXISTS #cte_prognose;
	DROP TABLE IF EXISTS #cte_realisatie;
	
		If @Testversie = 1
		Begin
			SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
			SET @bericht = @Bericht + format(@AantalRecords, 'N0');
			EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
		end

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'RealisatieDetails mbv functie SamengesteldeKolomNaarRijen omschrijving omzetten naar rijen';
	--  waarbij er 1 of meerdere keren ; voorkomt in omschrijving
	----------------------------------------------------------------------------------- 
		;WITH cte_realisatie
			AS (
				SELECT R.[id]
					,kolomID = FN.id
					,FN.tekstwaarde
				FROM [Dashboard].[RealisatieDetails] AS R
				CROSS APPLY staedion_dm.Algemeen.SamengesteldeKolomNaarRijen(R.Omschrijving, ';') AS FN
				--where r.id = 22753084
				--where R.fk_indicator_id = 110
				)
			SELECT id
				,kolomID
				,waarde = '[Details' + right('0' + convert(NVARCHAR(2), kolomID), 2) + ']'
				,tekstwaarde
			INTO #cte_realisatie
			FROM cte_realisatie
		;
		SET @AantalRecords = @@rowcount
		;
		If @Testversie = 1
		Begin
			SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
			SET @bericht = @Bericht + format(@AantalRecords, 'N0');
			EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
		end
		
	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Index hulptabel';
	----------------------------------------------------------------------------------- 
		CREATE INDEX i_1 ON #cte_realisatie (
		[id]
		,kolomID
		);
		SET @AantalRecords = @@rowcount
		;
		If @Testversie = 1
		Begin
			SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
			SET @bericht = @Bericht + format(@AantalRecords, 'N0');
			EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
		end
	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Dashboard.[DimensieJoin] vullen adhv voorgaande hulptabel';
	-- Voorgaande hulptabel kan gebruikt worden om DimensieJoin te vullen (aangevuld met alle mogelijke dimensies)
	-- NB hierbij worden de dimensiewaarden als rijen opgevoerd
	----------------------------------------------------------------------------------- 
	truncate table [Dashboard].[DimensieJoin]
	;
	WITH T
	AS (
		SELECT [num] = 1
	
		UNION ALL
	
		SELECT [num] + 1
		FROM T
		WHERE [num] < 16
		)
		,Q
	AS (
		SELECT [id] = R.[id]
			,[fk_indicator_id] = R.[fk_indicator_id]
			,[Clusternummer] = R.[Clusternummer]
			,[Dimensie.naam] = CONCAT (
				'Detail.'
				,right(CONCAT (
						'00'
						,T.[num]
						), 2)
				)
			,[Dimensie.id] = CONCAT (
				R.[fk_indicator_id]
				,'.'
				,'Detail.'
				,right(CONCAT (
						'00'
						,T.[num]
						), 2)
				)
			,[Datum] = R.[Datum]
			,[Laaddatum] = R.[Laaddatum]
			,Dimensie = CASE T.[num]
				WHEN 11
					THEN format(R.datum, 'yyyy-MM-dd')
				WHEN 12
					THEN format(R.datum, 'yyyy-MM')
				ELSE CTE.Tekstwaarde
				END
		--,R.Omschrijving
		--,T.[num]
		FROM [Dashboard].[RealisatieDetails] AS R
		FULL OUTER JOIN T ON 1 = 1
		LEFT OUTER JOIN #cte_realisatie AS CTE ON CTE.id = R.[id]
			AND CTE.kolomID = T.[num]
		WHERE R.[fk_indicator_id] IS NOT NULL
		)
	INSERT INTO Dashboard.[DimensieJoin] (
		[fk_indicator_id]
		,[Clusternummer]
		,[Dimensie.naam]
		,[Dimensie.id]
		,[Datum]
		,[Laaddatum]
		,Dimensie
		)
	SELECT [fk_indicator_id]
		,[Clusternummer]
		,[Dimensie.naam]
		,[Dimensie.id]
		,[Datum]
		,[Laaddatum]
		,Dimensie
	FROM Q
	WHERE (
			[Dimensie.naam] NOT IN (
				'Detail.13'
				,'Detail.14'
				,'Detail.15'
				,'Detail.16'
				)
			OR (
				[Dimensie.naam] IN (
					'Detail.13'
					,'Detail.14'
					,'Detail.15'
					,'Detail.16'
					)
				AND [Clusternummer] IS NOT NULL
				)
			)
		;
		SET @AantalRecords = @@rowcount
		;
		If @Testversie = 1
		Begin
			SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
			SET @bericht = @Bericht + format(@AantalRecords, 'N0');
			EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
		end
	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Dashboard.[RealisatiePrognose] - prognose 0 - vullen adhv voorgaande hulptabel';
	-- NB hierbij zijn de dimensiewaarden als kolommen opgevoerd
	----------------------------------------------------------------------------------- 
	TRUNCATE TABLE Dashboard.RealisatiePrognose;

	INSERT INTO Dashboard.RealisatiePrognose (
		[id]
		,[Datum]
		,[Waarde]
		,[Laaddatum]
		,[Omschrijving]
		,[fk_indicator_id]
		,[fk_eenheid_id]
		,[fk_contract_id]
		,[fk_klant_id]
		,[Teller]
		,[Noemer]
		,[Clusternummer]
		,[Prognose]
		,[Detail.01]
		,[Detail.02]
		,[Detail.03]
		,[Detail.04]
		,[Detail.05]
		,[Detail.06]
		,[Detail.07]
		,[Detail.08]
		,[Detail.09]
		,[Detail.10]
		)
	SELECT R.[id]
		,R.[Datum]
		,R.[Waarde]
		,R.[Laaddatum]
		,R.[Omschrijving]
		,R.[fk_indicator_id]
		,R.[fk_eenheid_id]
		,R.[fk_contract_id]
		,R.[fk_klant_id]
		,R.[Teller]
		,R.[Noemer]
		,R.[Clusternummer]
		,0
		,[Detail.01] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[1]','varchar(128)'))
		,[Detail.02] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[2]','varchar(128)'))
		,[Detail.03] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[3]','varchar(128)'))
		,[Detail.04] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[4]','varchar(128)'))
		,[Detail.05] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[5]','varchar(128)'))
		,[Detail.06] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[6]','varchar(128)'))
		,[Detail.07] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[7]','varchar(128)'))
		,[Detail.08] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[8]','varchar(128)'))
		,[Detail.09] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[9]','varchar(128)'))
		,[Detail.10] = trim(cast('<t><![CDATA[' + replace(R.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[10]','varchar(128)'))
	FROM [Dashboard].[RealisatieDetails] AS R
	;
		SET @AantalRecords = @@rowcount
		;
		If @Testversie = 1
		Begin
			SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
			SET @bericht = @Bericht + format(@AantalRecords, 'N0');
			EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
		end
	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Hulptabel tbv Dashboard.[RealisatiePrognose] - prognose 1';
	-- NB hierbij zijn de dimensiewaarden als kolommen opgevoerd
	----------------------------------------------------------------------------------- 
	;WITH cte_prognose
	AS (
		SELECT P.[id]
			,kolomID = FN.id
			,FN.tekstwaarde
		FROM [Dashboard].[PrognoseDetails] AS P
		CROSS APPLY Algemeen.SamengesteldeKolomNaarRijen(P.Omschrijving, ';') AS FN
		WHERE NOT EXISTS (
				SELECT 1
				FROM Dashboard.RealisatieDetails AS RD
				WHERE RD.[fk_indicator_id] = P.[fk_indicator_id]
					AND year(RD.[Datum]) = year(P.[Datum])
					AND month(RD.[Datum]) = month(P.[Datum])
				)
		)
	SELECT id
		,kolomID
		,waarde = '[Details' + right('0' + convert(NVARCHAR(2), kolomID), 2) + ']'
		,tekstwaarde
	INTO #cte_prognose
	FROM cte_prognose;

		SET @AantalRecords = @@rowcount
		;
		If @Testversie = 1
		Begin
			SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
			SET @bericht = @Bericht + format(@AantalRecords, 'N0');
			EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
		end
	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Index Hulptabel tbv Dashboard.[RealisatiePrognose] - prognose 1';
	-- NB hierbij zijn de dimensiewaarden als kolommen opgevoerd
	----------------------------------------------------------------------------------- 

	CREATE INDEX i_2 ON #cte_prognose (
		[id]
		,kolomID
		);
		SET @AantalRecords = @@rowcount
		;
		If @Testversie = 1
		Begin
			SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
			SET @bericht = @Bericht + format(@AantalRecords, 'N0');
			EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
		end

	-----------------------------------------------------------------------------------
	set @Onderwerp = 'Vullen Dashboard.[RealisatiePrognose] - prognose 1';
	-- NB hierbij zijn de dimensiewaarden als kolommen opgevoerd
	----------------------------------------------------------------------------------- 

	INSERT INTO Dashboard.RealisatiePrognose (
		[id]
		,[Datum]
		,[Waarde]
		,[Laaddatum]
		,[Omschrijving]
		,[fk_indicator_id]
		,[fk_eenheid_id]
		,[fk_contract_id]
		,[fk_klant_id]
		,[Teller]
		,[Noemer]
		,[Clusternummer]
		,[Prognose]
		,[Detail.01]
		,[Detail.02]
		,[Detail.03]
		,[Detail.04]
		,[Detail.05]
		,[Detail.06]
		,[Detail.07]
		,[Detail.08]
		,[Detail.09]
		,[Detail.10]
		)
	SELECT  [id] = (P.[id] + 1000000000000)
		,[Datum] = P.[Datum]
		,[Waarde] = P.[Waarde]
		,[Laaddatum] = getdate()
		,[Omschrijving] = P.[Omschrijving]
		,[fk_indicator_id] = P.[fk_indicator_id]
		,[fk_eenheid_id] = NULL
		,[fk_contract_id] = NULL
		,[fk_klant_id] = NULL
		,[Teller] = NULL
		,[Noemer] = NULL
		,[Clusternummer] = NULL
		,[Prognose] = 1
		,[Detail.01] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[1]','varchar(128)'))
		,[Detail.02] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[2]','varchar(128)'))
		,[Detail.03] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[3]','varchar(128)'))
		,[Detail.04] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[4]','varchar(128)'))
		,[Detail.05] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[5]','varchar(128)'))
		,[Detail.06] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[6]','varchar(128)'))
		,[Detail.07] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[7]','varchar(128)'))
		,[Detail.08] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[8]','varchar(128)'))
		,[Detail.09] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[9]','varchar(128)'))
		,[Detail.10] = trim(cast('<t><![CDATA[' + replace(P.[Omschrijving] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[10]','varchar(128)'))
	FROM [Dashboard].[RealisatieDetails] AS P
	WHERE NOT EXISTS (
			SELECT 1
			FROM Dashboard.RealisatieDetails AS RD
			WHERE RD.[fk_indicator_id] = P.[fk_indicator_id]
				AND year(RD.[Datum]) = year(P.[Datum])
				AND month(RD.[Datum]) = month(P.[Datum])
			)

		SET @AantalRecords = @@rowcount
		;
		If @Testversie = 1
		Begin
			SET @Bericht = 'Stap: ' + @Onderwerp + ' - records: ';
			SET @bericht = @Bericht + format(@AantalRecords, 'N0');
			EXEC empire_staedion_logic.dbo.hulp_log_nowait @Bericht;
		end


	PRINT convert(VARCHAR(20), getdate(), 121) + @LogboekTekst + ' - EINDE';

END





GO
