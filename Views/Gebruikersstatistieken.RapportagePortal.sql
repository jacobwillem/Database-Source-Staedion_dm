SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Gebruikersstatistieken].[RapportagePortal] as

select distinct Datum = format(LogTime, '20yy-MM-dd')
				, RapportNaam = right(RU.DocumentPath, CHARINDEX('/', REVERSE(RU.DocumentPath)) - 1)
				, RapportType = right(RU.DocumentPath, CHARINDEX('.', REVERSE(RU.DocumentPath)))
				, GebruikerID = lower(right(RU.UserLogin, len(RU.UserLogin) - CHARINDEX('\', RU.UserLogin)))
				, GebruikerFunctie = WN.Functie
				, GebruikerNaam = case when WN.[Volledige naam] IS NULL then '?' + lower(right(RU.UserLogin, len(RU.UserLogin) - CHARINDEX('\', RU.UserLogin))) collate Latin1_General_CI_AS_KS_WS else WN.[Volledige naam] end
				, GebruikerEmail = WN.[Werk email]
				, GebruikerService = case when lower(right(RU.UserLogin, len(RU.UserLogin) - CHARINDEX('\', RU.UserLogin))) like 'iusr' then 1
											when lower(right(RU.UserLogin, len(RU.UserLogin) - CHARINDEX('\', RU.UserLogin))) like 'svcdwhreport' then 1
											when lower(right(RU.UserLogin, len(RU.UserLogin) - CHARINDEX('\', RU.UserLogin))) like 'svcspfarm' then 1
											when lower(right(RU.UserLogin, len(RU.UserLogin) - CHARINDEX('\', RU.UserLogin))) like 'jvdw' then 1
											when lower(right(RU.UserLogin, len(RU.UserLogin) - CHARINDEX('\', RU.UserLogin))) like 'mbro' then 1
											when lower(right(RU.UserLogin, len(RU.UserLogin) - CHARINDEX('\', RU.UserLogin))) like 'ere' then 1
											when lower(right(RU.UserLogin, len(RU.UserLogin) - CHARINDEX('\', RU.UserLogin))) like 'pepijn.pennings' then 1
											when lower(right(RU.UserLogin, len(RU.UserLogin) - CHARINDEX('\', RU.UserLogin))) like 'martijn.vreugdenhil' then 1
											else 0 end
from empire_staedion_data.sharepoint.[RequestUsage] as RU
	left outer join empire_Staedion_Data.visma.werknemers as WN on
	cast(lower(right(RU.UserLogin, len(RU.UserLogin) - CHARINDEX('\', RU.UserLogin))) as nvarchar(100)) collate Latin1_General_CI_AS_KS_WS =
	cast(lower(right(WN.Inlognaam, len(WN.Inlognaam) - CHARINDEX('\', WN.Inlognaam))) as nvarchar(100))
GO
