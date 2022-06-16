SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE view [Dashboard].[vw_Dimensie]
AS
with clusterlocatie
as (
	select distinct fk_indicator_id from [Dashboard].[RealisatieDetails] where nullif(Clusternummer, '') is not null
)

select	 [fk_indicator_id] = I.[id]
		,[Dimensie_id] = (I.[id] * 100)  + row_number() over (partition by id order by id)
		,[Dimensie_label] = right((I.[id] * 100)  + row_number() over (partition by id order by id), 2) + ': ' + trim(D.[value])
    ,[Dimensie_naam] = trim(D.[value])
from [Dashboard].[Indicator] as I
outer apply string_split(I.[Details], ';') as D
where rtrim(I.[Details]) <> ''

union 

select	 [fk_indicator_id] = I.[id]
		,[Dimensie_id] = (I.[id] * 100) + row_number() over (partition by id order by id) + 10
		,[Dimensie_label] = case right((I.[id] * 100) + row_number() over (partition by id order by id) + 10, 2)
								when 11 then 'Datum: per dag'
								when 12 then 'Datum: per maand'
                when 13 then 'Datum: per tertaal'
                when 14 then 'Datum: per jaar'
							end
    ,[Dimensie_naam] = case right((I.[id] * 100) + row_number() over (partition by id order by id) + 10, 2)
								when 11 then 'Datum: per dag'
								when 12 then 'Datum: per maand'
                when 13 then 'Datum: per tertaal'
                when 14 then 'Datum: per jaar'
							end
from [Dashboard].[Indicator] as I
full outer join (
  select [Waarde] = 'Datum: per dag' union 
  select 'Datum: per maand' union
  select 'Datum: per tertaal' union
  select 'Datum: per jaar'
) as T on 1 = 1

union 

select	 [fk_indicator_id] = I.[id]
		,[Dimensie_id] = (I.[id] * 100) + row_number() over (partition by id order by id) + 14
		,[Dimensie_label] = case right((I.[id] * 100) + row_number() over (partition by id order by id) + 14, 2)
								when 15 then 'Locatie: Deelgebied'
								when 16 then 'Locatie: Wijk'
								when 17 then 'Locatie: Buurt'
								when 18 then 'Locatie: Clusternummer'
								when 19 then 'Locatie: Gemeente'
							end
    ,[Dimensie_naam] = case right((I.[id] * 100) + row_number() over (partition by id order by id) + 14, 2)
								when 15 then 'Locatie: Deelgebied'
								when 16 then 'Locatie: Wijk'
								when 17 then 'Locatie: Buurt'
								when 18 then 'Locatie: Clusternummer'
								when 19 then 'Locatie: Gemeente'
							end
from [Dashboard].[Indicator] as I
inner join clusterlocatie L on  L.[fk_indicator_id] = I.[id]
full outer join (
  select [Waarde] = 'Locatie: Deelgebied' union 
  select 'Locatie: Wijk' union 
  select 'Locatie: Buurt' union 
  select 'Locatie: Clusternummer' union 
  select 'Locatie: Gemeente'
) as T on 1 = 1


GO
