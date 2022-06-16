SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Onderhoudscontracten].[vw_ICLM_TeFiatterenBudgetten] as 
/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Nog te fiatteren POCOS contractenmodule
Opgesteld door Said in overleg met Nicole van der Helm'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Onderhoudscontracten'
       ,@level1type = N'VIEW'
       ,@level1name = 'ICLM_TeFiatterenBudgetten';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220520 JvdW aangemaakt nav verzoek Nicole van der Helm: "*" vervangen door kolomnamen
"Said heeft voor mij 2 queries gemaakt waar ik gebruik van wil maken in een power BI rapportage.
De vraag of jij mij kan helpen om deze dat in de Bron BI ICLM bestand te krijgen.
Kan ik iets met jou inplannen om dit te regelen?"
> empire_data: Empire_data.dbo.[Staedion$Contract_Prolongation_Log]
> empire_data: Empire.dbo.[Staedion$Mutation Data Order Line]
--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
Declare @Nr as nvarchar(20) = 'COOH-210001'--POCO-2200048'
select * from Empire_data.dbo.[Staedion$Contract_Prolongation_Log] where [Contract No_] = @Nr
select * from Empire_data.dbo.[Staedion$Maintenance_Contract_Mutation]  where [Contract No_] = @Nr
select * from Empire_data.dbo.[Staedion$Mutation_Data_Contract] where [Maintenance Contract No_] = @Nr 
select * from Empire_data.dbo.[Staedion$Maintenance_Contract]  where No_ = @Nr 
select * from Empire_data.dbo.[Staedion$Mutation_Data_Order_Line] where  [Maintenance Contract No_] = @Nr 

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE  - zie hieronder
--------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################# */




SELECT sub4.Leverancier, sub4.Omschrijving, sub4.ContractNo, sub4.POCO, sub4.DirecteKostenNieuw, sub4.Indexering, sub4.BudgetLJ, sub4.NieuwBudget 
	,IIF(sub4.nieuwbudget > sub4.budgetlj, 'WAAR', 'ONWAAR') AS [BudgetOverschreden]
FROM (
	SELECT sub3.Leverancier AS [Leverancier]
		,sub3.Omschrijving
		,sub3.[Maintenance Contract No_] AS [ContractNo]
		,sub3.POCO
		,sub3.[Direct Unit Cost (New)] AS [DirecteKostenNieuw]
		,cast(sub3.[Percentage] AS DECIMAL(18, 2)) AS [Indexering]
		,cast(sub3.[budgetlj] AS DECIMAL(18, 2)) AS [BudgetLJ]
		,cast(sub3.[Direct Unit Cost (New)] * (1 + (sub3.[Percentage] / 100)) AS DECIMAL(18, 2)) AS [NieuwBudget]
	FROM (
		SELECT sub2.[Maintenance Contract No_], sub2.mdcid, sub2.[Omschrijving], sub2.[Leverancier],sub2.[Percentage], sub2.budgetid
			,sum(mdol.[Direct Unit Cost (New)]) AS [Direct Unit Cost (New)]
			,max(mdol.[Job No_]) AS [POCO]
			,(
				SELECT TOP 1 cast(replace(cast(('<X>' + replace([Description], '|', '</X><X>') + '</X>') AS XML).value('X[1]', 'nvarchar(20)'), ',', '.') AS MONEY) AS BudgetLJ
				-- select Description, cast(replace(cast(('<X>' + replace([Description], '|', '</X><X>') + '</X>') AS XML).value('X[1]', 'nvarchar(20)'), ',', '.') AS MONEY) AS BudgetLJ
				FROM Empire_data.dbo.[Staedion$Contract_Prolongation_Log]
				WHERE [entry no_] = sub2.budgetid
				) AS [BudgetLJ]
		--,(select [percentage] from [Staedion$Maintenance Contract Mutation] where [entry no_] = sub2.mdolid) as [Percentage]
		FROM (
			SELECT sub1.[Maintenance Contract No_], sub1.mdcid, sub1.[Omschrijving], sub1.[Leverancier]
				,(
					SELECT sum([Percentage])
					FROM  Empire_data.dbo.[Staedion$Maintenance_Contract_Mutation]
					WHERE [Contract No_] = sub1.[Maintenance Contract No_]
					) AS [Percentage]
				,(
					SELECT max([entry no_])
					FROM  Empire_data.dbo.[Staedion$Contract_Prolongation_Log]
					WHERE [Contract No_] = sub1.[Maintenance Contract No_]
						AND [type of comment] = 'CBUDJR'
					) AS [budgetid]
			FROM (
				SELECT max(mdc.[Maintenance Contract No_]) AS [Maintenance Contract No_]
					,max(mdc.[Entry No_]) AS mdcid
					,max(mdc.[Description]) AS [Omschrijving]
					,MAX(vend.[Name]) AS [Leverancier]
				FROM  Empire_data.dbo.[Staedion$Mutation_Data_Contract] mdc
				INNER JOIN  Empire_data.dbo.[Staedion$Maintenance_Contract] mc ON mdc.[Maintenance Contract No_] = mc.no_
				INNER JOIN  Empire_data.dbo.[vendor] vend ON mc.[vendor no_] = vend.no_
				WHERE mdc.[Approval Status] = 0
					AND mdc.[date] > DATEFROMPARTS(2022, 01, 01)
				GROUP BY mdc.[Maintenance Contract No_]
				) sub1
			) sub2
		INNER JOIN  Empire_data.dbo.[Staedion$Mutation_Data_Order_Line] mdol ON sub2.mdcid = mdol.[entry no_]
		GROUP BY sub2.[Maintenance Contract No_]
			,sub2.mdcid
			,sub2.Omschrijving
			,sub2.[Percentage]
			,sub2.Leverancier
			,sub2.budgetid
		) sub3
	) sub4


/* 
--------------------------------------------------------------------------------------------------------------------------------
Versie Said
--------------------------------------------------------------------------------------------------------------------------------
--View: Nog te fiateren POCOS contractenmodule
--View: ICLM_Te_fiatteren_budgetten
select sub4.*,
IIF(sub4.nieuwbudget > sub4.budgetlj,'WAAR','ONWAAR') as [BudgetOverschreden]
from (select 
sub3.Leverancier as [Leverancier],
sub3.Omschrijving,
sub3.[Maintenance Contract No_] as [ContractNo],
sub3.POCO,
sub3.[Direct Unit Cost (New)] as [DirecteKostenNieuw],
cast(sub3.[Percentage] as decimal(18,2)) as [Indexering],
cast(sub3.[budgetlj] as decimal(18,2)) as [BudgetLJ],
cast(sub3.[Direct Unit Cost (New)]*(1+(sub3.[Percentage]/100)) as decimal(18,2)) as [NieuwBudget]
from (select 
sub2.*
,sum(mdol.[Direct Unit Cost (New)]) as [Direct Unit Cost (New)]
,max(mdol.[Job No_]) as [POCO]
,(select top 1 cast(replace(cast(('<X>'+replace([Description],'|' ,'</X><X>')+'</X>') as xml).value('X[1]','nvarchar(20)'),',','.') as money) as BudgetLJ from [Staedion$Contract Prolongation Log] where [entry no_] = sub2.budgetid) as [BudgetLJ]
--,(select [percentage] from [Staedion$Maintenance Contract Mutation] where [entry no_] = sub2.mdolid) as [Percentage]
from (select sub1.*
,(select sum([Percentage]) from [Staedion$Maintenance Contract Mutation] where [Contract No_] = sub1.[Maintenance Contract No_]) as [Percentage]
,(select max([entry no_]) from [Staedion$Contract Prolongation Log] where [Contract No_] = sub1.[Maintenance Contract No_] and [type of comment] = 'CBUDJR') as [budgetid]
from (select 
max(mdc.[Maintenance Contract No_]) as [Maintenance Contract No_],
max(mdc.[Entry No_]) as mdcid,
max(mdc.[Description]) as [Omschrijving],
MAX(vend.[Name]) as [Leverancier]
from 
[Staedion$Mutation Data Contract] mdc
inner join [Staedion$Maintenance Contract] mc on mdc.[Maintenance Contract No_] = mc.no_
inner join [vendor] vend on mc.[vendor no_] = vend.no_
where mdc.[Approval Status] = 0 and mdc.[date] > DATEFROMPARTS(2022,01,01) group by mdc.[Maintenance Contract No_]) sub1
) sub2
inner join [Staedion$Mutation Data Order Line] mdol on sub2.mdcid = mdol.[entry no_]
group by sub2.[Maintenance Contract No_], sub2.mdcid,sub2.Omschrijving, sub2.[Percentage], sub2.Leverancier, sub2.budgetid) sub3) sub4

--------------------------------------------------------------------------------------------------------------------------------
Versie obv logshipping omgeving - zie db project EmpireRapportage
--------------------------------------------------------------------------------------------------------------------------------



*/
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nog te fiatteren POCOS contractenmodule
Opgesteld door Said in overleg met Nicole van der Helm', 'SCHEMA', N'Onderhoudscontracten', 'VIEW', N'vw_ICLM_TeFiatterenBudgetten', NULL, NULL
GO
