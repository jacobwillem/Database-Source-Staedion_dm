SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Liqprog].[Projectgegevens]
as
select 
  [Datum bijgewerkt]                              = [BIJWERKDATUM],
  [Projectnummer]                                 = [PROJECTNUMMER],
  [Projectnaam]                                   = [PROJECTNAAM],
  [Projectsoort]                                  = [PROJECTSOORT],
  [Status]                                        = [STATUS_STAAT_OP],
  [THUISTEAMMANAGER]                              = [THUISTEAMMANAGER],
  [Assetmanager]                                  = [ASSETMANAGER_(GEBIED)],
  [Projectmanager]                                = [PROJECTMANAGER],
  [Aannemer]                                      = [AANNEMER],
  [Aanbestedingsvorm]                             = [AANBESTEDINGSVORM],
  [Projectfase]                                   = [PROJECTFASE],
  [Datum startdocument MJIR]                      = nullif(convert(date,convert(datetime,[STARTDOCUMENT_MJIR])),'1899-12-30'),
  [Datum projectbesluit MJIR]                     = nullif(convert(date,convert(datetime,[PROJECTBESLUIT_MJIR])),'1899-12-30'),
  [Datum aquisitie ontwikkelbesluit MJIR]         = nullif(convert(date,convert(datetime,[ACQUISITIE_ONTWIKKELBESLUIT_MJIR])),'1899-12-30'),
  [Datum investeringsbesluit MJIR]                = nullif(convert(date,convert(datetime,[INVESTERINGSBESLUIT_MJIR])),'1899-12-30'),
  [Datum aankoop uitvoeringsbesluit MJIR]         = nullif(convert(date,convert(datetime,[AANKOOP_UITVOERINGSBESLUIT_MJIR])),'1899-12-30'),
  [Datum dechargebesluit MJIR]                    = nullif(convert(date,convert(datetime,[DECHARGEBESLUIT_MJIR])),'1899-12-30'),
  [Datum intentieovereenkomst MJIR]               = nullif(convert(date,convert(datetime,[INTENTIEOVEREENKOMST_MJIR])),'1899-12-30'),
  [Datum samenwerkingsovereenkomst MJIR]          = nullif(convert(date,convert(datetime,[SAMENWERKINGSOVEREENKOMST_MJIR])),'1899-12-30'),
  [Datum prestatieovereenkomst MJIR]              = nullif(convert(date,convert(datetime,[PRESTATIEOVEREENKOMST_MJIR])),'1899-12-30'),
  [Datum bouwteamovereenkomst MJIR]               = nullif(convert(date,convert(datetime,[BOUWTEAMOVEREENKOMST_MJIR])),'1899-12-30'),
  [Datum turnkey overeenkomst MJIR]               = nullif(convert(date,convert(datetime,[TURN_KEY_OVEREENKOMST_MJIR])),'1899-12-30'),
  [Datum aannemingsovereenkomst MJIR]             = nullif(convert(date,convert(datetime,[AANNEMINGSOVEREENKOMST_MJIR])),'1899-12-30'),
  [Datum oplevering MJIR]                         = nullif(convert(date,convert(datetime,[OPLEVERING_MJIR])),'1899-12-30'),
  [Datum startdocument PROG]                      = nullif(convert(date,convert(datetime,[STARTDOCUMENT_PROG])),'1899-12-30'),
  [Datum projectbesluit PROG]                     = nullif(convert(date,convert(datetime,[PROJECTBESLUIT_PROG])),'1899-12-30'),
  [Datum aquisitie ontwikkelbesluit PROG]         = nullif(convert(date,convert(datetime,[ACQUISITIE_ONTWIKKELBESLUIT_PROG])),'1899-12-30'),
  [Datum investeringsbesluit PROG]                = nullif(convert(date,convert(datetime,[INVESTERINGSBESLUIT_PROG])),'1899-12-30'),
  [Datum aankoop uitvoeringsbesluit PROG]         = nullif(convert(date,convert(datetime,[AANKOOP_UITVOERINGSBESLUIT_PROG])),'1899-12-30'),
  [Datum dechargebesluit PROG]                    = nullif(convert(date,convert(datetime,[DECHARGEBESLUIT_PROG])),'1899-12-30'),
  [Datum intentieovereenkomst PROG]               = nullif(convert(date,convert(datetime,[INTENTIEOVEREENKOMST_PROG])),'1899-12-30'),
  [Datum samenwerkingsovereenkomst PROG]          = nullif(convert(date,convert(datetime,[SAMENWERKINGSOVEREENKOMST_PROG])),'1899-12-30'),
  [Datum prestatieovereenkomst PROG]              = nullif(convert(date,convert(datetime,[PRESTATIEOVEREENKOMST_PROG])),'1899-12-30'),
  [Datum bouwteamovereenkomst PROG]               = nullif(convert(date,convert(datetime,[BOUWTEAMOVEREENKOMST_PROG])),'1899-12-30'),
  [Datum turnkey overeenkomst PROG]               = nullif(convert(date,convert(datetime,[TURN_KEY_OVEREENKOMST_PROG])),'1899-12-30'),
  [Datum aannemingsovereenkomst PROG]             = nullif(convert(date,convert(datetime,[AANNEMINGSOVEREENKOMST_PROG])),'1899-12-30'),
  [Datum oplevering PROG]                         = nullif(convert(date,convert(datetime,[OPLEVERING_PROG])),'1899-12-30'),
  [Datum start sloop MJIR]                        = nullif(convert(date,convert(datetime,[START_SLOOP_MJIR])),'1899-12-30'),
  [Datum start bouw MJIR]                         = nullif(convert(date,convert(datetime,[START_BOUW_MJIR])),'1899-12-30'),
  [Datum programma nieuwbouw MJIR]                = nullif(convert(date,convert(datetime,[PROGRAMMA_NIEUWBOUW_MJIR])),'1899-12-30'),
  [Datum programma renovatie MJIR]                = nullif(convert(date,convert(datetime,[PROGRAMMA_RENOVATIE_MJIR])),'1899-12-30'),
  [Datum programma transformatie MJIR]            = nullif(convert(date,convert(datetime,[PROGRAMMA_TRANSFORMATIE_MJIR])),'1899-12-30'),
  [Datum programma sloop MJIR]                    = nullif(convert(date,convert(datetime,[PROGRAMMA_SLOOP_MJIR])),'1899-12-30'),
  [Datum omgevingsvergunning MJIR]                = nullif(convert(date,convert(datetime,[OMGEVINGSVERGUNNING_MJIR])),'1899-12-30'),
  [Datum start werkzaamheden MJIR]                = nullif(convert(date,convert(datetime,[START_WERKZAAMHEDEN_MJIR])),'1899-12-30'),
  [Datum start sloop PROG]                        = nullif(convert(date,convert(datetime,[START_SLOOP_PROG])),'1899-12-30'),
  [Datum start bouw PROG]                         = nullif(convert(date,convert(datetime,[START_BOUW_PROG])),'1899-12-30'),
  [Datum programma nieuwe PROG]                   = nullif(convert(date,convert(datetime,[PROGRAMMA_NIEUWBOUW_PROG])),'1899-12-30'),
  [Datum programma renovatie PROG]                = nullif(convert(date,convert(datetime,[PROGRAMMA_RENOVATIE_PROG])),'1899-12-30'),
  [Datum programma transformatie PROG]            = nullif(convert(date,convert(datetime,[PROGRAMMA_TRANSFORMATIE_PROG])),'1899-12-30'),
  [Datum programma sloop PROG]                    = nullif(convert(date,convert(datetime,[PROGRAMMA_SLOOP_PROG])),'1899-12-30'),
  [Datum omgevingsvergunning PROG]                = nullif(convert(date,convert(datetime,[OMGEVINGSVERGUNNING_PROG])),'1899-12-30'),
  [Datum start werkzaamheden PROG]                = nullif(convert(date,convert(datetime,[START_WERKZAAMHEDEN_PROG])),'1899-12-30'),
  [Bedrag project budget]                         = [PROJECT_BUDGET],
  [Bedrag project prognose]                       = [PROJECT_PROGNOSE],
  [Bedrag project gerealiseerd]                   = 0.00000
from [empire_staedion_data].[dbo].[gotikr_data]
GO
