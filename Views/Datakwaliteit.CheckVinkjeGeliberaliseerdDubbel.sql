SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











CREATE VIEW [Datakwaliteit].[CheckVinkjeGeliberaliseerdDubbel]
AS
/*

*/
SELECT Eenheidnr = Eenheidnr_
	,Huurdernr = [Customer No_]
	,[Einddatum contract] = coalesce((
		SELECT format(nullif([Einddatum],'17530101'),'dd-MM-yyyy', 'nl-NL')
		FROM empire_data.dbo.[Staedion$Additioneel] AD
		WHERE AD.Eenheidnr_ = CO.Eenheidnr_
			AND AD.[Customer No_] = CO.[Customer No_]
		), 'Geen einddatum')
FROM empire_Data.dbo.staedion$contract AS CO
WHERE [Dummy Contract] = 0
	--and Eenheidnr_ = 'OGEH-0036708'
	AND [Customer No_] <> ''
	AND NOT EXISTS (
		SELECT 1
		FROM empire_data.dbo.[Staedion$Additioneel] AD
		WHERE AD.Eenheidnr_ = CO.Eenheidnr_
			AND AD.[Customer No_] = CO.[Customer No_]
			AND coalesce(nullif(AD.[Einddatum], '17530101'), '20990101') < eomonth(dateadd(m,-13,getdate()))
		)
	-- Deze huurder heeft inderdaad 2 verschillende contractvormen als dit via whitelisting uitgezonderd kan worden - dan kan deze conditie er weer uit
	and NOT(CO.[Customer No_] = 'KLNT-0083585' 
	        and CO.Eenheidnr_ = 'OGEH-0055217')

GROUP BY Eenheidnr_
	,[Customer No_]
HAVING count(DISTINCT [Huurprijsliberalisatie]) > 1
GO
