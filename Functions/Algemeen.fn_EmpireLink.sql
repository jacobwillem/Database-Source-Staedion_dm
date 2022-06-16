SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE function [Algemeen].[fn_EmpireLink] (@bedrijf varchar(30), @page int, @filter varchar(250), @modus varchar(20) = 'view')

returns varchar(1000)
as
/*	===============================================================================================================================================
	functie om een link naar Empire te genereren
	Parameters: 
	@bedrijf wordt gevuld met het bedrijf waarnaar verwezen moet worden
	@page bevat het paginanummer dat moet worden geopend
	@filter bevat de sleutel waarmee de pagina moet worden geopend:
		opbouw is: de veldnaam zoals deze in de disigner wordt weergegeven (dus bv No. voor databasefield No_) gevolgd door het = teken en daarna 
				   de gezochte veldwaarde, tekstwaarden moeten tussen enkele quotes worden meegegeven
				   als er meerdere sleutelvelden zijn dan voor de volgende veld/waarde combinatie een komma meegeven
		voorbeeld voor factuur: set @filter = 'No.=''INKF-123456'''
				  voor contractregel: set @filter = 'Soort=1,Eenheidnr.=''OGEH-0020377'',Volgnr.=999999959'
	@modus waarde: 'view' scherm wordt in opvraagmodus geopend (dit is de standaard waarde)
		   waarde: 'edit' scherm wordt in wijzigmodus geopend
	
	in de functie variabele @mtier wordt het adres van de middletier vastgelegd

	20161214 JvdW: Soms doorstart naar instellingsscherm - geen filter
					Voorbeeld 
					select empire_staedion_data.empire.fnEmpireLink('Staedion', 314, '','view' )
	20190124 Ere: aangepast ten bate van R17. 
	===============================================================================================================================================
	Voorbeeld aanroep:
	Inkoopfactuur: select staedion_dm.algemeen.fn_EmpireLink('Staedion', 138, 'No.=''INKF-15012284''')				=> (opvraagscherm)
				   select staedion_dm.algemeen.fn_EmpireLink('Staedion', 138, 'No.=''INKF-15012284''', 'view')		=> (opvraagscherm)
				   select staedion_dm.algemeen.fn_EmpireLink('Staedion', 138, 'No.=''INKF-15012284''', 'edit')		=> (wijzigscherm)
	Contractregel: fout select staedion_dm.algemeen.fn_EmpireLink('Staedion', 11024013, 'Soort=1,Eenheidnr.=''OGEH-0020377'',Volgnr.=999999959', 'view')
					goed = select staedion_dm.algemeen.fn_EmpireLink('Staedion', 11024012, 'Soort=1,Eenheidnr.=''OGEH-0005175''', 'view')
	Projectorder : select staedion_dm.algemeen.fn_EmpireLink('Staedion', 50, 'No.=''IORD-1536677''')
	Woningwaard.:  select staedion_dm.algemeen.fn_EmpireLink('Staedion', 11024020, 'Eenheidnr.=''OGEH-0000217'',Ingangsdatum=''01-07-2016''', 'view') Zelfstandige woningen
				   select staedion_dm.algemeen.fn_EmpireLink('Staedion', 11024289, 'Eenheidnr.=''OGEH-0042987'',Ingangsdatum=''18-04-2011''', 'view') Onzelfstandige woningen

    Cartotheek	: select staedion_dm.algemeen.fn_EmpireLink('Staedion', 11024266, 'No.=''' +@OGE +'''' + ',Table=''1''','view') ERE 3-10-2017

	Inkooporder:   select staedion_dm.algemeen.fn_EmpireLink('Staedion', 11024119, 'Document Type=1,No.=''IORD-1621709''','view' )
	Verantwoording:select staedion_dm.algemeen.fn_EmpireLink('Staedion', 11152115,'Realty Object No.=''OGEH-0002100'',Entry No.=1,Version No.=1','view' )
					> krijg je Card te zien, niet lijst, dat zou 11152113 zijn maar daar zitten deze 3 velden niet in waardoor je een foutmelding krijgt

	Vaste activa:	select staedion_dm.algemeen.fn_EmpireLink('Staedion', 5600, 'No.=''ACTI-000394-02''','view')
					= DynamicsNAV://s-emp-as2.staedion.local:7046/emp-02-03/Staedion/runpage?page=5600&$filter='No.'%20IS%20'ACTI-000394-02'&mode=view
					voor SSAS-kubus:	"DynamicsNAV://s-emp-as2.staedion.local:7046/emp-02-03/Staedion/runpage?page=5600&$filter='No.'%20IS%20'"+[Vastactivum].[Vast Activum Parent].Currentmember.Properties('Activanummer')+"'"
										"Empire-scherm voor (alleen bedrijf Staedion) activakaart "+[Vastactivum].[Vast Activum Parent].Currentmember.Properties('Activanummer')

	Clusterkaart	select staedion_dm.algemeen.fn_EmpireLink('Staedion', 11024003, 'Nr.=''FT-1001''','view')		
						voor SSAS-kubus: "dynamicsnav://s-macht-as1.staedion.local:7446/macht-01-04/Staedion/runpage?page=11024003&$filter='Nr.'%20IS%20'"+[Cluster].[Cluster].Currentmember.Properties('Clusternummer')+"'"

	Reparatieverzoek: 	select staedion_dm.algemeen.fn_EmpireLink('Staedion', 11031240, 'No.=''OND00061446-000''','view' )


	Eenheidskaart
					voor SSAS-kubus: "dynamicsnav://s-emp-as1.staedion.local:7046/emp-01-01/Staedion/runpage?page=11024009&$filter='Nr.'%20IS%20'"+[Eenheid].[Eenheid].Currentmember.Properties('Eenheidnr')+"'"

	Betalingsregeling 
					> Zie SSAS-kubus: page=11024102&$filter='Code'

	NB				Link wordt ook gebruikt voor [dsp_load_f_staedion_grootboek], inbouwen van onderstaande functie duurde daar te lang
						=> die ook handmatig aanpassen

	=============================================================================================================================================== */

begin
	declare @bdr varchar(50)

	-- declare @mtier varchar(100) = 's-emp-as2.staedion.local:7046/emp-02-03/'-- oud R14
	--DECLARE @mtier VARCHAR(100) = 's-macht-as1:7446/MACHT-01-04/' -- oud R16
	DECLARE @mtier VARCHAR(100) = 's-emp17-as2.staedion.local:7146/EMP17_02_01/' -- nieuw R17
	DECLARE @pad_toevoegen nvarchar(3) = 'nee'   -- test mislukte
	declare @url varchar(1000) = 'DynamicsNAV://' + @mtier

	select @bdr = replace(replace(replace(cmp.Name, ' ', '%20'), '.', '%2E'), '/', '%2F')
	from empire_data.dbo.company cmp
	where replace(replace(replace(cmp.Name, ' ', '_'), '.', '_'), '/', '_') = @bedrijf

	If len(@Filter) > 0 
	set @url = @url + @bdr + '/runpage?page=' + convert(varchar(10), @page) + '&$filter=' + '''' + 
		replace(replace(@filter, '=', '''%20IS%20'), ',', '%20AND%20''') + 
		'&mode=' + @modus

	If len(@Filter) = 0 
	set @url = @url + @bdr + '/runpage?page=' + convert(varchar(10), @page)  + -- '&$filter=' + '''' + 
		--replace(replace(@filter, '=', '''%20IS%20'), ',', '%20AND%20''') + 
		'&mode=' + @modus

	if @pad_toevoegen = 'ja'
	 set @url = 'C:\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client\Microsoft.Dynamics.Nav.Client.exe '+ @url 

	return isnull(@url, '')
end
GO
