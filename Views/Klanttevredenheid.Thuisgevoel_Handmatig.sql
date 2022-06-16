SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [Klanttevredenheid].[Thuisgevoel_Handmatig] AS
/* #########################################################################################
--------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------
20210426 JvdW clusternr + clusternaam toegevoegd zodat Youness dit direct kan gebruiken in PBI 
> aantal rijen blijft gelijk
> 2 kolommen extra

--------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Klanttevredenheid', 'Thuisgevoel_Handmatig'

-- extended property toevoegen op object-niveau
USE staedion_dm;  
GO  
EXEC sys.sp_updateextendedproperty   
@name = N'MS_Description',   
@value = N'View die uit KCM via csv-download de gegevens van betreffende enquete haalt - vanaf 2019 (STN411) en 2020 (STN661) ',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel_Handmatig'
;  
EXEC sys.sp_addextendedproperty   
@name = N'Auteur',   
@value = N'JvdW',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel_Handmatig'
;  
EXEC sys.sp_addextendedproperty   
@name = N'VoorbeeldAanroep',   
@value = N'SELECT [Thuisgevoel ja/nee] = avg([Voelt zich thuis] * 1.00)
       ,[Thuisgevoel] = avg([Score thuisgevoel] * 1.00)
       ,[Woonkwaliteit] = avg([Score woningkwaliteit] * 1.00)
       ,[Score woningkwaliteit < 6] = avg([Score woningkwaliteit < 6] * 1.00)
       ,[Score woningkwaliteit > 8] = avg([Score woningkwaliteit > 8] * 1.00)
       ,[Aantal] = count(*)
FROM staedion_dm.[Klanttevredenheid].[Thuisgevoel_Handmatig]
WHERE year([Datum]) = 2020
       AND month([Datum]) = 1',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel_Handmatig'
;  
EXEC sys.sp_addextendedproperty   
@name = N'CNSAfhankelijk',   
@value = N'Nee',   
@level0type = N'SCHEMA', @level0name = 'Klanttevredenheid',  
@level1type = N'VIEW',  @level1name = 'Thuisgevoel_Handmatig'
;  


20210322 JvdW Na overleg met Youness historie toevoegen, in ieder geval alvast voor "Ervaren woonkwaliteit"
	-- 2020 + 2019 + 2014-2018
	SELECT YEAR([INGEVULDE GEGEVENS]),COUNT(*), MIN([INGEVULDE GEGEVENS]), MAX([INGEVULDE GEGEVENS])
	  FROM [empire_staedion_data].bik.STN661_Ingevulde_gegevens_2020
	  GROUP BY YEAR([INGEVULDE GEGEVENS])

	SELECT YEAR([INGEVULDE GEGEVENS]),COUNT(*), MIN([INGEVULDE GEGEVENS]), MAX([INGEVULDE GEGEVENS])
	  FROM [empire_staedion_data].bik.STN661_Ingevulde_gegevens_2019
	  GROUP BY YEAR([INGEVULDE GEGEVENS])

	SELECT YEAR([INGEVULDE GEGEVENS]),COUNT(*), MIN([INGEVULDE GEGEVENS]), MAX([INGEVULDE GEGEVENS])
	  FROM [empire_staedion_data].kcm.Thuisgevoel2014_okt_tm_2018_sep
	  GROUP BY YEAR([INGEVULDE GEGEVENS])

	SELECT YEAR([Datum]),COUNT(*), MIN([Datum]), MAX([Datum]), avg([Score woningkwaliteit])
	  FROM [Klanttevredenheid].[Thuisgevoel_Handmatig]
	  GROUP BY YEAR([Datum] )

######################################################################################### */    


SELECT
  [Datum]                                                   = CONVERT(DATE,kcm.[INGEVULDE GEGEVENS]),
  [Tijdstip]												= CONVERT(TIME,kcm.[INGEVULDE GEGEVENS]),
  [Postcode]												= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]												= kcm.eenheidnr,
  [Sleutel cluster] 										= cluster.lt_id,
  kcm.clusternr,
  Clusternaam = CLUS.[Naam],
  [Voelt zich thuis]                                        = kcm.[Voelt u zich thuis in uw woning van Staedion?] ,
  [Indicator Voelt zich thuis]                              = CASE WHEN kcm.[Voelt u zich thuis in uw woning van Staedion?] = 'Ja' THEN 1 ELSE 0 END,
  -- 20210201 JvdW toegevoegd
  [Voelt u zich thuis in uw buurt]                          = kcm.[Voelt u zich thuis in uw buurt?] ,
  [Indicator Voelt zich thuis in buurt]                     = CASE WHEN kcm.[Voelt u zich thuis in uw buurt?] = 'Ja' THEN 1 ELSE 0 END,
  [Algemene ruimte aanwezig]                                = CASE WHEN kcm.[Zijn er algemene ruimten rondom uw woning?]  = 'Ja' THEN 1 ELSE 0 END,
  -- [Vragen overgeslagen]                                     = case when kcm.[Zijn er nog zaken die u nog niet eerder in het onderzoek genoemd heeft waarmee Staedion uw 'thuisgevoel' kan vergroten?] = 1 then 'Ja' else 'Nee' end,
	-- Vraag verwijderd vanaf 2020
  [Verhuizen binnen een jaar]                               = NULL, 
  [Gezinssamenstelling]                                     = NULL, -- 20210105 niet meer van toepassing kcm.[Wat is uw huishoudsituatie?],
  [Financiele situatie]                                     = NULL, -- 20210105 niet meer van toepassing kcm.[Welke omschrijving past het beste bij de financiÃ«le situatie va],
	-- Vraag verwijderd vanaf 2020
  [Aantal personen inwonend]                                = NULL,
  [Gezondheid]                                              = NULL, -- 20210105 niet meer van toepassing kcm.[Welke omschrijving past momenteel het beste bij de gezondheid va],
  [Hulpafhankelijk]                                         = NULL, -- 20210105 niet meer van toepassing kcm.[In welke mate heeft u/uw gezin momenteel hulp of ondersteuning v],
 --- [Toesteming voor contact]                                 = case when kcm.[Mag Staedion eventueel contact met u opnemen over uw antwoorden?] = 1 then 'Ja' else 'Nee' end,
  [Suggesties]                                              = NULL, -- 20210105 niet meer van toepassing  -- convert(nvarchar(1000),kcm.[Namelijk:]),
  [Score thuisgevoel]                                       = kcm.[Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi],
  [Score woningkwaliteit]                                   = kcm.[Welk rapportcijfer geeft u voor de kwaliteit van uw woning? Een ],
  [Score woningkwaliteit < 6]                               = CASE WHEN kcm.[Welk rapportcijfer geeft u voor de kwaliteit van uw woning? Een ]  IS NOT NULL 
																	THEN  IIF(kcm.[Welk rapportcijfer geeft u voor de kwaliteit van uw woning? Een ]<6,1,0) END ,
  [Score woningkwaliteit >= 8]                              = CASE WHEN kcm.[Welk rapportcijfer geeft u voor de kwaliteit van uw woning? Een ] IS NOT NULL 
																	THEN  IIF(kcm.[Welk rapportcijfer geeft u voor de kwaliteit van uw woning? Een ]>=8,1,0) END,
	-- Vraag nader gespecificeerd vanaf 2020 
  [Score staat keuken/badkamer/toilet]                      = NULL,
  
  -- 20220211 JvdW: 8 onderdelen van kwaliteit woning  
  [Score staat keuken]										= kcm.[De kwaliteit van de keuken is goed#],			 -- 20220211 JvdW opnieuw toegevoegd
  [Score staat badkamer/toilet]								= kcm.[De kwaliteit van de badkamer en toilet is goed#], -- 20220211 JvdW opnieuw toegevoegd
  [Score energiezuinig]                                     = kcm.[Mijn woning is voldoende energiezuinig#],
  [Score gehorig]                                           = kcm.[Mijn woning is gehorig#],						 -- 20220211 JvdW opnieuw toegevoegd
  [Score gevoelstemperatuur]                                = kcm.[Ik heb last van vocht, tocht, schimmel#],		 -- 20220211 JvdW opnieuw toegevoegd	
  [Score prijskwaliteit]                                    = kcm.[De huur die ik betaal is goed vergeleken met de kwaliteit van de],
  [Score inbraakveilig]                                     = kcm.[Ik voel me veilig in mijn woning#],
  [Score geschikt voor lichamelijke beperking]				= kcm.[Mijn woning is geschikt om met een (lichte) lichamelijke beperki],

  [Score algemene ruimten]                                  = kcm.[Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron],
  [Score algemene ruimten netheid]                          = kcm.[De algemene ruimten zijn netjes en schoon#],
  [Score algemene ruimten verlichting]                      = kcm.[De algemene ruimten hebben goede verlichting#],
  [Score algemene ruimten veilig]                           = kcm.[Ik voel me veilig in de algemene ruimten#],
  [Score buurt]                                             = kcm.[Welk rapportcijfer geeft u voor uw buurt? Een 1 staat hier voor],
  --[Score buurt overlast]                                    = kcm.[Ik heb geen overlast van mensen in mijn buurt#],
  [Score buurt netheid]                                     = kcm.[Mijn buurt is schoon en netjes#],
  [Score buurt veilig]                                      = kcm.[Ik voel mij veilig in de buurt#],
  [Score buurt contact]                                     = kcm.[Het contact met mijn buren is prettig en voldoende#],


  -- 20220214 JvdW toegevoegd tbv detail-analyse in Staedion-dashboard
  [Thuisteam]												= kcm.[divisie],
  [Woningtype]												= kcm.[Woningtype],
  [Bouwjaarklasse]											= kcm.[Bouwjaarklasse],
  Bouwbloknr												= kcm.[Bouwblok],
  Bouwbloknaam												= kcm.[Bouwbloknaam]


-- select * 
FROM [empire_staedion_data].[kcm].[STN661_Ingevulde_gegevens] AS kcm
-- from Staging.kcm as kcm
LEFT JOIN empire_logic.dbo.lt_mg_oge AS oge ON 
  oge.mg_bedrijf = 'Staedion' AND
  oge.Nr_ = kcm.eenheidnr
LEFT JOIN empire_logic.dbo.lt_mg_cluster AS cluster ON			
  oge.mg_bedrijf = 'Staedion' AND
  cluster.Nr_ = kcm.clusternr
LEFT JOIN empire_data.dbo.staedion$cluster AS CLUS ON 
  CLUS.Nr_ = kcm.clusternr
  WHERE  YEAR(CONVERT(DATE,kcm.[INGEVULDE GEGEVENS])) >= 2021

UNION

SELECT
  [Datum]                                                   = CONVERT(DATE,kcm.[INGEVULDE GEGEVENS]),
  [Tijdstip]												= CONVERT(TIME,kcm.[INGEVULDE GEGEVENS]),
  [Postcode]												= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]												= kcm.eenheidnr,
  [Sleutel cluster] 										= cluster.lt_id,
  kcm.clusternr,
  Clusternaam = CLUS.[Naam],
  [Voelt zich thuis]                                        = kcm.[Voelt u zich thuis in uw woning van Staedion?] ,
  [Indicator Voelt zich thuis]                              = CASE WHEN kcm.[Voelt u zich thuis in uw woning van Staedion?] = 'Ja' THEN 1 ELSE 0 END,
  [Voelt u zich thuis in uw buurt]                          = NULL,
  [Indicator Voelt zich thuis in buurt]                     = NULL,
  [Algemene ruimte aanwezig]                                = CASE WHEN kcm.[Zijn er algemene ruimten rondom uw woning?  Met algemene ruimten]  = 'Ja' THEN 1 ELSE 0 END,

  -- [Vragen overgeslagen]                                     = case when kcm.[Zijn er nog zaken die u nog niet eerder in het onderzoek genoemd heeft waarmee Staedion uw 'thuisgevoel' kan vergroten?] = 1 then 'Ja' else 'Nee' end,
	-- Vraag verwijderd vanaf 2020
  [Verhuizen binnen een jaar]                               = NULL, 
  [Gezinssamenstelling]                                     = CONVERT(NVARCHAR(100), kcm.[Wat is uw huishoudsituatie?]),
  [Financiele situatie]                                     = kcm.[Welke omschrijving past het beste bij de financiÃ«le situatie va],
	-- Vraag verwijderd vanaf 2020
  [Aantal personen inwonend]                                = NULL,
  [Gezondheid]                                              = kcm.[Welke omschrijving past momenteel het beste bij de gezondheid va],
  [Hulpafhankelijk]                                         = kcm.[In welke mate heeft u/uw gezin momenteel hulp of ondersteuning v],
 --- [Toesteming voor contact]                                 = case when kcm.[Mag Staedion eventueel contact met u opnemen over uw antwoorden?] = 1 then 'Ja' else 'Nee' end,
  [Suggesties]                                              = kcm.[Namelijk:],
  [Score thuisgevoel]                                       = kcm.[Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi],
  [Score woningkwaliteit]                                   = kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa],
  [Score woningkwaliteit < 6]                               = CASE WHEN kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa] IS NOT NULL 
																 THEN  IIF(kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa]<6,1,0) END ,
  [Score woningkwaliteit > 8]                               = CASE WHEN kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa] IS NOT NULL 
																THEN  IIF(kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa]>8,1,0) END,
  -- Vraag nader gespecificeerd vanaf 2020 
  [Score staat keuken/badkamer/toilet]                      = kcm.[De kwaliteit van badkamer en toilet is goed#],

  -- 20220211 JvdW: 8 onderdelen van kwaliteit woning
  [Score staat keuken]										= NULL,
  [Score staat badkamer/toilet]								= NULL,
  [Score energiezuinig]                                     = kcm.[Mijn woning is voldoende energiezuinig#],
  [Score gehorig]                                           = kcm.[Mijn woning is niet gehorig#],
  [Score gevoelstemperatuur]                                = kcm.[Ik heb geen last van vocht, tocht, schimmel#],
  [Score prijskwaliteit]                                    = kcm.[De huur die ik betaal is goed vergeleken met de kwaliteit van de],
  [Score inbraakveilig]                                     = kcm.[Ik voel me veilig in mijn woning#],
  [Score geschikt voor lichamelijke beperking]				= NULL,

  [Score algemene ruimten]                                  = kcm.[Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron],
  [Score algemene ruimten netheid]                          = kcm.[De algemene ruimten zijn schoon en netjes#],
  [Score algemene ruimten verlichting]                      = kcm.[De algemene ruimten hebben goede verlichting#],
  [Score algemene ruimten veilig]                           = kcm.[Ik voel me veilig in de algemene ruimten#],
  [Score buurt]                                             = kcm.[Welk rapportcijfer geeft u voor uw buurt? Een 1 staat hier voor ],
  --[Score buurt overlast]                                    = kcm.[Ik heb geen overlast van mensen in mijn buurt#],
  [Score buurt netheid]                                     = kcm.[Mijn buurt is schoon en netjes#],
  [Score buurt veilig]                                      = kcm.[Ik voel mij veilig in de buurt#],
  [Score buurt contact]                                     = kcm.[Het contact met mijn buren is prettig en voldoende#],


  -- 20220214 JvdW toegevoegd tbv detail-analyse in Staedion-dashboard
  [Thuisteam]												= kcm.[divisie],
  [Woningtype]												= NULL,
  [Bouwjaarklasse]											= NULL,
  Bouwbloknr												= kcm.[Bouwblok],
  Bouwbloknaam												= kcm.[Bouwbloknaam]

  
FROM [empire_staedion_data].bik.STN661_Ingevulde_gegevens_2020 AS kcm
-- from Staging.kcm as kcm
LEFT JOIN empire_logic.dbo.lt_mg_oge AS oge ON 
  oge.mg_bedrijf = 'Staedion' AND
  oge.Nr_ = kcm.eenheidnr
LEFT JOIN empire_logic.dbo.lt_mg_cluster AS cluster ON 
  oge.mg_bedrijf = 'Staedion' AND
  cluster.Nr_ = kcm.clusternr
LEFT JOIN empire_data.dbo.staedion$cluster AS CLUS ON 
  CLUS.Nr_ = kcm.clusternr
WHERE  YEAR(CONVERT(DATE,kcm.[INGEVULDE GEGEVENS])) = 2020


UNION


SELECT
  [Datum]                                                   = CONVERT(DATE,kcm.[INGEVULDE GEGEVENS]),
  [Tijdstip]												= CONVERT(TIME,kcm.[INGEVULDE GEGEVENS]),
  [Postcode]												= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]												= kcm.eenheidnr,
  [Sleutel cluster] 										= cluster.lt_id,
  kcm.clusternr,
  Clusternaam = CLUS.[Naam],
  [Voelt zich thuis]                                        = kcm.[Voelt u zich thuis in uw woning van Staedion?] ,
  [Indicator Voelt zich thuis]                              = CASE WHEN kcm.[Voelt u zich thuis in uw woning van Staedion?] = 'Ja' THEN 1 ELSE 0 END,
  [Voelt u zich thuis in uw buurt]                          = NULL,
  [Indicator Voelt zich thuis in buurt]                     = NULL,
  [Algemene ruimte aanwezig]                                = CASE WHEN kcm.[Zijn er algemene ruimten rondom uw woning?  Met algemene ruimten]  = 'Ja' THEN 1 ELSE 0 END,

  -- [Vragen overgeslagen]                                     = case when kcm.[Zijn er nog zaken die u nog niet eerder in het onderzoek genoemd heeft waarmee Staedion uw 'thuisgevoel' kan vergroten?] = 1 then 'Ja' else 'Nee' end,
	-- Vraag verwijderd vanaf 2020
  [Verhuizen binnen een jaar]                               = NULL, 
  [Gezinssamenstelling]                                     = CONVERT(NVARCHAR(100), kcm.[Hoeveel personen wonen er in uw huis?]),
  [Financiele situatie]                                     = kcm.[Welke omschrijving past het beste bij de financiële situatie van],
	-- Vraag verwijderd vanaf 2020
  [Aantal personen inwonend]                                = NULL,
  [Gezondheid]                                              = kcm.[Welke omschrijving past momenteel het beste bij de gezondheid va],
  [Hulpafhankelijk]                                         = kcm.[In welke mate heeft u/uw gezin momenteel hulp of ondersteuning v],
 --- [Toesteming voor contact]                                 = case when kcm.[Mag Staedion eventueel contact met u opnemen over uw antwoorden?] = 1 then 'Ja' else 'Nee' end,
  [Suggesties]                                              = kcm.[Namelijk:],
  [Score thuisgevoel]                                       = kcm.[Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi],
  [Score woningkwaliteit]                                   = kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat],
  [Score woningkwaliteit < 6]                               = CASE WHEN kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat] IS NOT NULL 
																 THEN  IIF(kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat]<6,1,0) END ,
  [Score woningkwaliteit > 8]                               = CASE WHEN kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat] IS NOT NULL 
																THEN  IIF(kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat]>8,1,0) END,
	-- Vraag nader gespecificeerd vanaf 2020 
  [Score staat keuken/badkamer/toilet]                      = kcm.[De technische staat van keuken, badkamer en toilet is goed#],

  -- 20220211 JvdW: 8 onderdelen van kwaliteit woning
  [Score staat keuken]										= NULL,
  [Score staat badkamer/toilet]								= NULL,
  [Score energiezuinig]                                     = kcm.[Mijn woning is voldoende energiezuinig#],
  [Score gehorig]                                           = kcm.[Mijn woning is niet gehorig#],
  [Score gevoelstemperatuur]                                = kcm.[De temperatuur binnen in de woning is goed (geen last van vocht,],
  [Score prijskwaliteit]                                    = kcm.[De huur die ik betaal is goed vergeleken met de kwaliteit van de],
  [Score inbraakveilig]                                     = kcm.[Ik woon in een woning die veilig is tegen inbraak#],
  [Score geschikt voor lichamelijke beperking]				= NULL,

  [Score algemene ruimten]                                  = kcm.[Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron],
  [Score algemene ruimten netheid]                          = kcm.[De algemene ruimten zijn netjes en schoon#],
  [Score algemene ruimten verlichting]                      = kcm.[De algemene ruimten hebben goede verlichting#],
  [Score algemene ruimten veilig]                           = kcm.[Ik voel me veilig in de algemene ruimten#],
  [Score buurt]                                             = kcm.[Welk rapportcijfer geeft u uw buurt? Een 1 staat hier voor zeer ],
  --[Score buurt overlast]                                    = kcm.[Ik heb geen overlast van mensen in mijn buurt#],
  [Score buurt netheid]                                     = kcm.[Mijn buurt is schoon en netjes#],
  [Score buurt veilig]                                      = kcm.[Ik voel mij veilig in de buurt#],
  [Score buurt contact]                                     = kcm.[Het contact met mijn buren is prettig en voldoende#],


  -- 20220214 JvdW toegevoegd tbv detail-analyse in Staedion-dashboard
  [Thuisteam]												= kcm.[divisie],
  [Woningtype]												= NULL,
  [Bouwjaarklasse]											= NULL,
  Bouwbloknr												= kcm.[Bouwblok],
  Bouwbloknaam												= kcm.[Bouwbloknaam]

-- select * 
FROM [empire_staedion_data].bik.STN661_Ingevulde_gegevens_2019 AS kcm
-- from Staging.kcm as kcm
LEFT JOIN empire_logic.dbo.lt_mg_oge AS oge ON 
  oge.mg_bedrijf = 'Staedion' AND
  oge.Nr_ = kcm.eenheidnr
LEFT JOIN empire_logic.dbo.lt_mg_cluster AS cluster ON 
  oge.mg_bedrijf = 'Staedion' AND
  cluster.Nr_ = kcm.clusternr
LEFT JOIN empire_data.dbo.staedion$cluster AS CLUS ON 
  CLUS.Nr_ = kcm.clusternr
WHERE  YEAR(CONVERT(DATE,kcm.[INGEVULDE GEGEVENS])) = 2019



UNION


SELECT
  [Datum]                                                   = CONVERT(DATE,kcm.[INGEVULDE GEGEVENS]),
  [Tijdstip]												= CONVERT(TIME,kcm.[INGEVULDE GEGEVENS]),
  [Postcode]												= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]												= kcm.eenheidnr,
  [Sleutel cluster] 										= cluster.lt_id,
  kcm.clusternr,
  Clusternaam = CLUS.[Naam],
  [Voelt zich thuis]                                        = kcm.[Voelt u zich thuis in uw woning van Staedion?] ,
  [Indicator Voelt zich thuis]                              = CASE WHEN kcm.[Voelt u zich thuis in uw woning van Staedion?] = 'Ja' THEN 1 ELSE 0 END,
  [Voelt u zich thuis in uw buurt]                          = NULL,
  [Indicator Voelt zich thuis in buurt]                     = NULL,
  [Algemene ruimte aanwezig]                                = NULL, --case when kcm.[Zijn er algemene ruimten rondom uw woning?  Met algemene ruimten]  = 'Ja' then 1 else 0 end,

  -- [Vragen overgeslagen]                                     = case when kcm.[Zijn er nog zaken die u nog niet eerder in het onderzoek genoemd heeft waarmee Staedion uw 'thuisgevoel' kan vergroten?] = 1 then 'Ja' else 'Nee' end,
	-- Vraag verwijderd vanaf 2020
  [Verhuizen binnen een jaar]                               = NULL, 
  [Gezinssamenstelling]                                     = NULL, --convert(nvarchar(100), kcm.[Hoeveel personen wonen er in uw huis?]),
  [Financiele situatie]                                     = NULL, --kcm.[Welke omschrijving past het beste bij de financiële situatie van],
	-- Vraag verwijderd vanaf 2020
  [Aantal personen inwonend]                                = NULL,
  [Gezondheid]                                              = NULL, --kcm.[Welke omschrijving past momenteel het beste bij de gezondheid va],
  [Hulpafhankelijk]                                         = NULL, --kcm.[In welke mate heeft u/uw gezin momenteel hulp of ondersteuning v],
 --- [Toesteming voor contact]                                 = case when kcm.[Mag Staedion eventueel contact met u opnemen over uw antwoorden?] = 1 then 'Ja' else 'Nee' end,
  [Suggesties]                                              = NULL, --kcm.[Namelijk:],
  [Score thuisgevoel]                                       = kcm.[Welk rapportcijfer geeft u voor uw "thuisgevoel", ofwel het wonen in een woning van Staedion],
  [Score woningkwaliteit]                                   = kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?],
  [Score woningkwaliteit < 6]                               = CASE WHEN kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?] IS NOT NULL 
																 THEN  IIF(kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?]<6,1,0) END ,
  [Score woningkwaliteit > 8]                               = CASE WHEN kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?] IS NOT NULL 
																THEN  IIF(kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?]>8,1,0) END,
	-- Vraag nader gespecificeerd vanaf 2020 
  [Score staat keuken/badkamer/toilet]                      = NULL, --kcm.[De technische staat van keuken, badkamer en toilet is goed#],

  -- 20220211 JvdW: 8 onderdelen van kwaliteit woning
  [Score staat keuken]										= NULL,
  [Score staat badkamer/toilet]								= NULL,
  [Score energiezuinig]                                     = NULL, --kcm.[Mijn woning is voldoende energiezuinig#],
  [Score gehorig]                                           = NULL, --kcm.[Mijn woning is niet gehorig#],
  [Score gevoelstemperatuur]                                = NULL, --kcm.[De temperatuur binnen in de woning is goed (geen last van vocht,],
  [Score prijskwaliteit]                                    = NULL, --kcm.[De huur die ik betaal is goed vergeleken met de kwaliteit van de],
  [Score inbraakveilig]                                     = NULL, --kcm.[Ik woon in een woning die veilig is tegen inbraak#],
  [Score geschikt voor lichamelijke beperking]				= NULL,

  [Score algemene ruimten]                                  = NULL, --kcm.[Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron],
  [Score algemene ruimten netheid]                          = NULL, --kcm.[De algemene ruimten zijn netjes en schoon#],
  [Score algemene ruimten verlichting]                      = NULL, --kcm.[De algemene ruimten hebben goede verlichting#],
  [Score algemene ruimten veilig]                           = NULL, --kcm.[Ik voel me veilig in de algemene ruimten#],
  [Score buurt]                                             = NULL, --kcm.[Welk rapportcijfer geeft u uw buurt? Een 1 staat hier voor zeer ],
  --[Score buurt overlast]                                   = kcm.[Ik heb geen overlast van mensen in mijn buurt#],
  [Score buurt netheid]                                     = NULL, --kcm.[Mijn buurt is schoon en netjes#],
  [Score buurt veilig]                                      = NULL, --kcm.[Ik voel mij veilig in de buurt#],
  [Score buurt contact]                                     = NULL, --kcm.[Het contact met mijn buren is prettig en voldoende#]


  -- 20220214 JvdW toegevoegd tbv detail-analyse in Staedion-dashboard
  [Thuisteam]												= kcm.[divisie],
  [Woningtype]												= NULL,
  [Bouwjaarklasse]											= NULL,
  Bouwbloknr												= kcm.[Bouwblok],
  Bouwbloknaam												= kcm.[Bouwbloknaam]
-- select convert(date,kcm.[INGEVULDE GEGEVENS]),kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?],*
FROM [empire_staedion_data].kcm.Thuisgevoel2014_okt_tm_2018_sep AS kcm
-- from Staging.kcm as kcm
LEFT JOIN empire_logic.dbo.lt_mg_oge AS oge ON 
  oge.mg_bedrijf = 'Staedion' AND
  oge.Nr_ = kcm.eenheidnr
LEFT JOIN empire_logic.dbo.lt_mg_cluster AS cluster ON 
  oge.mg_bedrijf = 'Staedion' AND
  cluster.Nr_ = kcm.clusternr
LEFT JOIN empire_data.dbo.staedion$cluster AS CLUS ON 
  CLUS.Nr_ = kcm.clusternr
WHERE  YEAR(CONVERT(DATE,kcm.[INGEVULDE GEGEVENS])) < 2019



GO
EXEC sp_addextendedproperty N'Auteur', N'JvdW', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'Thuisgevoel_Handmatig', NULL, NULL
GO
EXEC sp_addextendedproperty N'CNSAfhankelijk', N'Nee', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'Thuisgevoel_Handmatig', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'View die uit KCM via csv-download de gegevens van betreffende enquete haalt - vanaf 2019 (STN411) en 2020 (STN661) ', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'Thuisgevoel_Handmatig', NULL, NULL
GO
EXEC sp_addextendedproperty N'VoorbeeldAanroep', N'SELECT [Thuisgevoel ja/nee] = avg([Indicator Voelt zich thuis] * 1.00)
       ,[Thuisgevoel] = avg([Score thuisgevoel] * 1.00)
       ,[Woonkwaliteit] = avg([Score woningkwaliteit] * 1.00)
       ,[Score woningkwaliteit < 6] = avg([Score woningkwaliteit < 6] * 1.00)
       ,[Score woningkwaliteit > 8] = avg([Score woningkwaliteit > 8] * 1.00)
       ,[Aantal] = count(*)
FROM staedion_dm.[Klanttevredenheid].[Thuisgevoel_Handmatig]
WHERE year([Datum]) = 2020
       AND month([Datum]) = 1', 'SCHEMA', N'Klanttevredenheid', 'VIEW', N'Thuisgevoel_Handmatig', NULL, NULL
GO
