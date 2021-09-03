SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_load_kpi_bedrijfslasten] (
  @peildatum date = '20210131'
)
as
begin
  exec dbo.sp_load_kpi_bedrijfslasten_realisatie_2021 @peildatum
  exec dbo.sp_load_kpi_bedrijfslasten_budget_2021 @peildatum
  exec dbo.sp_load_kpi_bedrijfslasten_prognose_2021 @peildatum
end
GO
