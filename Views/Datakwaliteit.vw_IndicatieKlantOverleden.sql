SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Datakwaliteit].[vw_IndicatieKlantOverleden] 
AS 
/* ########################################################################################################
Test opzet ter controle registratie huurder is overleden - gezien aanhefcode dan wel veld overlijdensdatum

CONTROLE: accuratesse: Is er een indicatie dat hoofdhuurder van de actieve huurders (actief contract dan wel saldo) is overleden gezien aanhefcode of veld overlijdensdatum
BRON: staedion_dm.[Datakwaliteit].[vw_IndicatieKlantOverleden] 

SELECT	* 
FROM	[Datakwaliteit].[vw_IndicatieKlantOverleden]  
WHERE	[Controle-bevinding] IS NOT null
order by [Controle-bevinding], Klantnr
------------------------------------------------------------------------------------------------------------
WIJZIGINGEN
------------------------------------------------------------------------------------------------------------
20210929 JvdW Aanzet na overleg met Marieke Peeters
NOG DOEN: ombouwen van empire_staedion_data.[dbo].ITVfnContractaanhef(HPR.huurdernr)
naar  staedion_dm.Klant.fn_Contractaanhef(huurdernr)
######################################################################################################## */

WITH cte_actieve_huurderset
AS
(SELECT
		Klantnr
	   ,Peildatum
	   ,Huishoudnr
	   ,Laaddatum
	   ,[Actief huurcontract]
	--SELECT TOP 10 *
	FROM staedion_dm.Datakwaliteit.SetHuurdersTeChecken)
SELECT
	CTE.Klantnr
   ,CTE.Peildatum
   ,CTE.Huishoudnr
   ,CTE.Laaddatum
   ,CTE.[Actief huurcontract]
   ,[Rol] = ROL.[Role Code]
   ,[Toon als eerste (contractrol)] = ROL.[Show first]
   ,HRD.[Indicatie overleden]
   ,HRD.Overlijdensdatum
   ,[Aanhef brief] = HRD.huurder1
   ,[Aanhefcode hoofdhuurder] = HRD.aanhefcode1
   ,[Controle-bevinding] =
	CASE
		WHEN HRD.Overlijdensdatum <> '17530101' AND
			HRD.aanhefcode1 NOT LIKE 'ERV%' AND CTE.[Actief huurcontract] = 1  THEN 'PRIO 1: wel datum overlijden geen aanhefcode ERVENVAN + actief huurcontract'
		ELSE CASE
		WHEN HRD.Overlijdensdatum <> '17530101' AND
			HRD.aanhefcode1 NOT LIKE 'ERV%'   THEN 'PRIO 2: wel datum overlijden geen aanhefcode ERVENVAN maar geen huurcontract, wel bijv saldo'

		ELSE CASE
				WHEN HRD.Overlijdensdatum = '17530101' AND
					HRD.aanhefcode1 LIKE 'ERV%' THEN 'PRIO 3: Geen datum overlijden wel aanhefcode ERVENVAN'
			END
	END END

FROM cte_actieve_huurderset AS CTE
LEFT OUTER JOIN empire_data.dbo.Customer AS CUST
	ON CUST.No_ = CTE.Klantnr
LEFT OUTER JOIN empire_data.dbo.Contact AS CONT
	ON CTE.Huishoudnr = CONT.No_
LEFT OUTER JOIN empire_data.dbo.Contact_Role AS ROL
	ON CUST.[contact no_] = ROL.[Related Contact No_]
		AND ROL.[Show first] = 1
OUTER APPLY empire_staedion_data.[dbo].ITVfnContractaanhef(CTE.Klantnr) AS HRD
WHERE HRD.[Indicatie overleden] = 'Ja'
--AND CTE.Klantnr = 'KLNT-0061768'
GO
