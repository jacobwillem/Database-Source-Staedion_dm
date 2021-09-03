SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE view [Algemeen].[Energielabel verlopen]
as

select   [eenheidnr]
		,[adviesbureau]
        ,[verloopjaar]
		,[fk_eenheid_id]  = o.lt_id
from [empire_staedion_data].[excel].[VABI_Energielabel_Verlopen] l
left join empire_data.dbo.vw_lt_mg_oge o on o.nr_ = l.eenheidnr and o.mg_bedrijf = 'Staedion'

GO
