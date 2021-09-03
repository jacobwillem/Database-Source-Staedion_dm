SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  function [dbo].[ITVF_contract_riool_glas] (@dagen_geleden_gestart as int = 31) 
returns table 
as
/* ###################################################################################################
VAN         : MV
BETREFT     : Lijst van riool- en glascontracten afgesloten in de afgelopen @dagen_geleden_gestart dagen
ZIE         : Peter van Dijk - rapportage op afgesloten contracten
------------------------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
Versie 1
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
SELECT * FROM [staedion_dm].[dbo].[ITVF_contract_riool_glas] (DEFAULT)
SELECT * FROM [staedion_dm].[dbo].[ITVF_contract_riool_glas] (90)

################################################################################################### */	
RETURN
with contracten as (
	select
		 [Eenheidnummer] = [Primary Key Field 3 Value]
		,[Element] = coalesce(nullif([Old Value], ''), nullif([New Value], ''))
		,[Omschrijving] = case coalesce(nullif([Old Value], ''), nullif([New Value], ''))
									when '255' then '255: Rioolcontract'
									when '256' then '256: Rioolcontract BTW'
									when '263' then '263: Glascontract'
									when '264' then '264: Glascontract BTW'
								 end
		,[Wijziging] = iif([New Value] <> '', 'Gestart', 'Gestopt')
		,[Gewijzigd] = convert(date, [Date and Time])
		,[Dagen sinds wijziging] = datediff(day, [Date and Time], getdate())
		,[Volgnummer] = row_number() over (partition by [Primary Key Field 3 Value], coalesce(nullif([Old Value], ''), nullif([New Value], '')) order by convert(datetime, [Date and Time]) desc)
		from empire_staedion_Data.dbo.change_log_entry e
		where e.mg_bedrijf = 'Staedion' and [Table No_] = 11024013
		and datediff(day, [Date and Time], getdate()) <= @dagen_geleden_gestart
		and [Primary Key Field 3 Value] <> ''
		and
		(  ([Old Value] in ('255', '256', '263', '264') and [New Value] = '')
		or ([New Value] in ('255', '256', '263', '264') and [Old Value] = '')
		) 
)

select   [Eenheidnummer]
		,[Element]
		,[Omschrijving]
		,[Wijziging]
		,[Gewijzigd]
		,[Dagen sinds wijziging]
from contracten
where [Volgnummer] = 1

GO
