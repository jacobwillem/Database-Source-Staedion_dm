SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  function [Datakwaliteit].[fn_HuurderFilter] (@Peildatum as date = null, @Klantnr as nvarchar(20) = null) 
returns table 
as
/* ###################################################################################################
VAN         : JvdW
BETREFT     : Per huurder aangeven of het een actieve huurder betreft en of het nog een actieve relatie betreft
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
Versie 1: [20201021 Nav Werkgroep Datakwaliteit]
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
-- performance alle data
SELECT  *
FROM   [Datakwaliteit].[fn_HuurderFilter](DEFAULT, DEFAULT)

-- dubbele ?
SELECT count(*), count(distinct Klantnr)
FROM   [Datakwaliteit].[fn_HuurderFilter](DEFAULT, DEFAULT)

SELECT *
FROM   [Datakwaliteit].[fn_HuurderFilter](DEFAULT, 'HRDR-0015865')

------------------------------------------------------------------------------------------------------
TEMP
------------------------------------------------------------------------------------------------------
-- Steekproef
Declare @Nr as nvarchar(20) = 'HRDR-0015865'
;
select * 
from empire_Data.dbo.customer 
where no_ = @Nr
;
select sum(Amount)
from empire_Data.dbo.vw_lt_mg_detailed_cust_ledg_entry 
where [Customer No_] = @Nr
;
select top 10 *
from empire_Data.dbo.vw_lt_mg_cust_ledger_entry 
where [Customer No_] = @Nr

select * from [Datakwaliteit].[fn_HuurderFilter] (getdate(), @Nr)
;
------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Datakwaliteit', 'fn_Huurder'

################################################################################################### */	
RETURN


WITH CTE_peildata -- voor tonen periode in dataset
AS (
       SELECT datum AS Laaddatum
       FROM empire_dwh.dbo.tijd
       WHERE [last_loading_day] = 1
       )
       ,CTE_huurcontract
AS (
       SELECT [Customer No_]
              ,[Actief contract] = 1
       FROM empire_data.dbo.staedion$contract
       WHERE [Dummy Contract] = 0
              AND Soort = 1 -- Verhuur
              AND [Status] IN (
                     0
                     ,1
                     ) -- 0 = Nieuw 1 = huidig
       )
SELECT Klantnr = CUS.No_
       ,Klantnaam = CUS.NAME
	   ,[Huishoudnr]= CUS.[Contact No_] -- 20210324 toegevoegd
	   ,Klantboekingsgroep = CUS.[Customer Posting Group]
       ,[Actief huurcontract] = coalesce(CTR.[Actief contract], 0)
       ,Peildatum = coalesce(@Peildatum, PEIL.Laaddatum)
       ,[Saldo rekening courant] = convert(DECIMAL(12, 2), sum(dcl.amount))
       ,[Saldo boekdatum] = convert(DECIMAL(12, 2), sum(iif(DCL.[Posting Date] <= coalesce(@Peildatum, PEIL.Laaddatum), dcl.amount, 0)))
       ,[Saldo vervaldatum] = convert(DECIMAL(12, 2), sum(iif(CLE.[Due Date] <= coalesce(@Peildatum, PEIL.Laaddatum)
                            OR CLE.[Document Type] IN (
                                   10
                                   ,11
                                   ), DCL.amount, 0.0)))
FROM empire_data.dbo.customer AS CUS
LEFT OUTER JOIN empire_data.dbo.vw_lt_mg_cust_ledger_entry AS CLE			-- niet de views gebruiken maar de gematerialiseerde tabellen - die zijn ook tijdens empire_data laden beschikbaar
       ON CLE.[Customer No_] = CUS.[No_]
LEFT OUTER JOIN cte_huurcontract AS CTR
       ON CTR.[Customer No_] = CUS.No_
LEFT OUTER JOIN empire_Data.dbo.vw_lt_mg_detailed_cust_ledg_entry AS DCL		-- niet de views gebruiken maar de gematerialiseerde tabellen - die zijn ook tijdens empire_data laden beschikbaar
       ON CLE.mg_bedrijf = DCL.mg_bedrijf
              AND CLE.[Entry No_] = DCL.[Cust_ Ledger Entry No_]
left outer join CTE_peildata as PEIL
on 1=1 
where (CUS.No_ = @Klantnr or @Klantnr is null)
GROUP BY CUS.No_
       ,CUS.NAME
       ,coalesce(CTR.[Actief contract], 0)
       ,CUS.[Customer Posting Group]
	   ,coalesce(@Peildatum, PEIL.Laaddatum)
	   ,CUS.[Contact No_] 
GO
