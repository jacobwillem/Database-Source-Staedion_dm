SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Leegstand].[Huurkorting]
as
select
  [Datum]               = de.datum,
  [Sleutel eenheid]     = de.fk_eenheid_id_contract,
  [Sleutel contract]    = de.fk_contract_id,
  [Element]             = el.descr,
  [Bedrag huurkorting]  = bedrag_opbrengst * -1.000
from empire_dwh.dbo.d_element_contract as de
join empire_dwh.dbo.element as el on el.id = de.fk_element_id
where el.fk_elementsoort_id = 9
GO
