SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Onderhoudscontracten].[vw_ICLM_BudgettenPerJaar] as 
/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Nog te fiatteren POCOS contractenmodule
Opgesteld door Said in overleg met Nicole van der Helm:
Voor alle contracten vanaf COOH-20 de budgetten per jaar -
Jaarlijkse budgetten op basis van alle contracten die groter zijn dan COOH-20. 
Einddatum en status levert geen schone lijst op omdat contracten uit het verleden niet zijn afgesloten
'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Onderhoudscontracten'
       ,@level1type = N'VIEW'
       ,@level1name = 'ICLM_BudgettenPerJaar';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220520 JvdW aangemaakt nav verzoek Nicole van der Helm: "*" vervangen door kolomnamen
"Said heeft voor mij 2 queries gemaakt waar ik gebruik van wil maken in een power BI rapportage.
De vraag of jij mij kan helpen om deze dat in de Bron BI ICLM bestand te krijgen.
Kan ik iets met jou inplannen om dit te regelen?"

--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE  - zie hieronder
--------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################# */
SELECT mc.No_ AS [ContractNo]
	,cast(('<X>' + replace(cpl.[Description], '|', '</X><X>') + '</X>') AS XML).value('X[2]', 'int') AS BudgetJaar
	,cast(replace(cast(('<X>' + replace(cpl.[Description], '|', '</X><X>') + '</X>') AS XML).value('X[1]', 'nvarchar(20)'), ',', '.') AS MONEY) AS BudgetBedrag
FROM Empire_data.dbo.[Staedion$Maintenance_Contract] mc
LEFT JOIN Empire_data.dbo.[Staedion$Contract_Prolongation_Log] cpl ON mc.no_ = cpl.[Contract No_]
	AND cpl.[type of comment] = 'CBUDJR'
WHERE [No_] > 'COOH-20'


/* 
--------------------------------------------------------------------------------------------------------------------------------
Versie Said
--------------------------------------------------------------------------------------------------------------------------------
View: ICLM_Budgetten_per_jaar

Voor alle contracten vanaf COOH-20 de budgetten per jaar -

Jaarlijkse budgetten op basis van alle contracten die groter zijn dan 'COOH-20'. 
Einddatum en status levert geen schone lijst op omdat contracten uit het verleden niet zijn afgesloten
select mc.No_ as [ContractNo],
cast(('<X>'+replace(cpl.[Description],'|' ,'</X><X>')+'</X>') as xml).value('X[2]','int') as BudgetJaar,
cast(replace(cast(('<X>'+replace(cpl.[Description],'|' ,'</X><X>')+'</X>') as xml).value('X[1]','nvarchar(20)'),',','.') as money) as BudgetBedrag
from 
[Staedion$Maintenance Contract] mc
left join [Staedion$Contract Prolongation Log] cpl on mc.no_ = cpl.[Contract No_] and cpl.[type of comment] = 'CBUDJR'
where [No_] > 'COOH-20'


*/
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nog te fiatteren POCOS contractenmodule
Opgesteld door Said in overleg met Nicole van der Helm:
Voor alle contracten vanaf COOH-20 de budgetten per jaar -
Jaarlijkse budgetten op basis van alle contracten die groter zijn dan COOH-20. 
Einddatum en status levert geen schone lijst op omdat contracten uit het verleden niet zijn afgesloten
', 'SCHEMA', N'Onderhoudscontracten', 'VIEW', N'vw_ICLM_BudgettenPerJaar', NULL, NULL
GO
