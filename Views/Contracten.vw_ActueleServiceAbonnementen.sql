SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Contracten].[vw_ActueleServiceAbonnementen]
AS

SELECT Eenheidnr, Huurdernr, Huurdernaam, Volgnummer, Elementnr, Bedrag, Eenmalig, [Afwijking standaardprijs]
FROM staedion_dm.[Contracten].[ActueleContractRegels]
WHERE Elementnr IN (
              '404'
              ,'405'
              ,'407'
              ,'408'
              ,'409'
              ,'410'
              ,'411'
              ,'412'
              ,'413'
              ,'415'
              )


GO
