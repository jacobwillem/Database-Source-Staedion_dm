SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Algemeen].[Grootboekrekening Staedion]
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
  [Ip categorieen]                                      = case when dra.[Indeling 4] = '' or dra.[Indeling 4] is null 
                                                               then '1.1) Overige niet gekoppelde rekeningen'
                                                               else [Indeling 4] end,
  [Rekening categorie]                                  = case when gla.[No_] in (
                                                               'A810200',
                                                               'A810300',
                                                               'A810400',
                                                               'A810450',
                                                               'A810500',
                                                               'A850150') 
                                                               then 'Opbrengsten'
                                                               when gla.[No_] in(  
                                                               'A816630',
                                                               'A816640',
                                                               'A816610',
                                                               'A815520',
                                                               'A815540',
                                                               'A815640',
                                                               'A815680',
                                                               'A815320',
                                                               'A815340',
                                                               'A815360',
                                                               'A814850',
                                                               'A815160',
                                                               'A850250',
                                                               'A815180',
                                                               'A812800',
                                                               'A815310',
                                                               'A815380',
                                                               'A815400',
                                                               'A816340',
                                                               'A816380',
                                                               'A814100',
                                                               'A814380') then 'Exploitatielasten' else null end,

  [Rekening subtotaal categorie]                            = case when gla.[No_] in
                                                                ('A810200', 
                                                                'A810300',
                                                                'A810350', 
                                                                'A810400', 
                                                                'A810450', 
                                                                'A810500', 
                                                                'A850150', 
                                                                'A850350') 
                                                               then 'bruto opbrengst totaal'
                                                               when gla.[No_] in
                                                                 ('A816630',
                                                                 'A814450', 
                                                                 'A816550', 
                                                                 'A816640') then 'zakelijke lasten (excl verzekering/erfpacht)'
                                                                when gla.[No_] in
                                                                 ('A816420',
                                                                 'A816430',
                                                                 'A850700',
                                                                 'A850710') then 'beheerkosten'
                                                                when gla.[No_] in
                                                                  ('A815120',
                                                                  'A815140',
                                                                  'A815160',
                                                                  'A815180',
                                                                  'A815220',
                                                                  'A815240',
                                                                  'A815310',
                                                                  'A815320',
                                                                  'A815340',
                                                                  'A815360') then 'correctief onderhoud'
                                                                when gla.[No_] in
                                                                  ('A815520', 
                                                                  'A815540', 
                                                                  'A815560', 
                                                                  'A815580', 
                                                                  'A815640', 
                                                                  'A815680', 
                                                                  'A815740',  
                                                                  'A815800',  
                                                                  'A815900',  
                                                                  'A815945',  
                                                                  'A816150',  
                                                                  'A816200',  
                                                                  'A816250',  
                                                                  'A816440',  
                                                                  'A850250') then 'planmatig onderhoud'
                                                                 when gla.[No_] in(
                                                                    'A811100',
                                                                    'A811200',
                                                                    'A811800',
                                                                    'A811900',
                                                                    'A816340',
                                                                    'A816380',
                                                                    'A816410',
                                                                    'A812100',
                                                                    'A812200',
                                                                    'A812900',
                                                                    'A812945',
                                                                    'A815380',
                                                                    'A815400') then 'servicekosten eigen rekening'
                                                                 when gla.[No_] in(
                                                                    'A814100',
                                                                    'A814200',
                                                                    'A814250',
                                                                    'A814300',
                                                                    'A814350',
                                                                    'A814380',
                                                                    'A814400',
                                                                    'A814450',
                                                                    'A814460',
                                                                    'A814550',
                                                                    'A814650',
                                                                    'A814700',
                                                                    'A814850',
                                                                    'A814900',
                                                                    'A814945') then 'beheer en verhuuractiviteiten'
                                                                 when gla.[No_] in(
                                                                     'A816610',
                                                                     'A816620') then 'beheer overige directe operationele lasten'
                                                                 when gla.[No_] in(
                                                                      'A815420',
                                                                      'A870100',
                                                                      'A870300',
                                                                      'A870400',
                                                                      'A870500',
                                                                      'A870520',
                                                                      'A870945') then 'beheer leefbaarheid' else null end

from empire_data.dbo.vw_lt_mg_g_l_account as gla
left join Groepering.[Grootboekrekening - Toegerekende kosten] as gtk on
  gtk.Rekening = gla.no_
left join empire_staedion_data.dbo.DwhRekeningschemaAlgemeen as dra on
  dra.No_ = gla.No_
where gla.mg_bedrijf = 'staedion'






GO
