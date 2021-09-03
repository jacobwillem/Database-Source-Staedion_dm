SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  function [Datakwaliteit].[tfn_els_completeness] (@Laaddatum as date = null, @Attribuut as nvarchar(50) = 'Bouwjaar', @FilterCorpoData as nvarchar(50) = null) 
returns table 
as
/* ###################################################################################################
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
JvdW 20200513 Aangemaakt tbv pilot datakwaliteit
JvdW 20200520 Aanpassing mbt @Laaddatum
NB: datum_uit_exploitatie = varchar en datum_in_exploitatie datetime 
JvdW 20201218 Toegevoegd: or @FilterCorpoData = ''

select * from empire_staedion_data.dbo.els where 
select distinct strWaarde from [staedion_dm].[Datakwaliteit].[tfn_els_completeness] ('20200517', 'corpodata_type','WON ONZ,WON ZELF');
select distinct datum_Gegenereerd from empire_staedion_data.dbo.els where year(datum_Gegenereerd) = 2020

------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
select * from [Datakwaliteit].[tfn_els_completeness] (default, default,default);
------------------------------------------------------------------------------------------------------
TEMP
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
-- Variant ter voorkoming foutmelding 2: The metadata could not be determined because statement 'exec (@sql)' in procedure 'dsp_info_object_en_velden'  contains dynamic SQL.  Consider using the WITH RESULT SETS clause to explicitly describe the result set.
SELECT * FROM OPENROWSET('SQLNCLI', 
'Server=s-dwh2012-db;Trusted_Connection=yes;', 
'EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] ''empire_staedion_data'', ''dbo'', ''ELS''
WITH RESULT SETS  
(   ([NaamTabel] nvarchar(50) ,						-- meerdere resultset op te geven door () te gebruiken
    [Kenmerk] nvarchar(50) ,  
		[OmschrijvingObject] sql_variant ,  
    [Soort_object] nvarchar(50) ,      
		[NaamVeld] nvarchar(50) ,  
		[OmschrijvingVeld] sql_variant ,  
    [DataTypeVeld] nvarchar(50) ,  
		[MaximaleLengteVeld] int,
		[collation_name] nvarchar(50),  
		[Volgorde] smallint)
)
')
WHERE [DataTypeVeld] LIKE '%decimal'
and  [DataTypeVeld] not LIKE '%varchar'
and  [DataTypeVeld] not LIKE '%decimal'
and [NaamVeld] not in ('id','ident') -- niet interessant


################################################################################################### */	
RETURN
WITH CTE_peildata -- voor tonen periode in dataset
AS (
			 select Laaddatum = max(datum_gegenereerd)
			 from		empire_staedion_data.dbo.els
			 where datum_gegenereerd <= coalesce(@Laaddatum,'20990101')
			 and datum_gegenereerd <= SYSDATETIME()
				)
		 , CTE_corpodata as (select ListItem from  empire_staedion_logic.dbo.dlf_ListInTable(',',@FilterCorpoData))
SELECT Eenheidnr = BRON.eenheidnr, 
			 Attribuut = @Attribuut,
				-- alle dec-velden
			 decWaarde =  
				case @Attribuut 
					when 'kalehuur'	then nullif(BRON.kalehuur,0)
					when 'brutohuur'	then nullif(BRON.brutohuur,0)
					when 'btw_compensatie_incl_btw'	then nullif(BRON.btw_compensatie_incl_btw,0)
					when 'energieindex'	then nullif(BRON.energieindex,0)
					when 'huurkorting_incl_btw'	then nullif(BRON.huurkorting_incl_btw,0)
					when 'water_incl_btw'	then nullif(BRON.water_incl_btw,0)
					when 'kalehuur'	then nullif(BRON.kalehuur,0)
					when 'Leegwaarde 31-12-2018'	then nullif(BRON.[Leegwaarde 31-12-2018],0)
					when 'Leegwaarde 31-12-2019'	then nullif(BRON.[Leegwaarde 31-12-2019],0)
					when 'Markthuur'	then nullif(BRON.Markthuur,0)
					when 'Markthuur 31-12-2018'	then nullif(BRON.[Markthuur 31-12-2018],0)
					when 'Markthuur 31-12-2019'	then nullif(BRON.[Markthuur 31-12-2019],0)
					when 'maximale_huur'	then nullif(BRON.maximale_huur,0)
					when 'nettohuur'	then nullif(BRON.nettohuur,0)
					when 'NettoMarktwaardeVerhuurdeStaat 31-12-2018'	then nullif(BRON.[NettoMarktwaardeVerhuurdeStaat 31-12-2018],0)
					when 'NettoMarktwaardeVerhuurdeStaat 31-12-2019'	then nullif(BRON.[NettoMarktwaardeVerhuurdeStaat 31-12-2019],0)
					when 'opp_vertr_ov_ruimte'	then nullif(BRON.opp_vertr_ov_ruimte,0)
					when 'oppervlakte'	then nullif(BRON.oppervlakte,0)
					when 'oppervlakte Badkamer'	then nullif(BRON.[oppervlakte Badkamer],0)
					when 'oppervlakte Keuken'	then nullif(BRON.[oppervlakte Keuken],0)
					when 'oppervlakte Overig'	then nullif(BRON.[oppervlakte Overig],0)
					when 'oppervlakte_BVO'	then nullif(BRON.[oppervlakte_BVO],0)
					when 'oppervlakte_vertrekken'	then nullif(BRON.[oppervlakte_vertrekken],0)
					when 'oppervlakte_VVO'	then nullif(BRON.[oppervlakte_VVO],0)
					when 'oppSlaapkamer1'	then nullif(BRON.oppSlaapkamer1,0)
					when 'oppSlaapkamer2'	then nullif(BRON.oppSlaapkamer2,0)
					when 'oppSlaapkamer3'	then nullif(BRON.oppSlaapkamer3,0)
					when 'oppSlaapkamer4'	then nullif(BRON.oppSlaapkamer4,0)
					when 'oppSlaapkamer5'	then nullif(BRON.oppSlaapkamer5,0)
					when 'oppSlaapkamer6'	then nullif(BRON.oppSlaapkamer6,0)
					when 'oppWoonkamer'	then nullif(BRON.oppWoonkamer,0)
					when 'pnt_bijzondere_voorziening'	then nullif(BRON.pnt_bijzondere_voorziening,0)
					when 'pnt_epa'	then nullif(BRON.pnt_epa,0)
					when 'pnt_gemeenschap_ruimtes'	then nullif(BRON.pnt_gemeenschap_ruimtes,0)
					when 'pnt_gemeenschap_vertr'	then nullif(BRON.pnt_gemeenschap_vertr,0)
					when 'pnt_keuken'	then nullif(BRON.pnt_keuken,0)
					when 'pnt_oppervlakte_overig'	then nullif(BRON.pnt_oppervlakte_overig,0)
					when 'pnt_oppervlakte_vertrekken'	then nullif(BRON.pnt_oppervlakte_vertrekken,0)
					when 'pnt_prive_buitenruimten'	then nullif(BRON.pnt_prive_buitenruimten,0)
					when 'pnt_sanitair'	then nullif(BRON.pnt_sanitair,0)
					when 'pnt_verwarming'	then nullif(BRON.pnt_verwarming,0)
					when 'punten_woz'	then nullif(BRON.punten_woz,0)
					when 'servicekosten'	then nullif(BRON.servicekosten,0)
					when 'streefhuur'	then nullif(BRON.streefhuur,0)
					when 'subsidiabelehuur'	then nullif(BRON.subsidiabelehuur,0)
					when 'totale_servicekosten'	then nullif(BRON.totale_servicekosten,0)
					when 'verbruikskosten_incl_btw'	then nullif(BRON.verbruikskosten_incl_btw,0)
					when 'water_incl_btw'	then nullif(BRON.water_incl_btw,0)
				end,
				-- alle dat-velden
			 datWaarde =  
				case @Attribuut 
					when 'datum_in_exploitatie'	then BRON.datum_in_exploitatie
					when 'datum_uit_exploitatie'	then BRON.datum_uit_exploitatie
					when 'datum_ingang_contract'	then BRON.datum_ingang_contract
					when 'datum_ingang_leegstand'	then BRON.datum_ingang_leegstand
					when 'WOZ_peil'	then BRON.WOZ_peil
				end,
				-- alle int-velden
			 intWaarde =  
				case @Attribuut 
					when 'Bouwjaar'	then BRON.Bouwjaar
					when 'aantal_kamers'	then BRON.aantal_kamers
					when 'aantal_slaapkamers'	then BRON.aantal_slaapkamers
					when 'BAG_huisnr'	then BRON.BAG_huisnr
					when 'huisnummer'	then BRON.huisnummer
					when 'monument'	then BRON.monument
					when 'pnt_monument'	then BRON.pnt_monument
					when 'pnt_totaal_na_afronding'	then BRON.pnt_totaal_na_afronding
					when 'WOZ_waarde'	then BRON.WOZ_waarde
				end,
					-- alle varchar-velden
			 strWaarde =  
				case @Attribuut 
					when 'Clusternummer'	then BRON.clusternummer
					when 'administratieve eigenaar'	then BRON.[administratieve eigenaar]
					when 'assetmanager'	then BRON.assetmanager
					when 'BAG_huis_letter'	then BRON.BAG_huis_letter
					when 'BAG_huisnr_toev'	then BRON.BAG_huisnr_toev
					when 'BAG_nr'	then BRON.BAG_nr
					when 'BAG_plaats'	then BRON.BAG_plaats
					when 'BAG_postcode'	then BRON.BAG_postcode
					when 'BAG_straatnaam'	then BRON.BAG_straatnaam
					when 'beheerder'	then BRON.beheerder
					when 'beschermd stadsgezicht'	then BRON.[beschermd stadsgezicht]
					when 'betreft'	then BRON.betreft
					when 'bouwbloknaam'	then BRON.bouwbloknaam
					when 'bouwbloknummer'	then BRON.bouwbloknummer
					when 'buurt'	then BRON.buurt
					when 'clustenr_oud'	then BRON.clustenr_oud
					when 'clusternaam'	then BRON.clusternaam
					when 'clusternaam_oud'	then BRON.clusternaam_oud
					when 'complex-type'	then BRON.[complex-type]
					when 'contactpersoon_CB_VHTEAM'	then BRON.contactpersoon_CB_VHTEAM
					when 'corpodata_type'	then BRON.corpodata_type
					when 'da_bedrijf'	then BRON.da_bedrijf
					when 'da_plaats'	then BRON.da_plaats
					when 'da_staedion_groep_technischtype'	then BRON.da_staedion_groep_technischtype
					when 'doelgroep'	then BRON.doelgroep
					when 'eenheidnr'	then BRON.eenheidnr
					when 'Eigen_parkeervoorziening_aanwezig'	then BRON.Eigen_parkeervoorziening_aanwezig
					when 'energiewaardering'	then BRON.energiewaardering
					when 'epa-label'	then BRON.[epa-label]
					when 'geliberaliseerd'	then BRON.geliberaliseerd
					when 'gemeente'	then BRON.gemeente
					when 'huidige labelconditie'	then BRON.[huidige labelconditie]
					when 'Juridisch eigenaar'	then BRON.[Juridisch eigenaar]
					when 'Keuken'	then BRON.Keuken
					when 'Leegstand'	then BRON.Leegstand
					when 'lift'	then BRON.lift
					when 'Met berging'	then BRON.[Met berging]
					when 'Met fietsenstalling'	then BRON.[Met fietsenstalling]
					when 'oge_type'	then BRON.oge_type
					when 'omschrijving_technischtype'	then BRON.omschrijving_technischtype
					when 'opmerking'	then BRON.opmerking
					when 'oppervlakte_BAG'	then BRON.oppervlakte_BAG
					when 'postcode'	then BRON.postcode
					when 'Reden in exploitatie'	then BRON.[Reden in exploitatie]
					when 'Reden uit exploitatie'	then BRON.[Reden uit exploitatie]
					when 'renovatiejaar'	then BRON.renovatiejaar
					when 'seniorenlabel'	then BRON.seniorenlabel
					when 'Status VVE'	then BRON.[Status VVE]
					when 'status_eenheidskaart'	then BRON.status_eenheidskaart
					when 'straat'	then BRON.straat
					when 'Studentenwoning'	then BRON.Studentenwoning
					when 'Thuisteam'	then BRON.Thuisteam
					when 'toevoegsel'	then BRON.toevoegsel
					when 'type monument'	then BRON.[type monument]
					when 'uitgebreide_opmerking'	then BRON.uitgebreide_opmerking
					when 'verdieping_WBS'	then BRON.verdieping_WBS
					when 'Verwarming'	then BRON.Verwarming
					when 'VvE vertegenwoordiger'	then BRON.[VvE vertegenwoordiger]
					when 'vve_contactpersoon'	then BRON.[vve_contactpersoon]
					when 'VVE-cluster'	then BRON.[VVE-cluster]
					when 'VVE-clusternaam'	then BRON.[VVE-clusternaam]
					when 'wijk'	then BRON.wijk
					when 'woonruimte'	then BRON.woonruimte
					when 'Zolder'	then BRON.Zolder
				end
-- select distinct Corpodata_type
FROM empire_staedion_data.dbo.els AS BRON
JOIN CTE_peildata AS P
       ON 1 = 1
              AND BRON.datum_gegenereerd = P.Laaddatum
WHERE BRON.datum_in_exploitatie <= P.Laaddatum
       AND (
              BRON.datum_uit_exploitatie >= P.Laaddatum
              OR nullif(BRON.datum_uit_exploitatie, '') IS NULL
              )
       AND (
              BRON.Corpodata_type IN (select ListItem from CTE_corpodata)
              OR @FilterCorpoData IS NULL or @FilterCorpoData = ''
              )

GO
