SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Datakwaliteit].[NaamgevingKlanten TEST] as
/* ##############################################################################################################################
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
JvdW 20200713 Aangemaakt obv input Marieke - nog uitzoeken wat zinvolle data is
--------------------------------------------------------------------------------------------------------------------------
TEST
--------------------------------------------------------------------------------------------------------------------------
select * from staedion_dm.Datakwaliteit.[NaamgevingKlanten TEST]
--------------------------------------------------------------------------------------------------------------------------
METADATA
--------------------------------------------------------------------------------------------------------------------------
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] 'staedion_dm', 'Datakwaliteit', '[NaamgevingKlanten TEST]'

--------------------------------------------------------------------------------------------------------------------------
AANVULLENDE INFO
--------------------------------------------------------------------------------------------------------------------------
-- Marieke: 
Een overzicht van de actuele/actieve huurders/klanten, waarbij de Naamvelden 1 t/m 3 zijn gevuld (check op Huishouden-relatiekaart en voor de zekerheid ook op Klantkaart?)
Velden: Naam (=vaak gelijk aan Achternaam?), Naam 2 en Naam 3



################################################################################################################################## */    


    
WITH cte_additioneel
AS (
       SELECT [Customer No_]
              ,[Meest recente einddatum] = max(Iif(Einddatum = '17530101', '20990101', Einddatum))
       FROM empire_Data.dbo.[Staedion$Additioneel]
       WHERE Ingangsdatum <= getdate()
       GROUP BY [Customer No_]
       )
SELECT  Klantnr = KLNT.[No_]
       ,Huishoudkaart = ROL.[Related Contact No_]
       ,[Opmerking] = iif(CTE.[Meest recente einddatum] < getdate(), 'Geen actieve contracten', iif(CTE.[Meest recente einddatum] is null, 'Geen contracten', 'Lopend contract'))
			 ,[Klantkaart Naam] = KLNT.[Name]
			 ,[Klantkaart Naam 2] = KLNT.[Name 2]
			 ,[Klantkaart Naam 3] = KLNT.[Naam 3]
       ,Laaddatum = (
              SELECT max(datum)
              FROM empire_Dwh.dbo.tijd
              WHERE last_loading_day = 1
              )
       ,Hyperlink = empire_staedion_data.empire.fnEmpireLink('Staedion', 21, 'No.=' + '''' + KLNT.[No_] + '''', 'view') --=> (opvraagscherm)
      -- ,CTE.[Meest recente einddatum]
FROM empire_data.dbo.Customer AS KLNT
LEFT OUTER JOIN cte_additioneel AS CTE
       ON CTE.[Customer No_] = KLNT.[No_]
INNER JOIN empire_data.dbo.[contact_role] AS ROL
       ON KLNT.[Contact No_] = ROL.[Related Contact No_]
             -- AND ROL.[Show first] = 1
where KLNT.[Name] <> ''
and KLNT.[Name 2] <> ''
and KLNT.[Naam 3] <> ''
--where ROL.[Contact No_] = 'RLTS-0044822'
--GROUP BY KLNT.[No_]
--       ,ROL.[Related Contact No_]
--       ,CTE.[Meest recente einddatum]
--HAVING count(ROL.[Show first]) > 1;
GO
