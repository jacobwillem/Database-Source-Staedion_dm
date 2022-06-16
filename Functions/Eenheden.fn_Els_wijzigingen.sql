SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [Eenheden].[fn_Els_wijzigingen] (
  @datum_1 date,
  @datum_2 date
)

returns @t table(
  [Datum 1] date, 
  [Datum 2] date, 
  Eenheidnr varchar(255), 
  Kolom varchar(255), 
  Datatype varchar(255), 
  Was sql_variant, 
  Wordt sql_variant,
  Verschil numeric(12,2)
)

as
begin

declare 
  @p_datum_1 date,
  @p_datum_2 date

set @p_datum_1 = @datum_1
set @p_datum_2 = @datum_2;

with cte_eenheden as (
select eenheidnr, datum_in_exploitatie, datum_uit_exploitatie, clusternummer, pnt_totaal_na_afronding, [epa-label], energieindex, nettohuur, oppervlakte_vvo, oppervlakte_bvo, [gebruiksoppervlakte conform nta 8800], omschrijving_technischtype, [administratieve eigenaar], bouwjaar, renovatiejaar, geliberaliseerd from empire_staedion_data.dbo.els where datum_gegenereerd = @datum_2
except 
select eenheidnr, datum_in_exploitatie, datum_uit_exploitatie, clusternummer, pnt_totaal_na_afronding, [epa-label], energieindex, nettohuur, oppervlakte_vvo, oppervlakte_bvo, [gebruiksoppervlakte conform nta 8800], omschrijving_technischtype, [administratieve eigenaar], bouwjaar, renovatiejaar, geliberaliseerd from empire_staedion_data.dbo.els where datum_gegenereerd = @datum_1
),
cte as (
select 
  datum_gegenereerd, 
  eenheidnr, 
  waarde, 
  kolom
from   
   (
  select 
    datum_gegenereerd,
    eenheidnr, 
    datum_in_exploitatie                    = convert(sql_variant,datum_in_exploitatie),
    datum_uit_exploitatie                   = convert(sql_variant,datum_uit_exploitatie),
    clusternummer                           = convert(sql_variant,clusternummer), 
    pnt_totaal_na_afronding                 = convert(sql_variant,pnt_totaal_na_afronding),  
    [epa-label]                             = convert(sql_variant,[epa-label]), 
    energieindex                            = convert(sql_variant,energieindex), 
    nettohuur                               = convert(sql_variant,nettohuur),
    oppervlakte_vvo                         = convert(sql_variant,oppervlakte_vvo),
    oppervlakte_bvo                         = convert(sql_variant,oppervlakte_bvo), 
    [gebruiksoppervlakte conform nta 8800]  = convert(sql_variant,[gebruiksoppervlakte conform nta 8800]), 
    omschrijving_technischtype              = convert(sql_variant,omschrijving_technischtype),
    [administratieve eigenaar]              = convert(sql_variant,[administratieve eigenaar]), 
    bouwjaar                                = convert(sql_variant,bouwjaar),
    renovatiejaar                           = convert(sql_variant,renovatiejaar), 
    geliberaliseerd                         = convert(sql_variant,geliberaliseerd)
  from empire_staedion_data.dbo.els
  where (datum_gegenereerd = @datum_1 or datum_gegenereerd = @datum_2) and
  exists (select eenheidnr from cte_eenheden ce where ce.eenheidnr = els.eenheidnr)
	--and eenheidnr = 'OGEH-0000393'
) p  
unpivot  
   (waarde for kolom in (
    datum_in_exploitatie, 
    datum_uit_exploitatie, 
    clusternummer, 
    pnt_totaal_na_afronding,  
    [epa-label], 
    energieindex, 
    nettohuur, 
    oppervlakte_vvo,
    oppervlakte_bvo, 
    [gebruiksoppervlakte conform nta 8800], 
    omschrijving_technischtype,
    [administratieve eigenaar], 
    bouwjaar,
    renovatiejaar, 
    geliberaliseerd)  
)as unpvt
)
insert into @t
select 
  oud.datum_gegenereerd as datum_was,
  nieuw.datum_gegenereerd as datum_wordt,
  nieuw.eenheidnr,
  nieuw.kolom,
	c.DATA_TYPE as datatype,
  case when c.data_type like 'date%' then convert(varchar,oud.waarde,105) else oud.waarde end as was,
  case when c.data_type like 'date%' then convert(varchar,nieuw.waarde,105) else nieuw.waarde end as wordt,
  case when c.data_type in ('int', 'decimal') then convert(numeric(12,2),nieuw.waarde) - convert(numeric(12,2),oud.waarde) else null end
from cte as nieuw
join cte as oud on 
  oud.eenheidnr = nieuw.eenheidnr and
  oud.kolom = nieuw.kolom and
  oud.datum_gegenereerd = @datum_1 -- haal vorige record op
join empire_staedion_data.INFORMATION_SCHEMA.columns as c on
  c.column_name = nieuw.kolom and
	c.TABLE_NAME = 'els' and
  c.TABLE_SCHEMA = 'dbo'
where nieuw.datum_gegenereerd = @datum_2
and oud.waarde <> nieuw.waarde

return

end

GO
