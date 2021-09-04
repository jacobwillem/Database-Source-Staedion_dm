SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Dashboard].[vw_Indicator2]
AS
with
cte_RapportDetails_tmp as (
select * from [Dashboard].[RapportDetails]
union all
select
	 [id] = (select max(id) + 1 from [Dashboard].[RapportDetails]) + row_number() over (partition by 1 order by I.[id])
	,[fk_rapport_id] = 1
	,[fk_indicator_id] = I.[id]
	,[parent_id] = null
	,[fk_indicatorgroep_id] = 14
	,[fk_kpilevel_id] = 1
	,[Aanduiding] = concat(I.[id], '.')
	,[Volgorde] = row_number() over (partition by 1 order by I.[id])
	,[Zichtbaar] = 1
	,[fk_bedrijfsonderdeel_id] = 5
from [Dashboard].[Indicator] as I
),

cte_RapportDetails as (
select * from cte_RapportDetails_tmp
union all
select
	 [id] = (select max(id) + 1 from cte_RapportDetails_tmp) + row_number() over (partition by 1 order by I.[id])
	,[fk_rapport_id] = 2
	,[fk_indicator_id] = I.[id]
	,[parent_id] = null
	,[fk_indicatorgroep_id] = 14
	,[fk_kpilevel_id] = 1
	,[Aanduiding] = concat(I.[id], '.')
	,[Volgorde] = row_number() over (partition by 1 order by I.[id])
	,[Zichtbaar] = 1
	,[fk_bedrijfsonderdeel_id] = 5
from [Dashboard].[Indicator] as I
where I.[Gecontroleerd] = 1
),

cte_Query as (
select  RA.[Rapport]
	   ,RA.[Rol]
	   ,RA.[Startdatum]
	   ,RA.[Einddatum]
	   ,[Indicatorgroep Id]	= IG.[id]
	   ,[Indicatorgroep]	= IG.[Omschrijving]
       ,[Id]				= I.[id]
	   ,[Parent]			= isnull(PA.[Omschrijving], I.[Omschrijving])
       ,[Omschrijving]		= case when PA.[omschrijving] is not null then replicate(' ',(RD.[fk_kpilevel_id] - 1) * 5) + I.[Omschrijving] else I.[Omschrijving] end
       ,[Indicator]			= case when PA.[omschrijving] is not null then replicate(' ',(RD.[fk_kpilevel_id] - 1) * 5) + coalesce(RD.Aanduiding, '') + ' ' + I.[Omschrijving] else coalesce(RD.Aanduiding, '') + ' ' + I.[Omschrijving] end
	   ,[Level 1]			= case when PA.[Omschrijving] is null then 'Ja' else 'Nee' end
       ,[Level]				= RD.[fk_kpilevel_id]
	   ,[Kpilevel]			= convert(varchar, RD.[fk_kpilevel_id]) + '. ' + KPI.[Omschrijving]
       ,RD.[Volgorde]
	   ,RD.[Zichtbaar]
       ,[Bedrijfsonderdeel]	= BO.[Omschrijving]
       ,[Aanspreekpunt]		= AP.[Omschrijving]
       ,[WijzeVanVullen]	= WV.[Omschrijving]
       ,[Schaalsoort]		= SS.[Omschrijving]
       ,[Systeembron]		= SYST.[Omschrijving]
	   ,[Frequentie]		= FR.[Omschrijving]
	   ,[Proces]			= PR.[Omschrijving]
       ,I.[Detailrapport]
       ,I.[Gecontroleerd]
       ,I.[Jaarnorm]
       ,I.[Weergaveformat]
       ,I.[Definitie]
       ,I.[Cumulatief]
       ,I.[Gemiddelde]
	   ,I.[Observatie]
	   ,[Bijgewerkt tot]	= (select max([datum]) from Dashboard.[RealisatieDetails] as DET where DET.fk_indicator_id = I.[id])
	   --,[Check records 2020 RealisatieDetails]	= (select count(*) from Dashboard.[RealisatieDetails] as DET where DET.fk_indicator_id = I.[id] AND year(DET.datum) = 2020)
	   --,[Check gemiddelde 2020 RealisatieDetails]	= (select  avg([Waarde] * 1.00) from Dashboard.[RealisatieDetails] as DET where DET.fk_indicator_id = I.[id] AND year(DET.datum) = 2020)
	   --,[Check gemiddelde 2020 Realisatie]	= (select avg([Waarde] * 1.00) from Dashboard.[Realisatie] as REL where REL.fk_indicator_id = I.[id] AND year(REL.datum) = 2020)
	   --,[Check aantal records 2020 brontabel] = (SELECT count(*) from Dashboard.check_kcm_aantallen as VW where  lower(VW.controle_brontabel) = lower(I.controle_brontabel) AND year(VW.Datum) = 2020)
	   ,I.[controle_brontabel]
	   ,I.[procedure_naam]
	   ,I.[procedure_argument]
	   ,I.Procedure_actief
	   ,I.[Details]
from [Dashboard].[Indicator] as I
LEFT OUTER JOIN [cte_RapportDetails] as RD
       on RD.fk_indicator_id = I.[id]
LEFT OUTER JOIN [Dashboard].[Rapport] as RA
       on RA.[id] = RD.[fk_rapport_id]
LEFT OUTER JOIN [Dashboard].[Indicatorgroep] as IG
       on IG.id = RD.fk_indicatorgroep_id
LEFT OUTER JOIN [Dashboard].[Kpilevel] as KPI
       on KPI.id = RD.fk_kpilevel_id
LEFT OUTER JOIN [Dashboard].Bedrijfsonderdeel as BO
       on BO.id = RD.fk_bedrijfsonderdeel_id
LEFT OUTER JOIN [Dashboard].Aanspreekpunt as AP
       on AP.id = I.fk_Aanspreekpunt_id
LEFT OUTER JOIN [Dashboard].WijzeVullen as WV
       on WV.id = I.fk_WijzeVullen_id
LEFT OUTER JOIN [Dashboard].Schaalsoort as SS
       on SS.id = I.fk_Schaalsoort_id
LEFT OUTER JOIN [Dashboard].Subsysteem as SYST
       on SYST.id = I.fk_Subsysteem_id
LEFT OUTER JOIN [Dashboard].[Frequentie] as FR
       on FR.id = I.fk_frequentie_id
LEFT OUTER JOIN [Dashboard].[Proces] as PR
       on PR.id = I.fk_proces_id
LEFT OUTER JOIN [Dashboard].[Indicator] as PA
       on PA.id = RD.parent_id
)

select [cte_Query].*, [Indicatorgroep Volgorde] = min([cte_Query].[Volgorde])
over(partition by [cte_Query].[Rapport], [cte_Query].[Indicatorgroep id]) 
from [cte_Query]

GO
