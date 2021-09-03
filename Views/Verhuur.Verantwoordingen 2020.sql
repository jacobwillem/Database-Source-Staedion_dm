SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











create view [Verhuur].[Verantwoordingen 2020] as
/* ##############################################################################################################################
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
20200819 Op verzoek van Hailey / Eric: toegevoeging rekenhuur = subsiabelehuur
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

select * from empire_dwh.dbo.f_verantwoording_Verhuring where fk_eenheid_id = 1631
################################################################################################################################## */    
with CTE_eenzijdige_wijken as
(select [Soort wijk] = case when CBS.id in (
                     'BU05182569'
                     ,'BU05182567'
                     ,'BU05182561'
                     ) -- Mariahoeve en Marlot
              OR CBS.id IN (
                     'BU05182718'
                     ,'BU05182763'
                     ,'BU05182762'
                     ) -- Stationsbuurt
              OR CBS.id IN (
                     'BU05182811'
                     ,'BU05182814'
                     ) -- Centrum
              OR CBS.id IN (
                     'BU05183033'
                     ,'BU05183032'
                     ,'BU05183034'
                     ) -- Transvaalkwartier'
              OR CBS.id IN (
                     'BU05183398'
                     ,'BU05183387'
                     ,'BU05183396'
                     ) -- Bouwlust en Vrederust 
              OR CBS.id IN (
                     'BU05183489'
                     ,'BU05183488'
                     ,'BU05183480'
                     ) -- Morgenstond
              OR CBS.id IN (
                     'BU05183638'
                     ,'BU05183637'
                     ,'BU05183639'
                     ) -- Moerwijk
              OR CBS.id IN (
                     'BU05183822'
                     ,'BU05183819'
                     ,'BU05183826'
                     ) -- Laakkwartier
				then 'Eenzijdige wijk' else 'Geen eenzijdige wijk' end , [sleutel buurt] = CBS.id, [Buurt] = CBS.descr
from		empire_dwh.dbo.cbsbuurt as CBS
)
SELECT [Datum ingang contract] = CONT.dt_ingang
			 ,[Contract aanwezig] = F.contract_aanwezig		 
			 ,Huurder = CONT.fk_klant_id
			 ,Eenheid = F.bk_eenheidnr_
			 ,[Sleutel eenheid] = F.fk_eenheid_id
			 ,[Sleutel contract] = F.fk_contract_id
			 ,[Sleutel klant] = CONT.fk_klant_id
			 ,CTE_CBS.[Soort wijk]
			 ,Buurt = E.fk_cbsbuurt_id
			 ,Wijk = E.fk_wijk_id
			 ,[Huidige doelgroep code] = DG.bk_code
			 ,[Huidige doelgroep omschrijving] = DG.descr
       --,[Eenzijdige verhuring] = CASE 
       --       WHEN WHT.descr IN (
       --                     'Vrije sector'
       --                     ,'Boven inkomensgrens'
       --                     ,'Niet Passend'
       --                     )
       --              THEN 1
							--			 else 0
       --       END
       ,[Eenzijdige verhuring] = CASE 
              WHEN F.huurprijscategorie_descr IN (
                             '> aftoppingsgrens hoog'
                            ,'> aftoppingsgrens laag'
                            ) AND F.ispassend <> 'Niet passend'				-- In overleg met Pascale van Empel toegevoegd
                     THEN 1
										 else 0
              END

			 ,[Categorie passendheid - CNS] = WHT.descr
       ,WHT.descr
       ,[Corpodata type] = TT.fk_eenheid_type_corpodata_id
       ,F.Passendheidstoets
       ,F.DAEBtoets
       ,F.Aanbiedhuur
       ,Geliberaliseerd = F.geliberaliseerd
       ,[Zittende huurder] = F.zittendehuurder
       ,Rechtspersoon = F.rechtspersoon
       ,[Onderverhuur via rechtspersoon] = F.onderverhuur_via_rechtspersoon
       ,[Dossier volledig] = dossier_volledig
       ,[Huurprijscategorie] = F.huurprijscategorie_descr
			 ,[Verhuurteam] = E.staedion_verhuurteam
			 ,[Hyperlink empire] = empire_staedion_data.empire.fnEmpireLink('Staedion', 11152115,'Realty Object No.='+''''+F.bk_eenheidnr_+''''+',Entry No.=1,Version No.=1','view' )
			 -- select distinct F.contract_aanwezig
			 ,[Categorie passendheid] = F.categorie_passendheid
			 ,[Categorie DAEB-toets] = F.categorie_daebtoets
			 ,[Is passend verhuurd] = F.Ispassend
			 ,[Inkomenscategorie passendheid] = F.inkomenscategorie_passendheid
       ,Inkomen = f.inkomen
       ,[Huurtoeslag gerechtigd] = case when f.contractanten = 1 and f.inkomen < 30846 then 'Ja'
                                        when f.contractanten > 1 and f.inkomen < 61692 then 'Ja'
                                        else 'nee' end
			 ,Rekenhuur = HPR.subsidiabelehuur
FROM empire_dwh.dbo.f_verantwoording_verhuring AS F
JOIN empire_dwh.dbo.wht_passendheid AS WHT
       ON F.fk_wht_passendheid_id = WHT.id
JOIN empire_dwh.dbo.eenheid AS E
       ON E.id = F.fk_eenheid_id
JOIN empire_dwh.dbo.technischtype AS TT
       ON TT.id = E.fk_technischtype_id
JOIN empire_dwh.dbo.[contract] AS CONT
       ON CONT.id = F.fk_contract_id
join empire_dwh.dbo.doelgroep as DG
on DG.id = E.fk_doelgroep_id
left outer join CTE_eenzijdige_wijken as CTE_CBS
on CTE_CBS.[sleutel buurt] = E.fk_cbsbuurt_id
outer apply empire_Staedion_Data.dbo.ITVfnHuurprijs (E.bk_nr_, CONT.dt_ingang) as HPR
where			year(F.dt_start_contract) >= 2015
--and				month(F.dt_start_contract) < 5
and				TT.fk_eenheid_type_corpodata_id in ('WON ZELF','WON ONZ')
and				E.staedion_verhuurteam <> 'Verhuurteam 3 - studenten'
--and				E.bk_nr_ = 'OGEH-0001505'
and				F.contract_aanwezig <> 'Contract vervallen'
and				F.contract_aanwezig <> 'Contract onbekend'








GO
