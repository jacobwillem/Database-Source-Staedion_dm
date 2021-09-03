SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [Leefbaarheid].[RstudioDatasetOpBuurt]
AS
WITH cte00
AS (
	SELECT GM.GemeenteCode
		,GM.WijkCode
		,CLBU.BuurtCode
		,BUcode = N'BU' + RIGHT(N'00000000' + CAST(CLBU.BuurtCode AS NVARCHAR), 8)
		,ELS.Jaar
		,AantalClusters = count(ELS.Clusternummer)
		,AantalWoningen = sum(ELS.AantalWoningen)
		,AantalBewonerscommissies = sum(CB.BewonerscommissieJN)
		,AantalHuismeesters = sum(CB.HuismeesterJN)
		,[OnrechtmatigGebruikPerWoning] = iif(ELS.Jaar < 2016, NULL, coalesce(cast(sum([AantalOnrechtmatigGebruikDossiers]) AS FLOAT) / cast(sum(ELS.AantalWoningen) AS FLOAT), 0))
		,[OverlastPerWoning] = iif(ELS.Jaar < 2016, NULL, coalesce(cast(sum([AantalOverlastDossiers]) AS FLOAT) / cast(sum(ELS.AantalWoningen) AS FLOAT), 0))
		--,[LFOsociaalOmschrijving] = string_agg([LFOsociaalOmschrijving], '; ')
		,[LFOsociaalBedrag] = iif(ELS.Jaar < 2013, NULL, SUM(coalesce([LFOsociaalBedrag], 0)))
		,[LFOsociaalAantal] = iif(ELS.Jaar < 2013, NULL, SUM(coalesce([LFOsociaalAantal], 0)))
		--,[LTBtechnischOmschrijving] = string_agg([LTBtechnischOmschrijving], '; ')
		,[LTBtechnischBedrag] = iif(ELS.Jaar < 2013, NULL, SUM(coalesce([LTBtechnischBedrag], 0)))
		,[LTBtechnischAantal] = iif(ELS.Jaar < 2013, NULL, SUM(coalesce([LTBtechnischAantal], 0)))
		--,[LTBschoonOmschrijving] = string_agg([LTBschoonOmschrijving], '; ')
		,[LTBschoonBedrag] = iif(ELS.Jaar < 2013, NULL, SUM(coalesce([LTBschoonBedrag], 0)))
		,[LTBschoonAantal] = COUNT([LTBschoonBedrag])
		--,[LTBalgemeneruimteOmschrijving] = string_agg([LTBalgemeneruimteOmschrijving], '; ')
		,[LTBalgemeneruimteBedrag] = iif(ELS.Jaar < 2013, NULL, SUM(coalesce([LTBalgemeneruimteBedrag], 0)))
		,[LTBalgemeneruimteAantal] = COUNT([LTBalgemeneruimteBedrag])
		--,[LTBveiligOmschrijving] = string_agg([LTBveiligOmschrijving], '; ')
		,[LTBveiligBedrag] = iif(ELS.Jaar < 2013, NULL, SUM(coalesce([LTBveiligBedrag], 0)))
		,[LTBveiligAantal] = COUNT([LTBveiligBedrag])
		--,[LTBongedierteOmschrijving] = string_agg([LTBongedierteOmschrijving], '; ')
		,[LTBongedierteBedrag] = iif(ELS.Jaar < 2013, NULL, SUM(coalesce([LTBongedierteBedrag], 0)))
		,[LTBongedierteAantal] = COUNT([LTBongedierteBedrag])
		,[LTBgrofvuilBedrag] = iif(ELS.Jaar < 2013, NULL, SUM(coalesce([LTBgrofvuilBedrag], 0)))
		,[LTBgrofvuilAantal] = COUNT([LTBgrofvuilBedrag])
	FROM empire_staedion_data.bik.ELS_AantalWoningenPerClusterUltimo AS ELS
	INNER JOIN empire_staedion_data.bik.ELS_ClusternummerBuurtCode AS CLBU ON ELS.Clusternummer = CLBU.Clusternummer
	INNER JOIN empire_staedion_data.bik.CBS_Buurt2020 AS GM ON CLBU.BuurtCode = GM.BuurtCode
	LEFT OUTER JOIN [staedion_dm].[Leefbaarheid].[ClusterKenmerkenContactPersonen] AS CB ON ELS.Clusternummer = CB.Clusternummer
	LEFT OUTER JOIN [staedion_dm].[Leefbaarheid].[Leefbaarheidsdossiers] AS LBD ON ELS.Clusternummer = LBD.Clusternummer
		AND ELS.Jaar = LBD.Jaar
	LEFT OUTER JOIN empire_staedion_data.bik.LeefbaarheidsuitgavenGrootboek AS GB ON ELS.Clusternummer = GB.Clusternummer
		AND ELS.Jaar = GB.Jaar
	GROUP BY GM.GemeenteCode
		,GM.WijkCode
		,CLBU.BuurtCode
		,ELS.Jaar
	)
	,cte01
AS (
	SELECT Jaar
		,[AVGVerlichtingAlgRui1tot5] = AVG(Antwoord)
		,[STD Verlichting Alg Rui 1tot5] = STDEV(Antwoord)
		,[CNT Verlichting Alg Rui 1tot5] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'De algemene ruimten hebben goede verlichting'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte02
AS (
	SELECT Jaar
		,[AVGSchoonAlgRui] = AVG(Antwoord)
		,[STD Schoon Alg Rui] = STDEV(Antwoord)
		,[CNT Schoon Alg Rui] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'De algemene ruimten zijn schoon en netjes'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte03
AS (
	SELECT Jaar
		,[AVGBewonersBuurt] = AVG(Antwoord)
		,[STD Bewoners Buurt] = STDEV(Antwoord)
		,[CNT Bewoners Buurt] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'De omgang met uw buurtgenoten'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte04
AS (
	SELECT Jaar
		,[AVGBewonersBuren1tot10] = AVG(Antwoord)
		,[STD Bewoners Buren 1tot10] = STDEV(Antwoord)
		,[CNT Bewoners Buren 1tot10] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'De omgang met uw directe buren'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte05
AS (
	SELECT Jaar
		,[AVGBewonersBuurtGeenHangjongeren] = AVG(Antwoord)
		,[STD Bewoners Buurt Geen Hangjongeren] = STDEV(Antwoord)
		,[CNT Bewoners Buurt Geen Hangjongeren] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Hangjongeren Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte06
AS (
	SELECT Jaar
		,[AVGBewonersBuren1tot5] = AVG(Antwoord)
		,[STD Bewoners Buren 1tot5] = STDEV(Antwoord)
		,[CNT Bewoners Buren 1tot5] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Het contact met mijn buren is prettig en voldoende'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte07
AS (
	SELECT Jaar
		,[AVGVeiligheidBuurtNacht] = AVG(Antwoord)
		,[STD Veiligheid Buurt Nacht] = STDEV(Antwoord)
		,[CNT Veiligheid Buurt Nacht] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Hoe ervaart u het gevoel van veiligheid op straat (''s avonds en/of ''s nachts) zeer onveilig, enigszins onveilig, neutraal, redelijk veilig, zeer veilig'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte08
AS (
	SELECT Jaar
		,[AVGVerlichtingTrap] = AVG(Antwoord)
		,[STD Verlichting Trap] = STDEV(Antwoord)
		,[CNT Verlichting Trap] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Hoe waardeert u de verlichting in het openbare trappenhuis'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte09
AS (
	SELECT Jaar
		,[AVGBewonersBuurtGeenOverlast] = AVG(Antwoord)
		,[STD Bewoners Buurt Geen Overlast] = STDEV(Antwoord)
		,[CNT Bewoners Buurt Geen Overlast] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Ik heb geen overlast van mensen in mijn buurt'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte10
AS (
	SELECT Jaar
		,[AVGVeiligheidAlgRui1tot5] = AVG(Antwoord)
		,[STD Veiligheid Alg Rui 1tot5] = STDEV(Antwoord)
		,[CNT Veiligheid Alg Rui 1tot5] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Ik voel me veilig in de algemene ruimten'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte11
AS (
	SELECT Jaar
		,[AVGVeiligheidWoning] = AVG(Antwoord)
		,[STD Veiligheid Woning] = STDEV(Antwoord)
		,[CNT Veiligheid Woning] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Ik voel me veilig in mijn woning'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte12
AS (
	SELECT Jaar
		,[AVGVeiligheidBuurt] = AVG(Antwoord)
		,[STD Veiligheid Buurt] = STDEV(Antwoord)
		,[CNT Veiligheid Buurt] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Ik voel mij veilig in de buurt'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte13
AS (
	SELECT Jaar
		,[AVGVeiligheidWoningTegenInbraak] = AVG(Antwoord)
		,[STD Veiligheid Woning Tegen Inbraak] = STDEV(Antwoord)
		,[CNT Veiligheid Woning Tegen Inbraak] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Ik woon in een woning die veilig is tegen inbraak'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte14
AS (
	SELECT Jaar
		,[AVGSchoonBuurt1tot5] = AVG(Antwoord)
		,[STD Schoon Buurt 1tot5] = STDEV(Antwoord)
		,[CNT Schoon Buurt 1tot5] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Mijn buurt is schoon en netjes'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte15
AS (
	SELECT Jaar
		,[AVGBewonersBuurtGeenVandalisme] = AVG(Antwoord)
		,[STD Bewoners Buurt Geen Vandalisme] = STDEV(Antwoord)
		,[CNT Bewoners Buurt Geen Vandalisme] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Vandalisme Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte16
AS (
	SELECT Jaar
		,[AVGThuisgevoelWoning0of1] = AVG(Antwoord)
		,[STDThuisgevoelWoning0of1] = STDEV(Antwoord)
		,[CNTThuisgevoelWoning0of1] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Voelt u zich thuis in uw woning van Staedion'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte17
AS (
	SELECT Jaar
		,[AVGVeiligheidTrap] = AVG(Antwoord)
		,[STD Veiligheid Trap] = STDEV(Antwoord)
		,[CNT Veiligheid Trap] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Wat vindt u van de veiligheid in het trappenhuis'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte18
AS (
	SELECT Jaar
		,[AVGKwaliteitWoning] = AVG(Antwoord)
		,[STD Kwaliteit Woning] = STDEV(Antwoord)
		,[CNT Kwaliteit Woning] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Welk cijfer geeft u voor de kwaliteit van uw woning'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte19
AS (
	SELECT Jaar
		,[AVGKwaliteitBuurt] = AVG(Antwoord)
		,[STD Kwaliteit Buurt] = STDEV(Antwoord)
		,[CNT Kwaliteit Buurt] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Welk rapportcijfer geeft u over uw eerste en algemene indruk van uw directe woonomgeving of Welk rapportcijfer geeft u voor uw buurt'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte20
AS (
	SELECT Jaar
		,[AVGKwaliteitAlgRui] = AVG(Antwoord)
		,[STD Kwaliteit Alg Rui] = STDEV(Antwoord)
		,[CNT Kwaliteit Alg Rui] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Welk rapportcijfer geeft u voor de netheid en uitstraling van de algemene ruimten of Welk rapportcijfer geeft u Staedion voor de algemene ruimten rondom uw woning'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte21
AS (
	SELECT Jaar
		,[AVGVerlichtingAlgRui1tot10] = AVG(Antwoord)
		,[STD Verlichting Alg Rui 1tot10] = STDEV(Antwoord)
		,[CNT Verlichting Alg Rui 1tot10] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Welk rapportcijfer geeft u voor de verlichting in de algemene ruimten'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte22
AS (
	SELECT Jaar
		,[AVGVeiligheidAlgRui1tot10] = AVG(Antwoord)
		,[STD Veiligheid Alg Rui 1tot10] = STDEV(Antwoord)
		,[CNT Veiligheid Alg Rui 1tot10] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Welk rapportcijfer geeft u voor uw gevoel van veiligheid in de algemene ruimten'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte23
AS (
	SELECT Jaar
		,[AVGThuisgevoelWoning1tot10] = AVG(Antwoord)
		,[STD Thuisgevoel Woning 1tot10] = STDEV(Antwoord)
		,[CNTThuisgevoelWoning1tot10] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Welk rapportcijfer geeft u voor uw thuisgevoel'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
	,cte24
AS (
	SELECT Jaar
		,[AVGSchoonBuurt1tot10] = AVG(Antwoord)
		,[STD Schoon Buurt 1tot10] = STDEV(Antwoord)
		,[CNT Schoon Buurt 1tot10] = Count(Antwoord)
		,BuurtCode
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Zwerfvuil in de wijk Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast'
	GROUP BY Vraag
		,Jaar
		,BuurtCode
	)
SELECT DISTINCT GemeenteCode = cte00.GemeenteCode
	,WijkCode = cte00.WijkCode
	,BuurtCode = cte00.BuurtCode
	,BUCode = cte00.BUcode
	,Buurt = BU.BuurtNaam
	,Jaar = cte00.Jaar
	,Thuisteam = THTE.Thuisteam
	,AantalWoningen
	,[AVGThuisgevoelWoning0of1]
	--,[AVGThuisgevoelWoning1tot10]
	,[AVGThuisgevoelWoningCijferNORM] = CASE 
		WHEN [AVGThuisgevoelWoning1tot10] IS NOT NULL
			THEN (cast([AVGThuisgevoelWoning1tot10] AS FLOAT) - 1) / 9
		ELSE NULL
		END
	--,[AVGKwaliteitWoning]
	,[AVGKwaliteitWoningNORM] = CASE 
		WHEN [AVGKwaliteitWoning] IS NOT NULL
			THEN (cast([AVGKwaliteitWoning] AS FLOAT) - 1) / 9
		ELSE NULL
		END
	--,[AVGKwaliteitAlgRui]
	,[AVGKwaliteitAlgemeneRuimteNORM] = CASE 
		WHEN [AVGKwaliteitAlgRui] IS NOT NULL
			THEN (cast([AVGKwaliteitAlgRui] AS FLOAT) - 1) / 9
		ELSE NULL
		END
	--,[AVGKwaliteitBuurt]
	,[AVGKwaliteitBuurtNORM] = CASE 
		WHEN [AVGKwaliteitBuurt] IS NOT NULL
			THEN (cast([AVGKwaliteitBuurt] AS FLOAT) - 1) / 9
		ELSE NULL
		END
	--,[AVGBewonersBuren1tot5]
	--,[AVGBewonersBuren1tot10]
	,[AVGBewonersBurenNORM] = CASE 
		WHEN [AVGBewonersBuren1tot10] IS NOT NULL
			THEN (cast([AVGBewonersBuren1tot10] AS FLOAT) - 1) / 9
		WHEN [AVGBewonersBuren1tot5] IS NOT NULL
			THEN (cast([AVGBewonersBuren1tot5] AS FLOAT) - 1) / 4
		ELSE NULL
		END
	--,[AVGBewonersBuurt]
	--,[AVGBewonersBuurtGeenOverlast]
	,[AVGBewonersBuurtNORM] = CASE 
		WHEN [AVGBewonersBuurt] IS NOT NULL
			THEN (cast([AVGBewonersBuurt] AS FLOAT) - 1) / 9
		WHEN [AVGBewonersBuurtGeenOverlast] IS NOT NULL
			THEN (cast([AVGBewonersBuurtGeenOverlast] AS FLOAT) - 1) / 4
		ELSE NULL
		END
	--,[AVGBewonersBuurtGeenHangjongeren]
	--,[AVGBewonersBuurtGeenVandalisme]
	--,[AVGVeiligheidWoning]
	,[AVGVeiligheidWoningNORM] = CASE 
	WHEN [AVGVeiligheidWoning] IS NOT NULL
		THEN (cast([AVGVeiligheidWoning] AS FLOAT) - 1) / 4
	ELSE NULL
	END
	--,[AVGVeiligheidWoningTegenInbraak]
	,[AVGVeiligheidWoningTegenInbraakNORM] = CASE 
	WHEN [AVGVeiligheidWoningTegenInbraak] IS NOT NULL
		THEN (cast([AVGVeiligheidWoningTegenInbraak] AS FLOAT) - 1) / 4
	ELSE NULL
	END
	--,[AVGVeiligheidAlgRui1tot5]
	--,[AVGVeiligheidAlgRui1tot10]
	,[AVGVeiligheidAlgemeneRuimteNORM] = CASE 
		WHEN [AVGVeiligheidAlgRui1tot10] IS NOT NULL
			THEN (cast([AVGVeiligheidAlgRui1tot10] AS FLOAT) - 1) / 9
		WHEN [AVGVeiligheidAlgRui1tot5] IS NOT NULL
			THEN (cast([AVGVeiligheidAlgRui1tot5] AS FLOAT) - 1) / 4
		ELSE NULL
		END
	--,[AVGVeiligheidTrap]
	--,[AVGVeiligheidBuurt]
	--,[AVGVeiligheidBuurtNacht]
	,[AVGVeiligheidBuurt1920Nacht1518NORM] = CASE 
		WHEN [AVGVeiligheidBuurt] IS NOT NULL
			THEN (cast([AVGVeiligheidBuurt] AS FLOAT) - 1) / 4
		WHEN [AVGVeiligheidBuurtNacht] IS NOT NULL
			THEN (cast([AVGVeiligheidBuurtNacht] AS FLOAT) - 1) / 4
		ELSE NULL
		END
	--,[AVGVerlichtingAlgRui1tot5]
	--,[AVGVerlichtingAlgRui1tot10]
	,[AVGVerlichtingAlgemeneRuimteNORM] = CASE 
		WHEN [AVGVerlichtingAlgRui1tot10] IS NOT NULL
			THEN (cast([AVGVerlichtingAlgRui1tot10] AS FLOAT) - 1) / 9
		WHEN [AVGVerlichtingAlgRui1tot5] IS NOT NULL
			THEN (cast([AVGVerlichtingAlgRui1tot5] AS FLOAT) - 1) / 4
		ELSE NULL
		END
	--,[AVGVerlichtingTrap]
	--,[AVGSchoonAlgRui]
	,[AVGSchoonAlgemeneRuimteNORM] = CASE 
		--WHEN [AVGSchoonAlgRui1tot10] IS NOT NULL
		--	THEN (cast([AVGSchoonAlgRui1tot10] AS FLOAT) - 1) / 9
		WHEN [AVGSchoonAlgRui] IS NOT NULL
			THEN (cast([AVGSchoonAlgRui] AS FLOAT) - 1) / 4
		ELSE NULL
		END
	--,[AVGSchoonBuurt1tot5]
	--,[AVGSchoonBuurt1tot10]
	,[AVGSchoonBuurtNORM] = CASE 
		WHEN [AVGSchoonBuurt1tot10] IS NOT NULL
			THEN (cast([AVGSchoonBuurt1tot10] AS FLOAT) - 1) / 9
		WHEN [AVGSchoonBuurt1tot5] IS NOT NULL
			THEN (cast([AVGSchoonBuurt1tot5] AS FLOAT) - 1) / 4
		ELSE NULL
		END
	,cte00.AantalBewonerscommissies
	,cte00.AantalHuismeesters
	,EenzijdigeWijk = case when EZW.[Soort wijk] = 'Eenzijdige wijk' then 'Ja' else 'Nee' end
	,[Klasse]
	,[ScoreTotaalRelatief]
	,[ScoreTotaalAbsoluut]
	,[ScoreWoningRelatief]
	,[ScoreBewonersRelatief]
	,[ScoreVoorzieningenRelatief]
	,[ScoreVeiligheidRelatief]
	,[ScoreFysiekeOmgevingRelatief]
	,[AantalInwoners]
	,[Mannen]
	,[Vrouwen]
	,[k_0Tot15Jaar]
	,[k_15Tot25Jaar]
	,[k_25Tot45Jaar]
	,[k_45Tot65Jaar]
	,[k_65JaarOfOuder]
	,[Ongehuwd]
	,[Gehuwd]
	,[Gescheiden]
	,[Verweduwd]
	,[WestersTotaal]
	,[NietWestersTotaal]
	,[Marokko]
	,[NederlandseAntillenEnAruba]
	,[Suriname]
	,[Turkije]
	,[OverigNietWesters]
	,[GeboorteTotaal]
	,[GeboorteRelatief]
	,[SterfteTotaal]
	,[SterfteRelatief]
	,[HuishoudensTotaal]
	,[Eenpersoonshuishoudens]
	,[HuishoudensZonderKinderen]
	,[HuishoudensMetKinderen]
	,[GemiddeldeHuishoudensgrootte]
	,[Bevolkingsdichtheid]
	,[Woningvoorraad]
	,StaedionWoningen = cte00.AantalWoningen
	,[GemiddeldeWoningwaarde]
	,[PercentageEengezinswoning]
	,[PercentageMeergezinswoning]
	,[PercentageBewoond]
	,[PercentageOnbewoond]
	,[Koopwoningen]
	,[HuurwoningenTotaal]
	,[InBezitWoningcorporatie]
	,[InBezitStaedion] = round(((cast(cte00.AantalWoningen AS FLOAT) / cast([Woningvoorraad] AS FLOAT)) * 100), 1)
	,[InBezitOverigeVerhuurders]
	,[EigendomOnbekend]
	,[BouwjaarVoor2000]
	,[BouwjaarVanaf2000]
	,[GemiddeldElektriciteitsverbruikTotaal]
	,[kWhAppartement]
	,[kWhTussenwoning]
	,[kWhHoekwoning]
	,[kWhTweeOnderEenKapWoning]
	,[kWhVrijstaandeWoning]
	,[kWhHuurwoning]
	,[kWhEigenWoning]
	,[GemiddeldAardgasverbruikTotaal]
	,[m3Appartement]
	,[m3Tussenwoning]
	,[m3Hoekwoning]
	,[m3TweeOnderEenKapWoning]
	,[m3VrijstaandeWoning]
	,[m3Huurwoning]
	,[m3EigenWoning]
	,[PercentageWoningenMetStadsverwarming]
	,[AantalInkomensontvangers]
	,[GemiddeldInkomenPerInkomensontvanger]
	,[GemiddeldInkomenPerInwoner]
	,[k_40PersonenMetLaagsteInkomen]
	,[k_20PersonenMetHoogsteInkomen]
	,[Actieven1575Jaar]
	,[k_40HuishoudensMetLaagsteInkomen]
	,[k_20HuishoudensMetHoogsteInkomen]
	,[HuishoudensMetEenLaagInkomen]
	,[HuishOnderOfRondSociaalMinimum]
	,[PersonenPerSoortUitkeringBijstand]
	,[PersonenPerSoortUitkeringAO]
	,[PersonenPerSoortUitkeringWW]
	,[PersonenPerSoortUitkeringAOW]
	,[BedrijfsvestigingenTotaal]
	,[ALandbouwBosbouwEnVisserij]
	,[BFNijverheidEnEnergie]
	,[GIHandelEnHoreca]
	,[HJVervoerInformatieEnCommunicatie]
	,[KLFinancieleDienstenOnroerendGoed]
	,[MNZakelijkeDienstverlening]
	,[RUCultuurRecreatieOverigeDiensten]
	,[PersonenautoSTotaal]
	,[PersonenautoSJongerDan6Jaar]
	,[PersonenautoS6JaarEnOuder]
	,[PersonenautoSBrandstofBenzine]
	,[PersonenautoSOverigeBrandstof]
	,[PersonenautoSPerHuishouden]
	,[PersonenautoSNaarOppervlakte]
	,[Bedrijfsmotorvoertuigen]
	,[Motorfietsen]
	,[AfstandTotHuisartsenpraktijk]
	,[AfstandTotGroteSupermarkt]
	,[AfstandTotKinderdagverblijf]
	,[AfstandTotSchool]
	,[ScholenBinnen3Km]
	,[OppervlakteTotaal]
	,[OppervlakteLand]
	,[OppervlakteWater]
	,[MeestVoorkomendePostcode]
	,[Dekkingspercentage]
	,[MateVanStedelijkheid]
	,[Omgevingsadressendichtheid]
	,[TotaalDiefstalUitWoningSchuurED]
	,[VernielingMisdrijfTegenOpenbareOrde]
	,[GeweldsEnSeksueleMisdrijven]
	,[OnrechtmatigGebruikPerWoning]
	,[OverlastPerWoning]
	,[AantalClusters]
	--,[LFOsociaalOmschrijving]
	,[LFOsociaalBedrag]
	,[LFOsociaalBedragPerWoning] = [LFOsociaalBedrag] / CAST(cte00.AantalWoningen AS FLOAT)
	,[LFOsociaalAantal]
	--,[LTBtechnischOmschrijving]
	,[LTBtechnischBedrag]
	,[LTBtechnischBedragPerWoning] = [LTBtechnischBedrag] / CAST(cte00.AantalWoningen AS FLOAT)
	,[LTBtechnischAantal]
	--,[LTBschoonOmschrijving]
	,[LTBschoonBedrag]
	,[LTBschoonBedragPerWoning] = [LTBschoonBedrag] / CAST(cte00.AantalWoningen AS FLOAT)
	,[LTBschoonAantal]
	--,[LTBalgemeneruimteOmschrijving]
	,[LTBalgemeneruimteBedrag]
	,[LTBalgemeneruimteBedragPerWoning] = [LTBalgemeneruimteBedrag] / CAST(cte00.AantalWoningen AS FLOAT)
	,[LTBalgemeneruimteAantal]
	--,[LTBveiligOmschrijving]
	,[LTBveiligBedrag]
	,[LTBveiligBedragPerWoning] = [LTBveiligBedrag] / CAST(cte00.AantalWoningen AS FLOAT)
	,[LTBveiligAantal]
	--,[LTBongedierteOmschrijving]
	,[LTBongedierteBedrag]
	,[LTBongedierteBedragPerWoning] = [LTBongedierteBedrag] / CAST(cte00.AantalWoningen AS FLOAT)
	,[LTBongedierteAantal]
	,[LTBgrofvuilBedrag]
	,[LTBgrofvuilBedragPerWoning] = [LTBgrofvuilBedrag] / CAST(cte00.AantalWoningen AS FLOAT)
	,[LTBgrofvuilAantal]
FROM cte00
INNER JOIN empire_staedion_data.bik.CBS_Buurt2020 AS BU on cte00.BuurtCode = BU.BuurtCode
INNER JOIN empire_staedion_data.bik.ELS_BuurtCodeThuisteam AS THTE on cte00.BuurtCode = THTE.BuurtCode
left outer join [empire_staedion_data].[bik].[BuurtGelabeldAlsEenzijdigeWijk] as EZW on cte00.BUcode = EZW.[sleutel buurt]
LEFT OUTER JOIN [staedion_dm].[Leefbaarheid].[Leefbaarometer] AS LBM ON cte00.BuurtCode = LBM.BuurtCode
	AND cte00.Jaar = LBM.Jaar
LEFT OUTER JOIN [staedion_dm].[Leefbaarheid].[CBSBuurtgegevens] AS CBS ON cte00.BuurtCode = CBS.BuurtCode
	AND CASE 
		WHEN cte00.Jaar < 2016
			THEN 2016
		WHEN cte00.Jaar > 2019
			THEN 2019
		ELSE cte00.Jaar
		END = CBS.Jaar
LEFT OUTER JOIN cte01 ON cte00.BuurtCode = cte01.BuurtCode
	AND cte00.Jaar = cte01.Jaar
LEFT OUTER JOIN cte02 ON cte00.BuurtCode = cte02.BuurtCode
	AND cte00.Jaar = cte02.Jaar
LEFT OUTER JOIN cte03 ON cte00.BuurtCode = cte03.BuurtCode
	AND cte00.Jaar = cte03.Jaar
LEFT OUTER JOIN cte04 ON cte00.BuurtCode = cte04.BuurtCode
	AND cte00.Jaar = cte04.Jaar
LEFT OUTER JOIN cte05 ON cte00.BuurtCode = cte05.BuurtCode
	AND cte00.Jaar = cte05.Jaar
LEFT OUTER JOIN cte06 ON cte00.BuurtCode = cte06.BuurtCode
	AND cte00.Jaar = cte06.Jaar
LEFT OUTER JOIN cte07 ON cte00.BuurtCode = cte07.BuurtCode
	AND cte00.Jaar = cte07.Jaar
LEFT OUTER JOIN cte08 ON cte00.BuurtCode = cte08.BuurtCode
	AND cte00.Jaar = cte08.Jaar
LEFT OUTER JOIN cte09 ON cte00.BuurtCode = cte09.BuurtCode
	AND cte00.Jaar = cte09.Jaar
LEFT OUTER JOIN cte10 ON cte00.BuurtCode = cte10.BuurtCode
	AND cte00.Jaar = cte10.Jaar
LEFT OUTER JOIN cte11 ON cte00.BuurtCode = cte11.BuurtCode
	AND cte00.Jaar = cte11.Jaar
LEFT OUTER JOIN cte12 ON cte00.BuurtCode = cte12.BuurtCode
	AND cte00.Jaar = cte12.Jaar
LEFT OUTER JOIN cte13 ON cte00.BuurtCode = cte13.BuurtCode
	AND cte00.Jaar = cte13.Jaar
LEFT OUTER JOIN cte14 ON cte00.BuurtCode = cte14.BuurtCode
	AND cte00.Jaar = cte14.Jaar
LEFT OUTER JOIN cte15 ON cte00.BuurtCode = cte15.BuurtCode
	AND cte00.Jaar = cte15.Jaar
LEFT OUTER JOIN cte16 ON cte00.BuurtCode = cte16.BuurtCode
	AND cte00.Jaar = cte16.Jaar
LEFT OUTER JOIN cte17 ON cte00.BuurtCode = cte17.BuurtCode
	AND cte00.Jaar = cte17.Jaar
LEFT OUTER JOIN cte18 ON cte00.BuurtCode = cte18.BuurtCode
	AND cte00.Jaar = cte18.Jaar
LEFT OUTER JOIN cte19 ON cte00.BuurtCode = cte19.BuurtCode
	AND cte00.Jaar = cte19.Jaar
LEFT OUTER JOIN cte20 ON cte00.BuurtCode = cte20.BuurtCode
	AND cte00.Jaar = cte20.Jaar
LEFT OUTER JOIN cte21 ON cte00.BuurtCode = cte21.BuurtCode
	AND cte00.Jaar = cte21.Jaar
LEFT OUTER JOIN cte22 ON cte00.BuurtCode = cte22.BuurtCode
	AND cte00.Jaar = cte22.Jaar
LEFT OUTER JOIN cte23 ON cte00.BuurtCode = cte23.BuurtCode
	AND cte00.Jaar = cte23.Jaar
LEFT OUTER JOIN cte24 ON cte00.BuurtCode = cte24.BuurtCode
	AND cte00.Jaar = cte24.Jaar
GO
