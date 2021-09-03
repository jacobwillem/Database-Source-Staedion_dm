SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [Eenheden].[fn_Eigenschappen] (@Eenheidnr varchar(20), @Peildatum date = null)
returns table
as
/* ########################################################################################################################## 
VAN 		JvdW
Betreft		Functie voor ophalen oge-kenmerken op basis van door Roelof gegenereerde meetwaarden tabel
--------------------------------------------------------------------------------------------------------------------------
TEST
--------------------------------------------------------------------------------------------------------------------------
-- per eenheid
select distinct [Reden in exploitatie] 
from [Eenheden].[fn_Eigenschappen] (null, getdate()) 

where [Reden in exploitatie] = 'Transformatie'

select * from [Eenheden].[fn_Eigenschappen] ( 'OGEH-0058982', getdate()) -- Niet meegenomen "In ontwikkeling"



-- wijziging
SELECT Opmerking =  'Wijziging in administratief eigenaar',Was = KENM1.[Administratieve eigenaar], Wordt = KENM2.[Administratieve eigenaar] 
FROM empire_data.dbo.Staedion$OGE as OGE
OUTER APPLY staedion_dm.Eenheden.[fnOgeKenmerkenAdmJur TEST](OGE.Nr_, '20181231') AS KENM1
OUTER APPLY staedion_dm.Eenheden.[fnOgeKenmerkenAdmJur TEST](OGE.Nr_, '20201231') AS KENM2
WHERE OGE.[Common Area] = 0
       AND (
              oge.[Einde exploitatie] >= getdate()
              OR oge.[Einde exploitatie] = datefromparts(1753, 1, 1)
              )
and KENM1.[Administratieve eigenaar] <> KENM2.[Administratieve eigenaar] 

-- check met else-lijst
select Eenheidnr, beheerder from empire_staedion_data.dbo.els where datum_gegenereerd = (Select max(datum_Gegenereerd) from empire_staedion_data.dbo.els)
and beheerder <> 'Staedion'
--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------
20210302 Aangemaakt obv code van Roelof zoals ook in ELS-lijst wordt gebruikt (maar dan zonder pivot)
20210416 Rvg Kolom Status gewijzigd in Eenheidstatus_id 
########################################################################################################################## */
RETURN
SELECT Peildatum = MW.Peildatum, 
	   EIG.Adres,
       EIG.[Bedrijf_id], 
       EIG.[Eenheidnr], 
       EIG.[Ingangsdatum], 
       EIG.[Einddatum], 
       EIG.[Straatnaam], 
       EIG.[Huisnummer], 
       EIG.[Huisnummer toevoeging], 
       EIG.[Postcode], 
       EIG.[Plaats], 
       EIG.[Gemeente], 
       EIG.[Wijk], 
       EIG.[Buurt], 
       typ.[Code] [Type], 
       EIG.[Betreft], 
       EIG.[Eenheidstatus_id], 
       EIG.[Datum in exploitatie], 
       EIG.[Reden in exploitatie], 
       EIG.[Datum uit exploitatie], 
       EIG.[Reden uit exploitatie], 
       EIG.[BAG verblijfsobject], 
       EIG.[BAG pand], 
       EIG.[BAG straatnaam], 
       EIG.[BAG huisnummer], 
       EIG.[BAG huisnummer toevoeging], 
       EIG.[BAG huisnummer letter], 
       EIG.[BAG postcode], 
       EIG.[BAG plaats], 
       EIG.[Doelgroep], 
       EIG.[Huurbeleid], 
       EIG.[Huidige labelconditie], 
       typ.[Technisch type], 
	   cty.Code [Corpodata type], 
	   cty.[Corpodatatype omschrijving],
       EIG.[OGE type], 
       EIG.[Cluster type], 
       EIG.[FT clusternr], 
       EIG.[FT clusternaam], 
       EIG.[Financieel clusternr], 
       EIG.[Financieel clusternaam], 
       EIG.[Bouwbloknr], 
       EIG.[Bouwbloknaam], 
       EIG.[Vve clusternr], 
       EIG.[VvE clusternaam], 
       EIG.[Status VVE], 
       EIG.[VvE (code) Extern], 
       EIG.[VvE Beheerder], 
       EIG.[Jaar laatste renovatie], 
       EIG.[Assetmanager], 
       EIG.[Contactpersoon VvE], 
       EIG.[Vertegenwoordiger VvE], 
       EIG.[Thuisteam], 
       EIG.[Verhuurteam], 
       EIG.[Oppervlakte BAG], 
       EIG.[Woonruimte], 
	   EIG.[Type monument],
	   EIG.[Rijksbeschermd stadsgezicht],
	   EIG.[Gemeentelijk beschermd stadsgezicht],
	   EIG.[Studentenwoning],
       MW.[Verhuurbare dagen], 
       MW.[Huurdernr], 
       MW.[Prolongatietermijn], 
       MW.[Kale huur], 
       MW.[Kale huur incl. btw], 
       MW.[Netto huur], 
       MW.[Netto huur incl. btw], 
       MW.[Btw op netto huur], 
       MW.[Huurkorting], 
       MW.[Huurkorting incl. btw], 
       MW.[Netto huur incl. korting en btw], 
       MW.[Btw compensatie], 
       MW.[Btw compensatie incl. btw], 
       MW.[Verbruikskosten], 
       MW.[Verbruikskosten incl. btw], 
       MW.[Servicekosten], 
       MW.[Service- en verbruikkosten], 
       MW.[Servicekosten incl. btw], 
       MW.[Stookkosten], 
       MW.[Water], 
       MW.[Water incl. btw], 
       MW.[Bruto huur], 
       MW.[Bruto huur incl. btw], 
       MW.[Subsidiabel deel], 
       MW.[Subsidiabele huur], 
       MW.[Markthuur], 
       WWD.Woningwaardering [Type woningwaardering], 
	   WWD.Ingangsdatum [Ingangsdatum woningwaardering], 
	   WWD.[Totaal punten], 
	   WWD.[Totaal punten afgerond], 
       MW.[Maximaal toegestane huur], 
	   WWD.[Oppervlakte totaal] [Totaal oppervlakte], 
       MW.[Percentage max. redelijke huur], 
	   WWD.[Energiewaardering], 
	   WWD.[EPA-label] [EPA label], 
	   WWD.[Energie index], 
	   WWD.[Bouwjaar], 
	   WWD.[Afmelddatum] [Datum afgemeld], 
	   WWD.[Punten energie] [Energie punten], 
	   WWD.[WOZ waarde (wwd)],
       MW.[Aftopgrens], 
       MW.[Streefhuur], 
       MW.[Administratief eigenaar], 
       MW.[Juridisch eigenaar], 
       MW.[Beheerder], 
       MW.[Mutatiehuur], 
       MW.[Subsidiabele energiekosten afgetopt], 
       MW.[Subsidiabele schoonmaakkosten afgetopt], 
       MW.[Subsidiabele huismeesterkosten afgetopt], 
       MW.[Subsidiabele kapitaal/onderhoudskosten afgetopt], 
       MW.[Subsidiabele energiekosten], 
       MW.[Subsidiabele schoonmaakkosten], 
       MW.[Subsidiabele huismeesterkosten], 
       MW.[Subsidiabele kapitaal/onderhoudskosten], 
       MW.[Aantal sterren toegankelijkheid], 
       MW.[Keuken], 
       MW.[Verdieping (WBS)], 
       MW.[Verwarming], 
       MW.[Zolder], 
       MW.[Lift], 
       MW.[Oppervlakte Woonkamer (WBS)], 
       MW.[Oppervlakte Keuken (WBS)], 
       MW.[Oppervlakte Badkamer (WBS)], 
       MW.[Oppervlakte Overig (WBS)], 
       MW.[Oppervlakte VVO], 
       MW.[Oppervlakte BVO],
	   MW.[WOZ-peildatum],
	   MW.[WOZ-objectnr],
	   MW.[WOZ-taxatiewaarde]
FROM staedion_dm.eenheden.Meetwaarden AS MW
     JOIN staedion_dm.eenheden.Eigenschappen AS EIG ON MW.Eigenschappen_id = EIG.Eigenschappen_id
	 JOIN [staedion_dm].[Eenheden].[Technisch type] typ ON EIG.[Technisch type_id] = typ.[Technisch type_id]
	 JOIN [staedion_dm].[Eenheden].[Corpodatatype] cty ON EIG.[Corpodatatype_id] = cty.Corpodatatype_id 
	 LEFT OUTER JOIN staedion_dm.eenheden.Woningwaardering WWD ON MW.Woningwaardering_id = WWD.Woningwaardering_id
WHERE (EIG.Eenheidnr = @Eenheidnr or @eenheidnr is null)
      AND EOMONTH(MW.Peildatum) = EOMONTH(@Peildatum);
GO
