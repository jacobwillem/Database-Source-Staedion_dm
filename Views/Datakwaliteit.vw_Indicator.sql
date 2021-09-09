SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [Datakwaliteit].[vw_Indicator]
AS
/*
JvdW 26-05-2021 Omwille van performance + foutmelding
> vullingsgraad als cte
> index
USE [staedion_dm]
GO
CREATE NONCLUSTERED INDEX i1_RealisatieDetails
ON [Datakwaliteit].[RealisatieDetails] ([fk_indicator_id])
INCLUDE ([Laaddatum],[fk_indicatordimensie_id])

*/
-- JvdW 20210602 Toegevoegd
WITH cte_laaddatum as (select Laaddatum = max([Laaddatum])
				FROM Datakwaliteit.RealisatieDetails AS R2
				WHERE Laaddatum <= getdate() -- soms per 1-7 van een lopend jaar al toegevoegd ?)
				),


cte_definites_els
AS (
	SELECT NaamVeld
		,OmschrijvingVeld
		,DataTypeVeld
		,MaximaleLengteVeld
	/*into master.dbo.ff */
	FROM OPENROWSET('SQLNCLI', 'Server=s-dwh2012-db;Trusted_Connection=yes;', 'EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] ''empire_staedion_data'', ''dbo'', ''ELS''
													WITH RESULT SETS  
													(   ([NaamTabel] nvarchar(50) ,						-- meerdere resultset op te geven door () te gebruiken
															[Kenmerk] nvarchar(50) ,  
															[OmschrijvingObject] sql_variant ,  
															[Soort_object] nvarchar(50) ,      
															[NaamVeld] nvarchar(50) ,  
															[OmschrijvingVeld] sql_variant ,  
															[DataTypeVeld] nvarchar(50) ,  
															[MaximaleLengteVeld] int,
															[collation_name] nvarchar(50),  
															[Volgorde] smallint)
													)
													')
	WHERE [NaamVeld] NOT IN (
			'id'
			,'ident'
			) -- niet interessant
	)
	-- 20210526 JvdW
	,cte_vullingsgraad
AS (
	SELECT R1.id_samengesteld
		,R1.[Laaddatum]
		,[Vullingsgraad] = iif(Noemer <> 0, Teller / Noemer * 1.00, NULL)
		,Volgnr = row_number() OVER (
			PARTITION BY R1.id_samengesteld ORDER BY R1.[Laaddatum] DESC
			)
	FROM Datakwaliteit.Realisatie AS R1
	JOIN [Datakwaliteit].[Indicatordimensie] AS ID ON ID.id = R1.fk_indicatordimensie_id
	WHERE ID.Omschrijving IN (
			'Completeness'
			,'Accuracy'
			)
	)
SELECT I.id_samengesteld
	,[Indicatordimensie Id] = IG.[id]
	,[Indicatordimensie] = IG.[Vertaling]
	,[Id] = I.[id]
	,[Parent] = isnull(PA.[Omschrijving], I.[omschrijving])
	,[Parent type] = iif(isnull(PA.[Omschrijving], I.[omschrijving]) LIKE '%proces%', 'Proces', 'Gegevensset')
	,[Omschrijving] = CASE 
		WHEN PA.[omschrijving] IS NOT NULL
			--AND I.Omschrijving <> 'bouwjaar' -- JVDW 05-10-2020 TEST -  toegevoegd tbv ophalen details bouwjaarregels in pbix
			THEN REPLICATE(' ', 10) + I.[Omschrijving]
		ELSE I.[Omschrijving]
		END
	,[Filter corpodata-type] = coalesce(I.FilterCorpodata, 'Alle types')
	,[Level_1] = CASE 
		WHEN PA.[Omschrijving] IS NULL
			THEN 'Ja'
		ELSE 'Nee'
		END
	,I.[Volgorde]
	,I.[Zichtbaar]
	,[Kleurschema] = KS.[Omschrijving]
	,[Bedrijfsonderdeel] = BO.[Omschrijving]
	,[Aanspreekpunt] = AP.[Omschrijving]
	,[WijzeVanVullen] = WV.[Omschrijving]
	,[Schaalsoort] = SS.[Omschrijving]
	,[Systeembron] = SYST.[Omschrijving]
	,[Frequentie] = FR.[Omschrijving]
	,I.[Marge_percentage]
	,I.[Weergaveformat]
	,I.[Definitie]
	,I.[Cumulatief]
	,I.[Gemiddelde]
	,[Bijgewerkt tot] = (
		SELECT max([Laaddatum])
		FROM Datakwaliteit.[Realisatie] AS R
		WHERE R.fk_indicator_id = I.[id]
		)
	,[Vullingsgraad] = VUL.[Vullingsgraad]
	-- 20210526 JvdW
	--,[Vullingsgraad] = (
	--       SELECT iif(Noemer <> 0, Teller / Noemer * 1.00, NULL)
	--       FROM Datakwaliteit.Realisatie AS R1
	--       JOIN [Datakwaliteit].[Indicatordimensie] AS ID
	--              ON ID.id = R1.fk_indicatordimensie_id
	--       WHERE ID.Omschrijving in ( 'Completeness','Accuracy')
	--              AND R1.fk_indicator_id = I.id
	--              AND R1.Laaddatum = (
	--                     SELECT max([Laaddatum])
	--                     FROM Datakwaliteit.[Realisatie] AS R2
	--                     WHERE R2.fk_indicator_id = I.[id]
	--                     )
	--       )
	-- JvdW 20210602 Weggehaald
	--,[Aantal fouten] = (
	--	--SELECT coalesce(Noemer,0) - coalesce(Teller,0)
	--	SELECT count(*)
	--	FROM Datakwaliteit.RealisatieDetails AS R1
	--	JOIN [Datakwaliteit].[Indicatordimensie] AS ID ON ID.id = R1.fk_indicatordimensie_id
	--	WHERE 1 = 1 -- ID.Omschrijving in ( 'Accuracy')
	--		AND R1.fk_indicator_id = I.id
	--		AND R1.Laaddatum = (
	--			SELECT max([Laaddatum])
	--			FROM Datakwaliteit.RealisatieDetails AS R2
	--			WHERE R2.fk_indicator_id = I.[id]
	--			)
	--	)
	-- JvdW 20210602 Toegevoegd
	,[Aantal fouten] = (
		--SELECT coalesce(Noemer,0) - coalesce(Teller,0)
		SELECT count(*)
		FROM Datakwaliteit.RealisatieDetails AS R1
		JOIN [Datakwaliteit].[Indicatordimensie] AS ID ON ID.id = R1.fk_indicatordimensie_id
		JOIN Datakwaliteit.[Indicator] as I
			on I.[id_samengesteld] = R1.[id_samengesteld]
		JOIN Datakwaliteit.[Indicator] as I_parent
				on I_parent.[id] = I.[parent_id]
		LEFT JOIN [Datakwaliteit].[Uitzondering] as UIT
				on UIT.[sleutel_entiteit] = case I_parent.[Omschrijving]
													when 'Eenheid' then R1.[Eenheidnr]
													when 'Klant' then R1.[Klantnr]
													when 'Relaties' then right(R1.[Omschrijving], 12)
													--when 'Contracten' then coalesce(R1.Eenheidnr,'OGEH-?') + '-' +  coalesce(R1.Klantnr,'KLNT-?') + '-' + coalesce(convert(nvarchar(20), R1.datIngang, 105),'ingangsdatum ?')
													when 'Contracten' then coalesce(nullif(R1.[Eenheidnr],''),'OGEH-?') + '-' +  coalesce(nullif(R1.[Klantnr],''),'KLNT-?')
													when 'Medewerker' then R1.[fk_medewerker_id]
													else 'Volgt - zie vw_RealisatieDetails'
												end
		AND UIT.[id_samengesteld] = R1.[id_samengesteld]
		AND getdate() between UIT.[Startdatum] and coalesce(dateadd(day, 1, UIT.[Einddatum]), dateadd(day, 1, getdate()))
		WHERE 1 = 1 -- ID.Omschrijving in ( 'Accuracy')
			--AND R1.fk_indicator_id = I.id
			AND UIT.[id] is null
			AND R1.id_samengesteld = I.id_samengesteld
			AND R1.Laaddatum = LD.Laaddatum
		)
	,[Details toegevoegd] = I.[Details_toevoegen]
	,I.Indicator_actief
	,[Definitie attribuut] = coalesce(ELS.OmschrijvingVeld, I.Definitie, 'Controle bij actieve huurders op bron in Empire: ' + I.bron_database)
	,[Definitie attribuut url] = I.Definitie_url
	,[Definitie attribuut aanduiding] = I.Definitie_aanduiding
--       ,fk_bron_id
--       ,fk_veldtype_id
-- select I.*
FROM [Datakwaliteit].[Indicator] AS I
LEFT OUTER JOIN [Datakwaliteit].[Indicatordimensie] AS IG ON IG.id = I.fk_indicatordimensie_id
LEFT OUTER JOIN [Datakwaliteit].[Kleurschema] AS KS ON KS.id = I.fk_kleurschema_id
LEFT OUTER JOIN [Datakwaliteit].Bedrijfsonderdeel AS BO ON BO.id = I.fk_bedrijfsonderdeel_id
LEFT OUTER JOIN [Datakwaliteit].Aanspreekpunt AS AP ON AP.id = I.fk_Aanspreekpunt_id
LEFT OUTER JOIN [Datakwaliteit].WijzeVullen AS WV ON WV.id = I.fk_WijzeVullen_id
LEFT OUTER JOIN [Datakwaliteit].Schaalsoort AS SS ON SS.id = I.fk_Schaalsoort_id
LEFT OUTER JOIN [Datakwaliteit].Subsysteem AS SYST ON SYST.id = I.fk_Subsysteem_id
LEFT OUTER JOIN [Datakwaliteit].[Frequentie] AS FR ON FR.id = I.fk_frequentie_id
LEFT OUTER JOIN [Datakwaliteit].[Indicator] AS PA ON PA.id = I.parent_id
LEFT OUTER JOIN cte_definites_els AS ELS ON ELS.NaamVeld = I.[Omschrijving]
LEFT OUTER JOIN cte_vullingsgraad AS VUL ON I.id_samengesteld = VUL.id_samengesteld
	AND VUL.Volgnr = 1
left outer join cte_laaddatum as LD on 1=1
	--	   where I.[Omschrijving] = 'bouwjaar'
GO
