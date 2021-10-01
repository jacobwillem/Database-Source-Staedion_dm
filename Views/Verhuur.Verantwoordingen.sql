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
WITH CTE_eenzijdige_wijken
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
         FROM backup_empire_dwh.dbo.cbsbuurt AS CBS),
     --,
     --cte_contractwijzigingen as 
     --(SELECT [Customer No_]
     --       ,[Eenheidnr_]
     --       ,Ingangsdatum
     --FROM empire_Data.dbo.[staedion$Additioneel]
     -- )

	 CTE_huishouden
	 AS (
	 SELECT  F.[fk_contract_id]
			,[Huishouden] = CASE
								WHEN F.inkomenscategorie_passendheid LIKE '1-pers%; niet AOW%' THEN 'EPHH'
								WHEN F.inkomenscategorie_passendheid LIKE '2-pers%; niet AOW%' THEN 'MPHH2'
								WHEN F.inkomenscategorie_passendheid LIKE 'meerpers%; niet AOW%' THEN 'MPHH3'
								WHEN F.inkomenscategorie_passendheid LIKE '1-pers%; AOW%' THEN 'EPOHH'
								WHEN F.inkomenscategorie_passendheid LIKE '2-pers%; AOW%' THEN 'MPOHH2'
								WHEN F.inkomenscategorie_passendheid LIKE 'meerpers%; AOW%' THEN 'MPOHH3'
								ELSE NULL
							END
	 
	 FROM backup_empire_dwh.dbo.f_verantwoording_verhuring F
	 LEFT OUTER JOIN empire_staedion_data.dbo.Passendtoewijzen_Uitzondering U ON YEAR(F.dt_start_contract) = U.Jaar AND U.Eenheidnummer = F.bk_eenheidnr_
	 WHERE [fk_contract_id] NOT IN ('', '-1')
	 AND contract_aanwezig <> 'Contract vervallen'
	 AND U.Eenheidnummer IS NULL
	 )

     SELECT [Datum ingang contract] = COALESCE(CONT.dt_ingang, F.dt_start_contract), 
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
            [Eenzijdige verhuring] = CASE
                                         WHEN WHT.descr IN('Vrije sector', 'Boven inkomensgrens')
                                         THEN 1
                                         ELSE 0
                                     END, 
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
			[Soort inkomen] = CASE
								WHEN I.Inkomensgrens = 'Laag' AND f.inkomen > 10 THEN CONCAT('1. Laag inkomen < ', FORMAT(I.InkomenMax, 'C0', 'nl-NL'))
								WHEN I.Inkomensgrens = 'Midden' THEN CONCAT('2. Midden inkomen ', FORMAT(I.InkomenMin, 'C0', 'nl-NL') , ' - ', FORMAT(I.InkomenMax, 'C0', 'nl-NL'))
								WHEN I.Inkomensgrens = 'Hoog' THEN CONCAT('3. Hoog inkomen > ', FORMAT(I.InkomenMin, 'C0', 'nl-NL'))
								WHEN I.Inkomensgrens IS NULL AND f.inkomen > 10 THEN '5. Inkomensgrens onbekend'
								ELSE '4. Inkomen onbekend (leeg of < €10)'
							  END,
			Inkomensgrens = CASE
								WHEN I.Inkomensgrens = 'Laag' THEN 0
								WHEN I.Inkomensgrens = 'Midden' THEN 1
								WHEN I.Inkomensgrens = 'Hoog' THEN 2
								WHEN I.Inkomensgrens IS NULL THEN 3
							END,
			I.Aandeel,
            [Huurtoeslag gerechtigd] = CASE
                                           WHEN f.contractanten = 1
                                                AND f.inkomen < 30846
                                           THEN 'Ja'
                                           WHEN f.contractanten > 1
                                                AND f.inkomen < 61692
                                           THEN 'Ja'
                                           ELSE 'nee'
                                       END,

            Rekenhuur = HPR.subsidiabelehuur, 
            [Ingangsdatum contract verantwoording] = F.dt_start_contract, 
            [Ingangsdatum huurcontract] = CONT.dt_ingang, 
            [Controle-opmerking] = CASE
                                       WHEN UPPER(K.descr) LIKE '%VPS%'
                                            OR UPPER(K.descr) LIKE '%LIVABLE%'
                                       THEN 'Niet meegenomen: VPS/Livable'
                                       ELSE CASE
                                                WHEN F.contract_aanwezig IN('Contract vervallen', 'Contract onbekend')
                                                THEN 'Niet meegenomen: geen verhuurcontract'
                                                ELSE CASE
                                                         WHEN E.staedion_verhuurteam = 'Verhuurteam 3 - studenten'
                                                         THEN 'Niet meegenomen: verhuurteam studenten'
                                                         ELSE CASE 
																WHEN E.staedion_fk_ftcluster_id = 13920 AND CONT.dt_ingang = '20210101'
																		THEN 'Niet meegenomen: contracten overgenomen' 
																		ELSE CASE WHEN F.dossier_volledig = 'Dossier incompleet' 
																				THEN 'Niet meegenomen: '+ COALESCE(F.dossier_reden_niet_volledig,'incompleet dossier')
																				ELSE 'OK' 
																		END		
																END
                                                     END
                                            END
                                   END
			,[Naam huurder] = K.descr
			,[Huishouden] = H.Huishouden
			,[Max inkomen] = P.InkomenMax
			,[Regeling van toepassing] = IIF(F.inkomen < P.InkomenMax 
											AND F.geliberaliseerd = 'Niet geliberaliseerd'
											AND F.inkomen > 10, 1, 0)
			,P.[Aftoppingsgrens]
			,[Passend toegewezen] = IIF(F.inkomen < P.InkomenMax 
										AND F.geliberaliseerd = 'Niet geliberaliseerd'
										AND F.inkomen > 10
										AND HPR.subsidiabelehuur < P.[Aftoppingsgrens], 1 , 0)
			-- select F.*
     FROM backup_empire_dwh.dbo.[contract] AS CONT
          LEFT OUTER JOIN backup_empire_dwh.dbo.f_verantwoording_verhuring AS F ON CONT.id = F.fk_contract_id
          JOIN backup_empire_dwh.dbo.wht_passendheid AS WHT ON F.fk_wht_passendheid_id = WHT.id
          JOIN backup_empire_dwh.dbo.eenheid AS E ON E.id = F.fk_eenheid_id
          JOIN backup_empire_dwh.dbo.technischtype AS TT ON TT.id = E.fk_technischtype_id
          JOIN backup_empire_dwh.dbo.doelgroep AS DG ON DG.id = E.fk_doelgroep_id
          LEFT OUTER JOIN backup_empire_dwh.dbo.klant AS K ON K.id = CONT.fk_klant_id
          LEFT OUTER JOIN CTE_eenzijdige_wijken AS CTE_CBS ON CTE_CBS.[sleutel buurt] = E.fk_cbsbuurt_id
		  LEFT OUTER JOIN empire_staedion_data.dbo.Europaregeling_Inkomensgrens I ON YEAR(F.dt_start_contract) = I.Jaar AND F.inkomen BETWEEN I.InkomenMin AND I.InkomenMax
		  LEFT OUTER JOIN CTE_huishouden H ON CONT.id = H.fk_contract_id
		  LEFT OUTER JOIN empire_staedion_data.dbo.Passendtoewijzen_Inkomensgrens P ON YEAR(F.dt_start_contract) = P.Jaar AND H.Huishouden = P.Huishouden
          --left outer join cte_contractwijzigingen as CTE_CTR
          --on CTR.[Eenheidnr_] = E.bk_nr_
          --and CTR.Ingangsdatum =  CONT.dt_ingang
          OUTER APPLY empire_Staedion_Data.dbo.ITVfnHuurprijs(E.bk_nr_, CONT.dt_ingang) AS HPR
     WHERE(YEAR(CONT.dt_ingang) >= 2015
           OR YEAR(F.dt_start_contract) >= 2015)
          -- year(F.dt_start_contract) >= 2015
          --and				month(F.dt_start_contract) < 5
          --AND TT.fk_eenheid_type_corpodata_id IN('WON ZELF', 'WON ONZ')
--and				E.staedion_verhuurteam <> 'Verhuurteam 3 - studenten'
--and				E.bk_nr_ = 'OGEH-0001540'
--and				F.contract_aanwezig <> 'Contract vervallen'
--and				F.contract_aanwezig <> 'Contract onbekend'


GO
