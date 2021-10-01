SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Datakwaliteit].[sp_import_uitzondering]
as
begin

insert into [Datakwaliteit].[Uitzondering]
	   ([id_samengesteld], [sleutel_entiteit], [Aangemaakt], [Aangemaakt_door], [Startdatum], [Einddatum], [Opmerking])
select [id_samengesteld], [sleutel_entiteit], [Aangemaakt], [Aangemaakt_door], [Startdatum], [Einddatum], [Opmerking]
  from ff...[Blad1$]
 where id_samengesteld is not null
   and sleutel_entiteit is not null
   and Aangemaakt is not null
   and Aangemaakt_door is not null
   and Startdatum is not null
   and Opmerking is not null
end

GO
