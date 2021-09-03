SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE view [Algemeen].[Grootboekrekening]
as
select
  [Sleutel]                                             = gla.lt_id,
  [Rekeningnummer]                                      = gla.[No_],
  [Rekeningnaam]                                        = gla.Name,
  [Rekening]                                            = gla.No_ + ' ' + gla.Name,
  [Hoofdgroep Waardeontwikkeling en rendement]          = isnull(gtk.Hoofdgroep, 'Niet ingedeeld'),
  [Hoofdgroep w en r sortering]                         = gtk.[Hoofdgroep sortering],
  [Subgroep Waardeontwikkeling en rendement]            = isnull(gtk.Subgroep, 'Niet ingedeeld'),
  [Subgroep w en r sortering]                           = gtk.[Subgroep sortering],
  [Toelichting Waardeontwikkeling en rendement]         = gtk.Toelichting,
  [Omschrijving Waardeontwikkeling en rendement]        = isnull(gtk.Omschrijving, 'Niet ingedeeld'),
  [Rekening voor Waardeontwikkeling en rendement]       = case when gla.no_ like 'A8%' then 'Ja' else 'Nee' end,
  [Ip categorieen]                                      = case when dra.[Indeling 4] = '' then '1.1) Overige niet gekoppelde rekeningen'
                                                                else [Indeling 4] end,
  [Soort onderhoud]                                     = case 
                                                            when [Indeling 4] like '%planmatig' then 'Planmatig onderhoud'
                                                            when [Indeling 4] like '%correctief' then 'Correctief onderhoud'
                                                            else 'Geen onderhoud'
                                                          end
from empire_data.dbo.vw_lt_mg_g_l_account as gla
left join Groepering.[Grootboekrekening - Toegerekende kosten] as gtk on
  gtk.Rekening = gla.no_
left join empire_staedion_data.dbo.DwhRekeningschemaAlgemeen as dra on
  dra.No_ = gla.No_
GO
