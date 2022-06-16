SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Verhuur].[Doelgroep]
AS
SELECT   *,[svh_aantal] = CASE 
							WHEN [svh_verhuur_doelstelling] = 'Statushouder' THEN [svh_huishoud_grootte]
							WHEN [svh_verhuur_doelstelling] = 'Convenant' THEN 1
						 END
FROM [TS_data].[dbo].[sociale_verhuur_haaglanden_mutaties_staedion]
WHERE YEAR([svh_huurcontract_getekend]) >= 2020
  AND svh_verhuur_doelstelling IN ('Statushouder', 'Convenant')

  -- Verhuringen in de Glenn Millerhof aan Anton Constandse uitsluiten, verzoek Rian Dijk 20220426
  AND [emp_oge] NOT IN ('OGEH-0064052',
						'OGEH-0064056',
						'OGEH-0064057',
						'OGEH-0064061',
						'OGEH-0064062',
						'OGEH-0064067',
						'OGEH-0064068',
						'OGEH-0064075',
						'OGEH-0064076',
						'OGEH-0064093',
						'OGEH-0064094',
						'OGEH-0064114',
						'OGEH-0064116',
						'OGEH-0064130',
						'OGEH-0064132'
						)
GO
