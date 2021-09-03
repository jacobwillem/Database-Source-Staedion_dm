SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




create view [Verhuur].[Verantwoordingen_rst_20210708] as
/* ##############################################################################################################################
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
20200819 Op verzoek van Hailey / Eric: toegevoeging rekenhuur = subsiabelehuur
20210206 View aangepast, paar kolommen hernoemd - ook willen aangeven welke verhuringen niet meetellen zodat je kan zien wat er uitgefilterd wordt
20210326 Zie Trelloboard "De toewijzing van een mutatie aan de ‘primaire doelgroep’ en ‘niet-primaire doelgroep inregelen op basis van toelichting die wij (jij, Anneke, Margot en ik) op 13-jan-2021 hebben opgesteld (zie bij bijlage)"
> bepalend is nu of verhuring plaatsvindt aan niet-primaire doelgroep, zijnde verhuringen vrije sector of hoog inkomen
> controle-opmerking uitgebreid
20210408 MV [Soort inkomen] + Aandeel toegevoegd
--------------------------------------------------------------------------------------------------------------------------
TEST
--------------------------------------------------------------------------------------------------------------------------
select Jaar = year([Datum ingang contract]), Maand = month([Datum ingang contract]), [Soort wijk], Aantal = sum([Eenzijdige verhuring]),Noemer = count(*),  [Percentage] = avg([Eenzijdige verhuring]*1.00)
from [Verhuur].[Verantwoordingen] 
group by year([Datum ingang contract]), month([Datum ingang contract]), [Soort wijk]


select *
from [Verhuur].[Verantwoordingen] 
select * from empire_dwh.dbo.eenheid where bk_nr_ = 'OGEH-0054868'

AANVULLENDE INFO
--------------------------------------------------------------------------------------------------------------------------
-- oude berekening 
select	distinct e.id, e.bk_nr_,e.fk_wijk_id,e.fk_cbsbuurt_id, t.fk_eenheid_type_corpodata_id, staedion_verhuurd_doelgroep_teller_1a, staedion_verhuurd_doelgroep_teller_1b, staedion_verhuurd_doelgroep_teller_1c, staedion_verhuurd_doelgroep_teller_1d, staedion_verhuurd_doelgroep_noemer_1	 , staedion_opmerking
-- select *
from		empire_dwh.dbo.f_verhuringen  as f
join		empire_Dwh.dbo.eenheid as e 
on			f.fk_eenheid_id = e.id
join		empire_dwh.dbo.technischtype as t
on			t.id = e.fk_technischtype_id
where		f.datum between '20200101' and '20200430'
and e.dt_in_exploitatie <= getdate()
and e.dt_uit_exploitatie is null
and t.fk_eenheid_type_corpodata_id like '%WON%'
and				E.staedion_verhuurteam <> 'Verhuurteam 3 - studenten'
and e.fk_wijk_id in ('WK051830','WK051836','WK051827','WK051825','WK051834','WK051828','WK051833','WK051838')
and coalesce(staedion_verhuurd_doelgroep_teller_1a,0) + coalesce(staedion_verhuurd_doelgroep_teller_1b,0)+coalesce(staedion_verhuurd_doelgroep_teller_1c,0)+coalesce(staedion_verhuurd_doelgroep_teller_1d,0)>0
order by 1
;
-- nieuwe berekening
select	Eenheid, [Datum ingang contract],*
from	 staedion_dm.[Verhuur].[Verantwoordingen] 
where	1=1
and		[Eenzijdige verhuring] = 1
and		[Soort wijk] = 'Eenzijdige wijk'
and		[Datum ingang contract] between '20200101'  and '20200430'
order by 1
;

-------------------------------------------------------------------------------------------------------------------------------------
AANVULLENDE INFO
-------------------------------------------------------------------------------------------------------------------------------------
From: Jaco van der Wel <JVDW@staedion.nl> 
Sent: dinsdag 10 maart 2020 08:23
To: Ruben Stolk <ruben.stolk@cns.nl>
Subject: vraagje

Hi Ruben,

Wil jij mij nog aangeven waar dit veld precies naar verwijst ? 

SELECT DISTINCT fk_wht_passendheid_id FROM empire_dwh.dbo.f_verantwoording_verhuring

  update f 
  set fk_wht_passendheid_id =
    case 
      when f.fk_daebindicator_id in (1,2)                                                   then 4          -- geen huurwoning
      when e.fk_woonruimte_id = 1 and f.verantwoord_als_huis = 2 and year(f.datum) >= 2018  then 8          -- onzelfstandige woongelegenheden die niet als woning verantwoord worden
      when c.kale_huur_bij_ingang < dgp.basishuurgrens and year(f.datum) >= 2018            then 7          -- wel een woongelegenheid maar de huur ligt onder de basishuurgrens
      when b.business_key > 6                                                               then 3          -- wel een huurwoning maar geen sociale huur (dus vrije sector)
      when f.rechtspersoon = 'Rechtspersoon'                                                then 6          -- bewust VOOR de controle op instantie wegens verschil tussen 'verhuur aan' en 'onderverhuur door' 
      when f.onderverhuur_via_rechtspersoon = 'Onderverhuur via rechtspersoon'              then 2          -- wel sociale huur maar verhuurd aan een intermediar / instantie
      when f.fk_daebindicator_id in (3,4)                                                   then p.passend  -- wel sociale huur maar niet aan een intermediar (dus natuurlijk persoon)
      else -1                                                                                               -- onbekend, nvt
    end
  from empire_dwh.dbo.f_verantwoording_verhuring as f
    join empire_dwh..bbshklasse as b on f.fk_bbshklasse_id = b.id
    left join empire_data..target_group_appropriateness tga on tga.Description = f.doelgroep_passendheid
    left join empire_dwh.dbo.wht_doelgroep_pt as dgp on dgp.id = f.fk_wht_doelgroep_pt_id
    left join empire_dwh.dbo.[contract] as c on c.id = f.fk_contract_id
    left join scd_eenheid as e on 
      e.id       = c.fk_eenheid_id and 
      f.datum   >= e.scd_start_date and 
      (f.datum  <= e.scd_end_date or e.scd_end_date is null)
    left join empire_dwh.dbo.klant as k on k.id = c.fk_klant_id
    outer apply dbo.df_passend_toegewezen_of_niet2 (
      b.business_key,
      dgp.business_key,
      f.huishoudgrootte,
      case when isnull(f.doelgroep_staatssteunregeling, 'Onbekend, nvt') <> 'Onbekend, nvt' and tga.Appropriate = 1 then 1 else 0 end             -- geen inkomenstoets nodig
    ) as p;








################################################################################################################################## */    
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
CTE_eenzijdige_wijken
     AS (SELECT [Soort wijk] = CASE
                                   WHEN CBS.id IN('BU05182569', 'BU05182567', 'BU05182561') -- Mariahoeve en Marlot
                                        OR CBS.id IN('BU05182718', 'BU05182763', 'BU05182762') -- Stationsbuurt
                                        OR CBS.id IN('BU05182811', 'BU05182814') -- Centrum
                                        OR CBS.id IN('BU05183033', 'BU05183032', 'BU05183034') -- Transvaalkwartier'
                                        OR CBS.id IN('BU05183398', 'BU05183387', 'BU05183396') -- Bouwlust en Vrederust 
                                        OR CBS.id IN('BU05183489', 'BU05183488', 'BU05183480') -- Morgenstond
                                        OR CBS.id IN('BU05183638', 'BU05183637', 'BU05183639') -- Moerwijk
                                        OR CBS.id IN('BU05183822', 'BU05183819', 'BU05183826') -- Laakkwartier
                                   THEN 'Eenzijdige wijk'
                                   ELSE 'Geen eenzijdige wijk'
                               END, 
                [sleutel buurt] = CBS.id, 
                [Buurt] = CBS.descr
         FROM backup_empire_dwh.dbo.cbsbuurt AS CBS)
     --,
     --cte_contractwijzigingen as 
     --(SELECT [Customer No_]
     --       ,[Eenheidnr_]
     --       ,Ingangsdatum
     --FROM empire_Data.dbo.[staedion$Additioneel]
     -- )

select 
  [Datum ingang contract]                 = coalesce(cont.dt_ingang, rj.[Start Date Rental Contract]), 
  [Contract aanwezig]                     = f.contract_aanwezig, 
  [fk_contract_id]                        = cont.id, 
  [Huurder]                               = cont.fk_klant_id, 
  [Eenheid]                               = rj.[Realty Object No_], 
  [Sleutel eenheid]                       = cont.fk_eenheid_id, 
  [Sleutel contract]                      = cont.id, 
  [Sleutel klant]                         = cont.fk_klant_id, 
  [Soort wijk]                            = CTE_CBS.[Soort wijk], 
  [Buurt]                                 = E.fk_cbsbuurt_id, 
  [Wijk]                                  = E.fk_wijk_id, 
  [Huidige doelgroep code]                = DG.bk_code, 
  [Huidige doelgroep omschrijving]        = DG.descr,
  [Eenzijdige verhuring]                  = case
                                              when wht.descr in('Vrije sector', 'Boven inkomensgrens') THEN 1
                                              else 0
                                            end,
  [Categorie passendheid - CNS]           = WHT.descr, 
  [Toelichting]                           = WHT.descr, 
  [Corpodata type]                        = TT.fk_eenheid_type_corpodata_id, 
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
  [Verhuurteam]                           = E.staedion_verhuurteam, 
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
                                              WHEN UPPER(K.descr) LIKE '%VPS%'OR UPPER(K.descr) LIKE '%LIVABLE%' THEN 'Niet meegenomen: VPS/Livable'
                                              ELSE
                                                CASE
                                                  WHEN F.contract_aanwezig IN('Contract vervallen', 'Contract onbekend') THEN 'Niet meegenomen: geen verhuurcontract'
                                                  ELSE
                                                    CASE
                                                      WHEN E.staedion_verhuurteam = 'Verhuurteam 3 - studenten' THEN 'Niet meegenomen: verhuurteam studenten'
                                                      ELSE
                                                        CASE 
																                          WHEN E.staedion_fk_ftcluster_id = 13920 AND CONT.dt_ingang = '20210101' THEN 'Niet meegenomen: contracten overgenomen' 
																		                      ELSE
                                                            CASE
                                                              WHEN rj.[incomplete dossier] = 1 THEN 'Niet meegenomen: '+ COALESCE(ijrc.[Description],'incompleet dossier')
																				                      ELSE 'OK' 
																		                        END
																                        END
                                                    END  
                                                END
                                            END,
  [Naam huurder]                          = K.descr
from backup_empire_dwh.dbo.[contract] as cont
left join cte_rj on 
  cte_rj.fk_contract_id = cont.id and
  cte_rj.prio = 1
left join empire_data.dbo.Staedion$rental_justification as rj on 
  rj.[Realty Object No_] = cte_rj.[Realty Object No_] and
  rj.[Entry No_] = cte_rj.[Entry No_] and
  rj.[Version No_] = cte_rj.[Version No_]
left join empire_data.dbo.incomplete_justif_reason_code as ijrc on
  ijrc.[Code] = rj.[Incomplete Dossier Reason]
left join backup_empire_dwh.dbo.f_verantwoording_verhuring as f on cont.id = f.fk_contract_id
join backup_empire_dwh.dbo.wht_passendheid as wht on f.fk_wht_passendheid_id = wht.id
join backup_empire_dwh.dbo.eenheid as e on e.id = f.fk_eenheid_id
join backup_empire_dwh.dbo.technischtype as tt on tt.id = e.fk_technischtype_id
join backup_empire_dwh.dbo.doelgroep as dg on dg.id = e.fk_doelgroep_id
left join backup_empire_dwh.dbo.klant as k on k.id = cont.fk_klant_id
left join cte_eenzijdige_wijken as cte_cbs on cte_cbs.[sleutel buurt] = e.fk_cbsbuurt_id
left join empire_staedion_data.dbo.inkomensgrens i on year(f.dt_start_contract) = i.jaar and f.inkomen between i.inkomenmin and i.inkomenmax 
outer apply empire_staedion_data.dbo.itvfnhuurprijs(e.bk_nr_, cont.dt_ingang) as hpr
where(year(cont.dt_ingang) >= 2015 or year(f.dt_start_contract) >= 2015)

GO
