SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[vw_pbi_facturenafhandeling]
/* 
-- RvG ten behoeve van analyse rapportage tijdig betalen facturen
-- 20220128 Aangemaakt

*/ 
as
select year(fac.[Afgesloten op]) Jaar,
	Format(eomonth(fac.[Afgesloten op]), 'yyyy-MM') Periode, fac.Factuurnr, fac.[Geboekte goedkeurders], fac.[Aantal geboekte goedkeuringsposten], 
	format(fac.Factuurbedrag, '#,##0.00', 'nl-NL') [Factuurbedrag],
	fac.goedkeuringssoort, fac.Leveranciernr, fac.[Naam leverancier], fac.Inkoper, isnull(wkn.[Name], '') [Inkoper naam], isnull(fac.[Afdeling], '') [Afdeling], fac.[Toegewezen gebruiker],
	fac.Documentdatum, fac.Boekdatum, fac.Vervaldatum, fac.[Afgesloten op], fac.[Eerste goedkeuring], fac.[Laatste goedkeuring], isnull(fac.[Afwachtcode], 	 '') [Afwachtcode],
	datediff(d, fac.Documentdatum, fac.Boekdatum) [Documentdatum => Boekdatum],
	datediff(d, fac.Documentdatum, fac.[Afgesloten op]) [Documentdatum => Betaaldatum],
	datediff(d, fac.Boekdatum, fac.[Afgesloten op]) [Boekdatum => Betaaldatum],
	datediff(d, fac.Boekdatum, fac.[Eerste goedkeuring]) [Boekdatum => 1e fiat],
	datediff(d, fac.Boekdatum, fac.[Laatste goedkeuring]) [Boekdatum => laatste fiat],
	datediff(d, fac.[Eerste goedkeuring], fac.[Laatste goedkeuring]) [Eerste fiat => laatste fiat],
	datediff(d, fac.[Laatste goedkeuring], fac.[Afgesloten op]) [Laatste fiat => Betaling],
	iif(datediff(d, fac.Documentdatum, fac.[Afgesloten op]) <= 30, 1, 0) [Tijdig betaald],
	iif(datediff(d, fac.Documentdatum, fac.Boekdatum) > 14, 1, 0) [Te laat geboekt],
	iif(datediff(d, fac.Boekdatum, fac.[Eerste goedkeuring]) > 7, 1, 0) [1e fiat na 7 dagen na boeken],
	iif(datediff(d, fac.[Eerste goedkeuring], fac.[Laatste goedkeuring]) > 7, 1, 0) [laatste fiat na 7 dagen na 1e fiat],
	iif(datediff(d, fac.[Laatste goedkeuring], fac.[Afgesloten op]) > 7, 1, 0) [betaling na 7 dagen na laatste fiat]
from staedion_dm.Financieel.Facturen fac left outer join empire_data.dbo.salesperson_purchaser wkn
on fac.Inkoper = wkn.Code
where fac.bedrijf_id = 1 and fac.Documentsoort_id = 2 and
fac.[Afgesloten op] >= datefromparts(year(getdate())-2, 1, 1)
GO
