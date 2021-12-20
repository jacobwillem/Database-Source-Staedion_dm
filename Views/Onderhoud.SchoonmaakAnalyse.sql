SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Onderhoud].[SchoonmaakAnalyse] as
with cte_BIK as (
select [Clusternummer]
      ,[Clusternaam]
      ,[AantalWoningen]
      ,[BIKscoreCluster]
  from [staedion_dm].[Leefbaarheid].[BIKOpCluster] where Jaar = 2020)
  
select LOC.[Deelgebied]
         ,LOC.Buurt
         ,LOC.BUcode
         ,LOC.Latitude
         ,LOC.Longitude
         ,LOC.Clusternummer
         ,[Aantal Woningen] = max(cte_BIK.[AantalWoningen])
		 ,[Aantal Woningen bins] = case 
										when max(cte_BIK.[AantalWoningen]) <12 then '<12'
										when max(cte_BIK.[AantalWoningen]) >= 12 and max(cte_BIK.[AantalWoningen]) < 50  then '12-50'
										when max(cte_BIK.[AantalWoningen]) > 50 then '>50'
									end
         ,[BIK score] = max(cte_BIK.BIKscoreCluster)
         ,[Contractpartner]
		 ,[Gemiddelde] = avg([Staedion regelt de schoonmaak van de ruimtes die alle bewoners g])
         ,[StandaardAfwijking] = stdev([Staedion regelt de schoonmaak van de ruimtes die alle bewoners g])
         ,[Aantal] = count(*)
		 ,[Categorie] = case 
							when [Staedion regelt de schoonmaak van de ruimtes die alle bewoners g] < 6 then '< 6'
							when [Staedion regelt de schoonmaak van de ruimtes die alle bewoners g] >= 6 and [Staedion regelt de schoonmaak van de ruimtes die alle bewoners g] < 7.5 then '6 - 7.5'
							when [Staedion regelt de schoonmaak van de ruimtes die alle bewoners g] >= 7.5 then '> 7.5'
						end
         ,[Representatie%] = count(*)*1.0 / max(cte_BIK.[AantalWoningen])*1.
		 ,[Representatief] = iif(count(*) >= case 
												when max(cte_BIK.[AantalWoningen]) >= 67 then 10
												when max(cte_BIK.[AantalWoningen]) < 67 and count(*) >= 2 then 0.15 * max(cte_BIK.[AantalWoningen])
												else 2
											 end,
							'Ja',
							'Nee')
  from [empire_staedion_data].[kcm].[STN660_Ingevulde_gegevens] as KCM
  left outer join staedion_dm.Dashboard.vw_Clusterlocatie as LOC on LOC.Clusternummer = KCM.Clusternr
  left outer join cte_BIK on cte_BIK.Clusternummer = LOC.Clusternummer
  where [Contractpartner] not in ('', 'Reinland Schoonmaak & glazen') 
  group by LOC.Deelgebied, LOC.Buurt, LOC.BUcode, LOC.Latitude ,LOC.Longitude, LOC.Clusternummer, Contractpartner, case 
							when [Staedion regelt de schoonmaak van de ruimtes die alle bewoners g] < 6 then '< 6'
							when [Staedion regelt de schoonmaak van de ruimtes die alle bewoners g] >= 6 and [Staedion regelt de schoonmaak van de ruimtes die alle bewoners g] < 7.5 then '6 - 7.5'
							when [Staedion regelt de schoonmaak van de ruimtes die alle bewoners g] >= 7.5 then '> 7.5'
						end
  --order by LOC.Deelgebied, LOC.Buurt, avg([Staedion regelt de schoonmaak van de ruimtes die alle bewoners g]) asc

GO
