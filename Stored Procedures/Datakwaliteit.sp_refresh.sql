SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Datakwaliteit].[sp_refresh]  @peildatum date = null 
as
begin

	-- eventuele queries tbv performance

	-- opgenomen procedures in tabel [Datakwaliteit].[Indicator] uitvoeren
  exec Datakwaliteit.sp_load_dashboard @Peildatum

	-- "maatwerk"-procedures uitvoeren

end
GO
