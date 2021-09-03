SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE view [Algemeen].[Cluster]
as
with cte_bouwjaar as (
  select
    o.mg_bedrijf,
    co.Clusternr_,
    bouwjaar = max(o.[Construction Year]),
    renovatiejaar = max(o.[renovation year])
from empire_data.dbo.mg_cluster_oge as co
  join empire_data.dbo.vw_lt_mg_oge as o on
    o.mg_bedrijf = co.mg_bedrijf and
    o.Nr_ = co.Eenheidnr_
  group by
    o.mg_bedrijf,
    co.Clusternr_
),
cte_tmp as (
  select
    [Sleutel]                         = c.lt_id,
    [Cluster]                         = c.Nr_ + ' ' + c.Naam,
    [Clusternummer]                   = c.Nr_,
    [Clusternaam]                     = c.Naam,
    [Clustersoort]                    = ct.Description,
    [Bouwjaar]                        = isnull(nullif(cb.bouwjaar,''),0),
    [Bouw/renovatiejaar]              = case when cb.renovatiejaar > cb.bouwjaar then cb.renovatiejaar else cb.bouwjaar end,
    [Renovatiejaar]                   = cb.renovatiejaar,
    [Nieuwbouw]                       = case
                                          when cb.bouwjaar >= year(dateadd( yy, -2, getdate())) then 'Ja'
                                          else 'Nee'
                                        end,
    [Sleutel assetmanager]            = ccp.Contactnr_
  from empire_data.dbo.vw_lt_mg_cluster as c
  left join empire_data.dbo.mg_cluster_type as ct on 
    ct.Code = c.Clustersoort and
    ct.mg_bedrijf = c.mg_bedrijf
  left join cte_bouwjaar as cb on
    cb.Clusternr_ = c.Nr_ and
    cb.mg_bedrijf = c.mg_bedrijf
  left join empire_data.dbo.mg_cluster_contactpersoon as ccp on
    ccp.mg_bedrijf = c.mg_bedrijf and
    ccp.Clusternr_ = c.Nr_ and
    ccp.Functie = 'CB-ASSMAN'
)
select 
  *,
  [Klasse bouw/renovatiejaar] = case
                                  when [Bouw/renovatiejaar] < 1945 then 'Tot 1945'
                                  when [Bouw/renovatiejaar] < 1960 then '1945 - 1959'
                                  when [Bouw/renovatiejaar] < 1970 then '1960 - 1969'
                                  when [Bouw/renovatiejaar] < 1980 then '1970 - 1979'
                                  when [Bouw/renovatiejaar] < 1990 then '1980 - 1989'
                                  when [Bouw/renovatiejaar] < 2000 then '1990 - 1999'
                                  when [Bouw/renovatiejaar] < 2010 then '2000 - 2009'
                                  when [Bouw/renovatiejaar] >= 2010 then '2010 en later'
                                  else 'Onbekend'
                                end,
  [Klasse bouw/renovatiejaar sortering] = case
                                            when [Bouw/renovatiejaar] < 1945 then 1
                                            when [Bouw/renovatiejaar] < 1960 then 2
                                            when [Bouw/renovatiejaar] < 1970 then 3
                                            when [Bouw/renovatiejaar] < 1980 then 4
                                            when [Bouw/renovatiejaar] < 1990 then 5
                                            when [Bouw/renovatiejaar] < 2000 then 6
                                            when [Bouw/renovatiejaar] < 2010 then 7
                                            when [Bouw/renovatiejaar] >= 2010 then 8
                                            else 9
                                          end
from cte_tmp



GO
