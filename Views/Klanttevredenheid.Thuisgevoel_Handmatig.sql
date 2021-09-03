SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Klanttevredenheid].[Thuisgevoel_Handmatig] as
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
  [Datum]                                                   = convert(date,kcm.[INGEVULDE GEGEVENS]),
  [Tijdstip]												= convert(time,kcm.[INGEVULDE GEGEVENS]),
  [Postcode]												= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]												= kcm.eenheidnr,
  [Sleutel cluster] 										= cluster.lt_id,
  kcm.clusternr,
  Clusternaam = CLUS.[Naam],
  [Voelt zich thuis]                                        = kcm.[Voelt u zich thuis in uw woning van Staedion?] ,
  [Indicator Voelt zich thuis]                              = case when kcm.[Voelt u zich thuis in uw woning van Staedion?] = 'Ja' then 1 else 0 end,
  -- 20210201 JvdW toegevoegd
  [Voelt u zich thuis in uw buurt]                          = kcm.[Voelt u zich thuis in uw buurt?] ,
  [Indicator Voelt zich thuis in buurt]                     = case when kcm.[Voelt u zich thuis in uw buurt?] = 'Ja' then 1 else 0 end,
  [Algemene ruimte aanwezig]                                = case when kcm.[Zijn er algemene ruimten rondom uw woning?  Met algemene ruimten]  = 'Ja' then 1 else 0 end,
  -- [Vragen overgeslagen]                                     = case when kcm.[Zijn er nog zaken die u nog niet eerder in het onderzoek genoemd heeft waarmee Staedion uw 'thuisgevoel' kan vergroten?] = 1 then 'Ja' else 'Nee' end,
	-- Vraag verwijderd vanaf 2020
  [Verhuizen binnen een jaar]                               = null, 
  [Gezinssamenstelling]                                     = null, -- 20210105 niet meer van toepassing kcm.[Wat is uw huishoudsituatie?],
  [Financiele situatie]                                     = null, -- 20210105 niet meer van toepassing kcm.[Welke omschrijving past het beste bij de financiÃ«le situatie va],
	-- Vraag verwijderd vanaf 2020
  [Aantal personen inwonend]                                = null,
  [Gezondheid]                                              = null, -- 20210105 niet meer van toepassing kcm.[Welke omschrijving past momenteel het beste bij de gezondheid va],
  [Hulpafhankelijk]                                         = null, -- 20210105 niet meer van toepassing kcm.[In welke mate heeft u/uw gezin momenteel hulp of ondersteuning v],
 --- [Toesteming voor contact]                                 = case when kcm.[Mag Staedion eventueel contact met u opnemen over uw antwoorden?] = 1 then 'Ja' else 'Nee' end,
  [Suggesties]                                              = null, -- 20210105 niet meer van toepassing  -- convert(nvarchar(1000),kcm.[Namelijk:]),
  [Score thuisgevoel]                                       = kcm.[Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi],
  [Score woningkwaliteit]                                   = kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa],
  [Score woningkwaliteit < 6]                               = case when kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa] is not null 
																																	then  iif(kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa]<6,1,0) end ,
  [Score woningkwaliteit >= 8]                              = case when kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa] is not null 
																																	then  iif(kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa]>=8,1,0) end,
	-- Vraag nader gespecificeerd vanaf 2020 
  [Score staat keuken/badkamer/toilet]                      = null,
  [Score staat keuken]										= null, -- 20210105 niet meer van toepassing  kcm.[De technische staat van keuken is goed#],
  [Score staat badkamer/toilet]								= null, -- 20210105 niet meer van toepassing  kcm.[De technische staat van badkamer en toilet is goed#],
  [Score energiezuinig]                                     = kcm.[Mijn woning is voldoende energiezuinig#],
  --[Score gehorig]                                           = kcm.[Mijn woning is niet gehorig#],
  [Score gevoelstemperatuur]                                = null, -- 20210105 niet meer van toepassing  kcm.[De temperatuur binnen in de woning is goed (geen last van vocht,],
  [Score prijskwaliteit]                                    = kcm.[De huur die ik betaal is goed vergeleken met de kwaliteit van de],
  [Score inbraakveilig]                                     = kcm.[Ik voel me veilig in mijn woning#],
  [Score algemene ruimten]                                  = kcm.[Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron],
  [Score algemene ruimten netheid]                          = kcm.[De algemene ruimten zijn schoon en netjes#],
  [Score algemene ruimten verlichting]                      = kcm.[De algemene ruimten hebben goede verlichting#],
  [Score algemene ruimten veilig]                           = kcm.[Ik voel me veilig in de algemene ruimten#],
  [Score buurt]                                             = kcm.[Welk rapportcijfer geeft u voor uw buurt? Een 1 staat hier voor],
  --[Score buurt overlast]                                    = kcm.[Ik heb geen overlast van mensen in mijn buurt#],
  [Score buurt netheid]                                     = kcm.[Mijn buurt is schoon en netjes#],
  [Score buurt veilig]                                      = kcm.[Ik voel mij veilig in de buurt#],
  [Score buurt contact]                                     = kcm.[Het contact met mijn buren is prettig en voldoende#]
-- select * 
FROM [empire_staedion_data].[kcm].[STN661_Ingevulde_gegevens] AS kcm
-- from Staging.kcm as kcm
left join empire_logic.dbo.lt_mg_oge as oge on 
  oge.mg_bedrijf = 'Staedion' and
  oge.Nr_ = kcm.eenheidnr
left join empire_logic.dbo.lt_mg_cluster as cluster on			
  oge.mg_bedrijf = 'Staedion' and
  cluster.Nr_ = kcm.clusternr
left join empire_data.dbo.staedion$cluster as CLUS on 
  CLUS.Nr_ = kcm.clusternr
  where  year(convert(date,kcm.[INGEVULDE GEGEVENS])) >= 2021

UNION

SELECT
  [Datum]                                                   = convert(date,kcm.[INGEVULDE GEGEVENS]),
  [Tijdstip]												= convert(time,kcm.[INGEVULDE GEGEVENS]),
  [Postcode]												= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]												= kcm.eenheidnr,
  [Sleutel cluster] 										= cluster.lt_id,
  kcm.clusternr,
  Clusternaam = CLUS.[Naam],
  [Voelt zich thuis]                                        = kcm.[Voelt u zich thuis in uw woning van Staedion?] ,
  [Indicator Voelt zich thuis]                              = case when kcm.[Voelt u zich thuis in uw woning van Staedion?] = 'Ja' then 1 else 0 end,
  [Voelt u zich thuis in uw buurt]                          = null,
  [Indicator Voelt zich thuis in buurt]                     = null,
  [Algemene ruimte aanwezig]                                = case when kcm.[Zijn er algemene ruimten rondom uw woning?  Met algemene ruimten]  = 'Ja' then 1 else 0 end,

  -- [Vragen overgeslagen]                                     = case when kcm.[Zijn er nog zaken die u nog niet eerder in het onderzoek genoemd heeft waarmee Staedion uw 'thuisgevoel' kan vergroten?] = 1 then 'Ja' else 'Nee' end,
	-- Vraag verwijderd vanaf 2020
  [Verhuizen binnen een jaar]                               = null, 
  [Gezinssamenstelling]                                     = convert(nvarchar(100), kcm.[Wat is uw huishoudsituatie?]),
  [Financiele situatie]                                     = kcm.[Welke omschrijving past het beste bij de financiÃ«le situatie va],
	-- Vraag verwijderd vanaf 2020
  [Aantal personen inwonend]                                = null,
  [Gezondheid]                                              = kcm.[Welke omschrijving past momenteel het beste bij de gezondheid va],
  [Hulpafhankelijk]                                         = kcm.[In welke mate heeft u/uw gezin momenteel hulp of ondersteuning v],
 --- [Toesteming voor contact]                                 = case when kcm.[Mag Staedion eventueel contact met u opnemen over uw antwoorden?] = 1 then 'Ja' else 'Nee' end,
  [Suggesties]                                              = kcm.[Namelijk:],
  [Score thuisgevoel]                                       = kcm.[Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi],
  [Score woningkwaliteit]                                   = kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa],
  [Score woningkwaliteit < 6]                               = case when kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa] is not null 
																 then  iif(kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa]<6,1,0) end ,
  [Score woningkwaliteit > 8]                               = case when kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa] is not null 
																then  iif(kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa]>8,1,0) end,
	-- Vraag nader gespecificeerd vanaf 2020 
  [Score staat keuken/badkamer/toilet]                      = kcm.[De kwaliteit van badkamer en toilet is goed#],
  [Score staat keuken]										= null,
  [Score staat badkamer/toilet]								= null,
  [Score energiezuinig]                                     = kcm.[Mijn woning is voldoende energiezuinig#],
 -- [Score gehorig]                                           = kcm.[Mijn woning is niet gehorig#],
  [Score gevoelstemperatuur]                                = kcm.[Ik heb geen last van vocht, tocht, schimmel#],
  [Score prijskwaliteit]                                    = kcm.[De huur die ik betaal is goed vergeleken met de kwaliteit van de],
  [Score inbraakveilig]                                     = kcm.[Ik voel me veilig in mijn woning#],
  [Score algemene ruimten]                                  = kcm.[Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron],
  [Score algemene ruimten netheid]                          = kcm.[De algemene ruimten zijn schoon en netjes#],
  [Score algemene ruimten verlichting]                      = kcm.[De algemene ruimten hebben goede verlichting#],
  [Score algemene ruimten veilig]                           = kcm.[Ik voel me veilig in de algemene ruimten#],
  [Score buurt]                                             = kcm.[Welk rapportcijfer geeft u voor uw buurt? Een 1 staat hier voor ],
  --[Score buurt overlast]                                    = kcm.[Ik heb geen overlast van mensen in mijn buurt#],
  [Score buurt netheid]                                     = kcm.[Mijn buurt is schoon en netjes#],
  [Score buurt veilig]                                      = kcm.[Ik voel mij veilig in de buurt#],
  [Score buurt contact]                                     = kcm.[Het contact met mijn buren is prettig en voldoende#]

FROM [empire_staedion_data].bik.STN661_Ingevulde_gegevens_2020 AS kcm
-- from Staging.kcm as kcm
left join empire_logic.dbo.lt_mg_oge as oge on 
  oge.mg_bedrijf = 'Staedion' and
  oge.Nr_ = kcm.eenheidnr
left join empire_logic.dbo.lt_mg_cluster as cluster on 
  oge.mg_bedrijf = 'Staedion' and
  cluster.Nr_ = kcm.clusternr
left join empire_data.dbo.staedion$cluster as CLUS on 
  CLUS.Nr_ = kcm.clusternr
where  year(convert(date,kcm.[INGEVULDE GEGEVENS])) = 2020


UNION


SELECT
  [Datum]                                                   = convert(date,kcm.[INGEVULDE GEGEVENS]),
  [Tijdstip]												= convert(time,kcm.[INGEVULDE GEGEVENS]),
  [Postcode]												= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]												= kcm.eenheidnr,
  [Sleutel cluster] 										= cluster.lt_id,
  kcm.clusternr,
  Clusternaam = CLUS.[Naam],
  [Voelt zich thuis]                                        = kcm.[Voelt u zich thuis in uw woning van Staedion?] ,
  [Indicator Voelt zich thuis]                              = case when kcm.[Voelt u zich thuis in uw woning van Staedion?] = 'Ja' then 1 else 0 end,
  [Voelt u zich thuis in uw buurt]                          = null,
  [Indicator Voelt zich thuis in buurt]                     = null,
  [Algemene ruimte aanwezig]                                = case when kcm.[Zijn er algemene ruimten rondom uw woning?  Met algemene ruimten]  = 'Ja' then 1 else 0 end,

  -- [Vragen overgeslagen]                                     = case when kcm.[Zijn er nog zaken die u nog niet eerder in het onderzoek genoemd heeft waarmee Staedion uw 'thuisgevoel' kan vergroten?] = 1 then 'Ja' else 'Nee' end,
	-- Vraag verwijderd vanaf 2020
  [Verhuizen binnen een jaar]                               = null, 
  [Gezinssamenstelling]                                     = convert(nvarchar(100), kcm.[Hoeveel personen wonen er in uw huis?]),
  [Financiele situatie]                                     = kcm.[Welke omschrijving past het beste bij de financiële situatie van],
	-- Vraag verwijderd vanaf 2020
  [Aantal personen inwonend]                                = null,
  [Gezondheid]                                              = kcm.[Welke omschrijving past momenteel het beste bij de gezondheid va],
  [Hulpafhankelijk]                                         = kcm.[In welke mate heeft u/uw gezin momenteel hulp of ondersteuning v],
 --- [Toesteming voor contact]                                 = case when kcm.[Mag Staedion eventueel contact met u opnemen over uw antwoorden?] = 1 then 'Ja' else 'Nee' end,
  [Suggesties]                                              = kcm.[Namelijk:],
  [Score thuisgevoel]                                       = kcm.[Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi],
  [Score woningkwaliteit]                                   = kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat],
  [Score woningkwaliteit < 6]                               = case when kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat] is not null 
																 then  iif(kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat]<6,1,0) end ,
  [Score woningkwaliteit > 8]                               = case when kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat] is not null 
																then  iif(kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat]>8,1,0) end,
	-- Vraag nader gespecificeerd vanaf 2020 
  [Score staat keuken/badkamer/toilet]                      = kcm.[De technische staat van keuken, badkamer en toilet is goed#],
  [Score staat keuken]										= null,
  [Score staat badkamer/toilet]								= null,
  [Score energiezuinig]                                     = kcm.[Mijn woning is voldoende energiezuinig#],
 -- [Score gehorig]                                           = kcm.[Mijn woning is niet gehorig#],
  [Score gevoelstemperatuur]                                = kcm.[De temperatuur binnen in de woning is goed (geen last van vocht,],
  [Score prijskwaliteit]                                    = kcm.[De huur die ik betaal is goed vergeleken met de kwaliteit van de],
  [Score inbraakveilig]                                     = kcm.[Ik woon in een woning die veilig is tegen inbraak#],
  [Score algemene ruimten]                                  = kcm.[Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron],
  [Score algemene ruimten netheid]                          = kcm.[De algemene ruimten zijn netjes en schoon#],
  [Score algemene ruimten verlichting]                      = kcm.[De algemene ruimten hebben goede verlichting#],
  [Score algemene ruimten veilig]                           = kcm.[Ik voel me veilig in de algemene ruimten#],
  [Score buurt]                                             = kcm.[Welk rapportcijfer geeft u uw buurt? Een 1 staat hier voor zeer ],
  --[Score buurt overlast]                                    = kcm.[Ik heb geen overlast van mensen in mijn buurt#],
  [Score buurt netheid]                                     = kcm.[Mijn buurt is schoon en netjes#],
  [Score buurt veilig]                                      = kcm.[Ik voel mij veilig in de buurt#],
  [Score buurt contact]                                     = kcm.[Het contact met mijn buren is prettig en voldoende#]
-- select * 
FROM [empire_staedion_data].bik.STN661_Ingevulde_gegevens_2019 AS kcm
-- from Staging.kcm as kcm
left join empire_logic.dbo.lt_mg_oge as oge on 
  oge.mg_bedrijf = 'Staedion' and
  oge.Nr_ = kcm.eenheidnr
left join empire_logic.dbo.lt_mg_cluster as cluster on 
  oge.mg_bedrijf = 'Staedion' and
  cluster.Nr_ = kcm.clusternr
left join empire_data.dbo.staedion$cluster as CLUS on 
  CLUS.Nr_ = kcm.clusternr
where  year(convert(date,kcm.[INGEVULDE GEGEVENS])) = 2019



UNION


SELECT
  [Datum]                                                   = convert(date,kcm.[INGEVULDE GEGEVENS]),
  [Tijdstip]												= convert(time,kcm.[INGEVULDE GEGEVENS]),
  [Postcode]												= kcm.postcode,
  [Sleutel eenheid]                                         = oge.lt_id,
  [Eenheidnr]												= kcm.eenheidnr,
  [Sleutel cluster] 										= cluster.lt_id,
  kcm.clusternr,
  Clusternaam = CLUS.[Naam],
  [Voelt zich thuis]                                        = kcm.[Voelt u zich thuis in uw woning van Staedion?] ,
  [Indicator Voelt zich thuis]                              = case when kcm.[Voelt u zich thuis in uw woning van Staedion?] = 'Ja' then 1 else 0 end,
  [Voelt u zich thuis in uw buurt]                          = null,
  [Indicator Voelt zich thuis in buurt]                     = null,
  [Algemene ruimte aanwezig]                                = null, --case when kcm.[Zijn er algemene ruimten rondom uw woning?  Met algemene ruimten]  = 'Ja' then 1 else 0 end,

  -- [Vragen overgeslagen]                                     = case when kcm.[Zijn er nog zaken die u nog niet eerder in het onderzoek genoemd heeft waarmee Staedion uw 'thuisgevoel' kan vergroten?] = 1 then 'Ja' else 'Nee' end,
	-- Vraag verwijderd vanaf 2020
  [Verhuizen binnen een jaar]                               = null, 
  [Gezinssamenstelling]                                     = null, --convert(nvarchar(100), kcm.[Hoeveel personen wonen er in uw huis?]),
  [Financiele situatie]                                     = null, --kcm.[Welke omschrijving past het beste bij de financiële situatie van],
	-- Vraag verwijderd vanaf 2020
  [Aantal personen inwonend]                                = null,
  [Gezondheid]                                              = null, --kcm.[Welke omschrijving past momenteel het beste bij de gezondheid va],
  [Hulpafhankelijk]                                         = null, --kcm.[In welke mate heeft u/uw gezin momenteel hulp of ondersteuning v],
 --- [Toesteming voor contact]                                 = case when kcm.[Mag Staedion eventueel contact met u opnemen over uw antwoorden?] = 1 then 'Ja' else 'Nee' end,
  [Suggesties]                                              = null, --kcm.[Namelijk:],
  [Score thuisgevoel]                                       = kcm.[Welk rapportcijfer geeft u voor uw "thuisgevoel", ofwel het wonen in een woning van Staedion],
  [Score woningkwaliteit]                                   = kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?],
  [Score woningkwaliteit < 6]                               = case when kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?] is not null 
																 then  iif(kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?]<6,1,0) end ,
  [Score woningkwaliteit > 8]                               = case when kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?] is not null 
																then  iif(kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?]>8,1,0) END,
	-- Vraag nader gespecificeerd vanaf 2020 
  [Score staat keuken/badkamer/toilet]                      = null, --kcm.[De technische staat van keuken, badkamer en toilet is goed#],
  [Score staat keuken]										= null,
  [Score staat badkamer/toilet]								= null,
  [Score energiezuinig]                                     = null, --kcm.[Mijn woning is voldoende energiezuinig#],
 -- [Score gehorig]                                           = kcm.[Mijn woning is niet gehorig#],
  [Score gevoelstemperatuur]                                = null, --kcm.[De temperatuur binnen in de woning is goed (geen last van vocht,],
  [Score prijskwaliteit]                                    = null, --kcm.[De huur die ik betaal is goed vergeleken met de kwaliteit van de],
  [Score inbraakveilig]                                     = null, --kcm.[Ik woon in een woning die veilig is tegen inbraak#],
  [Score algemene ruimten]                                  = null, --kcm.[Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron],
  [Score algemene ruimten netheid]                          = null, --kcm.[De algemene ruimten zijn netjes en schoon#],
  [Score algemene ruimten verlichting]                      = null, --kcm.[De algemene ruimten hebben goede verlichting#],
  [Score algemene ruimten veilig]                           = null, --kcm.[Ik voel me veilig in de algemene ruimten#],
  [Score buurt]                                             = null, --kcm.[Welk rapportcijfer geeft u uw buurt? Een 1 staat hier voor zeer ],
  --[Score buurt overlast]                                   = kcm.[Ik heb geen overlast van mensen in mijn buurt#],
  [Score buurt netheid]                                     = null, --kcm.[Mijn buurt is schoon en netjes#],
  [Score buurt veilig]                                      = null, --kcm.[Ik voel mij veilig in de buurt#],
  [Score buurt contact]                                     = null --kcm.[Het contact met mijn buren is prettig en voldoende#]
-- select convert(date,kcm.[INGEVULDE GEGEVENS]),kcm.[Welk cijfer geeft u voor de kwaliteit van uw woning?],*
FROM [empire_staedion_data].kcm.Thuisgevoel2014_okt_tm_2018_sep AS kcm
-- from Staging.kcm as kcm
left join empire_logic.dbo.lt_mg_oge as oge on 
  oge.mg_bedrijf = 'Staedion' and
  oge.Nr_ = kcm.eenheidnr
left join empire_logic.dbo.lt_mg_cluster as cluster on 
  oge.mg_bedrijf = 'Staedion' and
  cluster.Nr_ = kcm.clusternr
left join empire_data.dbo.staedion$cluster as CLUS on 
  CLUS.Nr_ = kcm.clusternr
where  year(convert(date,kcm.[INGEVULDE GEGEVENS])) < 2019



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
