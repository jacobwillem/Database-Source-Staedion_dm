SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE view [Onderhoudscontracten].[vw_WijzigingslogboekMutatiegegevensEenheid] as 

/* #############################################################################################################################
EXEC sys.sp_addextendedproperty @name = N'MS_Description'
       ,@value = N'Haalt wijzigingen op uit het wijzigingslogboek met betrekking tot wijzigen voor veld prolongeren - vinkje aan/uit zetten.
In logboek is eenheidnr niet direct terug te vinden. 
Zie bestaand rapport Bron ICM, huidige gekoppelde eenheden zie je terug in view [Contracten].[vw_OnderhoudscontractenEenheden]'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Onderhoudscontracten'
       ,@level1type = N'VIEW'
       ,@level1name = 'vw_WijzigingslogboekMutatiegegevensEenheid';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20220303 JvdW aangemaakt, zie Topdesk 21 12 791


--------------------------------------------------------------------------------------------------------------------------------
TESTEN
--------------------------------------------------------------------------------------------------------------------------------
select * from staedion_dm.Onderhoudscontracten.vw_WijzigingslogboekMutatiegegevensEenheid
;

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------
Onderhoudscontractnr COOH-210001	-- Maintenance Contract
volgnr 34							-- Mutation Data Contract
POCO-2100010						-- Mutation Data Budget 
x aantal eenheden					-- Mutation Data Realty Object
Mutation Data Order Line 

volgnr 41							-- Mutation Data Contract
POCO-2200045						-- Mutation Data Budget 
x aantal eenheden					-- Mutation Data Realty Object
Mutation Data Order Line	

############################################################################################################################# */

with cte_wijzigingslogboek as 
(SELECT [Date and Time] as Tijdstip
		,[User ID] collate database_default AS Gebruiker
		,CASE 
			WHEN [Field No_] = 14
				AND [New value] = 'false'
				THEN [Date and Time]
			END AS [Prolongatie uitgezet]
		,CASE 
			WHEN [Field No_] = 14
				AND [New value] = 'true'
				THEN [Date and Time]
			END AS [Prolongatie aangezet]
		,CASE 
			WHEN [Field No_] = 14
				AND [New value] = 'false'
				THEN [User ID]
			END AS [Prolongatie uitgezet door]
		,CASE 
			WHEN [Field No_] = 14
				AND [New value] = 'true'
				THEN [User ID]
			END AS [Prolongatie aangezet door]
		,[Primary Key Field 1 Value] collate database_default AS Onderhoudscontractnr
		,[Primary Key Field 2 Value] AS [Entry No_]
		,[Primary Key Field 3 Value] AS [MDB Line No_]
		,replace(substring([Primary Key], patindex('%Field4=0(%', [Primary Key]) + 9, len([Primary Key])), ')', '') AS [Line No_]
		,[Primary Key]
		,convert(NVARCHAR(20), NULL) collate database_default AS EenheidOfCollectiefnr
	FROM [S-LOGSH-PROD].empire.dbo.[staedion$change log entry]
	WHERE [Table No_] = '11030603'
	and [Field No_] = 14
	--and [Type of Change] = 1		-- 1 staat voor wijzigingen, maar regels verwijderd en toevoegen wil je ook zien
) 
select CLE.Onderhoudscontractnr, EMPIRE.[Realty Object No_] as EenheidCollectiefNr, EMPIRE.[Prolong] as [Actuele waarde prolongeren], CLE.Tijdstip, CLE.[Prolongatie uitgezet], CLE.[Prolongatie aangezet]
	FROM cte_wijzigingslogboek AS CLE
	JOIN [S-LOGSH-PROD].empire.dbo.[Staedion$Mutation Data Realty Object] AS EMPIRE ON EMPIRE.[Maintenance Contract No_] collate database_default = CLE.Onderhoudscontractnr collate database_default
		AND EMPIRE.[Entry No_] = CLE.[Entry No_]
		AND EMPIRE.[MDB Line No_] = CLE.[MDB Line No_]
		AND EMPIRE.[Line No_] = CLE.[Line No_];


GO
EXEC sp_addextendedproperty N'MS_Description', N'Haalt wijzigingen op uit het wijzigingslogboek met betrekking tot wijzigen voor veld prolongeren - vinkje aan/uit zetten.
In logboek is eenheidnr niet direct terug te vinden. 
Zie bestaand rapport Bron ICM, huidige gekoppelde eenheden zie je terug in view [Contracten].[vw_OnderhoudscontractenEenheden]', 'SCHEMA', N'Onderhoudscontracten', 'VIEW', N'vw_WijzigingslogboekMutatiegegevensEenheid', NULL, NULL
GO
