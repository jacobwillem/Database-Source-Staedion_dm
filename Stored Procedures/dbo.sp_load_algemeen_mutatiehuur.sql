SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_load_algemeen_mutatiehuur]
as
begin

  drop table if exists Algemeen.Mutatiehuur

  select
    Datum = db.datum,
    Eenheidnr = e.bk_nr_,
    Mutatiehuur = HPR.streefhuur_oud
  into Algemeen.Mutatiehuur
  from empire_dwh.dbo.d_bestand as db
  join empire_dwh.dbo.eenheid as e on e.id = db.fk_eenheid_id
  cross apply empire_staedion_data.[dbo].[ITVfnHuurprijs](e.bk_nr_, db.datum)  as HPR
  where e.da_bedrijf = 'Staedion'
  and db.datum >= DATEADD(yy,-2, getdate())

end
GO
