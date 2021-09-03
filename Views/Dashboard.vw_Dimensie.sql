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
		,[Dimensie.naam] = concat('Detail.', right(concat('00', row_number() over (partition by id order by id)), 2))
		,[Dimensie.id] = concat(I.[id], '.', 'Detail.', right(concat('00', row_number() over (partition by id order by id)), 2))
		,[Dimensie.label] = trim(D.value)
from [Dashboard].[Indicator] as I
outer apply string_split(I.[Details], ';') as D
where rtrim(I.[Details]) <> ''

union 

select	 [fk_indicator_id] = I.[id]
		,[Dimensie.naam] = concat('Detail.', right(concat('00', row_number() over (partition by I.[id] order by I.[id]) + 10), 2))
		,[Dimensie.id] = concat(I.[id], '.', 'Detail.', right(concat('00', row_number() over (partition by I.[id] order by I.[id]) + 10), 2))
		,[Dimensie.label] = T.Waarde
from [Dashboard].[Indicator] as I
full outer join (select [Waarde] = 'Datum: per dag' union select 'Datum: per maand') as T on 1 = 1

union 

select	 [fk_indicator_id] = I.[id]
		,[Dimensie.naam] = concat('Detail.', right(concat('00', row_number() over (partition by I.[id] order by I.[id]) + 12), 2))
		,[Dimensie.id] = concat(I.[id], '.', 'Detail.', right(concat('00', row_number() over (partition by I.[id] order by I.[id]) + 12), 2))
		,[Dimensie.label] = T.Waarde
from [Dashboard].[Indicator] as I
inner join clusterlocatie L on  L.[fk_indicator_id] = I.[id]
full outer join (select [Waarde] = 'Locatie: Deelgebied' union select 'Locatie: Wijk' union select 'Locatie: Buurt' union select 'Locatie: Clusternummer') as T on 1 = 1

GO
