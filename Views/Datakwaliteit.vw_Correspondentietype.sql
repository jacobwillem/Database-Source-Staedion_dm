SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Datakwaliteit].[vw_Correspondentietype] AS
/* ##############################################################################################################################
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
20211103 JvdW Toevoeging op verzoek van Marieke
--------------------------------------------------------------------------------------------------------------------------
TEST
--------------------------------------------------------------------------------------------------------------------------
select * from [Datakwaliteit].[vw_Correspondentietype] where [Consistentie email] = 1
select * from [Datakwaliteit].[vw_Correspondentietype] where [Onvolledigheid correspondentietype] = 1
select * from [Datakwaliteit].[vw_Correspondentietype] where [Inaccurate email]= 1
------------------------------------------------------------------------------------------------------------------------------------
METADATA
------------------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Datakwaliteit', 'vw_Correspondentietype'

------------------------------------------------------------------------------------------------------------------------------------
AANVULLENDE INFO
--------------------------------------------------------------------------------------------------------------------------
Toevoeging info over tabel/view
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Van alle huurders wordt opgehaald wat het correspondentietype is, of deze gevuld en als het correspondentietype email is, wordt gekeken of het emailadres ook daadwerkelijk is gevuld'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Datakwaliteit'
       ,@level1type = N'VIEW'
       ,@level1name = 'vw_Correspondentietype';
GO
################################################################################################################################## */    
WITH cte_Additioneel AS 
(

	SELECT [Klantnr] = AD.[Customer No_], AD.Ingangsdatum, Volgnr = ROW_NUMBER() OVER (PARTITION BY AD.[Customer No_] ORDER BY AD.Ingangsdatum DESC) 
		FROM empire_data.dbo.[Staedion$Additioneel] AS AD
		WHERE NULLIF(AD.[Einddatum],'20990101') >= GETDATE()
	)


SELECT [Klantnr] = C.No_,
       Huishoudkaartnr = H.No_,
       [Klantnaam] = C.[Name],
       CASE H.[Correspondence Type]
           WHEN 0 THEN
               ''
           WHEN 1 THEN
               'Afdruk'
           WHEN 2 THEN
               'E-mail'
           WHEN 3 THEN
               'Fax'
           ELSE
               'Onbekend'
       END AS [Correspondentietype huishoudkaart]
	   ,[Email huishoudkaart] = H.[E-Mail]
	   ,[Email 2 huishoudkaart] = H.[E-Mail 2]
	   ,[Consistentie email] = IIF(H.[Correspondence Type] = 2 AND H.[E-Mail] = '', 1,0)
	   ,[Onvolledigheid correspondentietype] = IIF(H.[Correspondence Type] IN (0,3), 1,0)
	   ,[Recentste ingangsdatum huurcontract] = CTE.Ingangsdatum
	   ,[Inaccurate email] = CASE WHEN C.[E-mail] <> '' AND H.[Correspondence Type] = 2 AND staedion_dm.[Datakwaliteit].[fn_check_emailadres] (C.[E-mail]) = 0 THEN 1 ELSE NULL END
					--										ELSE CASE WHEN CONT.[E-mail 2] <> '' AND staedion_dm.[Datakwaliteit].[fn_check_emailadres] (CONT.[E-mail 2])= 0 THEN 'Ja' 
					--										---ELSE CASE WHEN CONT.[E-mail 3] <> '' AND staedion_dm.[Datakwaliteit].[fn_check_emailadres] (CONT.[E-mail 3])= 0 THEN 'Ja' 
					--										--ELSE CASE WHEN CONT.[E-mail 4] <> '' AND staedion_dm.[Datakwaliteit].[fn_check_emailadres] (CONT.[E-mail 4])= 0 THEN 'Ja' 
					--										--ELSE CASE WHEN CONT.[E-mail 5] <> '' AND staedion_dm.[Datakwaliteit].[fn_check_emailadres] (CONT.[E-mail 5])= 0 THEN 'Ja' 
					--											ELSE 'Nee' END END 			
-- select H.[Correspondence Type],count(*)
FROM empire_data.dbo.customer AS C
    JOIN empire_data.dbo.contact AS H
        ON C.[Contact No_] = H.No_
		   LEFT OUTER JOIN cte_Additioneel AS CTE ON CTE.Klantnr = C.No_ AND CTE.volgnr = 1

GO
EXEC sp_addextendedproperty N'MS_Description', N'Van alle huurders wordt opgehaald wat het correspondentietype is, of deze gevuld en als het correspondentietype email is, wordt gekeken of het emailadres ook daadwerkelijk is gevuld', 'SCHEMA', N'Datakwaliteit', 'VIEW', N'vw_Correspondentietype', NULL, NULL
GO
