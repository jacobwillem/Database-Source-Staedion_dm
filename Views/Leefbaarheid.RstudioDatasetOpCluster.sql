SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Leefbaarheid].[RstudioDatasetOpCluster]
AS
WITH cte01
AS (
	SELECT Jaar
		,[AVGVerlichtingAlgRui1tot5] = AVG(Antwoord)
		,[STD Verlichting Alg Rui 1tot5] = STDEV(Antwoord)
		,[CNT Verlichting Alg Rui 1tot5] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'De algemene ruimten hebben goede verlichting'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte02
AS (
	SELECT Jaar
		,[AVGSchoonAlgRui] = AVG(Antwoord)
		,[STD Schoon Alg Rui] = STDEV(Antwoord)
		,[CNT Schoon Alg Rui] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'De algemene ruimten zijn schoon en netjes'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte03
AS (
	SELECT Jaar
		,[AVGBewonersBuurt] = AVG(Antwoord)
		,[STD Bewoners Buurt] = STDEV(Antwoord)
		,[CNT Bewoners Buurt] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'De omgang met uw buurtgenoten'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte04
AS (
	SELECT Jaar
		,[AVGBewonersBuren1tot10] = AVG(Antwoord)
		,[STD Bewoners Buren 1tot10] = STDEV(Antwoord)
		,[CNT Bewoners Buren 1tot10] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'De omgang met uw directe buren'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte05
AS (
	SELECT Jaar
		,[AVGBewonersBuurtGeenHangjongeren] = AVG(Antwoord)
		,[STD Bewoners Buurt Geen Hangjongeren] = STDEV(Antwoord)
		,[CNT Bewoners Buurt Geen Hangjongeren] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Hangjongeren Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte06
AS (
	SELECT Jaar
		,[AVGBewonersBuren1tot5] = AVG(Antwoord)
		,[STD Bewoners Buren 1tot5] = STDEV(Antwoord)
		,[CNT Bewoners Buren 1tot5] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Het contact met mijn buren is prettig en voldoende'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte07
AS (
	SELECT Jaar
		,[AVGVeiligheidBuurtNacht] = AVG(Antwoord)
		,[STD Veiligheid Buurt Nacht] = STDEV(Antwoord)
		,[CNT Veiligheid Buurt Nacht] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Hoe ervaart u het gevoel van veiligheid op straat (''s avonds en/of ''s nachts) zeer onveilig, enigszins onveilig, neutraal, redelijk veilig, zeer veilig'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte08
AS (
	SELECT Jaar
		,[AVGVerlichtingTrap] = AVG(Antwoord)
		,[STD Verlichting Trap] = STDEV(Antwoord)
		,[CNT Verlichting Trap] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Hoe waardeert u de verlichting in het openbare trappenhuis'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte09
AS (
	SELECT Jaar
		,[AVGBewonersBuurtGeenOverlast] = AVG(Antwoord)
		,[STD Bewoners Buurt Geen Overlast] = STDEV(Antwoord)
		,[CNT Bewoners Buurt Geen Overlast] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Ik heb geen overlast van mensen in mijn buurt'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte10
AS (
	SELECT Jaar
		,[AVGVeiligheidAlgRui1tot5] = AVG(Antwoord)
		,[STD Veiligheid Alg Rui 1tot5] = STDEV(Antwoord)
		,[CNT Veiligheid Alg Rui 1tot5] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Ik voel me veilig in de algemene ruimten'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte11
AS (
	SELECT Jaar
		,[AVGVeiligheidWoning] = AVG(Antwoord)
		,[STD Veiligheid Woning] = STDEV(Antwoord)
		,[CNT Veiligheid Woning] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Ik voel me veilig in mijn woning'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte12
AS (
	SELECT Jaar
		,[AVGVeiligheidBuurt] = AVG(Antwoord)
		,[STD Veiligheid Buurt] = STDEV(Antwoord)
		,[CNT Veiligheid Buurt] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Ik voel mij veilig in de buurt'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte13
AS (
	SELECT Jaar
		,[AVGVeiligheidWoningTegenInbraak] = AVG(Antwoord)
		,[STD Veiligheid Woning Tegen Inbraak] = STDEV(Antwoord)
		,[CNT Veiligheid Woning Tegen Inbraak] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Ik woon in een woning die veilig is tegen inbraak'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte14
AS (
	SELECT Jaar
		,[AVGSchoonBuurt1tot5] = AVG(Antwoord)
		,[STD Schoon Buurt 1tot5] = STDEV(Antwoord)
		,[CNT Schoon Buurt 1tot5] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Mijn buurt is schoon en netjes'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte15
AS (
	SELECT Jaar
		,[AVGBewonersBuurtGeenVandalisme] = AVG(Antwoord)
		,[STD Bewoners Buurt Geen Vandalisme] = STDEV(Antwoord)
		,[CNT Bewoners Buurt Geen Vandalisme] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Vandalisme Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte16
AS (
	SELECT Jaar
		,[AVGThuisgevoelWoning0of1] = AVG(Antwoord)
		,[STDThuisgevoelWoning0of1] = STDEV(Antwoord)
		,[CNTThuisgevoelWoning0of1] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Voelt u zich thuis in uw woning van Staedion'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte17
AS (
	SELECT Jaar
		,[AVGVeiligheidTrap] = AVG(Antwoord)
		,[STD Veiligheid Trap] = STDEV(Antwoord)
		,[CNT Veiligheid Trap] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Wat vindt u van de veiligheid in het trappenhuis'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte18
AS (
	SELECT Jaar
		,[AVGKwaliteitWoning] = AVG(Antwoord)
		,[STD Kwaliteit Woning] = STDEV(Antwoord)
		,[CNT Kwaliteit Woning] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Welk cijfer geeft u voor de kwaliteit van uw woning'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte19
AS (
	SELECT Jaar
		,[AVGOmgevingBuurt] = AVG(Antwoord)
		,[STD Omgeving Buurt] = STDEV(Antwoord)
		,[CNT Omgeving Buurt] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Welk rapportcijfer geeft u over uw eerste en algemene indruk van uw directe woonomgeving of Welk rapportcijfer geeft u voor uw buurt'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte20
AS (
	SELECT Jaar
		,[AVGKwaliteitAlgRui] = AVG(Antwoord)
		,[STD Kwaliteit Alg Rui] = STDEV(Antwoord)
		,[CNT Kwaliteit Alg Rui] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Welk rapportcijfer geeft u voor de netheid en uitstraling van de algemene ruimten'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte21
AS (
	SELECT Jaar
		,[AVGVerlichtingAlgRui1tot10] = AVG(Antwoord)
		,[STD Verlichting Alg Rui 1tot10] = STDEV(Antwoord)
		,[CNT Verlichting Alg Rui 1tot10] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Welk rapportcijfer geeft u voor de verlichting in de algemene ruimten'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte22
AS (
	SELECT Jaar
		,[AVGVeiligheidAlgRui1tot10] = AVG(Antwoord)
		,[STD Veiligheid Alg Rui 1tot10] = STDEV(Antwoord)
		,[CNT Veiligheid Alg Rui 1tot10] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Welk rapportcijfer geeft u voor uw gevoel van veiligheid in de algemene ruimten'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte23
AS (
	SELECT Jaar
		,[AVGThuisgevoelWoning1tot10] = AVG(Antwoord)
		,[STDThuisgevoelWoning1tot10] = STDEV(Antwoord)
		,[CNTThuisgevoelWoning1tot10] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Welk rapportcijfer geeft u voor uw thuisgevoel'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
	,cte24
AS (
	SELECT Jaar
		,[AVGSchoonBuurt1tot10] = AVG(Antwoord)
		,[STD Schoon Buurt 1tot10] = STDEV(Antwoord)
		,[CNT Schoon Buurt 1tot10] = Count(Antwoord)
		,Clusternummer
	FROM Leefbaarheid.KlantcontactMonitor kcm
	WHERE Vraag = 'Zwerfvuil in de wijk Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast'
	GROUP BY Vraag
		,Jaar
		,Clusternummer
	)
SELECT Clusternummer = ELS.Clusternummer
	,GemeenteCode = GM.GemeenteCode
	,WijkCode = GM.WijkCode
	,BuurtCode = CLBU.BuurtCode
	,Jaar = ELS.Jaar
	,Thuisteam = THTE.Thuisteam
	,[AVGThuisgevoelWoning0of1]
	--,[AVGThuisgevoelWoning0of1T] = CASE 
	--	WHEN [CNTThuisgevoelWoning0of1] < 3 THEN NULL
	--	WHEN [CNTThuisgevoelWoning0of1] / cast(AantalWoningen as float) < 0.03 THEN NULL
	--	ELSE [AVGThuisgevoelWoning0of1]
	--	END
	--,[CNTThuisgevoelWoning0of1]
	--,[PCTThuisgevoelWoning0of1] = [CNTThuisgevoelWoning0of1] / cast(AantalWoningen as float)
	,[AVGThuisgevoelWoning1tot10]
	,[AVGKwaliteitWoning]
	,[AVGKwaliteitAlgRui]
	,[AVGBewonersBuren1tot5]
	,[AVGBewonersBuren1tot10]
	,[AVGBewonersBuurt]
	,[AVGBewonersBuurtGeenOverlast]
	,[AVGBewonersBuurtGeenHangjongeren]
	,[AVGBewonersBuurtGeenVandalisme]
	,[AVGVeiligheidWoning]
	,[AVGVeiligheidWoningTegenInbraak]
	,[AVGVeiligheidAlgRui1tot5]
	,[AVGVeiligheidAlgRui1tot10]
	,[AVGVeiligheidTrap]
	,[AVGVeiligheidBuurt]
	,[AVGVeiligheidBuurtNacht]
	,[AVGVerlichtingAlgRui1tot5]
	,[AVGVerlichtingAlgRui1tot10]
	,[AVGVerlichtingTrap]
	,[AVGSchoonAlgRui]
	,[AVGSchoonBuurt1tot5]
	,[AVGSchoonBuurt1tot10]
	,[AVGOmgevingBuurt]
	,[BewonerscommissieJN]
	,[HuismeesterJN]
	,EenzijdigeWijk = case when EZW.[Soort wijk] = 'Eenzijdige wijk' then 'Ja' else 'Nee' end
	,[TeamscoreOverlast] = coalesce(TS19.[Leefbaarheid:                                  A# Overlast], TS20.[Leefbaarheid:                                  A# Overlast])
	,[TeamscoreVervuiling] = coalesce(TS19.[Leefbaarheid:                                  B# Vervuiling], TS20.[Leefbaarheid:                                  B# Vervuiling])
	,[TeamscoreGemiddeldOverlastVervuiling] = coalesce(TS18.[Leefbaarheid / Overlast / Vervuiling], TS19.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling], TS20.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling])
	,[TeamscoreCriminaliteitWoonfraude] = coalesce(TS18.[Criminaliteit / Woonfraude], TS19.[Criminaliteit & Woonfraude], TS20.[Criminaliteit & Woonfraude])
	,[TeamscoreParticipatie] = coalesce(TS18.[Participatie], TS19.[Participatie], TS20.[Participatie])
	,[TeamscoreLeefkwaliteit] = coalesce(TS18.[Leefkwaliteit (portieken/ kelder/gedeelde ruimtes en directe woo], TS19.[Leefkwaliteit], TS20.[Leefkwaliteit])
	,[TeamscoreBeheerintensiteit] = coalesce(TS18.[Huidige beheerintensiteit], TS19.[Huidige beheerintensiteit], TS20.[Huidige beheerintensiteit])
	,[Teamscore] = coalesce((TS18.[Leefbaarheid / Overlast / Vervuiling] +
								TS18.[Criminaliteit / Woonfraude] +
								TS18.[Participatie] +
								TS18.[Leefkwaliteit (portieken/ kelder/gedeelde ruimtes en directe woo] +
								TS18.[Huidige beheerintensiteit]) / 5, 
								(TS19.[Gemiddelde Leefbaarheid: Overlast/ Vervuiling] +
								TS19.[Criminaliteit & Woonfraude] +
								TS19.[Participatie] +
								TS19.[Leefkwaliteit] +
								TS19.[Huidige beheerintensiteit]) / 5,
								((TS20.[Leefbaarheid:                                  A# Overlast] +
								  TS20.[Leefbaarheid:                                  B# Vervuiling]) / 2 +
								TS20.[Criminaliteit & Woonfraude] +
								TS20.[Participatie] +
								TS20.[Leefkwaliteit] +
								TS20.[Huidige beheerintensiteit]) / 5)
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
	,StaedionWoningen = ELS.AantalWoningen
	,[GemiddeldeWoningwaarde]
	,[PercentageEengezinswoning]
	,[PercentageMeergezinswoning]
	,[PercentageBewoond]
	,[PercentageOnbewoond]
	,[Koopwoningen]
	,[HuurwoningenTotaal]
	,[InBezitWoningcorporatie]
	,[InBezitStaedion] = round(((cast(ELS.AantalWoningen AS FLOAT) / cast([Woningvoorraad] AS FLOAT)) * 100), 1)
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
	,[OnrechtmatigGebruikPerEenheid] = iif(ELS.Jaar < 2016, NULL, coalesce(cast([AantalOnrechtmatigGebruikDossiers] AS FLOAT) / cast(ELS.AantalWoningen AS FLOAT), 0))
	,[OverlastPerEenheid] = iif(ELS.Jaar < 2016, NULL, coalesce(cast([AantalOverlastDossiers] AS FLOAT) / cast(ELS.AantalWoningen AS FLOAT), 0))
	,[LFOsociaalOmschrijving]
	,[LFOsociaalBedrag]
	,[LFOsociaalAantal]
	,[LTBtechnischOmschrijving]
	,[LTBtechnischBedrag]
	,[LTBtechnischAantal]
	,[LTBschoonOmschrijving]
	,[LTBschoonBedrag]
	,[LTBalgemeneruimteOmschrijving]
	,[LTBalgemeneruimteBedrag]
	,[LTBveiligOmschrijving]
	,[LTBveiligBedrag]
	,[LTBongedierteOmschrijving]
	,[LTBongedierteBedrag]
FROM empire_staedion_data.bik.ELS_AantalWoningenPerClusterUltimo AS ELS
INNER JOIN empire_staedion_data.bik.ELS_ClusternummerBuurtCode AS CLBU ON ELS.Clusternummer = CLBU.Clusternummer
INNER JOIN empire_staedion_data.bik.CBS_Buurt2020 AS GM ON CLBU.BuurtCode = GM.BuurtCode
INNER JOIN empire_staedion_data.bik.ELS_BuurtCodeThuisteam AS THTE ON CLBU.BuurtCode = THTE.BuurtCode
LEFT OUTER JOIN [staedion_dm].[Leefbaarheid].[ClusterKenmerkenContactPersonen] AS CB ON ELS.Clusternummer = CB.Clusternummer
LEFT OUTER JOIN [empire_staedion_data].[bik].[Teamscore2018] AS TS18 ON ELS.Clusternummer = TS18.clusternummer
	AND ELS.Jaar = TS18.Jaar
LEFT OUTER JOIN [empire_staedion_data].[bik].[Teamscore2019] AS TS19 ON ELS.Clusternummer = TS19.clusternummer
	AND ELS.Jaar = TS19.Jaar
LEFT OUTER JOIN [empire_staedion_data].[bik].[Teamscore2020] AS TS20 ON ELS.Clusternummer = TS20.clusternummer
	AND ELS.Jaar = TS20.Jaar
left outer join [empire_staedion_data].[bik].[BuurtGelabeldAlsEenzijdigeWijk] as EZW on N'BU' + RIGHT(N'00000000' + CAST(CLBU.BuurtCode AS NVARCHAR), 8) = EZW.[sleutel buurt]
LEFT OUTER JOIN [staedion_dm].[Leefbaarheid].[Leefbaarometer] AS LBM ON CLBU.BuurtCode = LBM.BuurtCode
	AND ELS.Jaar = LBM.Jaar
LEFT OUTER JOIN [staedion_dm].[Leefbaarheid].[CBSBuurtgegevens] AS CBS ON CLBU.BuurtCode = CBS.BuurtCode
	AND CASE 
		WHEN ELS.Jaar < 2016
			THEN 2016
		WHEN ELS.Jaar > 2019
			THEN 2019
		ELSE ELS.Jaar
		END = CBS.Jaar
LEFT OUTER JOIN [staedion_dm].[Leefbaarheid].[Leefbaarheidsdossiers] AS LBD ON ELS.Clusternummer = LBD.Clusternummer
	AND ELS.Jaar = LBD.Jaar
LEFT OUTER JOIN empire_staedion_data.bik.LeefbaarheidsuitgavenGrootboek AS GB ON ELS.Clusternummer = GB.Clusternummer
	AND ELS.Jaar = GB.Jaar
LEFT OUTER JOIN cte01 ON ELS.Clusternummer = cte01.Clusternummer
	AND ELS.Jaar = cte01.Jaar
LEFT OUTER JOIN cte02 ON ELS.Clusternummer = cte02.Clusternummer
	AND ELS.Jaar = cte02.Jaar
LEFT OUTER JOIN cte03 ON ELS.Clusternummer = cte03.Clusternummer
	AND ELS.Jaar = cte03.Jaar
LEFT OUTER JOIN cte04 ON ELS.Clusternummer = cte04.Clusternummer
	AND ELS.Jaar = cte04.Jaar
LEFT OUTER JOIN cte05 ON ELS.Clusternummer = cte05.Clusternummer
	AND ELS.Jaar = cte05.Jaar
LEFT OUTER JOIN cte06 ON ELS.Clusternummer = cte06.Clusternummer
	AND ELS.Jaar = cte06.Jaar
LEFT OUTER JOIN cte07 ON ELS.Clusternummer = cte07.Clusternummer
	AND ELS.Jaar = cte07.Jaar
LEFT OUTER JOIN cte08 ON ELS.Clusternummer = cte08.Clusternummer
	AND ELS.Jaar = cte08.Jaar
LEFT OUTER JOIN cte09 ON ELS.Clusternummer = cte09.Clusternummer
	AND ELS.Jaar = cte09.Jaar
LEFT OUTER JOIN cte10 ON ELS.Clusternummer = cte10.Clusternummer
	AND ELS.Jaar = cte10.Jaar
LEFT OUTER JOIN cte11 ON ELS.Clusternummer = cte11.Clusternummer
	AND ELS.Jaar = cte11.Jaar
LEFT OUTER JOIN cte12 ON ELS.Clusternummer = cte12.Clusternummer
	AND ELS.Jaar = cte12.Jaar
LEFT OUTER JOIN cte13 ON ELS.Clusternummer = cte13.Clusternummer
	AND ELS.Jaar = cte13.Jaar
LEFT OUTER JOIN cte14 ON ELS.Clusternummer = cte14.Clusternummer
	AND ELS.Jaar = cte14.Jaar
LEFT OUTER JOIN cte15 ON ELS.Clusternummer = cte15.Clusternummer
	AND ELS.Jaar = cte15.Jaar
LEFT OUTER JOIN cte16 ON ELS.Clusternummer = cte16.Clusternummer
	AND ELS.Jaar = cte16.Jaar
LEFT OUTER JOIN cte17 ON ELS.Clusternummer = cte17.Clusternummer
	AND ELS.Jaar = cte17.Jaar
LEFT OUTER JOIN cte18 ON ELS.Clusternummer = cte18.Clusternummer
	AND ELS.Jaar = cte18.Jaar
LEFT OUTER JOIN cte19 ON ELS.Clusternummer = cte19.Clusternummer
	AND ELS.Jaar = cte19.Jaar
LEFT OUTER JOIN cte20 ON ELS.Clusternummer = cte20.Clusternummer
	AND ELS.Jaar = cte20.Jaar
LEFT OUTER JOIN cte21 ON ELS.Clusternummer = cte21.Clusternummer
	AND ELS.Jaar = cte21.Jaar
LEFT OUTER JOIN cte22 ON ELS.Clusternummer = cte22.Clusternummer
	AND ELS.Jaar = cte22.Jaar
LEFT OUTER JOIN cte23 ON ELS.Clusternummer = cte23.Clusternummer
	AND ELS.Jaar = cte23.Jaar
LEFT OUTER JOIN cte24 ON ELS.Clusternummer = cte24.Clusternummer
	AND ELS.Jaar = cte24.Jaar
GO
