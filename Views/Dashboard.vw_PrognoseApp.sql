SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Dashboard].[vw_PrognoseApp]
as
select * from (
	select 
			 [id]				= b.[id]
			,[Indicator]		= i.[Aanduiding] + ' ' + i.[Omschrijving]
			,[Volgorde]			= i.[Volgorde]
			,[Aanspreekpunt]	= a.[Omschrijving]
			,[Weergaveformat]	= i.[Weergaveformat]
			,[Jaarnorm]			= i.[Jaarnorm]
			,[Jaar]				= b.[Jaar]
			,[Maand]			= b.[Maand]
			,[Waarde]			= p.[Waarde]
	from (
		select
			 [id]				= i.[id]
			,[Jaarmaand]		= d.[Jaarmaand]
			,[Jaar]				= d.[Jaar]
			,[Maand]			= d.[Maand]
		from [Dashboard].[Indicator] i
		full outer join (select [Jaar], [Maand] = [Maand van het jaar kort], [Jaarmaand] = [Maand code] from [Algemeen].[Datum] where Jaar between year(dateadd(year, -1, getdate())) and year(dateadd(year, 1, getdate())) group by [Jaar], [Maand van het jaar kort], [Maand code]) d on 1 = 1
		) b
	left outer join [Dashboard].[Indicator] i on i.[id] = b.[id]
	left outer join [Dashboard].[Aanspreekpunt] a on a.[id] = i.[fk_aanspreekpunt_id]
	left outer join [Dashboard].[Prognose] p on p.[fk_indicator_id] = b.[id] and p.[Jaarmaand] = b.[Jaarmaand]
) qry
pivot (
	max([Waarde])
	for [Maand] in ([Jan],[Feb],[Mrt],[Apr],[Mei],[Jun],[Jul],[Aug],[Sep],[Okt],[Nov],[Dec])
) piv

GO
