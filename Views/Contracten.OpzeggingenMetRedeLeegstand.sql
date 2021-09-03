SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Contracten].[OpzeggingenMetRedeLeegstand]
as 
-- 20210315 JvdW 21 03 581: Excelrapportage Huidige opzeggingen ? status leegstandscode 

-- Beste benadering van d_opzegging
WITH cte_einddatum_contract
AS (
       SELECT Eenheidnr_
              ,[Customer No_]
              ,[Einddatum]
              ,volgnr = row_number() OVER (
                     PARTITION BY Eenheidnr_
                     ,[Customer No_] ORDER BY [Einddatum] DESC
                     )
       FROM empire_data.dbo.Staedion$Contract AS C
       WHERE C.[Dummy Contract] = 0
       ) 
       ,cte_opzegging
AS (
       SELECT OPZ.Eenheidnr_
              ,OPZ.[Customer No_]
              ,[Einde huur klant] = coalesce(CTE.[Einddatum], OPZ.[Einde huur klant])
              ,OPZ.[Ontvangst opzegging]
              ,[Verhuurbaar per] = nullif(OPZ.[Verhuurbaar per], '17530101')
							,[Huuropzegging afgehandeld] = Iif(OPZ.[Recision completed] = 1, 'Ja','Nee')
              ,volgnr = row_number() OVER (
                     PARTITION BY OPZ.Eenheidnr_
                     ,OPZ.[Customer No_] ORDER BY OPZ.[Ontvangst opzegging] DESC
                     )
       -- select top 10 *
       FROM empire_data.dbo.staedion$opzegging_verhuurcontract AS OPZ
       LEFT OUTER JOIN cte_einddatum_contract AS CTE
              ON OPZ.Eenheidnr_ = CTE.Eenheidnr_
                     AND OPZ.[Customer No_] = CTE.[Customer No_]
                     AND CTE.volgnr = 1
       WHERE year(coalesce(CTE.[Einddatum], OPZ.[Einde huur klant])) >= 2020
            --  AND OPZ.[Recision completed] = 1
       ) ,cte_additioneel as 
			 (select AD.[Customer No_], AD.Eenheidnr_, AD.Ingangsdatum, volgnr = row_number() OVER (
                     PARTITION BY AD.Eenheidnr_ ORDER BY AD.Ingangsdatum asc
                     )
			 from empire_data.dbo.Staedion$Additioneel as AD
			 left outer join cte_opzegging as OPZ
			 on OPZ.Eenheidnr_ = AD.Eenheidnr_
			 where AD.Ingangsdatum > OPZ.[Einde huur klant]
			 AND (AD.Ingangsdatum < COALESCE(NULLIF(AD.Einddatum,'17530101'),'20990101'))			-- toegevoegd - geannuleerde contracten
			 ),
			 cte_leegstand_begin
AS (
       SELECT C.Eenheidnr_
              ,C.[Customer No_]
							,C.Ingangsdatum
              ,C.[Einddatum]
							,C.Boekingsgroep 
              ,volgnr = row_number() OVER (
                     PARTITION BY C.Eenheidnr_ ORDER BY C.Ingangsdatum asc
                     )
       FROM empire_data.dbo.Staedion$Contract AS C
			 left outer join cte_opzegging as OPZ
			 on OPZ.Eenheidnr_ = C.Eenheidnr_
       WHERE C.[Dummy Contract] = 0
			 and C.Ingangsdatum > OPZ.[Einde huur klant]
	     ),
			 cte_leegstand_einde
AS (
       SELECT C.Eenheidnr_
              ,C.[Customer No_]
							,C.Ingangsdatum
              ,C.[Einddatum]
							,C.Boekingsgroep 
              ,volgnr = row_number() OVER (
                     PARTITION BY C.Eenheidnr_ ORDER BY C.Ingangsdatum desc
                     )
       FROM empire_data.dbo.Staedion$Contract AS C
			 left outer join cte_opzegging as OPZ
			 on OPZ.Eenheidnr_ = C.Eenheidnr_
       WHERE C.[Dummy Contract] = 0
			 and C.Ingangsdatum > OPZ.[Einde huur klant]
	     )
			 , cte_eenheid
			 as (select		Eenheidnr = Nr_ 
										,[Corpodate-type] = TT.[Analysis Group Code]
										,Adres = OGE.Straatnaam + ' ' + OGE.Huisnr_ + ' '+ OGE.Toevoegsel
						from	empire_data.dbo.Staedion$OGE as OGE
						join empire_data.dbo.staedion$Type as TT
							on TT.Soort <> 3	
							and TT.Code = OGE.[Type]) 
--select * from cte_leegstand
--where Eenheidnr_ = 'OGEH-0000400'
 
SELECT Eenheidnr = OPZ.Eenheidnr_
				,Adres = OGE.Adres
			  ,[Corpodata-type] = OGE.[Corpodate-type]
        ,[Opgezegde huurder] = OPZ.[Customer No_]
				,[Naam opgezegde huurder] = CUST2.Name
        ,[Opzegging (einde huur klant)] = OPZ.[Einde huur klant]
        ,OPZ.[Ontvangst opzegging]
				,[Huuropzegging afgehandeld]
        ,OPZ.[Verhuurbaar per]
				,[Jan] = iif(month(OPZ.[Einde huur klant]) = 1,1,0)
				,[Feb] = iif(month(OPZ.[Einde huur klant]) = 2,1,0)
				,[Mrt] = iif(month(OPZ.[Einde huur klant]) = 3,1,0)
				,[Apr] = iif(month(OPZ.[Einde huur klant]) = 4,1,0)
				,[Mei] = iif(month(OPZ.[Einde huur klant]) = 5,1,0)
				,[Jun] = iif(month(OPZ.[Einde huur klant]) = 6,1,0)
				,[Jul] = iif(month(OPZ.[Einde huur klant]) = 7,1,0)
				,[Aug] = iif(month(OPZ.[Einde huur klant]) = 8,1,0)
				,[Sep] = iif(month(OPZ.[Einde huur klant]) = 9,1,0)
				,[Okt] = iif(month(OPZ.[Einde huur klant]) = 10,1,0)
				,[Nov] = iif(month(OPZ.[Einde huur klant]) = 11,1,0)
				,[Dec] = iif(month(OPZ.[Einde huur klant]) = 12,1,0)
				,[Nieuwe huurder] = AD.[Customer No_]
				,[Naam nieuwe huurder] = CUST1.Name
				,[Ingangsdatum leegstand] = iif(LST_b.[Customer No_] = '', LST_b.Ingangsdatum,null)
				,[Ingangsdatum verhuring] = AD.Ingangsdatum
				,[Soort leegstand (meest recent)] = coalesce(LST_e.[Boekingsgroep] + ': '+ DIV.Omschrijving,'Geen leegstand')
				,Laaddatum = (select Laaddatum from empire_Dwh.dbo.tmv_laaddatum)
FROM cte_opzegging as OPZ
left outer join cte_eenheid as OGE
on OGE.Eenheidnr = OPZ.Eenheidnr_
left outer join cte_additioneel as AD
on AD.Eenheidnr_ = OPZ.Eenheidnr_
and AD.volgnr = 1
left outer join cte_leegstand_begin as LST_b
on LST_b.Eenheidnr_ = OGE.Eenheidnr
and LST_b.volgnr = 1
left outer join cte_leegstand_einde as LST_e
on LST_e.Eenheidnr_ = OGE.Eenheidnr
and LST_e.volgnr = 1
left outer join empire_data.dbo.Diversen2 as DIV
on DIV.Code = LST_e.[Boekingsgroep]						
and  DIV.Tabel  = 2	
left outer join empire_Data.dbo.customer as CUST1
on CUST1.No_ = AD.[Customer No_]
left outer join empire_Data.dbo.customer as CUST2
on CUST2.No_ = OPZ.[Customer No_]

WHERE OPZ.volgnr = 1
GO
