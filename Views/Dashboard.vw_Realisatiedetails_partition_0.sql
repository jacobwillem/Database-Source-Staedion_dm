SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [Dashboard].[vw_Realisatiedetails_partition_0]
as
select * from dashboard.vw_RealisatiePrognose2 where datum < dateadd(dd,-1, convert(date,getdate()))
GO
