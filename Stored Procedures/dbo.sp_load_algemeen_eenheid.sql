SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_load_algemeen_eenheid]
AS
/* ##########################################################################################################
-- Aangemaakt door Ruben Stolk tbv performance view algemeen.eenheid
-- JvdW 12-03-21 Toevoeging nav overleg met Hailey en Margot: 
-- alter table algemeen.eenheid add [Voorheen Vestia] nvarchar(20)  
-- alter table algemeen.eenheid add [Huidig contract met reden huurverlaging] nvarchar(20)
-- EXEC staedion_Dm.dbo.sp_load_algemeen_eenheid
-- SELECT * FROM staedion_dm.algemeen.eenheid where [Huidig contract met reden huurverlaging] is not null

------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
------------------------------------------------------------------------------------------------------------
20210623 JvdW
> Op verzoek van Paul de Vries EAN-codes toegevoegd
20210714 JvdW
> Op verzoek van Rianne expliciet toevoegen Contactpersoon BOG (functie = CB-BOG"
alter table Algemeen.eenheid add [Contactpersoon BOG] nvarchar(100)
select  * from  Algemeen.eenheid where eenheidnummer = 'OGEH-0052505'

########################################################################################################## */
begin

  drop table if exists Algemeen.eenheid
  
  select
    id = am.[sleutel eenheid],
    Leegwaarde = am.leegwaarde,
    Marktwaarde = am.marktwaarde,
    Markthuur = am.markthuur,
    Beleidswaarde = am.beleidswaarde,
    Peildatum = am.datum,
    Prio = row_number() over (partition by [sleutel eenheid] order by datum desc)
  into #marktenleegwaarde
  from Algemeen.Marktwaarde as am

  select
    mg_bedrijf,
    eenheidnr = [Realty Object No_],
    daeb = [Dimension Value],
    prio = ROW_NUMBER() over (partition by mg_bedrijf, [realty object no_] order by [start date] desc)
  into #daeb
  from empire_data.dbo.vw_lt_mg_oge_administrative_owner 

  select 
    eenheidnr = Code,
    verdieping = Waarde - 2,
    prio = ROW_NUMBER() over (partition by code order by ingangsdatum desc, archiefnr_ desc)
  into #verdieping
  from empire_data..Staedion$WRB_Kenmerkposten 
  where Kenmerk = 'OK135'
  and waarde >= 2

  select
    ec.Eenheidnr_,
    ec.Contactnr_,
    c.Name,
    prio = ROW_NUMBER() over (partition by eenheidnr_ order by contactnr_)
  into #verhuurder
  from empire_data.dbo.vw_lt_mg_eenheid_contactpersoon as ec 
  join empire_data.dbo.contact as c on c.No_ = ec.Contactnr_
  where Functie = 'CB-EVHPPL'
  

 select 
    cl.mg_bedrijf,
    [eenheidnummer]                = o.Nr_,
    Contactnr_                     = ISNULL(ec.contactnr_,ccp.Contactnr_),
    prio                           = ROW_NUMBER() over(partition by cl.mg_bedrijf,o.Nr_ order by ISNULL(ec.contactnr_,ccp.Contactnr_) desc)
  into #assman
  from algemeen.[cluster eenheid] as ce
  left join empire_data.dbo.vw_lt_mg_cluster as cl on
    cl.lt_id = ce.[Sleutel cluster] and
    cl.Clustersoort = 'FTCLUSTER'
  join  empire_logic.dbo.lt_mg_oge as o on
    o.lt_id = ce.[Sleutel eenheid]
  left join empire_data.dbo.vw_lt_mg_eenheid_contactpersoon as ec on
    ec.mg_bedrijf = cl.mg_bedrijf and
    ec.Eenheidnr_ = o.Nr_ and
    ec.Functie = 'CB-ASSMAN'
  left join empire_data.dbo.mg_cluster_contactpersoon as ccp on
    ccp.mg_bedrijf = cl.mg_bedrijf and
    ccp.Clusternr_ = cl.Nr_ and
    ccp.Functie = 'CB-ASSMAN'

  select 
    cl.mg_bedrijf,
    [eenheidnummer]                = o.Nr_,
    Contactnr_                     = ISNULL(ec.contactnr_,ccp.Contactnr_),
    prio                           = ROW_NUMBER() over(partition by cl.mg_bedrijf,o.Nr_ order by ISNULL(ec.contactnr_,ccp.Contactnr_) desc)
  into #vhteam
  from algemeen.[cluster eenheid] as ce
  join empire_logic.dbo.lt_mg_cluster as cl on
    cl.lt_id = ce.[Sleutel cluster]
  join  empire_logic.dbo.lt_mg_oge as o on
    o.lt_id = ce.[Sleutel eenheid]
  left join empire_data.dbo.mg_eenheid_contactpersoon as ec on
    ec.mg_bedrijf = cl.mg_bedrijf and
    ec.Eenheidnr_ = o.Nr_ and
    ec.Functie = 'CB-VHTEAM'
  left join empire_data.dbo.mg_cluster_contactpersoon as ccp on
    ccp.mg_bedrijf = cl.mg_bedrijf and
    ccp.Clusternr_ = cl.Nr_ and
    ccp.Functie = 'CB-VHTEAM'

  select 
  [Realty Object No_],
  [mg_bedrijf],
  [Owner],
  [Start Date],
  [prio] = ROW_NUMBER() OVER(PARTITION BY [Realty Object No_] ORDER BY [Start Date] desc)
  into #eigenaar
  from [empire_data].[dbo].[vw_lt_mg_realty_object_owner_supervisor]
  where Owner in ('RLTS-0002476','RLTS-0104788')

  select 
  [Eenheidnr_],
  [mg_bedrijf],
  [lift],
  [prio] = ROW_NUMBER() over(partition by [Eenheidnr_] order by [ingangsdatum] desc)
  into #lift
  from empire_data.dbo.vw_lt_mg_property_valuation


  -- vvo
  ;with cte as (
    select
      Eenheidnr_,
      Aantal,
      prio = ROW_NUMBER() over (partition by eenheidnr_ order by contractvolgnr_) 
    from empire_data.dbo.Staedion$OGE_functie ofu
    where Code = 'M2  VVO'
  )
  select * into #vvo from cte where prio = 1

  select oge.lt_id as fk_eenheid_id, [Start Date], upde.[entry no_], Count(*) as [aantal kamers],AVG(upde.m2) as [Gem. oppervlakte], SUM(upde.m2) as [Oppervlakte]
  into #kamer_per_eenheid
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
    and upde.[Start Date] <= GETDATE()
  group by 
    oge.lt_id,
    [Start Date], 
    upde.[entry no_]

  select 
    fk_eenheid_id, 
    [aantal kamers],
    [Groepering aantal kamers] = 
      case 
        when isnull([aantal kamers],0) <= 1 then '<= 1 kamer'
        when [aantal kamers] = 2 then '2 kamers'
        when [aantal kamers] = 3 then '3 kamers'
        when [aantal kamers] = 4 then '4 kamers'
        when [aantal kamers] >= 5 then '5 kamers of meer'
        else 'Onbekend'
      end,
    [Gem. oppervlakte], 
    [Oppervlakte]
  into #aantal_kamers
  from #kamer_per_eenheid as kpe1
  where not exists (
      select 1 
      from #kamer_per_eenheid as kpe2
      where kpe1.fk_eenheid_id = kpe2.fk_eenheid_id
        and kpe1.[Start Date] < kpe2.[Start Date]
    ) 
    and not exists (
      select 1 
      from #kamer_per_eenheid as kpe2
      where kpe1.fk_eenheid_id = kpe2.fk_eenheid_id
        and kpe1.[Start Date] = kpe2.[Start Date]
        and kpe1.[entry no_] < kpe2.[entry no_]
    )

  select
    mg_bedrijf,
    Eenheidnr_,
    opp = [Total Surface],
    prio = ROW_NUMBER() over (partition by mg_bedrijf, eenheidnr_ order by ingangsdatum desc, volgnummer desc)
  into #opp_onz
  from empire_data..vw_lt_mg_eenheidspunt_onzelfst_woonr_


  select
    fk_eenheid_id,
    c.descr as bouwblok,
    c.bk_nr_ as bouwbloknr,
    ROW_NUMBER() over (partition by fk_eenheid_id order by c.bk_nr_) as prio
  into #bouwblok
  from empire_dwh.dbo.vw_cluster_eenheid_actueel as ce
  join empire_dwh.dbo.cluster as c on
    c.id = ce.fk_cluster_id
  where c.fk_clustersoort_id = 'BOUWBLOK'

  select
    fk_eenheid_id,

    c.descr as ft_cluster,
    c.bk_nr_ as ft_clusternr,
    ROW_NUMBER() over (partition by fk_eenheid_id order by c.bk_nr_) as prio
  into #ftcluster
  from empire_dwh.dbo.vw_cluster_eenheid_actueel as ce
  join empire_dwh.dbo.cluster as c on
    c.id = ce.fk_cluster_id
  where c.fk_clustersoort_id = 'FTCLUSTER'

  select
    fk_eenheid_id,
    c.descr as vve_cluster,
    c.bk_nr_ as vve_clusternr,
    ROW_NUMBER() over (partition by fk_eenheid_id order by c.bk_nr_) as prio
  into #vvecluster
  from empire_dwh.dbo.vw_cluster_eenheid_actueel as ce
  join empire_dwh.dbo.cluster as c on
    c.id = ce.fk_cluster_id
  where c.fk_clustersoort_id = 'VVE'

select
  [Sleutel]                         = o.lt_id,
  [Eenheidnummer]                   = o.Nr_,
  [Eenheid]                         = ltrim(rtrim(o.Nr_ + ' ' + o.Straatnaam + ' ' + o.Huisnr_ + ' ' + o.Toevoegsel)),
  [Adres]                           = ltrim(rtrim(o.Straatnaam + ' ' + o.Huisnr_ + ' ' + o.Toevoegsel)),
  [Plaats]                          = o.plaats,
  [Wijk]                            = md.Description,
  [Buurt]                           = ca.Description,
  [Gemeente]                        = gem.descr,
  [Gemeente code]                   = gem.id,
  [Straatnaam]                      = o.straatnaam,
  [Huisnummer]                      = o.huisnr_,
  [Toevoegsel]                      = o.toevoegsel,
  [Postcode]                        = o.Postcode,
  [Bouwjaar]                        = nullif(o.[Construction Year],0),
  [Renovatiejaar]                   = nullif(o.[Renovation Year],0),
  [Gerenoveerd]                     = case when o.[Renovation Year] > 0 then 'Gerenoveerd' else 'Niet gerenoveerd' end,
  [Bouw/renovatiejaar]              = nullif(case when o.[Renovation Year] > o.[Construction Year] then o.[Renovation Year] else o.[Construction year] end, 0),
  [Klasse bouw/renovatiejaar]       = 'Moet nog gevuld worden',
  [Klasse bouw/renovatiejaar sortering] = 1,
  [Klasse bouwjaar]                 = 'Moet nog gevuld worden',
  [Klasse bouwjaar sortering]       = 1,
  [Klasse renovatiejaar]            = 'Moet nog gevuld worden',
  [Klasse renovatiejaar sortering]  = 1,
  [Bouwblok]                        = bb.bouwblok,
  [Bouwbloknummer]                  = bb.bouwbloknr,
  [Bouwbloknaam]                    = ltrim(replace(bb.bouwblok,bb.bouwbloknr,'')),
  [FT-Cluster]                      = ft.ft_cluster,
  [FT-Clusternummer]                = ft.ft_clusternr,
  [FT-Clusternaam]                  = ltrim(replace(ft.ft_cluster,ft.ft_clusternr,'')),
  [VVE-Cluster]                     = vve.vve_cluster,
  [VVE-Clusternummer]               = vve.vve_clusternr,
  [VVE-Clusternaam]                 = ltrim(replace(vve.vve_cluster,vve.vve_clusternr,'')),
  [Scootmobielstalling]             = case when t.Omschrijving = 'Scootmobielstalling' then 'Scootmobielstalling' else 'Overig' end,
  [Eenheidtype Corpodata]           = t.[Analysis Group Code],
  [Eenheidtype groepering]          = case
                                        when t.[Analysis Group Code] = 'BOG' then 'BOG'
                                        when t.[Analysis Group Code] = 'PP' then 'Parkeren'
                                        when t.[Analysis Group Code] like 'WON%' then 'Woningen'
                                        else 'Overig'
                                      end,
  [Eenheidtype groepering sortering] = case
                                        when t.[Analysis Group Code] = 'BOG' then 2
                                        when t.[Analysis Group Code] = 'PP' then 3
                                        when t.[Analysis Group Code] like 'WON%' then 1
                                        else 4
                                      end,
  [Technische type omschrijving]    = t.omschrijving,                                                  
  [Vastgoedtype]                    = case when LTRIM(RTRIM(t.[Analysis Group Code])) = 'WON ZELF' and LTRIM(RTRIM(t.omschrijving)) =  'Eengezinswoning' then 'Eengezinswoning'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Appartement' and l.Lift = 0 then 'Appartement zonder lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Appartement' and l.Lift = 1 then 'Appartement met lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Appartement' and l.Lift is null then 'Appartement zonder lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Maisonnette' and l.Lift = 0 then 'Appartement zonder lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Maisonnette' and l.Lift = 1 then 'Appartement met lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Maisonnette' and l.Lift is null then 'Appartement zonder lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Zorgwoning' and l.Lift = 0 then 'Appartement zonder lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Zorgwoning' and l.Lift = 1 then 'Appartement met lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Zorgwoning' and l.Lift is null then 'Appartement zonder lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Kangaroewoning' and l.Lift = 0 then 'Appartement zonder lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Kangaroewoning' and l.Lift = 1 then 'Appartement met lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Kangaroewoning'and l.Lift is null then 'Appartement zonder lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Serviceflat' and l.Lift = 0 then 'Appartement zonder lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Serviceflat' and l.Lift = 1 then 'Appartement met lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Serviceflat' and l.Lift is null then 'Appartement zonder lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Verzorgingshuis' and l.Lift = 0 then 'Appartement zonder lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Verzorgingshuis' and l.Lift = 1 then 'Appartement met lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Verzorgingshuis' and l.Lift is null then 'Appartement zonder lift'
                                           when LTRIM(RTRIM(t.omschrijving)) =  'Onzelfstandige woonruimte' then 'Onzelfstandig'
                                           when LTRIM(RTRIM(t.omschrijving)) in ('Antenne','Berging','Telefonieruimte','Scootmobielstalling','Uitgegeven grond','Standplaats','Algemene ruimte','Logeereenheid','energiemeter','Verzamelcontracten') then 'Overig'
                                           when LTRIM(RTRIM(t.omschrijving)) in ('Bedrijfsruimte','Winkel','Pakhuis / opslagruimte','Kantoorruimte','Studio/atelier') then    'Bedrijfsruimte'
                                           when LTRIM(RTRIM(t.omschrijving)) in ('Garagebox','Parkeerplaats in garage','Parkeerplaats op terrein','Parkeerplaats overdekt','Parkeerplaats motor','parkeerplaats in gem. ruimte','Parkeerplaats (type onbekend)') then 'Parkeergelegenheid'
                                           when (LTRIM(RTRIM(t.omschrijving)) = '' or LTRIM(RTRIM(t.omschrijving)) is null) then 'Onbekend'
                                         end,
  [Lift]                            = l.lift,
  [Etage]                           = case when verd.Verdieping =  0 then '00 - Begane grond'
                                           when verd.Verdieping =  1 then '01 - 1e etage'
                                           when verd.Verdieping =  2 then '02 - 2e etage'
                                           when verd.Verdieping =  3 then '03 - 3e etage'
                                           when verd.Verdieping =  4 then '04 - 4e etage'
                                           when verd.Verdieping >= 5 then '05 - 5e etage of hoger' 
                                      end,
  [Etage detail]                    = 'Etage ' + convert(varchar,convert(int,verd.verdieping)),
  [Etage detail sortering]          = verd.verdieping,
  [Aantal kamers]                   = ctea.[aantal kamers],
  [Groepering aantal kamers]        = isnull(ctea.[Groepering aantal kamers],'Onbekend'),
  [Gem. oppervlakte]                = ctea.[Gem. oppervlakte],
  [Oppervlakte]                     = coalesce(e.bagoppervlakte,ctea.[Oppervlakte],oo.opp,#vvo.aantal),
  [Leegwaarde]                      = cm.Leegwaarde,
  [Marktwaarde]                     = cm.marktwaarde,
  [Beleidswaarde]                   = cm.beleidswaarde,
  [Peildatum waarden]               = cm.peildatum,
  [Assetmanager]                    = isnull(nullif(c.[First Name],''),C.Initials) + ' ' + isnull(nullif(c.[Middle Name],'') + ' ','') + c.Surname,
  [Verhuurteam]                     = cv.Name,
  [Bedrijf]                         = o.mg_bedrijf,
  [Juridisch eigenaar]              = case when eig.Owner = 'RLTS-0104788' then 'WOM Stationsbuurt-oude centrum'
                                           when eig.Owner = 'RLTS-0002476' then 'Staedion VG Holding BV'
                                           when eig.Owner is null          then 'Staedion' end,
  [In exploitatie]                  = case when getdate() between nullif(o.[Begin exploitatie],'17530101') and isnull(nullif(o.[Einde exploitatie],'17530101'),'99991231')  then 'Ja' else 'Nee' end,
  [Einde exploitatie]               = isnull(nullif(o.[Einde exploitatie],'17530101'),'99991231'),
  [Reden in exploitatie]            = rc.description,
  [Reden uit exploitatie]           = uitex.description,
  [Is OGEH]                         = case when o.Nr_ like 'OGEH%' then 'Ja' else 'Nee' end,
  [Huidige labelconditie]           = o.[Huidige labelconditie],
  [Status eenheid]                  = case when o.Status = 0 then 'Leegstand'
                                      when o.Status = 1 then 'Uit beheer'
                                      when o.Status = 2 then 'Renovatie'
                                      when o.Status = 3 then 'Verhuurd'
                                      when o.Status = 4 then 'Administratief'
                                      when o.Status = 5 then 'Verkocht'
                                      when o.Status = 6 then 'In ontwikkeling' end,

  [Status VvE]                      = case when o.[Status VvE] = 0 then 'n.v.t.' 
                                           when o.[Status VvE] = 1 then 'Actief'
                                           when o.[Status VvE] = 2 then 'Slapend' end,
  [Datum in exploitatie]            = isnull(o.[Begin exploitatie],'17530101'),
  [Datum in exploitatie gevuld]     = case when nullif(o.[Begin exploitatie],'17530101') is null then 'Nee' else 'Ja' end,
  [Streefhuur]                      = de.streefhuur,
  [Maximale huur]                   = de.huur_maxredelijk,
  [Markthuur]                       = cm.Markthuur,
  [Kalehuur]                        = de.kalehuur,
  [Sleutel huurklasse obv kalehuur] = bbk.id,
  [Huurklasse 2 obv kalehuur]       = bbk.omschrijving_kort,
  [Huurklasse 2 obv kalehuur sort]  = bbk.id,
  [Huurklasse obv streefhuur]       = bbs.groep1_descr,
  [Huurklasse obv streefhuur sort]  = bbs.groep1_key,
  [Huurklasse obv kalehuur]         = bbk.groep1_descr,
  [Huurklasse obv kalehuur sort]    = bbk.groep1_key,
  [Huurklasse obv subsidiabel]      = bbss.groep1_descr,
  [Huurklasse obv subsidiabel sort] = bbss.groep1_key,
  [DAEB]                            = case daeb.daeb
                                        when 'DAEB' then 'DAEB'
                                        when 'N_DAEB' then 'Niet-DAEB'
                                        else 'Onbekend'
                                      end,
  [Doelgroep]                       = tar.Description,
  [Streefhuursegmentatie]           = case 
                                        when tar.description like 'A%' then 'Kwaliteitskortingsgrens'
                                        when tar.description like 'B%' then 'Aftoppingsgrens laag'
                                        when tar.description like 'C%' then 'Aftoppingsgrens hoog'
                                        when tar.description like 'D%' then 'Tot huurprijsgrens'
                                        when tar.Description like 'E%' then 'Middenhuur'
                                        else 'Vrije sector'
                                      end,
  [Streefhuursegmentatie sortering] = case 
                                        when tar.description like 'A%' then 1
                                        when tar.description like 'B%' then 2
                                        when tar.description like 'C%' then 3
                                        when tar.description like 'D%' then 4
                                        when tar.description like 'E%' then 5
                                        else 6
                                      end,
   [Voorheen Vestia] = CONVERT(NVARCHAR(10),NULL)	,															-- JvdW 12-03-2021
   [Huidig contract met reden huurverlaging] = CONVERT(NVARCHAR(20),NULL),							-- JvdW 12-03-2021
	 [EAN Code Electriciteit] = o.[EAN Code Electricity],												-- JvdW 23-06-2021
   o.[EAN Code Gas],																												-- JvdW 23-06-2021
	 [EAN Code] = coalesce(nullif(o.[EAN Code Gas],''),nullif(o.[EAN Code Electricity],'')), -- JvdW 12-10-2021
   [Contactpersoon BOG] = convert(nvarchar(100),null),														-- JvdW 14-07-2021
   [Verhuurder]                    = isnull(vh.Name,'Staedion'),
   [Parkeren type huurder]         = CONVERT(varchar(255),null),
   [Parkeren huurder]              = CONVERT(varchar(500),null)
into Algemeen.Eenheid
from empire_data.dbo.vw_lt_mg_oge as o
left join empire_dwh.dbo.eenheid as e on e.id = o.lt_id
left join #bouwblok as bb on 
  bb.fk_eenheid_id = o.lt_id and bb.prio = 1
left join #ftcluster as ft on 
  ft.fk_eenheid_id = o.lt_id and ft.prio = 1
left join #vvecluster as vve on 
  vve.fk_eenheid_id = o.lt_id and vve.prio = 1
left join #vvo on #vvo.Eenheidnr_ = o.Nr_ 
left join empire_data.dbo.vw_lt_mg_target_group tar on
  o.mg_bedrijf = tar.mg_bedrijf and
  nullif(o.[Target Group Code], '') = tar.code
left join empire_data.dbo.vw_lt_mg_type as t on 
  t.mg_bedrijf = o.mg_bedrijf and
  t.Code = o.[Type] and
  t.Soort <> 2
left join #lift as l on 
  l.Eenheidnr_ = o.Nr_ and
  l.mg_bedrijf = o.mg_bedrijf and
  l.prio = 1
left join #marktenleegwaarde as cm on
  cm.id = o.lt_id and
  cm.Prio = 1
left join #assman as ass on
  ass.mg_bedrijf = o.mg_bedrijf and
  ass.eenheidnummer = o.Nr_ and
  ass.prio = 1
left join #opp_onz as oo on 
  oo.mg_bedrijf = o.mg_bedrijf and
  oo.Eenheidnr_ = o.Nr_ and
  oo.prio = 1
left join empire_data.dbo.Contact as c on
  c.No_ = ass.Contactnr_
left join #vhteam as vht on
  vht.mg_bedrijf = o.mg_bedrijf and
  vht.eenheidnummer = o.Nr_ and
  vht.prio = 1
left join empire_data.dbo.Contact as cv on
  cv.No_ = vht.Contactnr_
left join empire_data.dbo.mg_cbs_area as ca on
  ca.code = o.[CBS buurt] and
  ca.mg_bedrijf = o.mg_bedrijf
left join empire_data.dbo.mg_district as md on
  md.Code = o.Wijk and
  md.mg_bedrijf = o.mg_bedrijf
 left join #eigenaar as eig on
  eig.[Realty Object No_] = o.Nr_ and
  eig.mg_bedrijf = o.mg_bedrijf and
  eig.prio = 1
left join empire_data.dbo.mg_exploitation_reason_code as rc on 
  rc.code = o.[Reden in exploitatie] and
  rc.mg_bedrijf = o.mg_bedrijf
left join empire_data.dbo.mg_exploitation_end_reason_code as uitex on 
  uitex.code = o.[Reden uit exploitatie] and
  uitex.mg_bedrijf = o.mg_bedrijf
left join #aantal_kamers as ctea
  on ctea.fk_eenheid_id = o.lt_id
left join empire_dwh.dbo.eenheid as de on
  de.bk_nr_ = o.Nr_ and
  de.da_bedrijf = 'Staedion'
left join empire_dwh.dbo.bbshklasse bbs on
	getdate() between bbs.vanaf and bbs.tot and
	isnull(de.streefhuur,0) between bbs.minimum and bbs.maximum 
left join empire_dwh.dbo.bbshklasse bbk on
	getdate() between bbk.vanaf and bbk.tot and
	isnull(de.kalehuur,0) between bbk.minimum and bbk.maximum 
left join empire_dwh.dbo.bbshklasse bbss on
	getdate() between bbss.vanaf and bbss.tot and
	isnull(de.subsidiabelehuur,0) between bbss.minimum and bbss.maximum 
left join empire_dwh.dbo.gemeente as gem on gem.id = de.fk_gemeente_id
left join #daeb as daeb on 
  daeb.mg_bedrijf = o.mg_bedrijf and
  daeb.eenheidnr = o.Nr_ and
  daeb.prio = 1
left join #verdieping as verd on 
  verd.eenheidnr = o.nr_ and
  verd.prio = 1
left join #verhuurder as vh on
  vh.Eenheidnr_ = o.Nr_

  update  BASIS
  set     Assetmanager = isnull(nullif(c.[First Name],''),C.Initials) + ' ' + isnull(nullif(c.[Middle Name],'') + ' ','') + c.Surname
  from    staedion_dm.algemeen.eenheid as BASIS
  join    empire_Data.dbo.Staedion$Eenheid_Contactpersoon as EC
  on      EC.Eenheidnr_ = BASIS.Eenheidnummer
  and     EC.Functie in ('CB-ASSMAN','CB-ASSMBOG')
  join    empire_data.dbo.Contact as C
	  on      C.No_ = EC.Contactnr_
  where BASIS.Bedrijf = 'Staedion'
  ;

  -- 20210714 
  update  BASIS
  set     [Contactpersoon BOG] = isnull(nullif(c.[First Name],''),C.Initials) + ' ' + isnull(nullif(c.[Middle Name],'') + ' ','') + c.Surname
  from    staedion_dm.algemeen.eenheid as BASIS
  join    empire_Data.dbo.Staedion$Eenheid_Contactpersoon as EC
  on      EC.Eenheidnr_ = BASIS.Eenheidnummer
  and     EC.Functie in ('CB-BOG')
  join    empire_data.dbo.Contact as C
	  on      C.No_ = EC.Contactnr_
  where BASIS.Bedrijf = 'Staedion'
  ;
  

  update e
  set 
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
                                          end,
  [Klasse bouwjaar] = case
                        when [Bouwjaar] < 1945 then 'Tot 1945'
                        when [Bouwjaar] < 1960 then '1945 - 1959'
                        when [Bouwjaar] < 1970 then '1960 - 1969'
                        when [Bouwjaar] < 1980 then '1970 - 1979'
                        when [Bouwjaar] < 1990 then '1980 - 1989'
                        when [Bouwjaar] < 2000 then '1990 - 1999'
                        when [Bouwjaar] < 2010 then '2000 - 2009'
                        when [Bouwjaar] >= 2010 then '2010 en later'
                        else 'Onbekend'
                      end,
  [Klasse bouwjaar sortering] = case
                                  when [Bouwjaar] < 1945 then 1
                                  when [Bouwjaar] < 1960 then 2
                                  when [Bouwjaar] < 1970 then 3
                                  when [Bouwjaar] < 1980 then 4
                                  when [Bouwjaar] < 1990 then 5
                                  when [Bouwjaar] < 2000 then 6
                                  when [Bouwjaar] < 2010 then 7
                                  when [Bouwjaar] >= 2010 then 8
                                  else 9
                                end,
  [Klasse Renovatiejaar] = case
                        when [Renovatiejaar] < 1945 then 'Tot 1945'
                        when [Renovatiejaar] < 1960 then '1945 - 1959'
                        when [Renovatiejaar] < 1970 then '1960 - 1969'
                        when [Renovatiejaar] < 1980 then '1970 - 1979'
                        when [Renovatiejaar] < 1990 then '1980 - 1989'
                        when [Renovatiejaar] < 2000 then '1990 - 1999'
                        when [Renovatiejaar] < 2010 then '2000 - 2009'
                        when [Renovatiejaar] >= 2010 then '2010 en later'
                        else 'Onbekend'
                      end,
  [Klasse Renovatiejaar sortering] = case
                                  when [Renovatiejaar] < 1945 then 1
                                  when [Renovatiejaar] < 1960 then 2
                                  when [Renovatiejaar] < 1970 then 3
                                  when [Renovatiejaar] < 1980 then 4
                                  when [Renovatiejaar] < 1990 then 5
                                  when [Renovatiejaar] < 2000 then 6
                                  when [Renovatiejaar] < 2010 then 7
                                  when [Renovatiejaar] >= 2010 then 8
                                  else 9
                                end
  from Algemeen.Eenheid as e

-- JvdW 12-03-21 Toevoeging nav overleg met Hailey en Margot: 
UPDATE BASIS
SET [Voorheen Vestia] = CASE WHEN VES.Eenheidnr IS NULL THEN 'Nee' ELSE 'Ja' END 
FROM  staedion_dm.algemeen.eenheid AS BASIS
LEFT OUTER JOIN empire_staedion_data.Vestia.Overname2020Nov AS VES
ON BASIS.Eenheidnummer = VES.Eenheidnr
;




-- JvdW 12-03-21 Toevoeging nav overleg met Hailey en Margot: 
-- Zijn er twee redenen opgevoerd op 1 contract, zou niet moeten mogen, maar kan wel, dan krijg je er maar 1 te zien nog
WITH cte_reden_wijziging
AS (
       SELECT Eenheidnr_
              ,[Reden wijziging]
              ,[Ingevoerd door]
              ,[Verhuurcontractvolgnr_]
              ,[Vorig verhuurcontractvolgnr_]
       FROM empire_Data.dbo.[Staedion$Verhuurmutatie]
       WHERE [Reden wijziging] IN (
                     'EHVL_B'
                     ,'EHVL_I'
                     ) -- EHVL_B Eenm.huurverl. bulk Wet 2021  + EHVL_I Eenm.huurverl. indiv. Wet 2021
       )
       ,cte_contract
AS (
       SELECT Eenheidnr_
              ,Volgnr_
       FROM empire_Data.dbo.Staedion$contract AS CO
       WHERE [Dummy Contract] = 0
              AND EXISTS (
                     SELECT 1
                     FROM empire_Data.dbo.[Staedion$Additioneel] AS AD
                     WHERE AD.Eenheidnr_ = CO.Eenheidnr_
                            AND AD.[Customer No_] = CO.[Customer No_]
                            AND (
                                   AD.[Einddatum] = '17530101'
                                   OR AD.[Einddatum] > GETDATE()
                                   )
                     )
       )
UPDATE BASIS
SET [Huidig contract met reden huurverlaging] = CTE_R.[Reden wijziging]
FROM staedion_dm.algemeen.eenheid AS BASIS
JOIN cte_reden_wijziging AS CTE_R
       ON CTE_R.Eenheidnr_ = BASIS.Eenheidnummer
JOIN cte_contract AS CTE_C
       ON CTE_R.Eenheidnr_ = CTE_C.eenheidnr_;


;with cte_parkeer as (
  select 
    sleutel,
    o.nr_
  from Algemeen.eenheid as ae
  join empire_data.dbo.vw_lt_mg_oge as o on
    o.lt_id = ae.sleutel
  where [Eenheidtype groepering] = 'parkeren'
),
cte_typehuurder as (
  select 
    p.sleutel, 
	hk.geliberaliseerd, 
	c.[Customer No_] + ' ' + c.Naam as huurder,
	ROW_NUMBER() over (partition by p.sleutel order by ae2.kalehuur desc) as prio
  from cte_parkeer p join
  empire_data.dbo.vw_lt_mg_contract as c on
    c.mg_bedrijf = 'staedion' and
    c.Eenheidnr_ = p.Nr_ and
    GETDATE() between c.Ingangsdatum and isnull(nullif(c.einddatum,'17530101'),'99991231')
  join empire_data.dbo.vw_lt_mg_contract as c2 on
    c2.mg_bedrijf = c.mg_bedrijf and
    c2.[Customer No_] = c.[Customer No_] and
    c2.Eenheidnr_ <> c.Eenheidnr_ and
    c2.[Customer No_] <> '' and
    GETDATE() between c2.Ingangsdatum and isnull(nullif(c2.einddatum,'17530101'),'99991231')
  join Algemeen.Eenheid as ae2 on
    ae2.Eenheidnummer = c2.Eenheidnr_ and
    ae2.Bedrijf = c2.mg_bedrijf and
    ae2.[Eenheidtype groepering] = 'Woningen'
  join Algemeen.Huurklasse as hk on hk.id = ae2.[Sleutel huurklasse obv kalehuur]
)
update ae
set 
  ae.[Parkeren type huurder] =  case 
                                   when cth.geliberaliseerd = 'Geliberaliseerd' then 'Vrije sector'
                                   when cth.geliberaliseerd = 'Bereikbaar' then 'Sociale huurwoning'
                                   when ae.[Status eenheid] = 'Leegstand' then 'Leegstand'
                                   when cth.Sleutel is null then 'Geen huurder van woning'
                                   else 'Overig'
                                end,
  ae.[Parkeren huurder]      = cth.huurder

from Algemeen.eenheid as ae
left join cte_typehuurder as cth on
  cth.prio = 1 and
  cth.Sleutel = ae.sleutel
where ae.[Eenheidtype groepering] = 'Parkeren'

  

  





end
GO
