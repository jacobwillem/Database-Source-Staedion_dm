SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Algemeen].[Energielabel verandering]
as
	
	--Eenheidnummer = 'OGEH-0006033' 3 maanden tijdelijke opname zonder afmelding
	--Eenheidnummer = 'OGEH-0001665' 6 maanden durende opname met 3 nette afmeldingen
	--Eenheidnummer = 'OGEH-0026214' geen sprongen maar 50% toename in EI zonder nieuwe afmelding sinds september 2019

	--select	*
	--from [staedion_dm].[Algemeen].[Vabi Energielabel eenheden]
	--where Eenheidnummer = 'OGEH-0007430'
	--order by Datum


with CTE as (
	select OG.[Eenheidnummer]
			,[Huidige Energieindex] = OG.[Energieindex]
			,[Laatste Opnamedatum] = OG.[Opname data]
			,[Laatste Afmelddatum] = OG.[Afmeld data]
			,OG.[Status label]
			,[Na laatste opname afgemeld] = case when OG.[Opname data] <= OG.[Afmeld data] then 1 else 0 end
	from [staedion_dm].[Algemeen].[Vabi Energielabel eenheden] as OG
	where eomonth(OG.Datum) = eomonth(DATEADD(month, 0, getdate()))
	group by OG.Eenheidnummer, OG.[Energieindex], OG.[Opname data], OG.[Afmeld data], OG.[Status label]
	), 
	CTEpre as (
	select	 OG.[Eenheidnummer]
			,[Maand voor laatste opname] = max(OG.[Datum])
	from [staedion_dm].[Algemeen].[Vabi Energielabel eenheden] as OG
	inner join CTE on CTE.Eenheidnummer = OG.Eenheidnummer
	where CTE.[Laatste Opnamedatum] <> OG.[Opname data]
	group by OG.Eenheidnummer
	)

	select 	CTE.Eenheidnummer,
			CTE.[Huidige Energieindex],
			[Vorige Energieindex] = OG.[Energieindex],
			[Delta Energieindex] = (CTE.[Huidige Energieindex] - OG.[Energieindex]),
			[Delta Energieindex %] = 100 * ((CTE.[Huidige Energieindex] - OG.[Energieindex]) / OG.[Energieindex]),
			CTE.[Laatste Opnamedatum],
			[Vorige Opnamedatum] = OG.[Opname data],
			[Laatste Afmelddatum] = cast(CTE.[Laatste Afmelddatum] as date),
			[Vorige Afmelddatum] = cast(OG.[Afmeld data] as date),
			CTE.[Na laatste opname afgemeld],
			[Laatste status label] = CTE.[Status label],
			[Vorige status label] = OG.[Status label],
			[adviesbureau] = coalesce(VLP.adviesbureau,
										ADV.adviesbureau,
										case	when OG.Deelvoorraad like 'Breman%' then 'Breman'
												when OG.Deelvoorraad like 'Atriensis%' then 'Atriensis'
												when OG.Deelvoorraad like 'Staedion' then 'Staedion'
												else null end,
										'Onbekend'
										),
			[Aanvraag Energieindex door verloop] = case when VLP.eenheidnr is null then 0 else 1 end
	from CTE
	inner join CTEpre on 
	CTE.Eenheidnummer = CTEpre.Eenheidnummer
	inner join [staedion_dm].[Algemeen].[Vabi Energielabel eenheden] as OG on
	CTE.Eenheidnummer = OG.Eenheidnummer and
	CTEpre.[Maand voor laatste opname] = OG.Datum
	left outer join [empire_staedion_data].[excel].[VABI_Energielabel_Verlopen] as VLP on
	OG.Eenheidnummer = VLP.eenheidnr
	left outer join [empire_staedion_data].[excel].[VABI_Energielabel_Vernieuwen_Adviesbureau] as ADV on
	OG.Eenheidnummer = ADV.eenheidnr
GO
