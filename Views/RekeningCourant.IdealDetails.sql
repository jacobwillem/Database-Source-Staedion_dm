SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [RekeningCourant].[IdealDetails] as 
select	R.Rekeningnr
		,GB.Boekdatum  
		,GB.Volgnummer  
		,GB.[Document nr]  
		,GB.Omschrijving 
		,Broncode = B.Bron
		,Bedrag = GB.[Bedrag incl. verplichting]
		,[Uniek volgnr ideal per klant] = dense_rank() OVER (
		ORDER BY [Bron Klant]
		) 
		-- select top 10 *
from	[Grootboek].Grootboekposten as GB
join	[Grootboek].Rekening as R
on		GB.Rekening_id = R.Rekening_id
left outer join	[Grootboek].[Bronnen] as B
on		B.Bron_id = GB.Bron_id
where	year(GB.Boekdatum)>= 2015
and		R.Rekeningnr in ('A155200')
and		coalesce([Bron Klant],'') is not null
GO
