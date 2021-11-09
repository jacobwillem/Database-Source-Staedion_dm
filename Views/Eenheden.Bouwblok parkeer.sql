SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [Eenheden].[Bouwblok parkeer]
as
select  
       [Clusternummer] = b.[cluster_nr]
	  ,[Clusternaam] = l.[Cluster]
      ,[Bouwbloknummer] = b.[bouwblok_nr]
      ,[Bouwblok latitude] = c.[latitude]
      ,[Bouwblok longitude] = c.[longitude]
      ,[Eenheidnummer] = b.[eenheid_nr]
      ,[Eenheid latitude] = e.[latitude]
      ,[Eenheid longitude] = e.[longitude]
      ,[Type] = b.[Type]
      ,[Afstand] = b.[afstand]
      ,[Locatie] = 'Bouwblok'
      ,[Latitude] = c.[latitude]
      ,[Longitude] = c.[longitude]
      ,[Tooltip] = concat(b.[cluster_nr], ' / ', b.[bouwblok_nr])
      ,[Status] = 'Bouwblok'
	  ,[Klantnummer] = null
	  ,[BTW] = null
  from [empire_staedion_data].[geo].[bouwblok_parkeer] b 
inner join [empire_data].[dbo].[Staedion$OGE] s on s.[Nr_] = b.[eenheid_nr] and s.[Status] <> 1
inner join [empire_staedion_data].[geo].[cluster_locatie] c on c.[bouwblok_nr] = b.[bouwblok_nr]
inner join [empire_staedion_data].[geo].[eenheid_locatie] e on e.[eenheidnr] = b.[eenheid_nr]
inner join [empire_dwh].[dbo].[tmv_cluster] l on l.Clusternr = b.[cluster_nr]

union

select 
       [Clusternummer] = b.[cluster_nr]
	  ,[Clusternaam] = l.[Cluster]
      ,[Bouwbloknummer] = b.[bouwblok_nr]
      ,[Bouwblok latitude] = c.[latitude]
      ,[Bouwblok longitude] = c.[longitude]
      ,[Eenheidnummer] = b.[eenheid_nr]
      ,[Eenheid latitude] = e.[latitude]
      ,[Eenheid longitude] = e.[longitude]
      ,[Type] = b.[Type]
      ,[Afstand] = b.[afstand]
      ,[Locatie] = 'Parkeerplaats'
      ,[Latitude] = e.[latitude]
      ,[Longitude] = e.[longitude]
      ,[Tooltip] = b.[eenheid_nr]
	  ,[Status] = case
						when m.exploitatiestatus = 'In exploitatie' and [BTW contract] = 'Ja' then 'Parkeren verhuurd met BTW'
						when m.exploitatiestatus = 'In exploitatie' and [BTW contract] = 'Nee' then 'Parkeren verhuurd zonder BTW'
						when m.exploitatiestatus = 'Uit exploitatie' then 'Parkeren beschikbaar'
						else 'Parkeren anders'
					end
	  ,[Klantnummer] = v.[Customer No_]
	  ,[BTW] = v.[btw]
  from [empire_staedion_data].[geo].[bouwblok_parkeer] b 
inner join [empire_data].[dbo].[Staedion$OGE] s on s.[Nr_] = b.[eenheid_nr] and s.[Status] <> 1
inner join [empire_staedion_data].[geo].[cluster_locatie] c on c.[bouwblok_nr] = b.[bouwblok_nr]
inner join [empire_staedion_data].[geo].[eenheid_locatie] e on e.[eenheidnr] = b.[eenheid_nr]
inner join [empire_dwh].[dbo].[tmv_eenheid] t on t.[Eenheidnummer] = b.[eenheid_nr]
inner join [empire_dwh].[dbo].[tmv_eenheid_meetwaarden] m on t.[Sleutel_eenheid] = m.[Sleutel eenheid] and [Datum] = convert(varchar, dateadd(day, -1, getdate()), 23)
inner join [empire_dwh].[dbo].[tmv_cluster] l on l.Clusternr = b.[cluster_nr]
outer apply [empire_staedion_data].[dbo].[ITVFnbtwVerhuurd](convert(varchar, dateadd(day, -1, getdate()), 23), b.[eenheid_nr]) v
GO
