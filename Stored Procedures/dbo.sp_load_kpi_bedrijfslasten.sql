SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_load_kpi_bedrijfslasten] (
  @peildatum date = '20210131'
)
as
begin
	declare @sql nvarchar(1000) 
	
	set @sql = 'exec [dbo].[sp_load_kpi_bedrijfslasten_realisatie_' + convert(varchar(4), @peildatum, 120) + '] ''' +  convert(varchar(10), @peildatum, 120) + ''''
	exec (@sql)

	set @sql = 'exec [dbo].[sp_load_kpi_bedrijfslasten_budget_' + convert(varchar(4), @peildatum, 120) + '] ''' +  convert(varchar(10), @peildatum, 120) + ''''
	exec (@sql)

	set @sql = 'exec [dbo].[sp_load_kpi_bedrijfslasten_prognose_' + convert(varchar(4), @peildatum, 120) + '] ''' +  convert(varchar(10), @peildatum, 120) + ''''
	exec (@sql)

  --exec dbo.sp_load_kpi_bedrijfslasten_realisatie_2021 @peildatum
  --exec dbo.sp_load_kpi_bedrijfslasten_budget_2021 @peildatum
  --exec dbo.sp_load_kpi_bedrijfslasten_prognose_2021 @peildatum
end
GO
