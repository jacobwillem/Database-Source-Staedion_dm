SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE[dbo].[sp_load_kpi_verhuringen](
  @peildatum date
)
as
begin

  -- eerst de details laden
  declare @indicator int = 100
  
  -- verwijderen eerder opgehaalde data voor dezelfde periode (van 1e t/m laatste van de maand)
  delete from Dashboard.[RealisatieDetails] where fk_indicator_id = @indicator and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

  insert into Dashboard.[RealisatieDetails](
    fk_indicator_id, 
    Datum, 
    Waarde, 
    Omschrijving,
    Laaddatum,
    fk_contract_id
  ) 
  select
    @indicator,
    c.dt_ingang,
    1,
    c.fk_klant_id + ' ; ' + trim(e.descr) + ' ; ' + e.da_postcode + ' ; ' + e.da_plaats + ' ; kalehuur: '+ format(HPR.kalehuur,'N2') ,
    GETDATE(),
    c.id
  from empire_dwh.dbo.[contract] as c inner join empire_dwh.dbo.eenheid e
  on c.fk_eenheid_id = e.id
  inner join empire_dwh.dbo.technischtype t
  on e.fk_technischtype_id = t.id
	-- JvdW 20200916 ovv EdG toegevoegd: kalehuur in omschrijving
	outer apply empire_staedion_data.dbo.[ITVfnHuurprijs](E.bk_nr_,c.dt_ingang) as HPR
  where c.dt_ingang between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum and 
  t.fk_eenheid_type_corpodata_id in ('WON ZELF', 'WON ONZ')

  -- obv de details vullen we de totalen

  delete from Dashboard.[Realisatie] where fk_indicator_id = @indicator and Datum between dateadd(d, 1-day(@peildatum), @peildatum) and eomonth(@peildatum)

  insert into Dashboard.[Realisatie] (
    fk_indicator_id,
    Datum,
    Waarde,
    Laaddatum
  )
  select
    fk_indicator_id,
    @peildatum,
    Waarde = SUM(rd.waarde),
    getdate()
  from Dashboard.[RealisatieDetails] as rd
  where rd.fk_indicator_id = @indicator and
  rd.Datum between dateadd(d, 1-day(@peildatum), @peildatum) and @peildatum
  group by fk_indicator_id
end

GO
