SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Eenheden].[Els wijzigingen] 
as
 with cte as (        
select 
  datum_gegenereerd, 
  eenheidnr, 
  waarde, 
  kolom, 
  row_number() over (partition by eenheidnr, kolom order by datum_gegenereerd) as prio
from   
   (
  select 
    datum_gegenereerd,
    eenheidnr, 
    datum_in_exploitatie                    = convert(sql_variant,datum_in_exploitatie, 105),
    datum_uit_exploitatie                   = convert(sql_variant,datum_uit_exploitatie, 105),
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
		-- select distinct datum_gegenereerd
  from empire_staedion_data.dbo.els
  where datum_gegenereerd in ('20211231','20220613') -- day(dateadd(dd,1,datum_gegenereerd)) = 1 -- alleen laatste dag van de maand
	--and eenheidnr like 'OGEH-0000%' 
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
select 
  nieuw.datum_gegenereerd as datum,
  nieuw.eenheidnr,
  nieuw.kolom,
	c.DATA_TYPE as datatype,
  oud.waarde as was,
  nieuw.waarde as wordt
from cte as nieuw
join cte as oud on 
  oud.eenheidnr = nieuw.eenheidnr and
  oud.kolom = nieuw.kolom and
  oud.prio = nieuw.prio - 1 -- haal vorige record op
join empire_staedion_data.INFORMATION_SCHEMA.columns as c on
  c.column_name = nieuw.kolom and
	c.TABLE_NAME = 'els'
where oud.waarde <> nieuw.waarde

GO
