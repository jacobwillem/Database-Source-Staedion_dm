SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  view [Datakwaliteit].[vw_Realisatie]
AS
SELECT I.id_samengesteld
	   ,Entiteit = I_parent.Omschrijving
       ,Attribuut = I.Omschrijving
       ,[Controle onderwerp] = DIM.Vertaling
       ,Datum = R.[Laaddatum]
       ,[Toelichting] = R.[Omschrijving]
       ,R.[fk_indicator_id]
       ,R.[Teller]
       ,R.[Noemer]
			 ,R.Omschrijving
			 ,R.Waarde
       ,[Ontbrekend] = R.Noemer - R.Teller
       ,I.Procedure_completeness
FROM Datakwaliteit.Realisatie AS R
JOIN Datakwaliteit.[Indicator] AS I
       ON I.id_samengesteld = R.id_samengesteld
JOIN Datakwaliteit.[Indicator] AS I_parent
       ON I_parent.[id] = I.parent_id
JOIN [staedion_dm].[Datakwaliteit].Indicatordimensie AS DIM
       ON DIM.id = R.fk_indicatordimensie_id
WHERE I.[Zichtbaar] = 1



GO
