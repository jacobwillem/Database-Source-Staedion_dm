SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Datakwaliteit].[vw_EmpireProjectBudgethouderUitDienst] AS 
/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Check op niet-vervallen projecten met een verwijziging naar budgethouders die volgens Visma uit dienst zijn
Deze zullen beoordeeld en vervangen moeten worden door juiste budgethouder
Status: test-opzet af te stemmen met aanvrager Marieke
ZIE: Topdesk W 29090
'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Datakwaliteit'
       ,@level1type = N'VIEW'
       ,@level1name = 'vw_EmpireProjectBudgethouderUitDienst';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
<JJJJMMDD> <Initialen> <Toelichting>


--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------
WITH cte_basis AS 
(SELECT Projectnr = P.Nr_,
       P.Naam,
       Soort = CASE BH.Soort
                   WHEN 0 THEN
                       'Order'
                   WHEN 1 THEN
                       'Factuur'
                   WHEN 2 THEN
                       'Verkoop'
               END,
       [Actief project] = P.Active,             --Project.actief = Ja
       [Beblokkeerd project] = P.[Geblokkeerd], -- Project.Geblokkeerd = Nee
       [Status project] = P.[Status] + COALESCE(' (' + EPS.Omschrijving + ')', ''),
       Inkoopfactuurbudgethouder = IIF(BH.Soort = 1, BH.Budgethouder, NULL),					
       [Volgorde Inkoopfactuurbudgethouder] = IIF(BH.Soort = 1, BH.Volgorde, NULL),				-- max 5
       Orderbudgethouder = IIF(BH.Soort = 0, BH.Budgethouder, NULL),
       [Volgorde Orderbudgethouder] = IIF(BH.Soort = 0, BH.Volgorde, NULL),						-- max 8
       Verkoopbudgethouder = IIF(BH.Soort = 2, BH.Budgethouder, NULL),
       [Volgorde Verkoopbudgethouder] = IIF(BH.Soort = 2, BH.Volgorde, NULL)					-- max 8
FROM empire_data.dbo.[staedion$Empire_Project_budgethouder] AS BH
    JOIN empire_data.dbo.[Staedion$Empire_Project] AS P
        ON P.Nr_ = BH.Projectnr_
    LEFT OUTER JOIN empire_data.dbo.[Staedion$Empire_Projectstatus] AS EPS
        ON EPS.[Code] = P.[Status]
WHERE BH.[Budgetregelnr_ ] = 0
AND P.[Status] <> 'VERV'
AND P.Nr_ = '4012400364'
) ,
cte_visma_uitdienst AS (SELECT DISTINCT inlognaam
FROM ts_data.visma.vault_werknemers 
WHERE (contract_end IS NOT NULL AND contract_end <= GETDATE())
)
SELECT CTE.Projectnr,
       CTE.Naam,
       CTE.Soort,
       CTE.[Actief project],
       CTE.[Beblokkeerd project],
       CTE.[Status project],
       Inkoopfactuurbudgethouders = STRING_AGG(CAST(CTE.[Volgorde Inkoopfactuurbudgethouder] AS NVARCHAR(2))+ ': '+CTE.[Inkoopfactuurbudgethouder],'> ') WITHIN GROUP (ORDER BY CTE.[Volgorde Inkoopfactuurbudgethouder])
-- gaat niet in 1 keer zo
--	   ,Orderbudgethouder = STRING_AGG(CAST(CTE.[Volgorde Orderbudgethouder] AS NVARCHAR(2))+ ': '+CTE.[Orderbudgethouder],'> ') WITHIN GROUP (ORDER BY CTE.[Volgorde Orderbudgethouder])
--	   ,Verkoopbudgethouder = STRING_AGG(CAST(CTE.[Volgorde Verkoopbudgethouder] AS NVARCHAR(2))+ ': '+CTE.[Verkoopbudgethouder],'> ') WITHIN GROUP (ORDER BY CTE.[Volgorde Verkoopbudgethouder])
FROM cte_basis AS CTE
WHERE [Inkoopfactuurbudgethouder] IN (SELECT inlognaam FROM cte_visma_uitdienst)
OR Orderbudgethouder IN (SELECT inlognaam FROM cte_visma_uitdienst)
OR Verkoopbudgethouder IN (SELECT inlognaam FROM cte_visma_uitdienst)
GROUP BY CTE.Projectnr,
       CTE.Naam,
       CTE.Soort,
       CTE.[Actief project],
       CTE.[Beblokkeerd project],
       CTE.[Status project]
;
############################################################################################################################# */


-- opzet met alle detailregels
WITH cte_basis
AS (SELECT Projectnr = P.Nr_,
           P.Naam,
           --Soort = CASE BH.Soort
           --            WHEN 0 THEN
           --                'Order'
           --            WHEN 1 THEN
           --                'Factuur'
           --            WHEN 2 THEN
           --                'Verkoop'
           --        END,
           [Actief project] = P.Active,                                                 -- Project.actief = Ja
           [Beblokkeerd project] = P.[Geblokkeerd],                                     -- Project.Geblokkeerd = Nee
           [Status project] = P.[Status] + COALESCE(' (' + EPS.Omschrijving + ')', ''),
           Inkoopfactuurbudgethouder = IIF(BH.Soort = 1, BH.Budgethouder, NULL),
           [Volgorde Inkoopfactuurbudgethouder] = IIF(BH.Soort = 1, BH.Volgorde, NULL), -- max 5
           Orderbudgethouder = IIF(BH.Soort = 0, BH.Budgethouder, NULL),
           [Volgorde Orderbudgethouder] = IIF(BH.Soort = 0, BH.Volgorde, NULL),         -- max 8
           Verkoopbudgethouder = IIF(BH.Soort = 2, BH.Budgethouder, NULL),
           [Volgorde Verkoopbudgethouder] = IIF(BH.Soort = 2, BH.Volgorde, NULL)        -- max 8
    FROM empire_data.dbo.[staedion$Empire_Project_budgethouder] AS BH
        JOIN empire_data.dbo.[Staedion$Empire_Project] AS P
            ON P.Nr_ = BH.Projectnr_
        LEFT OUTER JOIN empire_data.dbo.[Staedion$Empire_Projectstatus] AS EPS
            ON EPS.[Code] = P.[Status]
    WHERE BH.[Budgetregelnr_ ] = 0
          AND P.[Status] <> 'VERV'),
     cte_visma_uitdienst
AS (SELECT DISTINCT
           inlognaam,
           [volledige_naam],
           contract_end
    FROM TS_data.visma.vault_werknemers
    WHERE (
              contract_end IS NOT NULL
              AND contract_end <= GETDATE()
          ))
SELECT CTE.Projectnr,
       CTE.Naam,
       --CTE.Soort,
       CTE.[Actief project],
       CTE.[Beblokkeerd project],
       CTE.[Status project],
       COALESCE(CTE.Inkoopfactuurbudgethouder,'') AS Inkoopfactuurbudgethouder,
       COALESCE(CTE.[Volgorde Inkoopfactuurbudgethouder],'') AS [Volgorde Inkoopfactuurbudgethouder],
	   IIF(CTE_V1.inlognaam IS NOT NULL, 'Visma inlognaam = ' + CTE_V1.volledige_naam + ' - uit dienst: '+ CONVERT(NVARCHAR(20),CTE_V1.contract_end ,105),'') AS [Opmerking Inkoopfactuurbudgethouder],
       COALESCE(CTE.Orderbudgethouder,'') AS Orderbudgethouder,
       COALESCE(CTE.[Volgorde Orderbudgethouder],'') AS [Volgorde Orderbudgethouder],
	   IIF(CTE_V2.inlognaam IS NOT NULL, 'Visma inlognaam = ' + CTE_V2.volledige_naam + ' - uit dienst: '+ CONVERT(NVARCHAR(20),CTE_V2.contract_end ,105),'') AS [Opmerking Orderbudgethouder],
       COALESCE(CTE.Verkoopbudgethouder,'') AS Verkoopbudgethouder,
       COALESCE(CTE.[Volgorde Verkoopbudgethouder],'') AS [Volgorde Verkoopbudgethouder],
	   IIF(CTE_V3.inlognaam IS NOT NULL, 'Visma inlognaam = ' + CTE_V3.volledige_naam + ' - uit dienst: '+ CONVERT(NVARCHAR(20),CTE_V3.contract_end ,105),'') AS [Opmerking Verkoopbudgethouder],
	   CAST(GETDATE() AS DATE) AS Gegenereerd
FROM cte_basis AS CTE
    LEFT OUTER JOIN cte_visma_uitdienst AS CTE_V1
        ON CTE_V1.inlognaam = CTE.Inkoopfactuurbudgethouder
    LEFT OUTER JOIN cte_visma_uitdienst AS CTE_V2
        ON CTE_V2.inlognaam = CTE.Orderbudgethouder
    LEFT OUTER JOIN cte_visma_uitdienst AS CTE_V3
        ON CTE_V3.inlognaam = CTE.Verkoopbudgethouder
WHERE CTE_V1.inlognaam IS NOT NULL
      OR CTE_V2.inlognaam IS NOT NULL
      OR CTE_V3.inlognaam IS NOT NULL;
GO
