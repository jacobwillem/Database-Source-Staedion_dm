SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE VIEW [Financieel].[Grootboekdetails onderhoud]
AS
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
  [Documentnummer]                          = age.[document no_],
  [Werksoort]                               = ews.Omschrijving,
  [Projectnummer]                           = gle.[Empire Projectnr_],
  [Projecttype]                             = gle.[Empire Projecttype]
FROM empire_data..Staedion$Allocated_G_L_Entries AS age
LEFT JOIN empire_data..Staedion$G_L_Entry AS gle ON 
  gle.[Entry No_] = age.[G_L Entry No_]
LEFT JOIN empire_logic.dbo.lt_mg_g_l_account AS gla ON
  gla.mg_bedrijf = 'Staedion' AND
  gla.No_ = age.[G_L Account No_]
LEFT JOIN empire_logic.dbo.lt_mg_oge AS o ON 
  o.mg_bedrijf = 'Staedion' AND
  o.Nr_ = age.[Realty Object No_]
LEFT JOIN empire_logic.dbo.lt_mg_cluster AS cl ON
  cl.mg_bedrijf = 'Staedion' AND
  cl.Nr_ = age.[Cluster No_]
LEFT JOIN empire_data.dbo.[Staedion$Empire_Werksoort] ews ON
  ews.code = gle.[Empire Werksoort]
join empire_staedion_data.dbo.DwhRekeningschemaAlgemeen as dra on
  dra.No_ = gla.No_ and
  (dra.[Indeling 4] like '%planmatig' or [Indeling 4] like '%correctief')
WHERE age.[G_L Account No_] LIKE 'A8%'
      AND gle.[Source code] NOT LIKE '%DAEB%'				--  JvdW 2021-05-11 toegevoegd
      AND gle.[Source code] NOT LIKE '%BEHEER%'				--  JvdW 2021-05-11 toegevoegd	
	  --AND  DATEPART(HOUR,gle.[Posting Date]) = 23				--  JvdW 2022-01-11 ultimoposten uitsluiten
GO
