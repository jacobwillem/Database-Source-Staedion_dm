SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [RekeningCourant].[vw_HuurstandenBOGAchterstandsduur]
as 
select	[Duur stand] = case when [Saldo tov maandhuur] <0 then 'Nvt'
			else case when [Saldo tov maandhuur] < 1 then 'Nieuwe stand'
				else case when [Saldo tov maandhuur] < 2 then '1 maand'
					else case when [Saldo tov maandhuur] < 3 then '2 maanden'
						else case when [Saldo tov maandhuur] < 4 then '3 maanden'
							else case when [Saldo tov maandhuur] < 7 then '4 tot 6 maanden'
								else case when [Saldo tov maandhuur] < 12 then '7 tot 12 maanden'
									else case when [Saldo tov maandhuur] >= 12 then '12 maanden of meer'
										else '' end end end end end end end end
		,[Duur stand - sortering] = case when [Saldo tov maandhuur] <0 then 0
			else case when [Saldo tov maandhuur] < 1 then 1
				else case when [Saldo tov maandhuur] < 2 then 2
					else case when [Saldo tov maandhuur] < 3 then 3
						else case when [Saldo tov maandhuur] < 4 then 4
							else case when [Saldo tov maandhuur] < 7 then 5
								else case when [Saldo tov maandhuur] < 12 then 7
									else case when [Saldo tov maandhuur] >= 12 then 12
										else '' end end end end end end end end
		,[Klantnr], [Klantnaam], [Saldo klant], [Rekensaldo klant], [Zittend of vertrokken], [Achterstand of voorstand], [Aantal], [Heeft minnelijke beschikking], [Heeft WNSP], [Bij deurwaarder], [Heeft betalingsregeling], [Huur klant], [Eenheidnr], [Adres], [Rekensaldo oge], [Saldo eenheid], [Huur oge], [Saldo tov maandhuur], [Peildatum]
from	 RekeningCourant.vw_HuurstandenBOGInclEenheden
;
GO
