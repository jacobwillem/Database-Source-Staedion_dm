SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Verhuur].[Verantwoordingen_rst]
as

with cte_contract as (
  select 
    id, 
    fk_eenheid_id, 
    dt_ingang, 
    dt_einde = isnull(dt_einde, '99991231'), 
    fk_klant_id,
    bk_eenheidnr
  from backup_empire_dwh.dbo.[contract]
  where dt_ingang is not null
  and fk_soortcontract_id <> 2 --geen erfpacht
),
cte_rj as (
  select
    cc.id as fk_contract_id,
    rj.[Realty Object No_],
    rj.[Entry No_],
    rj.[Version No_],
    prio = ROW_NUMBER() over (partition by cc.id order by [Entry No_] desc, [Version No_] desc)
  from empire_data.dbo.Staedion$rental_justification as rj
  join cte_contract as cc on 
    cc.bk_eenheidnr = rj.[Realty Object No_] and
    abs(datediff(dd, rj.[start date rental contract], cc.dt_ingang)) <= 31 and
    rj.[start date rental contract] <= cc.dt_einde
),
cte_eenzijdige_wijken as (
  select
    code,
    soort_wijk = 
      case
        when 'BU' + cn.code IN('BU05182569', 'BU05182567', 'BU05182561') -- Mariahoeve en Marlot
          OR 'BU' + cn.code IN('BU05182718', 'BU05182763', 'BU05182762') -- Stationsbuurt
          OR 'BU' + cn.code IN('BU05182811', 'BU05182814') -- Centrum
          OR 'BU' + cn.code IN('BU05183033', 'BU05183032', 'BU05183034') -- Transvaalkwartier'
          OR 'BU' + cn.code IN('BU05183398', 'BU05183387', 'BU05183396') -- Bouwlust en Vrederust 
          OR 'BU' + cn.code IN('BU05183489', 'BU05183488', 'BU05183480') -- Morgenstond
          OR 'BU' + cn.code IN('BU05183638', 'BU05183637', 'BU05183639') -- Moerwijk
          OR 'BU' + cn.code IN('BU05183822', 'BU05183819', 'BU05183826') -- Laakkwartier
          then 'Eenzijdige wijk'
        else 'Geen eenzijdige wijk'
      end
    from empire_data.dbo.[CBS_Neighborhood] as cn
),
cte_wht as (
    select id =-1, niveau = 'Onbekend',      descr = 'Onbekend' union 
    select id = 0, niveau = 'Telt mee',      descr = 'Niet Passend' union 
    select id = 1, niveau = 'Telt mee',      descr = 'Passend' union 
    select id = 2, niveau = 'Telt mee',      descr = 'Intermediair' union               -- instanties / rechtspersonen
    select id = 3, niveau = 'Telt niet mee', descr = 'Vrije sector' union               -- vrije sector
    select id = 4, niveau = 'Telt niet mee', descr = 'Geen Huurwoning' union 
    select id = 5, niveau = 'Telt niet mee', descr = 'Boven inkomensgrens' union 
    select id = 6, niveau = 'Telt niet mee', descr = 'Verhuur aan rechtspersoon' union 
    select id = 7, niveau = 'Telt niet mee', descr = 'Huur lager dan basishuur' union     
    select id = 8, niveau = 'Telt niet mee', descr = 'Onzelfstandige woning'
),
cte_verhuurteam as (
  select
    o.nr_,
    C.name as verhuurteam,
    prio = ROW_NUMBER() over (partition by o.nr_ order by c.name)
  from empire_data.dbo.Staedion$OGE as o
  join empire_data.dbo.Staedion$Eenheid_contactpersoon as EC on EC.Eenheidnr_ = o.nr_
  join empire_data.dbo.Staedion$Job_Responsibility as JR on EC.Functie = JR.Code
  join empire_data.dbo.Contact as C on EC.Contactnr_ = C.No_
  where JR.Code = 'CB-VHTEAM'
 )
select 
  [Datum ingang contract]                 = coalesce(cont.dt_ingang, rj.[Start Date Rental Contract]), 
  [Contract aanwezig]                     = 'Contract aanwezig', 
  [fk_contract_id]                        = cont.id, 
  [Huurder]                               = cont.fk_klant_id, 
  [Eenheid]                               = rj.[Realty Object No_], 
  [Sleutel eenheid]                       = cont.fk_eenheid_id, 
  [Sleutel contract]                      = cont.id, 
  [Sleutel klant]                         = cont.fk_klant_id, 
  [Soort wijk]                            = cte_cbs.[soort_wijk], 
  [Buurt]                                 = nullif(o.[CBS buurt], ''), 
  [Wijk]                                  = nullif(o.Wijk, ''), 
  [Huidige doelgroep code]                = tar.code, 
  [Huidige doelgroep omschrijving]        = tar.Description,
  [Eenzijdige verhuring]                  = case
                                              when wht.descr in('Vrije sector', 'Boven inkomensgrens') THEN 1
                                              else 0
                                            end,
  [Categorie passendheid - CNS]           = WHT.descr, 
  [Toelichting]                           = WHT.descr, 
  [Corpodata type]                        = nullif(ty.[analysis group code], ''), 
  [Passendheidstoets]                     = case 
                                              when rj.[non-house] = 1                             then 'Nee' 
                                              when rj.[rental price exceeds lib_limit] = 1        then 'Nee'
                                              when rj.[non-house] = 0                             then 'Ja' 
                                              else 'Onbekend' 
                                            end, 
  [DAEBtoets]                             = case
                                              when rj.[daeb not applicable] = 1                   then 'Nee'
                                              when rj.[daeb not applicable] = 0                   then 'Ja'
                                              else 'Onbekend'
                                            end, 
  [Aanbiedhuur]                           = rj.[net rental price],
  [Geliberaliseerd]                       = case 
                                              when rj.[rental price exceeds lib_limit] = 1        then 'Geliberaliseerd'
                                              when rj.[rental price exceeds lib_limit] = 0        then 'Niet geliberaliseerd'
                                              else 'Onbekend / nvt'
                                            end, 
  [Zittende huurder]                      = case 
                                              when rj.[current tenant] = 1                        then 'Zittende huurder'
                                              when rj.[current tenant] = 0                        then 'Geen zittende huurder'
                                              else 'Onbekend / nvt'
                                            end,
  Rechtspersoon                           = case 
                                              when rj.[legal entity tenant] = 1                   then 'Rechtspersoon'
                                              when rj.[legal entity tenant] = 0                   then 'Geen rechtspersoon'
                                              else 'Onbekend / nvt'
                                            end,
  [Onderverhuur via rechtspersoon]        = case 
                                              when rj.[sublet through legal entity] = 1           then 'Onderverhuur via rechtspersoon'
                                              when rj.[sublet through legal entity] = 0           then 'Geen onderverhuur via rechtspersoon'
                                              else 'Onbekend / nvt'
                                            end,
  [Dossier volledig]                      = case
                                              when rj.[incomplete dossier] = 1                    then 'Dossier incompleet' 
                                              else 'Dossier compleet'
                                            end,
  [Huurprijscategorie]                    = case rj.[rental price category]
                                              when 1 then '<= kwaliteitsgrens'
                                              when 2 then '<= aftoppingsgrens'
                                              when 3 then '<= aftoppingsgrens hoog'
                                              when 4 then '> aftoppingsgrens laag'
                                              when 5 then '> aftoppingsgrens hoog'
                                              else 'Onbekend, nvt'
                                            end, 
  [Verhuurteam]                           = cvht.verhuurteam, 
  [Hyperlink empire]                      = empire_staedion_data.empire.fnEmpireLink('Staedion', 11152115, 'Realty Object No.=' + '''' + cont.bk_eenheidnr + '''' + ',Entry No.=1,Version No.=1', 'view'),
  [Categorie passendheid]                 = case rj.[Appropriateness Category]
                                              when 1  then 'Aanbieding zittende huurder; niet getoetst'
                                              when 2  then 'Verhuring aan rechtspersoon; niet getoetst'
                                              when 3  then 'Verhuring van niet-woning; niet getoetst'
                                              when 4  then 'Verhuring aan doelgroep; 1- of 2-pers hh; passend'
                                              when 5  then 'Verhuring aan doelgroep; 1- of 2-pers hh; niet-passend'
                                              when 6  then 'Verhuring aan doelgroep; meerpers hh; passend'
                                              when 7  then 'Verhuring aan doelgroep; meerpers hh; niet-passend'
                                              when 8  then 'Boven liberalisatiegrens; niet getoetst'
                                              when 9  then '1-pers hh; passend'
                                              when 10 then '1-pers hh; niet passend'
                                              when 11 then '1-pers hh, inkomen te hoog; niet getoetst'
                                              when 12 then '2-pers hh; passend'
                                              when 13 then '2-pers hh; niet passend'
                                              when 14 then '2-pers hh, inkomen te hoog; niet getoetst'
                                              when 15 then 'meerpers hh; passend'
                                              when 16 then 'meerpers hh; niet passend'
                                              when 17 then 'meerpers hh, inkomen te hoog; niet getoetst'
                                              when 18 then '1-pers hh, ouderen; passend'
                                              when 19 then '1-pers hh, ouderen; niet passend'
                                              when 20 then '1-pers hh, ouderen, inkomen te hoog; niet getoetst'
                                              when 21 then '2-pers hh, ouderen; passend'
                                              when 22 then '2-pers hh, ouderen; niet passend'
                                              when 23 then '2-pers hh, ouderen, inkomen te hoog; niet getoetst'
                                              when 24 then 'meerpers hh, ouderen; passend'
                                              when 25 then 'meerpers hh, ouderen; niet passend'
                                              when 26 then 'meerpers hh, ouderen, inkomen te hoog; niet getoetst'
                                              else isnull(nullif(convert(varchar(11), rj.[Appropriateness Category]),''),'Onbekend, nvt')
                                            end, 
  [Categorie DAEB-toets]                  = case rj.[daeb test category]
                                              when 1 then 'Aanbieding zittende huurder; niet getoetst;'
                                              when 2 then 'Verhuring van niet-woning of niet-DAEB woning; niet getoetst;'
                                              when 3 then 'DAEB verhuurd aan doelgroep;'
                                              when 4 then 'DAEB verhuurd tot inkomensgrens laag;'
                                              when 5 then 'DAEB verhuurd tussen inkomensgrens laag en hoog;'
                                              when 6 then 'Niet-DAEB verhuurd'
                                              else isnull(nullif(convert(varchar(11), rj.[daeb test category]),''),'Onbekend, nvt')
                                            end,
  [Is passend verhuurd]                   = case 
                                              when rj.[non-house] = 1                             then 'Niet van toepassing'
                                              when rj.[rental price exceeds lib_limit] = 1        then 'Niet van toepassing'
                                              when rj.[non-appropriate rented] = 0                then 'Passend'
                                              when rj.[non-appropriate rented] = 1                then 'Niet passend'
                                              else 'Onbekend / nvt'
                                            end, 
  [Inkomenscategorie passendheid]         = case 
                                              when rj.[income category appropriatenes] = 1        then '1-pers.hh. <= max.inkomen; niet AOW-gerechtigd'
                                              when rj.[income category appropriatenes] = 2        then '1-pers.hh. > max.inkomen; niet AOW-gerechtigd'
                                              when rj.[income category appropriatenes] = 3        then '1-pers.hh. <= max.inkomen; AOW-gerechtigd'
                                              when rj.[income category appropriatenes] = 4        then '1-pers.hh. > max.inkomen; AOW-gerechtigd'
                                              when rj.[income category appropriatenes] = 5        then '2-pers.hh. <= max.inkomen; niet AOW-gerechtigd'
                                              when rj.[income category appropriatenes] = 6        then '2-pers.hh. > max.inkomen; niet AOW-gerechtigd'
                                              when rj.[income category appropriatenes] = 7        then '2-pers.hh. <= max.inkomen; AOW-gerechtigd'
                                              when rj.[income category appropriatenes] = 8        then '2-pers.hh. > max.inkomen; AOW-gerechtigd'
                                              when rj.[income category appropriatenes] = 9        then 'meerpers. hh. <= max inkomen; niet AOW-gerechtigd'
                                              when rj.[income category appropriatenes] = 10       then 'meerpers. hh. > max inkomen; niet AOW-gerechtigd'
                                              when rj.[income category appropriatenes] = 11       then 'meerpers. hh. <= max inkomen; AOW-gerechtigd'
                                              when rj.[income category appropriatenes] = 12       then 'meerpers. hh. > max inkomen; AOW-gerechtigd'
                                              else 'Inkomen onbekend'
                                            end,
  Inkomen                                 = rj.[household income],
	[Soort inkomen]                         = case
								                              when I.Inkomensgrens = 'Laag' AND rj.[household income] > 10 then CONCAT('1. Laag inkomen < ', FORMAT(I.InkomenMax, 'C0', 'nl-NL'))
								                              when I.Inkomensgrens = 'Midden' then CONCAT('2. Midden inkomen ', FORMAT(I.InkomenMin, 'C0', 'nl-NL') , ' - ', FORMAT(I.InkomenMax, 'C0', 'nl-NL'))
								                              when I.Inkomensgrens = 'Hoog' then CONCAT('3. Hoog inkomen > ', FORMAT(I.InkomenMin, 'C0', 'nl-NL'))
								                              when I.Inkomensgrens IS NULL AND rj.[household income] > 10 then '5. Inkomensgrens onbekend'
								                              else '4. Inkomen onbekend (leeg of < €10)'
							                              end,
	Inkomensgrens                           = case
								                              when i.inkomensgrens = 'Laag' then 0
								                              when i.inkomensgrens = 'Midden' then 1
								                              when i.inkomensgrens = 'Hoog' then 2
								                              when i.inkomensgrens is null then 3
							                              end,
	[Aandeel]                               = I.Aandeel,
  [Huurtoeslag gerechtigd]                = case
                                              when rj.[no_ of names on contract] = 1 and rj.[household income] < 30846 then 'Ja'
                                              when rj.[no_ of names on contract] > 1 and rj.[household income] < 61692 then 'Ja'
                                              else 'Nee'
                                            end, 
  [Rekenhuur]                             = HPR.subsidiabelehuur, 
  [Ingangsdatum contract verantwoording]  = [Start Date Rental Contract], 
  [Ingangsdatum huurcontract]             = CONT.dt_ingang, 
  [Controle-opmerking]                    = CASE
                                              WHEN UPPER(cust.name) LIKE '%VPS%'OR UPPER(cust.name) LIKE '%LIVABLE%' THEN 'Niet meegenomen: VPS/Livable'
                                              ELSE
                                                CASE
                                                  WHEN 'Contract aanwezig' IN('Contract vervallen', 'Contract onbekend') THEN 'Niet meegenomen: geen verhuurcontract'
                                                  ELSE
                                                    CASE
                                                      WHEN cvht.verhuurteam = 'Verhuurteam 3 - studenten' THEN 'Niet meegenomen: verhuurteam studenten'
                                                      ELSE
                                                        CASE 
																                          WHEN co.Eenheidnr_ is not null AND CONT.dt_ingang = '20210101' THEN 'Niet meegenomen: contracten overgenomen' 
																		                      ELSE
                                                            CASE
                                                              WHEN rj.[incomplete dossier] = 1 THEN 'Niet meegenomen: '+ COALESCE(ijrc.[Description],'incompleet dossier')
																				                      ELSE 'OK' 
																		                        END
																                        END
                                                    END  
                                                END
                                            END,
  [Naam huurder]                          = cust.name
from backup_empire_dwh.dbo.[contract] as cont
left join cte_rj on 
  cte_rj.fk_contract_id = cont.id and
  cte_rj.prio = 1
left join empire_data.dbo.Staedion$rental_justification as rj on 
  rj.[Realty Object No_] = cte_rj.[Realty Object No_] and
  rj.[Entry No_] = cte_rj.[Entry No_] and
  rj.[Version No_] = cte_rj.[Version No_]
join empire_data.dbo.staedion$oge as o on o.Nr_ = rj.[Realty Object No_]
left join empire_data.dbo.Staedion$Rental_Proposal as rp on 
  rp.Eenheidnr_ = rj.[Realty Object No_] and
  rp.Volgnummer = rj.[Entry No_]
left join empire_data.dbo.Staedion$Cluster_OGE as co on co.Clusternr_ = 'FT-1681' and co.Eenheidnr_ = o.Nr_
left join cte_verhuurteam as cvht on
  cvht.Nr_ = o.Nr_ and
  cvht.prio = 1 -- voor de zekerheid
left join empire_data.dbo.incomplete_justif_reason_code as ijrc on
  ijrc.[Code] = rj.[Incomplete Dossier Reason]
join cte_wht as wht on 
    case 
      when nullif(rj.[daeb indicator],0) in (1,2)                                                           then 4          -- geen huurwoning
      when o.Woonruimte = 1 and rj.[Justify as House] = 2 and year(rj.[start date rental contract]) >= 2018 then 8          -- onzelfstandige woongelegenheden die niet als woning verantwoord worden
      when rj.[Rental Price Category] = 1 and year(rj.[start date rental contract]) >= 2018                 then 7          -- wel een woongelegenheid maar de huur ligt onder de basishuurgrens
      when rj.[Rental Price Exceeds Lib_Limit] = 1                                                          then 3          -- wel een huurwoning maar geen sociale huur (dus vrije sector)
      when rj.[legal entity tenant] = 1                                                                     then 6          -- bewust VOOR de controle op instantie wegens verschil tussen 'verhuur aan' en 'onderverhuur door' 
      when rj.[sublet through legal entity] = 1                                                             then 2          -- wel sociale huur maar verhuurd aan een intermediar / instantie
      when nullif(rj.[daeb indicator],0) in (3,4)                                                           then case when rj.[Non-Appropriate Rented] = 1 then 0 else 1 end  -- wel sociale huur maar niet aan een intermediar (dus natuurlijk persoon)
      else -1                                                                                               -- onbekend, nvt
    end = wht.id
left join empire_data.dbo.staedion$type as ty on ty.Code = o.Type
left join empire_data.dbo.Staedion$Target_Group as tar on nullif(o.[Target Group Code], '') = tar.code
--join backup_empire_dwh.dbo.eenheid as e on e.bk_nr_ = o.Nr_
left join empire_data.dbo.Customer as cust on cust.No_ = rp.[Customer No_]
--left join backup_empire_dwh.dbo.klant as k on k.id = cont.fk_klant_id
left join cte_eenzijdige_wijken as cte_cbs on cte_cbs.code = nullif(o.[CBS Neighborhood Code], '')
left join empire_staedion_data.dbo.inkomensgrens i on year(rj.[Start Date Rental Contract]) = i.jaar and rj.[household income] between i.inkomenmin and i.inkomenmax 
outer apply empire_staedion_data.dbo.itvfnhuurprijs(o.nr_, cont.dt_ingang) as hpr
where(year(cont.dt_ingang) >= 2015 or year(rj.[start date rental contract]) >= 2015)
GO
