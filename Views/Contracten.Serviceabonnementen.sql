SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Contracten].[Serviceabonnementen]
as
WITH cte_staedion_brede_elementen
AS (
       SELECT Element = '404'
              ,Was = 6.40
              ,Wordt = 6.40 -- Servicecontract
       
       UNION
       
       SELECT Element = '413'
              ,Was = - 0.97
              ,Wordt = - 0.97 -- Woonduurkorting 10 jaar
       
       UNION
       
       SELECT Element = '415'
              ,Was = - 1.95
              ,Wordt = - 1.95 -- woonduurkorting 20 jaar 
       ),
cte_correspondentie
AS (
	SELECT Huurdernr = ADT.[Customer No_]
		,[Correspondentietype] = max(CASE CON.[Correspondence Type]
			WHEN 0
				THEN ''
			WHEN 1
				THEN 'Afdruk'
			WHEN 2
				THEN 'E-mail'
			WHEN 3
				THEN 'Fax'
			ELSE 'Onbekend'
			END)
	FROM empire_data.dbo.Staedion$Additioneel AS ADT
	INNER JOIN empire_data.dbo.Contact AS CON ON ADT.[Customer No_] = CON.[Customer No_]
	group by ADT.[Customer No_]
	)
SELECT
	CTE.Correspondentietype,
  Eenheidnr = C.[Eenheidnr_],
  Huurdernr = C.[Customer No_],
	Huurdernaam = C.Naam,
  Volgnummer = C.Volgnr_,
  Elementnr = E.[Nr_],
  Bedrag = E.[Bedrag (LV)],
  Eenmalig = E.Eenmalig,
  [Afwijking standaardprijs] = iif(CTE_ST.Wordt <> E.[Bedrag (LV)],'Afwijking',null ),
  [Status contractregel] = CASE WHEN C.[Status] = 0 THEN 'Nieuw' ELSE CASE WHEN   C.[Status] = 1 then 'Huidig' else 'Oud' END end,
  C.Ingangsdatum,
  Einddatum = nullif(C.Einddatum,'17530101'),
  [Einddatum contract] = nullif(ADT.Einddatum,'17530101')
FROM empire_data.dbo.[Staedion$Contract] AS C
INNER JOIN empire_data.dbo.[Staedion$Element] AS E
       ON C.[Eenheidnr_] = E.[Eenheidnr_]
              AND C.[Volgnr_] = E.[Volgnummer]
INNER JOIN empire_data.dbo.[Staedion$Oge] AS O
       ON C.Eenheidnr_ = O.[Nr_]
LEFT OUTER JOIN cte_staedion_brede_elementen AS CTE_ST
       ON CTE_ST.Element = E.Nr_
LEFT OUTER JOIN cte_correspondentie AS CTE ON CTE.Huurdernr = C.[Customer No_]
left join empire_data.dbo.Staedion$Additioneel AS ADT on
  ADT.[Customer No_] = C.[Customer No_] and
  ADT.Eenheidnr_ = C.Eenheidnr_
WHERE C.[Ingangsdatum] <= getdate()
       AND C.[Dummy Contract] = 0 -- JvdW 20200526 toegevoegd
       and e.nr_ IN (
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
