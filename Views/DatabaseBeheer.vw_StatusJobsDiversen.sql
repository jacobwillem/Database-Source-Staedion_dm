SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [DatabaseBeheer].[vw_StatusJobsDiversen] AS 


SELECT JOB.[id]
	,JOB.[Categorie]
	,JOB.[Omschrijving]
	,JOB.[Toelichting]
	,JOB.[Status]
	,JOB.[Tijdsduur in minuten]
	,JOB.[Meest recente tijdstip]
	--,JOB.[Laaddatum]
	,cast(JOB.[Meest recente tijdstip] as date) as Laaddatum
	--, IIF(Job.Laaddatum = (select max(Laaddatum) from staedion_Dm.Databasebeheer.StatusJobsDiversen),1,0) AS [Huidig]
	,IIF(datediff(d,JOB.[Meest recente tijdstip],getdate())=0, 1, 0) AS [Huidig]
	,DATEDIFF(d, JOB.[Meest recente tijdstip], GETDATE()) AS [Aantal dagen geleden]
	,CASE 
		WHEN JOB.Omschrijving IN (
				N'Goedkeuring en vervallen berichtitems verwijderen'
				,N'Rekening courant cumulatief'
				,N'Controle-waarden OGE-tabel'
				,N'Goedkeuringssamenvatting verzenden'
				,N'Connect-It Import Order'
				,N'Connect-It Import Hours'
				,N'Connect-It Import Used Articles'
				)
			THEN 'Lightgrey'
		WHEN JOB.[STATUS] NOT IN (
				'Klaar'
				,'Ok'
				)
			THEN '#FD625E' --red
		WHEN JOB.Categorie = 'Empire wachtrij'
			AND DATEDIFF(d, [Meest recente tijdstip], GETDATE()) > 7
			THEN '#0072FF'
		WHEN JOB.Categorie = 'SQL-agent-jobs dwh'
			AND DATEDIFF(d, [Meest recente tijdstip], GETDATE()) > 1
			THEN '#0072FF' --lichtblauw
		ELSE '#00FF27'
		END AS Signaleringskleur -- lichtgroen
		,row_number() over (partition by JOB.[Categorie], JOB.[Omschrijving] order by JOB.[Meest recente tijdstip] desc)  as [Volgnummer job]
	-- select max(Laaddatum) from staedion_Dm.Databasebeheer.StatusJobsDiversen
FROM staedion_Dm.Databasebeheer.StatusJobsDiversen AS JOB
--ORDER BY [Meest recente tijdstip] DESC
GO
