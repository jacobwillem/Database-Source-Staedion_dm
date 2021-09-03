SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO












CREATE view [Leefbaarheid].[KlantcontactMonitor] as

select Bron = '[empire_staedion_data].[bik].[Directe_Woonomgeving].[1#_Welk rapportcijfer geeft u over uw eerste en algemene indruk ]',
		Steekproefgrootte = case when year(DW.[INGEVULDE GEGEVENS]) = 2016 then 4495
								 when year(DW.[INGEVULDE GEGEVENS]) = 2017 then 6202
								 when year(DW.[INGEVULDE GEGEVENS]) = 2018 then 4920 end,
		Vraag = 'Welk rapportcijfer geeft u over uw eerste en algemene indruk van uw directe woonomgeving of Welk rapportcijfer geeft u voor uw buurt',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(DW.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(DW.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = DW.[1#_Welk rapportcijfer geeft u over uw eerste en algemene indruk ],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when DW.Clusternr like '%FT%' then DW.Clusternr
								when DW.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = DW.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when DW.Clusternr like '%FINC%' then DW.Clusternr else null end,
		Bouwblok = DW.Bouwblok

from [empire_staedion_data].[bik].[Directe_Woonomgeving] as DW
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = DW.Buurtcode 
where year(DW.[INGEVULDE GEGEVENS]) <> 2019

union all

select Bron = '[empire_staedion_data].[bik].[Directe_Woonomgeving].[2#_Welk rapportcijfer geeft u voor de netheid en uitstraling van]',
		Steekproefgrootte = case when year(DW.[INGEVULDE GEGEVENS]) = 2016 then 4495
								 when year(DW.[INGEVULDE GEGEVENS]) = 2017 then 6202
								 when year(DW.[INGEVULDE GEGEVENS]) = 2018 then 4920 end,
		Vraag = 'Welk rapportcijfer geeft u voor de netheid en uitstraling van de algemene ruimten of Welk rapportcijfer geeft u Staedion voor de algemene ruimten rondom uw woning',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(DW.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(DW.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = DW.[2#_Welk rapportcijfer geeft u voor de netheid en uitstraling van],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when DW.Clusternr like '%FT%' then DW.Clusternr
								when DW.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = DW.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when DW.Clusternr like '%FINC%' then DW.Clusternr else null end,
		Bouwblok = DW.Bouwblok

from [empire_staedion_data].[bik].[Directe_Woonomgeving] as DW
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = DW.Buurtcode 
where year(DW.[INGEVULDE GEGEVENS]) <> 2019

union all

select Bron = '[empire_staedion_data].[bik].[Directe_Woonomgeving].[3#_Welk rapportcijfer geeft u voor uw gevoel van veiligheid in d]',
		Steekproefgrootte = case when year(DW.[INGEVULDE GEGEVENS]) = 2016 then 4495
								 when year(DW.[INGEVULDE GEGEVENS]) = 2017 then 6202
								 when year(DW.[INGEVULDE GEGEVENS]) = 2018 then 4920 end,
		Vraag = 'Welk rapportcijfer geeft u voor uw gevoel van veiligheid in de algemene ruimten',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(DW.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(DW.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = DW.[3#_Welk rapportcijfer geeft u voor uw gevoel van veiligheid in d],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when DW.Clusternr like '%FT%' then DW.Clusternr
								when DW.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = DW.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when DW.Clusternr like '%FINC%' then DW.Clusternr else null end,
		Bouwblok = DW.Bouwblok

from [empire_staedion_data].[bik].[Directe_Woonomgeving] as DW
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = DW.Buurtcode 
where year(DW.[INGEVULDE GEGEVENS]) <> 2019

union all

select Bron = '[empire_staedion_data].[bik].[Directe_Woonomgeving].[4#_Welk rapportcijfer geeft u voor de verlichting in de algemene]',
		Steekproefgrootte = case when year(DW.[INGEVULDE GEGEVENS]) = 2016 then 4495
								 when year(DW.[INGEVULDE GEGEVENS]) = 2017 then 6202
								 when year(DW.[INGEVULDE GEGEVENS]) = 2018 then 4920 end,
		Vraag = 'Welk rapportcijfer geeft u voor de verlichting in de algemene ruimten',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(DW.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(DW.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = DW.[4#_Welk rapportcijfer geeft u voor de verlichting in de algemene],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when DW.Clusternr like '%FT%' then DW.Clusternr
								when DW.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = DW.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when DW.Clusternr like '%FINC%' then DW.Clusternr else null end,
		Bouwblok = DW.Bouwblok

from [empire_staedion_data].[bik].[Directe_Woonomgeving] as DW
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = DW.Buurtcode 
where year(DW.[INGEVULDE GEGEVENS]) <> 2019

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015].[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat (''s a]',
		Steekproefgrootte = 4651,
		Vraag = 'Hoe ervaart u het gevoel van veiligheid op straat (''s avonds en/of ''s nachts) zeer onveilig, enigszins onveilig, neutraal, redelijk veilig, zeer veilig',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = case when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'zeer onveilig' then 1
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'enigzins onveilig' then 2
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'neutraal' then 3
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'redelijk veilig' then 4
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'zeer veilig' then 5
						end,
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015] as OL
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] is not null and (case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end) is not null 

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015].[Vraag 7# Wat vindt u van de veiligheid in het trappenhuis?]',
		Steekproefgrootte = 4651,
		Vraag = 'Wat vindt u van de veiligheid in het trappenhuis',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Vraag 7# Wat vindt u van de veiligheid in het trappenhuis?],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015] as OL
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Vraag 7# Wat vindt u van de veiligheid in het trappenhuis?] is not null and (case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end) is not null

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015].[Vraag 8# Hoe waardeert u de verlichting in het openbare trappenh]',
		Steekproefgrootte = 4651,
		Vraag = 'Hoe waardeert u de verlichting in het openbare trappenhuis',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Vraag 8# Hoe waardeert u de verlichting in het openbare trappenh],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015] as OL
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Vraag 8# Hoe waardeert u de verlichting in het openbare trappenh] is not null and (case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end) is not null

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015].[De omgang met uw directe buren]',
		Steekproefgrootte = 4651,
		Vraag = 'De omgang met uw directe buren',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [De omgang met uw directe buren],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015] as OL
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [De omgang met uw directe buren] is not null and (case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end) is not null

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015].[De omgang met uw buurtgenoten]',
		Steekproefgrootte = 4651,
		Vraag = 'De omgang met uw buurtgenoten',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [De omgang met uw buurtgenoten],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015] as OL
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [De omgang met uw buurtgenoten] is not null and (case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end) is not null

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015].[Zwerfvuil in de wijk]',
		Steekproefgrootte = 4651,
		Vraag = 'Zwerfvuil in de wijk Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Zwerfvuil in de wijk],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015] as OL
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Zwerfvuil in de wijk] is not null and (case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end) is not null

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015].[Vandalisme]',
		Steekproefgrootte = 4651,
		Vraag = 'Vandalisme Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Vandalisme],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015] as OL
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Vandalisme] is not null and (case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end) is not null

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015].[Hangjongeren]',
		Steekproefgrootte = 4651,
		Vraag = 'Hangjongeren Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Hangjongeren],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2015] as OL
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Hangjongeren] is not null and (case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end) is not null

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016].[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat (''s a]',
		Steekproefgrootte = 16575,
		Vraag = 'Hoe ervaart u het gevoel van veiligheid op straat (''s avonds en/of ''s nachts) zeer onveilig, enigszins onveilig, neutraal, redelijk veilig, zeer veilig',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = case when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'zeer onveilig' then 1
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'enigzins onveilig' then 2
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'neutraal' then 3
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'redelijk veilig' then 4
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'zeer veilig' then 5
						end,
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016].[Vraag 7# Wat vindt u van de veiligheid in het trappenhuis?]',
		Steekproefgrootte = 16575,
		Vraag = 'Wat vindt u van de veiligheid in het trappenhuis',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Vraag 7# Wat vindt u van de veiligheid in het trappenhuis?],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 
where [Vraag 7# Wat vindt u van de veiligheid in het trappenhuis?] is not null

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016].[Vraag 8# Hoe waardeert u de verlichting in het openbare trappenh]',
		Steekproefgrootte = 16575,
		Vraag = 'Hoe waardeert u de verlichting in het openbare trappenhuis',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Vraag 8# Hoe waardeert u de verlichting in het openbare trappenh],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 
where [Vraag 8# Hoe waardeert u de verlichting in het openbare trappenh] is not null

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016].[De omgang met uw directe buren]',
		Steekproefgrootte = 16575,
		Vraag = 'De omgang met uw directe buren',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [De omgang met uw directe buren],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016].[De omgang met uw buurtgenoten]',
		Steekproefgrootte = 16575,
		Vraag = 'De omgang met uw buurtgenoten',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [De omgang met uw buurtgenoten],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016].[Zwerfvuil in de wijk]',
		Steekproefgrootte = 16575,
		Vraag = 'Zwerfvuil in de wijk Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Zwerfvuil in de wijk],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016].[Vandalisme]',
		Steekproefgrootte = 16575,
		Vraag = 'Vandalisme Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Vandalisme],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016].[Hangjongeren]',
		Steekproefgrootte = 16575,
		Vraag = 'Hangjongeren Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Hangjongeren],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when OL.Clusternr like '%FT%' then OL.Clusternr
								when OL.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = OL.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when OL.Clusternr like '%FINC%' then OL.Clusternr else null end,
		Bouwblok = null

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2016] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017].[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat (''s a]',
		Steekproefgrootte = 20582,
		Vraag = 'Hoe ervaart u het gevoel van veiligheid op straat (''s avonds en/of ''s nachts) zeer onveilig, enigszins onveilig, neutraal, redelijk veilig, zeer veilig',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = case when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'zeer onveilig' then 1
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'enigzins onveilig' then 2
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'neutraal' then 3
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'redelijk veilig' then 4
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'zeer veilig' then 5
						end,
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017].[Vraag 7# Wat vindt u van de veiligheid in het trappenhuis?]',
		Steekproefgrootte = 20582,
		Vraag = 'Wat vindt u van de veiligheid in het trappenhuis',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Vraag 7# Wat vindt u van de veiligheid in het trappenhuis?],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 
where [Vraag 7# Wat vindt u van de veiligheid in het trappenhuis?] is not null

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017].[Vraag 8# Hoe waardeert u de verlichting in het openbare trappenh]',
		Steekproefgrootte = 20582,
		Vraag = 'Hoe waardeert u de verlichting in het openbare trappenhuis',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Vraag 8# Hoe waardeert u de verlichting in het openbare trappenh],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 
where [Vraag 8# Hoe waardeert u de verlichting in het openbare trappenh] is not null

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017].[De omgang met uw directe buren]',
		Steekproefgrootte = 20582,
		Vraag = 'De omgang met uw directe buren',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [De omgang met uw directe buren],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017].[De omgang met uw buurtgenoten]',
		Steekproefgrootte = 20582,
		Vraag = 'De omgang met uw buurtgenoten',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [De omgang met uw buurtgenoten],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017].[Zwerfvuil in de wijk]',
		Steekproefgrootte = 20582,
		Vraag = 'Zwerfvuil in de wijk Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Zwerfvuil in de wijk],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017].[Vandalisme]',
		Steekproefgrootte = 20582,
		Vraag = 'Vandalisme Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Vandalisme],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017].[Hangjongeren]',
		Steekproefgrootte = 20582,
		Vraag = 'Hangjongeren Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Hangjongeren],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2017] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018].[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat (''s a]',
		Steekproefgrootte = 21199,
		Vraag = 'Hoe ervaart u het gevoel van veiligheid op straat (''s avonds en/of ''s nachts) zeer onveilig, enigszins onveilig, neutraal, redelijk veilig, zeer veilig',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = case when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'zeer onveilig' then 1
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'enigzins onveilig' then 2
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'neutraal' then 3
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'redelijk veilig' then 4
						when OL.[Vraag 2# Hoe ervaart u het gevoel van veiligheid op straat ('s a] like 'zeer veilig' then 5
						end,
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018].[Vraag 7# Wat vindt u van de veiligheid in het trappenhuis?]',
		Steekproefgrootte = 21199,
		Vraag = 'Wat vindt u van de veiligheid in het trappenhuis',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Vraag 7# Wat vindt u van de veiligheid in het trappenhuis?],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 
where [Vraag 7# Wat vindt u van de veiligheid in het trappenhuis?] is not null

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018].[Vraag 8# Hoe waardeert u de verlichting in het openbare trappenh]',
		Steekproefgrootte = 21199,
		Vraag = 'Hoe waardeert u de verlichting in het openbare trappenhuis',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Vraag 8# Hoe waardeert u de verlichting in het openbare trappenh],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 
where [Vraag 8# Hoe waardeert u de verlichting in het openbare trappenh] is not null

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018].[De omgang met uw directe buren]',
		Steekproefgrootte = 21199,
		Vraag = 'De omgang met uw directe buren',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [De omgang met uw directe buren],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018].[De omgang met uw buurtgenoten]',
		Steekproefgrootte = 21199,
		Vraag = 'De omgang met uw buurtgenoten',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [De omgang met uw buurtgenoten],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018].[Zwerfvuil in de wijk]',
		Steekproefgrootte = 21199,
		Vraag = 'Zwerfvuil in de wijk Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Zwerfvuil in de wijk],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018].[Vandalisme]',
		Steekproefgrootte = 21199,
		Vraag = 'Vandalisme Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Vandalisme],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 

union all

select Bron = '[empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018].[Hangjongeren]',
		Steekproefgrootte = 21199,
		Vraag = 'Hangjongeren Hierbij staat een 1 voor zeer veel overlast en een 10 voor helemaal geen overlast',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(OL.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(OL.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Hangjongeren],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when OL.FT_Cluster like '%FT%' then OL.FT_Cluster else null end,
		ClusternummerOud = case when OL.clusternr_oud like '%FINC%' then OL.clusternr_oud else null end,
		Bouwblok = OL.bouwblok

from [empire_staedion_data].[bik].[Onderzoek_leefbaarheid_2018] as OL
inner join empire_staedion_data.bik.CBS_Buurt2020 as BU on (N'BU' + RIGHT(N'00000000' + CAST(BU.BuurtCode AS nvarchar), 8)) = OL.Buurtcode 

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019].[De algemene ruimten hebben goede verlichting#]',
		Steekproefgrootte = null,
		Vraag = 'De algemene ruimten hebben goede verlichting',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [De algemene ruimten hebben goede verlichting#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [De algemene ruimten hebben goede verlichting#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019].[De algemene ruimten zijn netjes en schoon#]',
		Steekproefgrootte = null,
		Vraag = 'De algemene ruimten zijn schoon en netjes',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [De algemene ruimten zijn netjes en schoon#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [De algemene ruimten zijn netjes en schoon#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019].[Ik voel me veilig in de algemene ruimten#]',
		Steekproefgrootte = null,
		Vraag = 'Ik voel me veilig in de algemene ruimten',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Ik voel me veilig in de algemene ruimten#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Ik voel me veilig in de algemene ruimten#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019].[Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron]',
		Steekproefgrootte = null,
		Vraag = 'Welk rapportcijfer geeft u voor de netheid en uitstraling van de algemene ruimten of Welk rapportcijfer geeft u Staedion voor de algemene ruimten rondom uw woning',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019].[Ik voel mij veilig in de buurt#]',
		Steekproefgrootte = null,
		Vraag = 'Ik voel mij veilig in de buurt',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Ik voel mij veilig in de buurt#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Ik voel mij veilig in de buurt#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019].[Welk rapportcijfer geeft u uw buurt? Een 1 staat hier voor zeer ]',
		Steekproefgrootte = null,
		Vraag = 'Welk rapportcijfer geeft u over uw eerste en algemene indruk van uw directe woonomgeving of Welk rapportcijfer geeft u voor uw buurt',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Welk rapportcijfer geeft u uw buurt? Een 1 staat hier voor zeer ],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Welk rapportcijfer geeft u uw buurt? Een 1 staat hier voor zeer ] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019].[Het contact met mijn buren is prettig en voldoende#]',
		Steekproefgrootte = null,
		Vraag = 'Het contact met mijn buren is prettig en voldoende',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Het contact met mijn buren is prettig en voldoende#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Het contact met mijn buren is prettig en voldoende#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019].[Ik heb geen overlast van mensen in mijn buurt#]',
		Steekproefgrootte = null,
		Vraag = 'Ik heb geen overlast van mensen in mijn buurt',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Ik heb geen overlast van mensen in mijn buurt#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Ik heb geen overlast van mensen in mijn buurt#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019].[Mijn buurt is schoon en netjes#]',
		Steekproefgrootte = null,
		Vraag = 'Mijn buurt is schoon en netjes',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Mijn buurt is schoon en netjes#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Mijn buurt is schoon en netjes#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019].[Ik woon in een woning die veilig is tegen inbraak#]',
		Steekproefgrootte = null,
		Vraag = 'Ik woon in een woning die veilig is tegen inbraak',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Ik woon in een woning die veilig is tegen inbraak#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Ik woon in een woning die veilig is tegen inbraak#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019].[Voelt u zich thuis in uw woning van Staedion?]',
		Steekproefgrootte = null,
		Vraag = 'Voelt u zich thuis in uw woning van Staedion',
		Antwoordmogelijkheden = '0, 1', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = case when [Voelt u zich thuis in uw woning van Staedion?] = 'nee' then 0
						when [Voelt u zich thuis in uw woning van Staedion?] = 'ja' then 1 end,
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Voelt u zich thuis in uw woning van Staedion?] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019].[Welk rapportcijfer geeft u voor uw ''thuisgevoel''? Een 1 staat hi]',
		Steekproefgrootte = null,
		Vraag = 'Welk rapportcijfer geeft u voor uw thuisgevoel',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019].[Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat]',
		Steekproefgrootte = null,
		Vraag = 'Welk cijfer geeft u voor de kwaliteit van uw woning',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'


union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020].[De algemene ruimten hebben goede verlichting#]',
		Steekproefgrootte = 21576,
		Vraag = 'De algemene ruimten hebben goede verlichting',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [De algemene ruimten hebben goede verlichting#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [De algemene ruimten hebben goede verlichting#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020].[De algemene ruimten zijn schoon en netjes#]',
		Steekproefgrootte = 21576,
		Vraag = 'De algemene ruimten zijn schoon en netjes',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [De algemene ruimten zijn schoon en netjes#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [De algemene ruimten zijn schoon en netjes#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020].[Ik voel me veilig in de algemene ruimten#]',
		Steekproefgrootte = 21576,
		Vraag = 'Ik voel me veilig in de algemene ruimten',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Ik voel me veilig in de algemene ruimten#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Ik voel me veilig in de algemene ruimten#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020].[Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron]',
		Steekproefgrootte = 21576,
		Vraag = 'Welk rapportcijfer geeft u voor de netheid en uitstraling van de algemene ruimten of Welk rapportcijfer geeft u Staedion voor de algemene ruimten rondom uw woning',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020].[Ik voel mij veilig in de buurt#]',
		Steekproefgrootte = 21576,
		Vraag = 'Ik voel mij veilig in de buurt',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Ik voel mij veilig in de buurt#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Ik voel mij veilig in de buurt#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020].[Welk rapportcijfer geeft u voor uw buurt? Een 1 staat hier voor ]',
		Steekproefgrootte = 21576,
		Vraag = 'Welk rapportcijfer geeft u over uw eerste en algemene indruk van uw directe woonomgeving of Welk rapportcijfer geeft u voor uw buurt',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Welk rapportcijfer geeft u voor uw buurt? Een 1 staat hier voor ],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Welk rapportcijfer geeft u voor uw buurt? Een 1 staat hier voor ] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020].[Het contact met mijn buren is prettig en voldoende#]',
		Steekproefgrootte = 21576,
		Vraag = 'Het contact met mijn buren is prettig en voldoende',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Het contact met mijn buren is prettig en voldoende#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Het contact met mijn buren is prettig en voldoende#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020].[Ik heb geen overlast van mensen in mijn buurt#]',
		Steekproefgrootte = 21576,
		Vraag = 'Ik heb geen overlast van mensen in mijn buurt',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Ik heb geen overlast van mensen in mijn buurt#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Ik heb geen overlast van mensen in mijn buurt#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020].[Mijn buurt is schoon en netjes#]',
		Steekproefgrootte = 21576,
		Vraag = 'Mijn buurt is schoon en netjes',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Mijn buurt is schoon en netjes#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Mijn buurt is schoon en netjes#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020].[Ik voel me veilig in mijn woning#]',
		Steekproefgrootte = 21576,
		Vraag = 'Ik voel me veilig in mijn woning',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Ik voel me veilig in mijn woning#],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Ik voel me veilig in mijn woning#] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020].[Voelt u zich thuis in uw woning van Staedion?]',
		Steekproefgrootte = 21576,
		Vraag = 'Voelt u zich thuis in uw woning van Staedion',
		Antwoordmogelijkheden = '0, 1', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = case when [Voelt u zich thuis in uw woning van Staedion?] = 'nee' then 0
						when [Voelt u zich thuis in uw woning van Staedion?] = 'ja' then 1 end,
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Voelt u zich thuis in uw woning van Staedion?] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020].[Welk rapportcijfer geeft u voor uw ''thuisgevoel''? Een 1 staat hi]',
		Steekproefgrootte = 21576,
		Vraag = 'Welk rapportcijfer geeft u voor uw thuisgevoel',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020].[Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa]',
		Steekproefgrootte = 21576,
		Vraag = 'Welk cijfer geeft u voor de kwaliteit van uw woning',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(STN661.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(STN661.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =	case when STN661.Clusternr like '%FT%' then STN661.Clusternr else null end,
		ClusternummerOud = null,
		Bouwblok = STN661.Bouwblok

from [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020] as STN661
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = STN661.Clusternr
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa] is not null and STN661.Clusternr is not null and STN661.Clusternr like '%FT%'

union all

select Bron = '[empire_staedion_data].[bik].[Thuisgevoel_ingevulde_gegevens_2015_2018].[Voelt u zich thuis in uw woning van Staedion?]',
		Steekproefgrootte = case when year(TG.[INGEVULDE GEGEVENS]) = 2016 then 13725
								 when year(TG.[INGEVULDE GEGEVENS]) = 2017 then 15302
								 when year(TG.[INGEVULDE GEGEVENS]) = 2018 then 7353 end,
		Vraag = 'Voelt u zich thuis in uw woning van Staedion',
		Antwoordmogelijkheden = '0, 1', 
		Jaar = year(TG.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(TG.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = case when [Voelt u zich thuis in uw woning van Staedion?] = 'nee' then 0
						when [Voelt u zich thuis in uw woning van Staedion?] = 'ja' then 1 end,
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when TG.Clusternr like '%FT%' then TG.Clusternr
								when TG.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = TG.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when TG.Clusternr like '%FINC%' then TG.Clusternr else null end,
		Bouwblok = TG.Bouwblok

from [empire_staedion_data].[bik].Thuisgevoel_ingevulde_gegevens_2015_2018 as TG
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = (case when TG.Clusternr like '%FT%' then TG.Clusternr
								when TG.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = TG.Clusternr
																	order by Clusternummer asc)
								else null end)
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Voelt u zich thuis in uw woning van Staedion?] is not null and TG.Clusternr is not null and year(TG.[INGEVULDE GEGEVENS]) <> 2015

union all

select Bron = '[empire_staedion_data].[bik].[Thuisgevoel_ingevulde_gegevens_2015_2018].[Welk rapportcijfer geeft u voor uw "thuisgevoel", ofwel het wone]',
		Steekproefgrootte = case when year(TG.[INGEVULDE GEGEVENS]) = 2016 then 13725
								 when year(TG.[INGEVULDE GEGEVENS]) = 2017 then 15302
								 when year(TG.[INGEVULDE GEGEVENS]) = 2018 then 7353 end,
		Vraag = 'Welk rapportcijfer geeft u voor uw thuisgevoel',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(TG.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(TG.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Welk rapportcijfer geeft u voor uw "thuisgevoel", ofwel het wone],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when TG.Clusternr like '%FT%' then TG.Clusternr
								when TG.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = TG.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when TG.Clusternr like '%FINC%' then TG.Clusternr else null end,
		Bouwblok = TG.Bouwblok

from [empire_staedion_data].[bik].Thuisgevoel_ingevulde_gegevens_2015_2018 as TG
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = (case when TG.Clusternr like '%FT%' then TG.Clusternr
								when TG.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = TG.Clusternr
																	order by Clusternummer asc)
								else null end)
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Welk rapportcijfer geeft u voor uw "thuisgevoel", ofwel het wone] is not null and TG.Clusternr is not null and year(TG.[INGEVULDE GEGEVENS]) <> 2015

union all

select Bron = '[empire_staedion_data].[bik].[Thuisgevoel_ingevulde_gegevens_2015_2018].[Welk cijfer geeft u voor de kwaliteit van uw woning?]',
		Steekproefgrootte = case when year(TG.[INGEVULDE GEGEVENS]) = 2016 then 13725
								 when year(TG.[INGEVULDE GEGEVENS]) = 2017 then 15302
								 when year(TG.[INGEVULDE GEGEVENS]) = 2018 then 7353 end,
		Vraag = 'Welk cijfer geeft u voor de kwaliteit van uw woning',
		Antwoordmogelijkheden = '1, 2, 3, 4, 5, 6, 7, 8, 9, 10', 
		Jaar = year(TG.[INGEVULDE GEGEVENS]),
		IngevuldOp = cast(TG.[INGEVULDE GEGEVENS] as datetime),
		Antwoord = [Welk cijfer geeft u voor de kwaliteit van uw woning?],
		GemeenteCode = BU.GemeenteCode, 
		WijkCode = BU.Wijkcode,
		BuurtCode = BU.Buurtcode,
		Clusternummer =		case when TG.Clusternr like '%FT%' then TG.Clusternr
								when TG.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = TG.Clusternr
																	order by Clusternummer asc)
								else null end,
		ClusternummerOud = case when TG.Clusternr like '%FINC%' then TG.Clusternr else null end,
		Bouwblok = TG.Bouwblok

from [empire_staedion_data].[bik].Thuisgevoel_ingevulde_gegevens_2015_2018 as TG
inner join [empire_staedion_data].[bik].[ELS_ClusternummerBuurtCode] as CL on CL.Clusternummer = (case when TG.Clusternr like '%FT%' then TG.Clusternr
								when TG.Clusternr like '%FINC%' then (SELECT TOP 1 Clusternummer
																	FROM [empire_staedion_data].[bik].[ELS_ClusternummerClusternummerOud] 
																	where ClusternummerOud = TG.Clusternr
																	order by Clusternummer asc)
								else null end)
inner join [empire_staedion_data].[bik].CBS_Buurt2020 as BU on CL.BuurtCode = BU.BuurtCode
where [Welk cijfer geeft u voor de kwaliteit van uw woning?] is not null and TG.Clusternr is not null and year(TG.[INGEVULDE GEGEVENS]) <> 2015

GO
