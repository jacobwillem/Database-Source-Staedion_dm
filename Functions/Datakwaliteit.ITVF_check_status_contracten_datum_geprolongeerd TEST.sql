SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [Datakwaliteit].[ITVF_check_status_contracten_datum_geprolongeerd TEST] () 
returns table 
as
/* ###################################################################################################
VAN         : JvdW
BETREFT     : Contracten van nog lopende huurcontracten (tabel Additioneel) met gevulde datum [Datum geprolongeerd tot] die niet overeenkomt met einddatum+1d en met Einddatum contractregel ook gevuld

----------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
Versie 1: 20200527 JvdW, ovv Marieke
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
SELECT *
FROM backup_empire_Dwh.dbo.[ITVF_check_status_contracten_datum_geprolongeerd]()
WHERE [Einddatum contractregel] IS NOT NULL
--       AND Eenheidnr in ( 'OGEH-0018550', 'OGEH-0036681','OGEH-0054597','OGEH-0018550')

------------------------------------------------------------------------------------------------------
TEMP
------------------------------------------------------------------------------------------------------


################################################################################################### */	
RETURN
WITH CTE_peildata -- voor tonen periode in dataset
AS (
       SELECT datum AS Laaddatum
       FROM empire_dwh.dbo.tijd
       WHERE [last_loading_day] = 1
       )
       ,
CTE_Eenheidkaart
AS (
       SELECT oge.Nr_
              ,[Statuscode] = oge.[status]
              ,[Status] = CASE oge.[status]
                     WHEN 0
                            THEN 'Leegstand'
                     WHEN 1
                            THEN 'Uit beheer'
                     WHEN 2
                            THEN 'Renovatie'
                     WHEN 3
                            THEN 'Verhuurd'
                     WHEN 4
                            THEN 'Administratief'
                     WHEN 5
                            THEN 'Verkocht'
                     WHEN 6
                            THEN 'In ontwikkeling'
                     ELSE convert(NVARCHAR(4), oge.[status])
                     END
       FROM empire_data.dbo.[staedion$oge] AS oge
       ),

			 cte_additioneel
AS (
       SELECT [Customer No_]
              ,[Eenheidnr_]
							,Ingangsdatum
							,Einddatum
       FROM empire_data.dbo.[Staedion$Additioneel]
       WHERE Ingangsdatum <= getdate()
              AND (
                     Einddatum >= getdate()
                     OR Einddatum = '17530101'
                     )
       )
SELECT Eenheidnr = CONTR.Eenheidnr_
       ,Volgnummer = CONTR.Volgnr_
       ,[Ingangsdatum contractregel] = convert(NVARCHAR(20), CONTR.Ingangsdatum, 105)
			 ,[Geprolongeerd tot] = convert(NVARCHAR(20), CONTR.[Geprolongeerd tot], 105) 
       ,[Einddatum contractregel] = convert(NVARCHAR(20), nullif(CONTR.Einddatum,'17530101'), 105)
       ,[Ingangsdatum contract] = convert(NVARCHAR(20), CTE_A.Ingangsdatum, 105)
       ,[Einddatum contract] = convert(NVARCHAR(20), nullif(CTE_A.Einddatum,'17530101'), 105)
       ,Klantnr = CONTR.[Customer No_]
			 ,[Vinkje beeindigd] = iif(CONTR.[Beëindigd] =1,'Ja','Nee')
       ,[Status contractregel] = CASE CONTR.[Status]
              WHEN 0
                     THEN 'Nieuw'
              WHEN 1
                     THEN 'Huidig'
              WHEN 2
                     THEN 'Oud'
              ELSE convert(NVARCHAR(4), CONTR.[Status])
              END
       ,[Status volgens huidige contractregel] = CASE CONTR.[Exploitation State Type]
              WHEN 0
                     THEN 'Leegstand'
              WHEN 1
                     THEN 'Uit beheer'
              WHEN 2
                     THEN 'Renovatie'
              WHEN 3
                     THEN 'Verhuurd'
              WHEN 4
                     THEN 'Administratief'
              WHEN 5
                     THEN 'Verkocht'
              WHEN 6
                     THEN 'In ontwikkeling'
              ELSE convert(NVARCHAR(4), CONTR.[Exploitation State Type])
              END
       ,[Status ogekaart] = OGE.[Status]
       ,[Gegenereerd] = P.Laaddatum
			 ,datIngang = CTE_A.Ingangsdatum
			 ,datEinde = nullif(CTE_A.Einddatum,'17530101')
			 ,Omschrijving = 'Vinkje beeindigd: ' + iif(CONTR.[Beëindigd] =1,'Ja','Nee')
FROM empire_data.dbo.[staedion$contract] AS CONTR
join cte_additioneel as CTE_A
on CTE_A.Eenheidnr_ = CONTR.Eenheidnr_
and CTE_A.[Customer No_] = CONTR.[Customer No_]
JOIN CTE_peildata AS P
       ON 1 = 1
FULL OUTER JOIN CTE_Eenheidkaart AS OGE
       ON OGE.Nr_ = CONTR.Eenheidnr_
WHERE 1=1--  CONTR.[Status] <> 0 -- 
and CONTR.[Geprolongeerd tot] <> dateadd(d,1,CONTR.Einddatum)
and CONTR.[Geprolongeerd tot] <> '17530101'
and CONTR.[Dummy Contract] = 0
;
GO
