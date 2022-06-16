SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE VIEW [Financieel].[Grootboekdetails]
AS
-- JvdW 2022-01-11 22 01 353 Onderhoudslasten 2022 niet te zien
-- select count(*) from [Financieel].[Grootboekdetails] -- 40.598.718 01:35 voor 
-- select count(*) from [Financieel].[Grootboekdetails] -- 40.598.718 01:23 voor 
SELECT
  [Sleutel grootboekrekening]               = gla.lt_id,
  [Sleutel eenheid]                         = o.lt_id,
  [Rekeningnummer]                          = gla.No_,
  [Sleutel cluster]                         = cl.lt_id,
  [Datum]                                   = CONVERT(DATE,gle.[Posting Date]),
  [Bedrag toegewezen]                       = age.[Allocated Amount],--case when [Realty Object No_] like '%co%' then age.Amount else age.[Allocated Amount] end,
  [Is DAEB]                                 = CASE WHEN [administrative owner name] LIKE '%Niet%' THEN 'Nee'
                                                   WHEN [administrative owner name] = '' THEN NULL
                                                   ELSE 'Ja' END,
  [Documentnummer]                          = age.[document no_]
  --[Werksoort]                               = ews.Omschrijving,
  --[Projectnummer]                           = gle.[Empire Projectnr_],
  --[Projecttype]                             = gle.[Empire Projecttype]
FROM empire_data..Staedion$Allocated_G_L_Entries AS age
-- RST: Let op: hier echt de vw_lt_mg_g_l_entry pakken want daar zitten indexen op!
LEFT JOIN empire_data..vw_lt_mg_g_l_entry AS gle ON 
  gle.[Entry No_] = age.[G_L Entry No_] and
  gle.mg_bedrijf = 'Staedion' 
LEFT JOIN empire_logic.dbo.lt_mg_g_l_account AS gla ON
  gla.mg_bedrijf = 'Staedion' AND
  gla.No_ = age.[G_L Account No_]
LEFT JOIN empire_logic.dbo.lt_mg_oge AS o ON 
  o.mg_bedrijf = 'Staedion' AND
  o.Nr_ = age.[Realty Object No_]
LEFT JOIN empire_logic.dbo.lt_mg_cluster AS cl ON
  cl.mg_bedrijf = 'Staedion' AND
  cl.Nr_ = age.[Cluster No_]
WHERE age.[G_L Account No_] LIKE 'A8%'
      AND gle.[Source code] NOT LIKE '%DAEB%'				--  JvdW 2021-05-11 toegevoegd
      AND gle.[Source code] NOT LIKE '%BEHEER%'				--  JvdW 2021-05-11 toegevoegd	
	  --AND  DATEPART(HOUR,gle.[Posting Date]) = 23				--  JvdW 2022-01-11 ultimoposten uitsluiten


UNION ALL
-- 2020 in backup weggeschreven
SELECT		[Sleutel grootboekrekening],
		  [Sleutel eenheid],
		  [Rekeningnummer],
		  [Sleutel cluster],
		  [Datum],
		  [Bedrag toegewezen],
		  [Is DAEB],
		  [Documentnummer]
		  --[Werksoort],
		  --[Projectnummer],
		  --[Projecttype]  
FROM	staedion_dm.[Financieel].[Grootboekdetails_2020_A8]



GO
