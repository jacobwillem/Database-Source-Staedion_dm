SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





Create VIEW [Jaarrekening].[HuuropbrengstGrootboekControleerEenheden]
AS
with cteHS as(
  SELECT	 HS.Eenheidnummer
			,Jaar = year(HS.Peildatum)
			,Maand = MONTH(HS.Peildatum)
			,Huurstand = sum(HS.[Netto huur])
  FROM [staedion_dm].[Jaarrekening].[Huurstanden] as HS
  where [Prolongatietermijn] = '1M'
  group by HS.Eenheidnummer, year(HS.Peildatum), month(HS.Peildatum)
 )
 , cteGB as(
  SELECT	 GB.Eenheidnummer
			,Jaar = year(GB.Boekdatum)
			,Maand = MONTH(GB.Boekdatum)
			,Geboekt = sum(coalesce(GB.Geboekt, 0))
  FROM [staedion_dm].[Jaarrekening].[HuuropbrengstGrootboek] as GB
  where GB.Eenheidnummer <> '' and GB.Broncode = 'PROLON'
  group by GB.Eenheidnummer, year(GB.Boekdatum), month(GB.Boekdatum)
 )
SELECT DISTINCT Eenheidnummer = HS.Eenheidnummer,
  Jaar = HS.Jaar
  FROM cteHS as HS
  left outer join cteGB as GB on
	HS.Eenheidnummer = GB.Eenheidnummer and HS.Jaar = GB.Jaar and HS.Maand = GB.Maand
  where abs(HS.Huurstand + coalesce(Geboekt, 0)) <> 0.00
GO
