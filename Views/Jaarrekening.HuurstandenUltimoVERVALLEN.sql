SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










CREATE view [Jaarrekening].[HuurstandenUltimoVERVALLEN] as

select	oge,
		jaar, 
		juridischEigenaar,
		administratiefEigenaar,
		gemeente,
		eenheidType,
		[decAantal] = [decExploitatie],
		[decNettohuur] = iif([decExploitatie] = 1, coalesce([decNettoHuur], 0), 0),
		gegenereerd = gegenereerd
		from [empire_staedion_data].[jaarrekening].[HuurStanden]
;
GO
