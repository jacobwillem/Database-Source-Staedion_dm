SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE view [Onderhoud].[OnderhoudsurenPortieken] as
/* #########################################################################################
-- info
EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'Onderhoud', 'OnderhoudsurenPortieken'
 select * from staedion_dm.Onderhoud.OnderhoudsurenPortieken
######################################################################################### */    
SELECT Onderhoudsorder = ORD.No_
       ,[Omschrijving werkzaamheden] = ORD.[Description]
       ,[Aantal uren] = JLE.[Quantity]
       ,[Boekdatum] = JLE.[Posting Date]
       ,[Leverancier] = ORD.[Vendor No_]
       ,[Eenheidsnr] = JLE.Eenheidnr_
       ,[Omschrijving onderhoudspost] = JLE.[Description]
       ,[Locatie] = OGE.Straatnaam + ' ' + convert(nvarchar(20),OGE.Huisnr_)
-- select sum(JLE.[Quantity]) 
FROM empire_Data.dbo.[Staedion$Job_Ledger_Entry] AS JLE
JOIN empire_Data.dbo.[Staedion$DM___Maintenance_Order] AS ORD
       ON ORD.no_ = JLE.[Job No_]
LEFT OUTER JOIN empire_Data.dbo.Staedion$OGE AS OGE
       ON OGE.Nr_ = JLE.Eenheidnr_
WHERE year(JLE.[Posting Date]) >= 2020
       AND ORD.[Vendor No_] = 'LEVE-02164'
       AND ORD.[Description] = 'Standaardtaak Planmatig Onderhoud'
       AND JLE.[Type] = 0		-- geen materiaal, alleen uren
       AND ORD.[Maintenance Request No_] NOT IN (
              SELECT No_
              FROM empire_Data.dbo.Staedion$Maintenance_Request
              WHERE [Realty Object No_] = 'OGEH-0025518'					-- Klopperman
              )
       -- and ORD.No_ = 'OND00121668-000-01'

GO
