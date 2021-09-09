SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Liqprog].[Projectgegevens_unpvt]
as
select
  Projectnummer, 
  kolom, 
  waarde,
  case when kolom like 'JAAR%' then 'Jaar' else 'Maand' end as soort,
  nummer = REPLACE(REPLACE(kolom, 'LQ_MND_',''),'JAAR_','')
from (
  select Projectnummer, [LQ_MND_1], [LQ_MND_2], [LQ_MND_3], [LQ_MND_4], [LQ_MND_5], [LQ_MND_6], [LQ_MND_7], [LQ_MND_8], [LQ_MND_9], [LQ_MND_10], [LQ_MND_11], [LQ_MND_12], [JAAR_1], [JAAR_2], [JAAR_3], [JAAR_4], [JAAR_5], [JAAR_6], [JAAR_7], [JAAR_8], [JAAR_9], [JAAR_10], [JAAR_11], [JAAR_12], [JAAR_13], [JAAR_14], [JAAR_15] from Liqprog.Projectgegevens
  ) p
unpivot
  (waarde for kolom in
    ([LQ_MND_1], [LQ_MND_2], [LQ_MND_3], [LQ_MND_4], [LQ_MND_5], [LQ_MND_6], [LQ_MND_7], [LQ_MND_8], [LQ_MND_9], [LQ_MND_10], [LQ_MND_11], [LQ_MND_12], [JAAR_1], [JAAR_2], [JAAR_3], [JAAR_4], [JAAR_5], [JAAR_6], [JAAR_7], [JAAR_8], [JAAR_9], [JAAR_10], [JAAR_11], [JAAR_12], [JAAR_13], [JAAR_14], [JAAR_15])
    ) as unpvt
GO
