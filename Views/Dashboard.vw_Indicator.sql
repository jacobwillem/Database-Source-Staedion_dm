SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










CREATE VIEW [Dashboard].[vw_Indicator]
AS
SELECT  [Jaargang]			= JG.[Jaargang]
	   ,[Indicatorgroep Id]	= IG.[id]
	   ,[Indicatorgroep]	= IG.[Omschrijving]
       ,[Id]				= I.[id]
	   ,[Parent]			= isnull(PA.[Omschrijving], I.[omschrijving])
       ,[Omschrijving]		= case when PA.[omschrijving] is not null then replicate(' ',(JG.[fk_kpilevel_id] - 1) * 10) + I.[Omschrijving] else I.[Omschrijving] end
       ,[Indicator]			= case when PA.[omschrijving] is not null then replicate(' ',(JG.[fk_kpilevel_id] - 1) * 10) + coalesce(JG.Aanduiding, '') + ' ' + I.[Omschrijving] else coalesce(JG.Aanduiding, '') + ' ' + I.[Omschrijving] end
	   ,[Level 1]			= case when PA.[Omschrijving] is null then 'Ja' else 'Nee' end
       ,[Level]				= JG.[fk_kpilevel_id]
	   ,[Kpilevel]			= convert(varchar, JG.[fk_kpilevel_id]) + '. ' + KPI.[Omschrijving]
       ,JG.[Volgorde]
	   ,JG.[Zichtbaar]
       ,[Kleurschema]		= KS.[Omschrijving]
       ,I.[Grenswaarde_1]
       ,I.[Grenswaarde_2]
       ,I.[Grenswaarde_3]
       ,[Bedrijfsonderdeel]	= BO.[Omschrijving]
       ,[Aanspreekpunt]		= AP.[Omschrijving]
       ,[WijzeVanVullen]	= WV.[Omschrijving]
       ,[Schaalsoort]		= SS.[Omschrijving]
       ,[Systeembron]		= SYST.[Omschrijving]
	   ,[Frequentie]		= FR.[Omschrijving]
	   ,[Proces]			= PR.[Omschrijving]
       ,I.[Marge_percentage]
       ,I.[Url]
       ,I.[Gecontroleerd]
       ,I.[Jaarnorm]
       ,I.[Weergaveformat]
       ,I.[Definitie]
       ,I.[Cumulatief]
       ,I.[Gemiddelde]
	   ,[Bijgewerkt tot]	= (select max([datum]) from Dashboard.[RealisatieDetails] as DET where DET.fk_indicator_id = I.[id])
	   ,[Check records 2020 RealisatieDetails]	= (select count(*) from Dashboard.[RealisatieDetails] as DET where DET.fk_indicator_id = I.[id] AND year(DET.datum) = 2020)
	   ,[Check gemiddelde 2020 RealisatieDetails]	= (select  avg([Waarde] * 1.00) from Dashboard.[RealisatieDetails] as DET where DET.fk_indicator_id = I.[id] AND year(DET.datum) = 2020)
	   ,[Check gemiddelde 2020 Realisatie]	= (select avg([Waarde] * 1.00) from Dashboard.[Realisatie] as REL where REL.fk_indicator_id = I.[id] AND year(REL.datum) = 2020)
	   ,[Check aantal records 2020 brontabel] = (SELECT count(*) FROM Dashboard.check_kcm_aantallen AS VW WHERE lower(VW.controle_brontabel) = lower(I.controle_brontabel) AND year(VW.Datum) = 2020)
	   ,I.controle_brontabel
	   ,I.[procedure_naam]
	   ,I.[procedure_argument]
	   ,I.Procedure_actief
	   ,I.[Details]
FROM [Dashboard].[Indicator] AS I
LEFT OUTER JOIN [Dashboard].[Jaargang] AS JG
       ON JG.fk_indicator_id = I.[id] --AND JG.[Jaargang] = 2020
LEFT OUTER JOIN [Dashboard].[Indicatorgroep] AS IG
       ON IG.id = JG.fk_indicatorgroep_id
LEFT OUTER JOIN [Dashboard].[Kpilevel] AS KPI
       ON KPI.id = JG.fk_kpilevel_id
LEFT OUTER JOIN [Dashboard].[Kleurschema] AS KS
       ON KS.id = I.fk_kleurschema_id
LEFT OUTER JOIN [Dashboard].Bedrijfsonderdeel AS BO
       ON BO.id = JG.fk_bedrijfsonderdeel_id
LEFT OUTER JOIN [Dashboard].Aanspreekpunt AS AP
       ON AP.id = I.fk_Aanspreekpunt_id
LEFT OUTER JOIN [Dashboard].WijzeVullen AS WV
       ON WV.id = I.fk_WijzeVullen_id
LEFT OUTER JOIN [Dashboard].Schaalsoort AS SS
       ON SS.id = I.fk_Schaalsoort_id
LEFT OUTER JOIN [Dashboard].Subsysteem AS SYST
       ON SYST.id = I.fk_Subsysteem_id
LEFT OUTER JOIN [Dashboard].[Frequentie] AS FR
       ON FR.id = I.fk_frequentie_id
LEFT OUTER JOIN [Dashboard].[Proces] AS PR
       ON PR.id = I.fk_proces_id
LEFT OUTER JOIN [Dashboard].[Indicator] AS PA
       ON PA.id = JG.parent_id

GO
