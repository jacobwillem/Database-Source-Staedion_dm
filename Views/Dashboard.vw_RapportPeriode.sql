SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Dashboard].[vw_RapportPeriode]
AS
select	 RAP.[Rapport]
		,DAT.[Datum]
from [Dashboard].[Rapport] RAP
inner join [Algemeen].[Datum] DAT on DAT.[Datum] between coalesce(RAP.[Startdatum], '17530101') and iif(RAP.[Einddatum] <= getdate(), RAP.[Einddatum], dateadd(yy, datediff(yy, 0, getdate()) + 1, -1))

GO
