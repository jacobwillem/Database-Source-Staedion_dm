SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Leegstand].[Totale leegstand]
as
with cte_addit as (
  select 
    ad.eenheidnr_, 
    ad.[customer no_], 
    ad.[ingangsdatum], 
    ad.[einddatum], 
    volgnr = row_number() over(partition by ad.eenheidnr_ order by ad.[ingangsdatum]), 
    [vorige] = lag(ad.[customer no_], 1, 'nvt') over(partition by ad.eenheidnr_ order by ad.[ingangsdatum])
  from empire_data.dbo.[staedion$additioneel] as ad
)
select 
  [Sleutel eenheid]       = o.lt_id,
  [Sleutel klant]         = basis.Huurder,
  basis.*,
  [Voorgaande huurder]    = case 
                              when ad.vorige in('hrdr-0000001', 'hrdr-0000005', 'hrdr-0000006', 'hrdr-0006942','hrdr-0040736','klnt-0574' ) then 'Saffier of Respect' 
                              else 'Geen Saffier of Respect'
                            end,
  [Huidige huurder]       = case 
                              when basis.huurder in ('klnt-0085743','klnt-0059119','klnt-0054303') then 'Ad Hoc Verhuur, Livable, of VPS' 
                              else 'Overige huurder' 
                            end
from backup_empire_dwh.dbo.[itvf_leegstand_gemiddelde]('20170101', default) as basis
left join cte_Addit as ad on 
  basis.eenheid = ad.eenheidnr_ and
  basis.huurder = ad.[customer no_] and
  basis.[ingang huurcontract] = ad.[ingangsdatum]
left join empire_data.dbo.vw_lt_mg_oge as o on
  o.mg_bedrijf = 'Staedion' and
  o.Nr_ = ad.Eenheidnr_
GO
