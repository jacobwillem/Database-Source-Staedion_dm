SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Datakwaliteit].[vw_EmpireProjectBudgethouders] AS 
/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Check op niet-vervallen projecten (zonder verwijziging naar budgethouders die volgens Visma uit dienst zijn)
Deze zullen beoordeeld en vervangen moeten worden door juiste budgethouder
Status: test-opzet af te stemmen met aanvrager Marieke
ZIE: Topdesk W 29090
'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Datakwaliteit'
       ,@level1type = N'VIEW'
       ,@level1name = 'vw_EmpireProjectBudgethouders';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220318 Marieke Peeters


--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------
############################################################################################################################# */

SELECT	 Projectnr = P.Nr_,
           P.Naam,
           Soort = CASE BH.Soort
                       WHEN 0 THEN
                           '0 = Order'
                       WHEN 1 THEN
                           '1 = Inkoopfactuur'
                       WHEN 2 THEN
                           '2 = Verkoop'
                   END
		   , BH.Budgethouder
		   , BH.[Budgetregelnr_ ] AS [Budgetregelnr]
		   , BH.Volgorde,
           [Actief project] = P.Active,                                                 -- Project.actief = Ja
           [Geblokkeerd project] = P.[Geblokkeerd],                                     -- Project.Geblokkeerd = Nee
           [Status project] = P.[Status] + COALESCE(' (' + EPS.Omschrijving + ')', '')
		   ,P.Projectfase
           --Inkoopfactuurbudgethouder = IIF(BH.Soort = 1, BH.Budgethouder, NULL),
           --[Volgorde Inkoopfactuurbudgethouder] = IIF(BH.Soort = 1, BH.Volgorde, NULL), -- max 5
           --Orderbudgethouder = IIF(BH.Soort = 0, BH.Budgethouder, NULL),
           --[Volgorde Orderbudgethouder] = IIF(BH.Soort = 0, BH.Volgorde, NULL),         -- max 8
           --Verkoopbudgethouder = IIF(BH.Soort = 2, BH.Budgethouder, NULL),
           --[Volgorde Verkoopbudgethouder] = IIF(BH.Soort = 2, BH.Volgorde, NULL)        -- max 8
		   --select *
    FROM empire_data.dbo.[staedion$Empire_Project_budgethouder] AS BH
        JOIN empire_data.dbo.[Staedion$Empire_Project] AS P
            ON P.Nr_ = BH.Projectnr_
        LEFT OUTER JOIN empire_data.dbo.[Staedion$Empire_Projectstatus] AS EPS
            ON EPS.[Code] = P.[Status]
    WHERE BH.[Budgetregelnr_ ] = 0
          AND P.[Status] <> 'VERV'
;
GO
EXEC sp_addextendedproperty N'MS_Description', N'Check op niet-vervallen projecten (zonder verwijziging naar budgethouders die volgens Visma uit dienst zijn)
Deze zullen beoordeeld en vervangen moeten worden door juiste budgethouder
Status: test-opzet af te stemmen met aanvrager Marieke
ZIE: Topdesk W 29090
', 'SCHEMA', N'Datakwaliteit', 'VIEW', N'vw_EmpireProjectBudgethouders', NULL, NULL
GO
