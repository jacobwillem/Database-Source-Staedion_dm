SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Dashboard].[vw_Indicator2]
AS
with
cte_RapportDetails_cnt as (
select [Indicatorgroep] = coalesce(R.[Rapport], 'Niet toegewezen')
	,[Aantal] = count(distinct I.[id])
from [Dashboard].[Indicator] as I
left outer join [Dashboard].[RapportDetails] as RD on RD.[fk_indicator_id] = I.[id]
left outer join [Dashboard].[Rapport] as R on R.[id] = RD.[fk_rapport_id]
left outer join [Dashboard].Prioriteit as P on P.[id] = I.[fk_prioriteit_id]
where I.[Gecontroleerd] <> 1
or I.[Gecontroleerd] is null
group by coalesce(R.[Rapport], 'Niet toegewezen')
),
cte_RapportDetails_tmp as (
select [id]
      ,[fk_rapport_id]
      ,[fk_indicator_id]
      ,[parent_id]
      ,[fk_indicatorgroep_id]
	  ,[Indicatorgroep] =  null
      ,[fk_kpilevel_id]
      ,[Aanduiding]
      ,[Volgorde]
      ,[Zichtbaar]
      ,[fk_bedrijfsonderdeel_id]
from [Dashboard].[RapportDetails]
union all
select
	 [id] = (select max(id) + 1 from [Dashboard].[RapportDetails]) + row_number() over (partition by 1 order by I.[id])
	,[fk_rapport_id] = 1
	,[fk_indicator_id] = I.[id]
	,[parent_id] = null
	,[fk_indicatorgroep_id] = 14
	,[Indicatorgroep] = concat(coalesce(R.[Rapport], 'Niet toegewezen'), ' (', C.[Aantal], ')')
	,[fk_kpilevel_id] = 1
	,[Aanduiding] = upper(concat(coalesce(P.[Omschrijving], '9 Onbekend'), '. ', I.[id]))
	,[Volgorde] = row_number() over (partition by 1 order by coalesce(I.[fk_prioriteit_id], 9))
	,[Zichtbaar] = 'TRUE'
	,[fk_bedrijfsonderdeel_id] = 5
from [Dashboard].[Indicator] as I
left outer join [Dashboard].[RapportDetails] as RD on RD.[fk_indicator_id] = I.[id]
left outer join [Dashboard].[Rapport] as R on R.[id] = RD.[fk_rapport_id]
left outer join [Dashboard].[Prioriteit] as P on P.[id] = I.[fk_prioriteit_id]
left outer join cte_RapportDetails_cnt as C on C.Indicatorgroep = coalesce(R.[Rapport], 'Niet toegewezen')
where I.[fk_status_id] not in (7, 9, 10) -- Gereed, Verlopen, Vervallen
or I.[fk_status_id] is null
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
	,[Indicatorgroep] =  null
	,[fk_kpilevel_id] = 1
	,[Aanduiding] = concat(I.[id], '.')
	,[Volgorde] = row_number() over (partition by 1 order by I.[id])
	,[Zichtbaar] = 'TRUE'
	,[fk_bedrijfsonderdeel_id] = 5
from [Dashboard].[Indicator] as I
where I.[fk_status_id] = 7
),

cte_Query as (
select   RA.[Rapport]
		,RA.[Rol]
		,RA.[Startdatum]
		,RA.[Einddatum]
		,[Indicatorgroep Id]	= IG.[id]
		,[Indicatorgroep]	= coalesce(RD.[Indicatorgroep], IG.[Omschrijving])
		,[Id]				= I.[id]
		,[Parent]			= isnull(PA.[Omschrijving], I.[Omschrijving])
		,[Omschrijving]		= case when PA.[omschrijving] is not null then replicate(' ',(RD.[fk_kpilevel_id] - 1) * 5) + I.[Omschrijving] else I.[Omschrijving] end
		,[Indicator]			= case when PA.[omschrijving] is not null then replicate(' ',(RD.[fk_kpilevel_id] - 1) * 5) + coalesce(RD.Aanduiding, '') + ' ' + I.[Omschrijving] else coalesce(RD.Aanduiding, '') + ' ' + I.[Omschrijving] end
		,[Level 1]			= case when PA.[Omschrijving] is null then 'Ja' else 'Nee' end
		,[Level]				= RD.[fk_kpilevel_id]
		,[Kpilevel]			= convert(varchar, RD.[fk_kpilevel_id]) + '. ' + KPI.[Omschrijving]
		,RD.[Volgorde]
		,RD.[Zichtbaar]
		,[Bedrijfsonderdeel]= BO.[Omschrijving]
		,[Aanspreekpunt]	= AP.[Omschrijving]
		,[WijzeVanVullen]	= WV.[Omschrijving]
		,[Schaalsoort]		= SS.[Omschrijving]
		,[Systeembron]		= SYST.[Omschrijving]
		,[Frequentie]		= FR.[Omschrijving]
		,[Proces]			= PR.[Link] --PR.[Omschrijving]
		,I.[Detailrapport]
		,I.[Gecontroleerd]
		,[Status]			= ST.Omschrijving
		,[Status pictogram] = ST.Pictogram
		,I.[Jaarnorm]
		,[Marge] = I.Marge
		,[Margetype] = MT.omschrijving
		,I.[Weergaveformat]
		,[Weergaveformat detail] = I.Weergaveformat_detail
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
		--,I.[Details]
		,[Detail_01] = TRIM(CAST('<t><![CDATA[' + REPLACE(I.[Details] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[1]','varchar(128)'))
		,[Detail_02] = TRIM(CAST('<t><![CDATA[' + REPLACE(I.[Details] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[2]','varchar(128)'))
		,[Detail_03] = TRIM(CAST('<t><![CDATA[' + REPLACE(I.[Details] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[3]','varchar(128)'))
		,[Detail_04] = TRIM(CAST('<t><![CDATA[' + REPLACE(I.[Details] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[4]','varchar(128)'))
		,[Detail_05] = TRIM(CAST('<t><![CDATA[' + REPLACE(I.[Details] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[5]','varchar(128)'))
		,[Detail_06] = TRIM(CAST('<t><![CDATA[' + REPLACE(I.[Details] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[6]','varchar(128)'))
		,[Detail_07] = TRIM(CAST('<t><![CDATA[' + REPLACE(I.[Details] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[7]','varchar(128)'))
		,[Detail_08] = TRIM(CAST('<t><![CDATA[' + REPLACE(I.[Details] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[8]','varchar(128)'))
		,[Detail_09] = TRIM(CAST('<t><![CDATA[' + REPLACE(I.[Details] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[9]','varchar(128)'))
		,[Detail_10] = TRIM(CAST('<t><![CDATA[' + REPLACE(I.[Details] ,';', ']]></t><t><![CDATA[') + ']]></t>' AS XML).value('/t[10]','varchar(128)'))
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
LEFT OUTER JOIN [Dashboard].[Margetype] as MT
       on MT.id = I.fk_margetype_id
LEFT OUTER JOIN [Dashboard].[Status] as ST
       on ST.id = I.fk_status_id
)

select [cte_Query].*, [Indicatorgroep Volgorde] = min([cte_Query].[Volgorde])
over(partition by [cte_Query].[Rapport], [cte_Query].[Indicatorgroep id]) 
from [cte_Query]

GO
