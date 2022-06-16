SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [Eenheden].[fn_Contactbeheer] (@Eenheidnr varchar(20))
returns table
as
/******************************************************************************
VAN 			RvG
Betreft			Ophalen verschillende contactpersonen bij eenheden. Van de contactpersoon wordt 
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
CB-VVEVER	Vertegenwoordiger VvE
01-02-2021 JvdW Kopie van empire_staedion_data: relevante functies en views en procedures in 1 database met schema's onderbrengen
---------------------------------------------------------------------------------------------------
TEST
---------------------------------------------------------------------------------------------------		
select * from dbo.functie where descr like '%DO%'  or id in ('CB-EDOOST','CB-EDWEST')
select * from empire_Staedion_data.dbo.[ITVFnContactbeheer] ('OGEH-0004580' )



SELECT oge.Nr_
       ,cnt.Assetmanager
       ,con.NAME
FROM empire_data.dbo.Staedion$OGE oge
OUTER APPLY empire_staedion_data.dbo.ITVFnContactbeheer(oge.nr_) AS cnt
INNER JOIN empire_data.dbo.Contact con
       ON cnt.Assetmanager = con.No_
WHERE oge.[Common Area] = 0
       AND (
              oge.[Einde exploitatie] >= getdate()
              OR oge.[Einde exploitatie] = datefromparts(1753, 1, 1)
              )

******************************************************************************/
return
SELECT piv.Eenheidnr_
       ,[Bewonerscommissie] = piv.[BEWCIE] 
       ,[Assetmanager] = piv.[CB-ASSMAN] 
       ,[Assetmanager BOG] = piv.[CB-ASSMBOG] 
       ,[Contactpersoon BOG] = piv.[CB-BOG] 
       ,[Bewonersconsulent] = piv.[CB-BWCON] 
       ,[Complexbeheerder 1] = piv.[CB-CPXBEH1] 
       ,[Complexbeheerder 2] = piv.[CB-CPXBEH2] 
       ,[Huismeester 1] = piv.[CB-HUISM1] 
       ,[Huismeester 2] = piv.[CB-HUISM2] 
       ,[Huismeester Extern] = piv.[CB-HUISMEX] 
       ,[Medewerker Herstructurering] = piv.[CB-MWHS] 
       ,[Beheerder technische leefomgeving] = piv.[CB-MWTB] 
       ,[Opzichter inspectie dagelijks onderhoud 1] = piv.[CB-OPZDGO1] 
       ,[Opzichter inspectie dagelijks onderhoud 2] = piv.[CB-OPZDGO2] 
       ,[Opzichter inspectie mutatie 1] = piv.[CB-OPZMUT1] 
       ,[Opzichter inspectie mutatie 2] = piv.[CB-OPZMUT2] 
       ,[Sociaal Complexbeheerder] = piv.[CB-SOCBEH] 
       ,[Service & Verbruik team] = piv.[CB-SVTEAM] 
       ,[Thuisteam] = piv.[CB-THTEAM] 
       ,[Verhuurteam] = piv.[CB-VHTEAM] 
       ,[Contactpersoon VvE] = piv.[CB-VVE] 
       ,[Vertegenwoordiger VvE] = piv.[CB-VVEVER] 
       ,[Ketenpartner] = piv.[CB-WKET] 
       ,[DO Bouwkundig] = piv.[CB-WKETB] 
       ,[DO Dakpannen] = piv.[CB-WKETD] 
       ,[DO Electra] = piv.[CB-WKETE] 
       ,[DO Intercom] = piv.[CB-WKETI] 
       ,[DO Loodgieter] = piv.[CB-WKETL] 
	   ,[Opz.inspectie DO - BKT] = piv.[CB-INSDOBK]
	   ,[Opz.inspectie DO - BOG] = piv.[CB-INSDOBO]
	   ,[Opz.inspectie DO - Regulier] = piv.[CB-INSDORE]
	   ,[Opz.inspectie DO - Specials] = piv.[CB-INSDOSP]

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
