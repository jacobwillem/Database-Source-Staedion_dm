SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [Dashboard].[vw_DimensieJoin]
AS
with
T as (
	select [num] = 1
	union all
	select [num] + 1
	from T
	where [num] < 16
),

Q as (
	select 	 [id] = R.[id]
			,[fk_indicator_id] = R.[fk_indicator_id]
			,[Clusternummer] = R.[Clusternummer]
			,[Dimensie.naam] = concat('Detail.', right(concat('00', T.[num]), 2))
			,[Dimensie.id] = concat(R.[fk_indicator_id], '.', 'Detail.', right(concat('00', T.[num]), 2))
			,[Datum] = R.[Datum]
			,[Laaddatum] = R.[Laaddatum]
	from [Dashboard].[RealisatieDetails] as R
	full outer join T on 1 = 1
	where R.[fk_indicator_id] is not null
)

select * from Q --where ([Dimensie.naam] not in ('Detail.13', 'Detail.14', 'Detail.15', 'Detail.16')
				--   or ([Dimensie.naam] in ('Detail.13', 'Detail.14', 'Detail.15', 'Detail.16') and [Clusternummer] is not null)
				--	  )

--,[Dimensie.naam] = concat('Detail.', right(concat('00', row_number() over (partition by R.[fk_indicator_id] order by R.[fk_indicator_id])), 2))
--,[Dimensie.id] = concat(R.[fk_indicator_id], '.', 'Detail.', right(concat('00', row_number() over (partition by R.[fk_indicator_id] order by R.[fk_indicator_id])), 2))

GO
