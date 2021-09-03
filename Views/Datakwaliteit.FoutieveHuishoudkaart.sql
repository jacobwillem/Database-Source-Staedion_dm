SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Datakwaliteit].[FoutieveHuishoudkaart] as
/* ##############################################################################################################################
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
--------------------------------------------------------------------------------------------------------------------------
TEST
--------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Eenheden', 'fn_Kernvoorraad TEST'

------------------------------------------------------------------------------------------------------------------------------------
AANVULLENDE INFO
--------------------------------------------------------------------------------------------------------------------------
-- Alternatief: mbv functie 
	SELECT [Originele klantnr] = FF.[Customer No_]
				 ,[Originele klantnaam] = FF.Klantnaam
				 ,[Huishoudkaart] = FF.[Contact no_]
				 ,[Persoonskaart hoofdhuurder] = FF.[contact_1]
				 ,[Huishoudkaart medehuurder] = FF.contact_2
				 --,FF.contact_2_type
				 ,[Klantkaart op huishoudkaart medehuurder] = C2.No_
	from empire_Data.dbo.customer as C
	cross  apply empire_staedion_data.dbo.[ITVfnContractaanhef FF](C.No_) as FF
	join empire_data.dbo.customer as C2
	on C2.[Contact No_] = FF.contact_2
	where FF.contact_2_type = 0
################################################################################################################################## */    
					
-- 2: zonder functie
sELECT [Klantnr] = C.No_
       ,Huishoudkaartnr = H.No_
       ,[Klantnaam] = C.NAME
			 ,[Relatienr persoonskaart medehuurder] = P2.Name
			 ,[Relatienr huishoudkaart medehuurder] = P2.No_
			 ,[Klantnr huishoudkaart medehuurder] = C2.No_
-- select C.*
FROM empire_data.dbo.customer AS C
JOIN empire_data.dbo.contact AS H
       ON C.[Contact No_] = H.No_
LEFT OUTER JOIN empire_data.dbo.contact_role AS CR
       ON CR.[Related Contact No_] = C.[Contact No_]
			 --and CR.[Show first] = 1
LEFT OUTER JOIN empire_data.dbo.contact AS P1
       ON CR.[Contact No_] = P1.[No_]
			 and CR.[Show first] = 1
LEFT OUTER JOIN empire_data.dbo.contact AS P2
       ON CR.[Contact No_] = P2.[No_]
			 and CR.[Show first] = 0
left outer join empire_Data.dbo.[customer] as C2
on C2.[Contact No_] = P2.[No_]
where P2.[Type] = 0




GO
