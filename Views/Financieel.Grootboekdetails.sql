SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






--USE [staedion_dm]
--GO

--/****** Object:  View [Financieel].[Grootboekdetails]    Script Date: 7-4-2020 13:42:29 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO






CREATE view [Financieel].[Grootboekdetails]
as
select
  [Sleutel grootboekrekening]               = gla.lt_id,
  [Sleutel eenheid]                         = o.lt_id,
  [Rekeningnummer]                          = gla.No_,
  [Sleutel cluster]                         = cl.lt_id,
  [Datum]                                   = convert(date,age.[Posting Date]),
  [Bedrag toegewezen]                       = case when [Realty Object No_] like '%co%' then age.Amount else age.[Allocated Amount] end,
  [Is DAEB]                                 = case when [administrative owner name] like '%Niet%' then 'Nee'
                                                   when [administrative owner name] = '' then null
                                                   else 'Ja' end,
  [Documentnummer]                          = age.[document no_],
  [Werksoort]                               = ews.Omschrijving,
  [Projectnummer]                           = gle.[Empire Projectnr_],
  [Projecttype]                             = gle.[Empire Projecttype]
from empire_data..Staedion$Allocated_G_L_Entries as age
left join empire_data..Staedion$G_L_Entry as gle on 
  gle.[Entry No_] = age.[G_L Entry No_]
left join empire_logic.dbo.lt_mg_g_l_account as gla on
  gla.mg_bedrijf = 'Staedion' and
  gla.No_ = age.[G_L Account No_]
left join empire_logic.dbo.lt_mg_oge as o on 
  o.mg_bedrijf = 'Staedion' and
  o.Nr_ = age.[Realty Object No_]
left join empire_logic.dbo.lt_mg_cluster as cl on
  cl.mg_bedrijf = 'Staedion' and
  cl.Nr_ = age.[Cluster No_]
left join empire_data.dbo.[Staedion$Empire_Werksoort] ews on
  ews.code = gle.[Empire Werksoort]
where age.[G_L Account No_] like 'A8%'
      AND gle.[Source code] NOT LIKE '%DAEB%'				--  JvdW 2021-05-11 toegevoegd
      AND gle.[Source code] NOT LIKE '%BEHEER%'				--  JvdW 2021-05-11 toegevoegd	


--



























GO
