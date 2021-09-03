SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  CREATE function [dbo].[fn_aantal_kamers_per_eenheid] ()
returns table
as
  return


  with cte_kamer_per_eenheid as (
  select oge.lt_id as fk_eenheid_id, [Start Date], upde.[entry no_], Count(*) as [aantal kamers],AVG(upde.m2) as [Gem. oppervlakte]
  from empire_data.dbo.mg_prop_valuation_detail_entry upde
    join empire_data.dbo.mg_unit_point_detail upd on 
      upd.mg_bedrijf = upde.mg_bedrijf and
      upd.[type] = upde.[type] and
      upd.[description] = upde.[description]
    left join empire_logic.dbo.lt_mg_oge oge on
      oge.mg_bedrijf = upde.mg_bedrijf and 
      oge.[Nr_] = upde.[Unit No_]
  where upde.Type = 0
    and upd.[room type] in (1,2,5,6) --woonkamers + slaapkamers + zolders + extra vertrekken
    and upde.[counts as space] = 0
    and upde.[Start Date] <= (select loading_day from empire_logic.dbo.dlt_loading_day)
  group by 
    oge.lt_id,
    [Start Date], 
    upde.[entry no_]),

    cte_aantal_kamers as(

  select fk_eenheid_id, [aantal kamers],[Gem. oppervlakte]
  from cte_kamer_per_eenheid as kpe1
  where not exists (
      select 1 
      from cte_kamer_per_eenheid as kpe2
      where kpe1.fk_eenheid_id = kpe2.fk_eenheid_id
        and kpe1.[Start Date] < kpe2.[Start Date]
    ) 
    and not exists (
      select 1 
      from cte_kamer_per_eenheid as kpe2
      where kpe1.fk_eenheid_id = kpe2.fk_eenheid_id
        and kpe1.[Start Date] = kpe2.[Start Date]
        and kpe1.[entry no_] < kpe2.[entry no_]
    ))

    select * from cte_aantal_kamers
GO
