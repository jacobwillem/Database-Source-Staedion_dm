SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE procedure [dbo].[sp_load_kpi_personeelslasten] (
  @peildatum date = '20210131'
)
as
begin
  exec dbo.sp_load_kpi_personeelslasten_realisatie @peildatum
  exec dbo.sp_load_kpi_personeelslasten_budget @peildatum
  --exec dbo.sp_load_kpi_personeelslasten_prognose @peildatum
end
GO
