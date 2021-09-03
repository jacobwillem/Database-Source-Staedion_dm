SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [Algemeen].[verdeelsleutel]
as
   SELECT 
    [FT-clusternummer],
    [eenheidnummer],
    [KVS-verdeelsleutel]         
FROM staedion_dm.dbo.[ITVF_verdeelsleutels](DEFAULT, 'GEWOGEN')
GO
