SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Projecten].[VerplichtingStatus]
AS
WITH cte
AS (
	SELECT [Project No_]
		,[Name]
		,ROW_NUMBER() OVER (
			PARTITION BY [Project No_] ORDER BY [Priority] ASC
			) AS Row#
	FROM empire_data.dbo.Staedion$Empire_Project_Contact_Person
	WHERE [Line No_] = 0
		AND [Job Responsibility Code] = 'PM'
	)
	,cte2
AS (
	SELECT [Project No_]
		,Projectmanager = STRING_AGG([Name], '; ')
	FROM cte
	GROUP BY [Project No_]
	)
SELECT id = VPL.[id]
	,PRJ.Nr_
	,VPL.[Document No_]
	,VPL.Inkoopregelnr_
	,BDR.Budgetregelnr_
	,Projectmanager = coalesce(PM.Projectmanager, '[Onbekend, nvt]')
	,[Datum] = BDR.Invoerdatum
	,[BudRegStatus] = CASE 
		WHEN BDR.[Status] = 6
			THEN 'Vrijgegeven'
		WHEN BDR.[Status] = 7
			THEN 'Gegund'
		WHEN BDR.[Status] = 8
			THEN 'Gereed'
		WHEN BDR.[Status] = 9
			THEN 'Afgehandeld'
		ELSE '[Onbekend, nvt]'
		END
	,[Orderstatus] = CASE 
		WHEN PUR.[Status] = 0
			THEN 'Open'
		WHEN PUR.[Status] = 1
			THEN 'Vrijgegeven'
		WHEN PUR.[Status] = 2
			THEN 'Wacht op goedkeuring'
		ELSE '[Onbekend, nvt]'
		END
FROM [empire_staedion_data].[project].[Verplichting] AS VPL
JOIN [empire_data].[dbo].[Staedion$Empire_Projectbudg_det_regel] AS BDR ON VPL.[Document No_] = BDR.Nr_
	AND VPL.Inkoopregelnr_ = BDR.Inkoopregelnr_
LEFT OUTER JOIN empire_data.dbo.Staedion$Purchase_Header AS PUR ON VPL.[Document No_] = PUR.[No_]
LEFT OUTER JOIN [empire_staedion_data].[project].Project AS PRJ ON PRJ.id = VPL.Project_id
LEFT OUTER JOIN cte2 AS PM ON PRJ.Nr_ = PM.[Project No_]
WHERE cast(VPL.peildatum AS DATE) = datefromparts(2021, 3, 31)
	--(SELECT max(peildatum)
	--FROM [empire_staedion_data].[project].[Verplichting])
GO
