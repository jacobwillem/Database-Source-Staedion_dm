SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Dashboard].[vw_DimensieDetails_partition_1]
as
select * from dashboard.vw_DimensieDetails where datum >= dateadd(yy,-2, convert(date,getdate()))
GO
