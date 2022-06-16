SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [Eenheden].[fn_ContactbeheerInclNaam] (@Eenheidnr varchar(20))
returns table
as
/******************************************************************************
VAN 		RvG
Betreft		Ophalen verschillende contactpersonen bij eenheden. Van de contactpersoon wordt 
			het relatienummer opgehaald, een join met empire_data.dbo.Contact levert de naam 
			van de betreffende contactpersoon
---------------------------------------------------------------------------------------------------	
08-05-5050 RvG aangemaakt
19-11-2020 JvdW Toegevoegd: 
						CB-INSDOBK	Opz.inspectie DO - BKT
						CB-INSDOBO	Opz.inspectie DO - BOG
						CB-INSDORE	Opz.inspectie DO - Regulier
						CB-INSDOSP	Opz.inspectie DO - Specials
04-12-2020 RvG Toegevoegd:
						CB-VVEVER	Vertegenvoordiger VvE
01-02-2021 JvdW Kopie van empire_staedion_data: relevante functies en views en procedures in 1 database met schema's onderbrengen

---------------------------------------------------------------------------------------------------
TEST
---------------------------------------------------------------------------------------------------		
-- Bestaande functie met RLTS-nrs
select Eenheidnr_  
			 ,[Opz.inspectie DO - BKT] = [dbo].[fnContactbeheerNaam]([Opz.inspectie DO - BKT])
			 ,[Opz.inspectie DO - BOG] = [dbo].[fnContactbeheerNaam]([Opz.inspectie DO - BOG])
			 ,[Opz.inspectie DO - Regulier] = [dbo].[fnContactbeheerNaam]([Opz.inspectie DO - Regulier])
			 ,[Opz.inspectie DO - Specials] = [dbo].[fnContactbeheerNaam]([Opz.inspectie DO - Specials])
from		empire_Staedion_data.dbo.[ITVFnContactbeheer] ('OGEH-0004580' )

-- Nieuwe functie waarin RLTS al is omgezet naar naam
select Eenheidnr_  
			 ,[Opz.inspectie DO - BKT] 
			 ,[Opz.inspectie DO - BOG] 
			 ,[Opz.inspectie DO - Regulier] 
			 ,[Opz.inspectie DO - Specials] 
from		empire_Staedion_data.dbo.[ITVFnContactbeheerInclNaam] ('OGEH-0004580' )

-- Nieuwe functie voor Contactgegevens cluster
			 ,[Ketenpartner] 
       ,[DO Bouwkundig] 
       ,[DO Dakpannen]
       ,[DO Electra] 
       ,[DO Intercom]
       ,[DO Loodgieter]
			 ,[Opz.inspectie DO - BKT] 
			 ,[Opz.inspectie DO - BOG] 
			 ,[Opz.inspectie DO - Regulier] 
			 ,[Opz.inspectie DO - Specials] 
-- select *
from		empire_Staedion_data.dbo.[ITVFnContactbeheerClusterInclNaam] ('FT-1001' )




******************************************************************************/
return
SELECT piv.Eenheidnr_
       ,[Bewonerscommissie] = Eenheden.fn_ContactbeheerNaam(piv.[BEWCIE]) 
       ,[Assetmanager] = Eenheden.fn_ContactbeheerNaam(piv.[CB-ASSMAN]) 
       ,[Assetmanager BOG] = Eenheden.fn_ContactbeheerNaam(piv.[CB-ASSMBOG]) 
       ,[Contactpersoon BOG] = Eenheden.fn_ContactbeheerNaam(piv.[CB-BOG])
       ,[Bewonersconsulent] = Eenheden.fn_ContactbeheerNaam(piv.[CB-BWCON] )
       ,[Complexbeheerder 1] = Eenheden.fn_ContactbeheerNaam(piv.[CB-CPXBEH1]) 
       ,[Complexbeheerder 2] = Eenheden.fn_ContactbeheerNaam(piv.[CB-CPXBEH2])
       ,[Huismeester 1] = Eenheden.fn_ContactbeheerNaam(piv.[CB-HUISM1]) 
       ,[Huismeester 2] = Eenheden.fn_ContactbeheerNaam(piv.[CB-HUISM2]) 
       ,[Huismeester Extern] = Eenheden.fn_ContactbeheerNaam(piv.[CB-HUISMEX]) 
       ,[Medewerker Herstructurering] = Eenheden.fn_ContactbeheerNaam(piv.[CB-MWHS]) 
       ,[Beheerder technische leefomgeving] = Eenheden.fn_ContactbeheerNaam(piv.[CB-MWTB]) 
       ,[Opzichter inspectie dagelijks onderhoud 1] = Eenheden.fn_ContactbeheerNaam(piv.[CB-OPZDGO1]) 
       ,[Opzichter inspectie dagelijks onderhoud 2] = Eenheden.fn_ContactbeheerNaam(piv.[CB-OPZDGO2]) 
       ,[Opzichter inspectie mutatie 1] = Eenheden.fn_ContactbeheerNaam(piv.[CB-OPZMUT1]) 
       ,[Opzichter inspectie mutatie 2] = Eenheden.fn_ContactbeheerNaam(piv.[CB-OPZMUT2]) 
       ,[Sociaal Complexbeheerder] = Eenheden.fn_ContactbeheerNaam(piv.[CB-SOCBEH]) 
       ,[Service & Verbruik team] = Eenheden.fn_ContactbeheerNaam(piv.[CB-SVTEAM]) 
       ,[Thuisteam] = Eenheden.fn_ContactbeheerNaam(piv.[CB-THTEAM]) 
       ,[Verhuurteam] = Eenheden.fn_ContactbeheerNaam(piv.[CB-VHTEAM]) 
       ,[Contactpersoon VvE] = Eenheden.fn_ContactbeheerNaam(piv.[CB-VVE]) 
	   ,[Vertegenwoordiger VvE] = Eenheden.fn_ContactbeheerNaam(piv.[CB-VVEVER]) 
       ,[Ketenpartner] = Eenheden.fn_ContactbeheerNaam(piv.[CB-WKET]) 
       ,[DO Bouwkundig] = Eenheden.fn_ContactbeheerNaam(piv.[CB-WKETB]) 
       ,[DO Dakpannen] = Eenheden.fn_ContactbeheerNaam(piv.[CB-WKETD]) 
       ,[DO Electra] = Eenheden.fn_ContactbeheerNaam(piv.[CB-WKETE]) 
       ,[DO Intercom] = Eenheden.fn_ContactbeheerNaam(piv.[CB-WKETI]) 
       ,[DO Loodgieter] = Eenheden.fn_ContactbeheerNaam(piv.[CB-WKETL]) 
			 ,[Opz.inspectie DO - BKT] = Eenheden.fn_ContactbeheerNaam(piv.[CB-INSDOBK])
			 ,[Opz.inspectie DO - BOG] = Eenheden.fn_ContactbeheerNaam(piv.[CB-INSDOBO])
			 ,[Opz.inspectie DO - Regulier] = Eenheden.fn_ContactbeheerNaam(piv.[CB-INSDORE])
			 ,[Opz.inspectie DO - Specials] = Eenheden.fn_ContactbeheerNaam(piv.[CB-INSDOSP])

FROM (
       SELECT ecp.Eenheidnr_
              ,ecp.Contactnr_
              ,ecp.Functie
       FROM empire_data.dbo.Staedion$Eenheid_contactpersoon ecp
       WHERE ecp.Eenheidnr_ = @Eenheidnr
              AND ecp.Functie IN (
						'BEWCIE'
						,'CB-ASSMAN'
						,'CB-ASSMBOG'
						,'CB-BOG'
						,'CB-BWCON'
						,'CB-CPXBEH1'
						,'CB-CPXBEH2'
						,'CB-HUISM1'
						,'CB-HUISM2'
						,'CB-HUISMEX'
						,'CB-MWHS'
						,'CB-MWTB'
						,'CB-OPZDGO1'
						,'CB-OPZDGO2'
						,'CB-OPZMUT1'
						,'CB-OPZMUT2'
						,'CB-SOCBEH'
						,'CB-SVTEAM'
						,'CB-THTEAM'
						,'CB-VHTEAM'
						,'CB-VVE'
						,'CB-VVEVER'
						,'CB-WKET'
						,'CB-WKETB'
						,'CB-WKETD'
						,'CB-WKETE'
						,'CB-WKETI'
						,'CB-WKETL'
						,'CB-INSDOBK' 
						,'CB-INSDOBO' 
						,'CB-INSDORE' 
						,'CB-INSDOSP'
                     )
       ) AS src
pivot(max(src.Contactnr_) FOR src.Functie IN (
                     [BEWCIE]
                     ,[CB-ASSMAN]
                     ,[CB-ASSMBOG]
                     ,[CB-BOG]
                     ,[CB-BWCON]
                     ,[CB-CPXBEH1]
                     ,[CB-CPXBEH2]
                     ,[CB-HUISM1]
                     ,[CB-HUISM2]
                     ,[CB-HUISMEX]
                     ,[CB-MWHS]
                     ,[CB-MWTB]
                     ,[CB-OPZDGO1]
                     ,[CB-OPZDGO2]
                     ,[CB-OPZMUT1]
                     ,[CB-OPZMUT2]
                     ,[CB-SOCBEH]
                     ,[CB-SVTEAM]
                     ,[CB-THTEAM]
                     ,[CB-VHTEAM]
                     ,[CB-VVE]
                     ,[CB-VVEVER]
                     ,[CB-WKET]
                     ,[CB-WKETB]
                     ,[CB-WKETD]
                     ,[CB-WKETE]
                     ,[CB-WKETI]
                     ,[CB-WKETL]
					 ,[CB-INSDOBK]
					 ,[CB-INSDOBO]
					 ,[CB-INSDORE]
					 ,[CB-INSDOSP]
                     )) AS piv
GO
