SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  FUNCTION [Projecten].[fn_VastgoedProjectenAppAantallen] (@Peildatum AS DATE)
RETURNS TABLE 
AS 
/* #########################################################################################################
volgt
######################################################################################################### */


RETURN

		--
SELECT   BASIS.[Project]
		,BASIS.[Peildatum]
		,BASIS.[Jaar]
		,BASIS.[FT-cluster]
		,BASIS.[Projectnummer]
		,BASIS.[Aantal]
		,BASIS.[AantalStart]
		,BASIS.[AantalOplevering]
		,BASIS.[Laaddatum]
		,BASIS.[TypeProject]
		,BASIS.[StartOplevering]
		,BASIS.[Projectmanager]
		,BASIS.[OmschrijvingStart]
		,BASIS.[Cum_Start]
		,BASIS.[Cum_Oplevering]
		,BASIS.[Aantal_regels]
		,BASIS.[Detail_01]
		,BASIS.[Detail_02]
		,BASIS.[Detail_03]
		,BASIS.[Detail_04]
		,BASIS.[Detail_05]
		,BASIS.[Detail_06]
		,BASIS.[Detail_07]
		,BASIS.[Detail_08]
		,BASIS.[Detail_09]
		,BASIS.[Detail_10]
		,COALESCE(BASIS.[AantalStart], 0) - COALESCE(BASIS.[AantalOplevering], 0) AS AantalStartMinusOplevering
		,iif(COALESCE(BASIS.[Cum_Start], 0) - COALESCE(BASIS.[Cum_Oplevering],0) < 0 
				, 0
				, COALESCE(BASIS.[Cum_Start], 0) - COALESCE(BASIS.[Cum_Oplevering],0)) AS AantalCumStartMinusOplevering
		,CASE 
			WHEN EOMONTH(BASIS.[Peildatum]) > @Peildatum
				THEN 'Prognose restant jaar'
			ELSE 'Realisatie dit jaar'
			END AS [Beschrijving aantal]
FROM [S-emp17-sql].[P-apps].[dbo].[vw_VastgoedProjectenAantallen] AS BASIS
GO
