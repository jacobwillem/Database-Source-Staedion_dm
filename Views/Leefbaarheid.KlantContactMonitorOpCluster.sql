SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Leefbaarheid].[KlantContactMonitorOpCluster]
AS
WITH KCM
AS (
	SELECT Clusternr
		,Jaar = 2020
		,AantalRespondenten = COUNT([Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi])
		,KCMThuisgevoel = avg([Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi])
		,KCMTevredenheidWoning = avg([Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa])
		,KCMTevredenheidAlgemeneRuimte = avg([Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron])
		,KCMTevredenheidBuurt = avg([Welk rapportcijfer geeft u voor uw buurt? Een 1 staat hier voor ])
		,KCMCijfer = avg(iif([Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron] IS NOT NULL, ([Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi] + [Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa] + [Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron] + [Welk rapportcijfer geeft u voor uw buurt? Een 1 staat hier voor ]) / 4, ([Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi] + [Welk cijfer geeft u voor de kwaliteit van uw woning?Â Een 1 staa] + [Welk rapportcijfer geeft u voor uw buurt? Een 1 staat hier voor ]) / 3))
	FROM [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2020] AS KCM20
	WHERE Clusternr IS NOT NULL
	GROUP BY Clusternr
	
	--UNION ALL
	
	--SELECT CLBU.BuurtCode
	--	,Jaar = year([INGEVULDE GEGEVENS])
	--	,AantalRespondenten = COUNT([Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi])
	--	,KCMThuisgevoel = avg([Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi])
	--	,KCMTevredenheidWoning = avg([Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat])
	--	,KCMTevredenheidAlgemeneRuimte = avg([Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron])
	--	,KCMTevredenheidBuurt = avg([Welk rapportcijfer geeft u uw buurt? Een 1 staat hier voor zeer ])
	--	,KCMCijfer = avg(iif([Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron] IS NOT NULL, ([Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi] + [Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat] + [Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron] + [Welk rapportcijfer geeft u uw buurt? Een 1 staat hier voor zeer ]) / 4, ([Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi] + [Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat] + [Welk rapportcijfer geeft u uw buurt? Een 1 staat hier voor zeer ]) / 3))
	--FROM [empire_staedion_data].[bik].[STN661_Ingevulde_gegevens_2019] AS KCM19
	--LEFT OUTER JOIN empire_staedion_data.bik.ELS_ClusternummerBuurtCode AS CLBU ON KCM19.Clusternr = CLBU.Clusternummer
	--WHERE Clusternr IS NOT NULL
	--GROUP BY CLBU.BuurtCode
	--	,year([INGEVULDE GEGEVENS])

	UNION ALL
	
	SELECT Clusternr
		,Jaar = 2019
		,AantalRespondenten = COUNT([Thuisgevoel])
		,KCMThuisgevoel = avg([Thuisgevoel])
		,KCMTevredenheidWoning = avg([Kwaliteit woning])
		,KCMTevredenheidAlgemeneRuimte = avg([Algemene ruimte rapportcijfer])
		,KCMTevredenheidBuurt = avg([Buurt rapportcijfer])
		,KCMCijfer = avg(iif([Algemene ruimte rapportcijfer] IS NOT NULL, ([Thuisgevoel] + [Kwaliteit woning] + [Algemene ruimte rapportcijfer] + [Buurt rapportcijfer]) / 4, ([Thuisgevoel] + [Kwaliteit woning] + [Buurt rapportcijfer]) / 3))
	FROM [empire_staedion_data].[bik].KCM_BIK2020_Thuisgevoel_jan2019_jan2020 AS KCM19
	WHERE Clusternr IS NOT NULL
	GROUP BY Clusternr

	UNION ALL
	
	SELECT Clusternr
		,Jaar = 2018
		,AantalRespondenten = COUNT([Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi])
		,KCMThuisgevoel = avg([Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi])
		,KCMTevredenheidWoning = avg([Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat])
		,KCMTevredenheidAlgemeneRuimte = avg([Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron])
		,KCMTevredenheidBuurt = avg([Welk rapportcijfer geeft u uw buurt? Een 1 staat hier voor zeer ])
		,KCMCijfer = avg(iif([Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron] IS NOT NULL, ([Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi] + [Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat] + [Welk rapportcijfer geeft u Staedion voor de algemene ruimten ron] + [Welk rapportcijfer geeft u uw buurt? Een 1 staat hier voor zeer ]) / 4, ([Welk rapportcijfer geeft u voor uw 'thuisgevoel'? Een 1 staat hi] + [Welk cijfer geeft u voor de kwaliteit van uw woning? Een 1 staat] + [Welk rapportcijfer geeft u uw buurt? Een 1 staat hier voor zeer ]) / 3))
	FROM [empire_staedion_data].[bik].KCM_BIK2019_Thuisgevoel_okt2018_apr2019 AS KCM18
	WHERE Clusternr IS NOT NULL
	GROUP BY Clusternr

	)
SELECT Clusternummer = KCM.Clusternr
	,KCM.Jaar
	,KCM.AantalRespondenten
	,KCM.KCMThuisgevoel
	,KCM.KCMTevredenheidWoning
	,KCM.KCMTevredenheidAlgemeneRuimte
	,KCM.KCMTevredenheidBuurt
	,KCMCijfer = iif(KCM.KCMTevredenheidAlgemeneRuimte is not null, (KCM.KCMThuisgevoel + KCM.KCMTevredenheidWoning + KCM.KCMTevredenheidAlgemeneRuimte + KCMTevredenheidBuurt) / 4, (KCM.KCMThuisgevoel + KCM.KCMTevredenheidWoning + KCMTevredenheidBuurt) / 3)
FROM KCM
LEFT OUTER JOIN empire_staedion_data.bik.ELS_AantalWoningenPerClusterUltimo as AW ON KCM.Jaar = AW.Jaar
	AND KCM.Clusternr = AW.Clusternummer
WHERE KCM.AantalRespondenten >= CASE 
		WHEN AW.AantalWoningen >= 67
			THEN 10
		WHEN AW.AantalWoningen < 67
			AND KCM.AantalRespondenten >= 2
			THEN 0.15 * AW.AantalWoningen
		ELSE 2
		END
GO
