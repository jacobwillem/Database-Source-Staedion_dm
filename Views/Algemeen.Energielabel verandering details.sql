SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create view [Algemeen].[Energielabel verandering details]
as
	
	--Eenheidnummer = 'OGEH-0006033' 3 maanden tijdelijke opname zonder afmelding
	--Eenheidnummer = 'OGEH-0001665' 6 maanden durende opname met 3 nette afmeldingen
	--Eenheidnummer = 'OGEH-0026214' geen sprongen maar 50% toename in EI zonder nieuwe afmelding sinds september 2019

	--select	*
	--from [staedion_dm].[Algemeen].[Vabi Energielabel eenheden]
	--where Eenheidnummer = 'OGEH-0007430'
	--order by Datum

	select 	VABIEI.*
	from Algemeen.[Vabi Energielabel eenheden] as VABIEI
	inner join Algemeen.[Energielabel verandering] as ELV on
	VABIEI.Eenheidnummer = ELV.Eenheidnummer

GO
