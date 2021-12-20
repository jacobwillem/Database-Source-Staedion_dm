SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE view [Verhuur].[Verantwoordingen] as
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
20210408 MV [Soort inkomen], Inkomensgrens + Aandeel toegevoegd
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
with CTE_eenzijdige_wijken
     as (select [Soort wijk] = case
                                   when CBS.id in('BU05182569', 'BU05182567', 'BU05182561') -- Mariahoeve en Marlot
                                        or CBS.id in('BU05182718', 'BU05182763', 'BU05182762') -- Stationsbuurt
                                        or CBS.id in('BU05182811', 'BU05182814') -- Centrum
                                        or CBS.id in('BU05183033', 'BU05183032', 'BU05183034') -- Transvaalkwartier'
                                        or CBS.id in('BU05183398', 'BU05183387', 'BU05183396') -- Bouwlust en Vrederust 
                                        or CBS.id in('BU05183489', 'BU05183488', 'BU05183480') -- Morgenstond
                                        or CBS.id in('BU05183638', 'BU05183637', 'BU05183639') -- Moerwijk
                                        or CBS.id in('BU05183822', 'BU05183819', 'BU05183826') -- Laakkwartier
                                   then 'Eenzijdige wijk'
                                   else 'Geen eenzijdige wijk'
                               end, 
                [sleutel buurt] = CBS.id, 
                [Buurt] = CBS.descr
         from backup_empire_dwh.dbo.cbsbuurt as CBS),
     --,
     --cte_contractwijzigingen as 
     --(SELECT [Customer No_]
     --       ,[Eenheidnr_]
     --       ,Ingangsdatum
     --FROM empire_Data.dbo.[staedion$Additioneel]
     -- )

	 -- BEGIN 2021-10-01 MV: Eigen toetsing middels flexibele configuratie tabellen
	 CTE_korting_leegstandsbeheer
	 as (select [fk_contract_id] = CONT.id, CONT.dt_ingang
		   from backup_empire_dwh.dbo.[contract] as CONT
		   join empire_data.dbo.Staedion$Element E on CONT.volgnummer = E.Volgnummer
		    and CONT.bk_eenheidnr = E.Eenheidnr_
		    and E.Nr_ = '064'
	 ),

	 CTE_uitzondering
	 as (
	 select  F.[fk_contract_id]
			,[Huishouden] = case
								when F.inkomenscategorie_passendheid like '1-pers%; niet AOW%' then 'EPHH'
								when F.inkomenscategorie_passendheid like '2-pers%; niet AOW%' then 'MPHH2'
								when F.inkomenscategorie_passendheid like 'meerpers%; niet AOW%' then 'MPHH3'
								when F.inkomenscategorie_passendheid like '1-pers%; AOW%' then 'EPOHH'
								when F.inkomenscategorie_passendheid like '2-pers%; AOW%' then 'MPOHH2'
								when F.inkomenscategorie_passendheid like 'meerpers%; AOW%' then 'MPOHH3'
								else null
							end
			,[Korting leegstandsbeheer] = iif(K.fk_contract_id is not null, 1, 0)
			,[dt_ingang_jaar] = year(CONT.dt_ingang)
	 from backup_empire_dwh.dbo.[contract] as CONT
          left outer join backup_empire_dwh.dbo.f_verantwoording_verhuring as F on CONT.id = F.fk_contract_id
		  left outer join empire_staedion_data.dbo.Passendtoewijzen_Uitzondering U on year(F.dt_start_contract) = U.Jaar and U.Eenheidnummer = F.bk_eenheidnr_
		  left outer join CTE_korting_leegstandsbeheer K on CONT.id = K.fk_contract_id and CONT.dt_ingang = K.dt_ingang
	 where F.[fk_contract_id] not in ('', '-1')
	 and F.contract_aanwezig <> 'Contract vervallen'
	 and U.Eenheidnummer is null
	 )
	 -- EIND 2021-10-01 MV: Eigen toetsing middels flexibele configuratie tabellen

	 --select * from CTE_uitzondering where [Korting leegstandsbeheer] = 1 and huishouden is not null

     select [Datum ingang contract] = coalesce(CONT.dt_ingang, F.dt_start_contract), 
            [Contract aanwezig] = F.contract_aanwezig, 
            F.fk_contract_id, 
            Huurder = CONT.fk_klant_id, 
            Eenheid = F.bk_eenheidnr_, 
            [Sleutel eenheid] = F.fk_eenheid_id, 
            [Sleutel contract] = F.fk_contract_id, 
            [Sleutel klant] = CONT.fk_klant_id, 
            CTE_CBS.[Soort wijk], 
            Buurt = E.fk_cbsbuurt_id, 
            Wijk = E.fk_wijk_id, 
            [Huidige doelgroep code] = DG.bk_code, 
            [Huidige doelgroep omschrijving] = DG.descr
            ,
            --,[Eenzijdige verhuring] = CASE 
            --       WHEN WHT.descr IN (
            --                     'Vrije sector'
            --                     ,'Boven inkomensgrens'
            --                     ,'Niet Passend'
            --                     )
            --              THEN 1
            --			 else 0
            --       END 
            --[Eenzijdige verhuring OUD] = CASE
            --                             WHEN F.huurprijscategorie_descr IN('> aftoppingsgrens hoog', '> aftoppingsgrens laag')
            --                                  AND F.ispassend <> 'Niet passend'					-- In overleg met Pascale van Empel toegevoegd
            --                             THEN 1
            --                             ELSE 0
            --                         END, 
            [Eenzijdige verhuring] = case
                                         when WHT.descr in('Vrije sector', 'Boven inkomensgrens')
                                         then 1
                                         else 0
                                     end, 
            [Categorie passendheid - CNS] = WHT.descr, 
            [Toelichting] = WHT.descr, 
            [Corpodata type] = TT.fk_eenheid_type_corpodata_id, 
            F.Passendheidstoets, 
            F.DAEBtoets, 
            F.Aanbiedhuur, 
            Geliberaliseerd = F.geliberaliseerd, 
            [Zittende huurder] = F.zittendehuurder, 
            Rechtspersoon = F.rechtspersoon, 
            [Onderverhuur via rechtspersoon] = F.onderverhuur_via_rechtspersoon, 
            [Dossier volledig] = dossier_volledig, 
            [Huurprijscategorie] = F.huurprijscategorie_descr, 
            [Verhuurteam] = E.staedion_verhuurteam, 
            [Hyperlink empire] = empire_staedion_data.empire.fnEmpireLink('Staedion', 11152115, 'Realty Object No.=' + '''' + F.bk_eenheidnr_ + '''' + ',Entry No.=1,Version No.=1', 'view')
     ,
     -- select distinct F.contract_aanwezig 
            [Categorie passendheid] = F.categorie_passendheid, 
            [Categorie DAEB-toets] = F.categorie_daebtoets, 
            [Is passend verhuurd] = F.Ispassend, 
            [Inkomenscategorie passendheid] = F.inkomenscategorie_passendheid, 
            Inkomen = f.inkomen,
			[Soort inkomen] = case
								when I.Inkomensgrens = 'Laag' and f.inkomen > 10 then concat('1. Laag inkomen < ', format(I.InkomenMax, 'C0', 'nl-NL'))
								when I.Inkomensgrens = 'Midden' then concat('2. Midden inkomen ', format(I.InkomenMin, 'C0', 'nl-NL') , ' - ', format(I.InkomenMax, 'C0', 'nl-NL'))
								when I.Inkomensgrens = 'Hoog' then concat('3. Hoog inkomen > ', format(I.InkomenMin, 'C0', 'nl-NL'))
								when I.Inkomensgrens is null and f.inkomen > 10 then '5. Inkomensgrens onbekend'
								else '4. Inkomen onbekend (leeg of < €10)'
							  end,
			Inkomensgrens = case
								when I.Inkomensgrens = 'Laag' then 0
								when I.Inkomensgrens = 'Midden' then 1
								when I.Inkomensgrens = 'Hoog' then 2
								when I.Inkomensgrens is null then 3
							end,
			[Europaregeling norm] = I.Aandeel,
            [Huurtoeslag gerechtigd] = case
                                           when f.contractanten = 1
                                                and f.inkomen < 30846
                                           then 'Ja'
                                           when f.contractanten > 1
                                                and f.inkomen < 61692
                                           then 'Ja'
                                           else 'nee'
                                       end,

            Rekenhuur = HPR.subsidiabelehuur, 
            [Ingangsdatum contract verantwoording] = F.dt_start_contract, 
            [Ingangsdatum huurcontract] = CONT.dt_ingang, 
            [Controle-opmerking] = case
                                       when upper(K.descr) like '%VPS%'
                                            or upper(K.descr) like '%LIVABLE%'
                                       then 'Niet meegenomen: VPS/Livable'
                                       else case
                                                when F.contract_aanwezig in('Contract vervallen', 'Contract onbekend')
                                                then 'Niet meegenomen: geen verhuurcontract'
                                                else case
                                                         when E.staedion_verhuurteam = 'Verhuurteam 3 - studenten'
                                                         then 'Niet meegenomen: verhuurteam studenten'
                                                         else case 
																when E.staedion_fk_ftcluster_id = 13920 and CONT.dt_ingang = '20210101'
																		then 'Niet meegenomen: contracten overgenomen' 
																		else case when F.dossier_volledig = 'Dossier incompleet' 
																				then 'Niet meegenomen: '+ coalesce(F.dossier_reden_niet_volledig,'incompleet dossier')
																				else 'OK' 
																		end		
																end
                                                     end
                                            end
                                   end
			,[Naam huurder] = K.descr
			
			-- BEGIN 2021-10-01 MV: Eigen toetsing middels flexibele configuratie tabellen
			,[Huishouden]			= U.Huishouden
			,[Max inkomen]			= P.InkomenMax
			,[Passendheidsregeling] = iif(F.inkomen < P.InkomenMax 
											and F.geliberaliseerd = 'Niet geliberaliseerd'
											-- and F.inkomen > 10
											and U.[Korting leegstandsbeheer] = 0
											and TT.fk_eenheid_type_corpodata_id in ('WON ZELF', 'WON ONZ'), 1, 0)
			,P.[Aftoppingsgrens]
			,[Passend toegewezen]	= iif(F.inkomen < P.InkomenMax 
											and F.geliberaliseerd = 'Niet geliberaliseerd'
											-- and F.inkomen > 10
											and U.[Korting leegstandsbeheer] = 0
											and TT.fk_eenheid_type_corpodata_id in ('WON ZELF', 'WON ONZ')
											and HPR.subsidiabelehuur <= P.[Aftoppingsgrens], 1 , 0)
			,U.[Korting leegstandsbeheer]
			,[Passend toewijzen norm] = P.Aandeel
			-- EIND 2021-10-01 MV: Eigen toetsing middels flexibele configuratie tabellen

			-- select F.*
     from backup_empire_dwh.dbo.[contract] as CONT
          left outer join backup_empire_dwh.dbo.f_verantwoording_verhuring as F on CONT.id = F.fk_contract_id
          join backup_empire_dwh.dbo.wht_passendheid as WHT on F.fk_wht_passendheid_id = WHT.id
          join backup_empire_dwh.dbo.eenheid as E on E.id = F.fk_eenheid_id
          join backup_empire_dwh.dbo.technischtype as TT on TT.id = E.fk_technischtype_id
          join backup_empire_dwh.dbo.doelgroep as DG on DG.id = E.fk_doelgroep_id
          left outer join backup_empire_dwh.dbo.klant as K on K.id = CONT.fk_klant_id
          left outer join CTE_eenzijdige_wijken as CTE_CBS on CTE_CBS.[sleutel buurt] = E.fk_cbsbuurt_id
		  left outer join empire_staedion_data.dbo.Europaregeling_Inkomensgrens I on year(F.dt_start_contract) = I.Jaar and F.inkomen between I.InkomenMin and I.InkomenMax
		  left outer join CTE_uitzondering U on CONT.id = U.fk_contract_id and year(CONT.dt_ingang) = U.dt_ingang_jaar
		  left outer join empire_staedion_data.dbo.Passendtoewijzen_Inkomensgrens P on year(F.dt_start_contract) = P.Jaar and U.Huishouden = P.Huishouden
          --left outer join cte_contractwijzigingen as CTE_CTR
          --on CTR.[Eenheidnr_] = E.bk_nr_
          --and CTR.Ingangsdatum =  CONT.dt_ingang
          outer apply empire_Staedion_Data.dbo.ITVfnHuurprijs(E.bk_nr_, CONT.dt_ingang) as HPR
     where(year(CONT.dt_ingang) >= 2015
           or year(F.dt_start_contract) >= 2015)

          -- year(F.dt_start_contract) >= 2015
          --and				month(F.dt_start_contract) < 5
          --AND TT.fk_eenheid_type_corpodata_id IN('WON ZELF', 'WON ONZ')
--and				E.staedion_verhuurteam <> 'Verhuurteam 3 - studenten'
--and				E.bk_nr_ = 'OGEH-0001540'
--and				F.contract_aanwezig <> 'Contract vervallen'
--and				F.contract_aanwezig <> 'Contract onbekend'


GO
