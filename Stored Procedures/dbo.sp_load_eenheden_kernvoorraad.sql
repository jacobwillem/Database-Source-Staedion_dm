SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_load_eenheden_kernvoorraad]
as
begin

  declare @datum date
  
  declare ref_cursor cursor local fast_forward 
  for select distinct datum from empire_dwh.dbo.d_bestand where datum between DATEADD(mm,-12,GETDATE()) and getdate()

  open ref_cursor
  
  fetch next from ref_cursor into @datum
  
  while @@fetch_status = 0
  begin

    delete from Eenheden.Kernvoorraad where month(Peildatum) = month(@datum) and YEAR(peildatum) = YEAR(@datum)

    insert into Eenheden.Kernvoorraad
    select * FROM staedion_dm.Eenheden.[fn_Kernvoorraad](@datum) 
        
    fetch next from ref_cursor into @datum
        
  end

  close ref_cursor
  deallocate ref_cursor

end
GO
