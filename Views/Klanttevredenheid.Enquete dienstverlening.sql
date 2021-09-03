SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Klanttevredenheid].[Enquete dienstverlening]
as

select
 [Sleutel eenheid]                                         = oge.lt_id,
 [Algemene tevredenheid]                                   = convert(int,skcm.algemene_tevredenheid),
 [Datum]                                                   = convert(date, ingevulddate)
from staging.kcm_dienstverlening as skcm
left join empire_logic.dbo.lt_mg_oge as oge on 
  oge.mg_bedrijf = 'Staedion' and
  oge.Nr_ = skcm.eenheidnr
GO
