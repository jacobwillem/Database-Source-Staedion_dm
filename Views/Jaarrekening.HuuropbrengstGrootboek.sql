SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Jaarrekening].[HuuropbrengstGrootboek]
AS
SELECT Boekdatum = GLE.[Posting Date]
	,Eenheidnummer = OGE.[Realty Object No_]
	,Rekeningnummer = GLE.[G_L Account No_]
	,Rekeningnaam = GLA.NAME
	,Broncode = GLE.[Source Code]
	,Geboekt = GLE.Amount
	,Omschrijving = GLE.[Description]
FROM empire_data.dbo.Staedion$G_L_Entry AS GLE
JOIN empire_Data.dbo.[Staedion$G_L_Account] AS GLA ON GLA.No_ = GLE.[G_L Account No_]
LEFT OUTER JOIN empire_Data.dbo.Staedion$G_L_Entry___Additional_Data AS OGE ON OGE.[G_L Entry No_] = GLE.[Entry No_]
WHERE GLE.[G_L Account No_] IN (
		'A810200'
		,'A850150'
		,'A810450'
		,'A810500'
		)
	AND GLE.[Posting Date] >= DATEFROMPARTS(YEAR(getdate()) - 2, 12, 01)
	AND GLE.Amount <> 0
GO
