SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Financieel].[Grootboek budget]
as
select		 [Budget]			= e.[Budget Name]
			,[Rekeningnummer]	= a.[No_]
			,[Rekeningnaam]		= a.[Name]
			,[Rekening]			= a.[No_] + ' ' + a.[Name]
			,[Kostenplaatscode]	= e.[Global Dimension 1 Code]
			,[Kostenplaatsnaam]	= d.[Name]
			,[Kostenplaats]		= e.[Global Dimension 1 Code] + ' ' + d.[Name]	 
			,[Datum]			= convert(date, e.[Date])
			,[Bedrag]			= sum(convert(float, e.[Amount]))
from		empire_data.dbo.Staedion$G_L_Account a
inner join	empire_data.dbo.Staedion$G_L_Budget_Entry e on e.[G_L Account No_] = a.[No_]
left join	empire_data.dbo.Staedion$Dimension_Value d on d.[Code] = e.[Global Dimension 1 Code] and d.[Dimension Code] = 'KOSTENPLAATS'
where		year(e.[Date]) >= year(getdate())-2
group by	e.[Budget Name], a.[No_], a.[Name], e.[Global Dimension 1 Code], d.[Name], e.[Date]

GO
