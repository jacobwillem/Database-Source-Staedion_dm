SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Contracten].[vw_OnderhoudscontractenEenheden]
AS

select	 [Contract - Nummer]							= HOL.[No_]
		,[Contract - Budgethouder]						= HOL.[Budget Holder User ID]
		,[Contract - Goedkeurder]						= HOL.[Approver User ID]
		,[Contract - Goedgekeurd]						= HOL.[Approved]
		,[Contract - Datum goedgekeurd]					= iif(HOL.[Approval Date] <> '17530101', cast(HOL.[Approval Date] as date), null) 
		,[Contract - Budget]							= FORMAT(CON.[Total Budget], 'C', 'nl-nl')
		,[Contract - Leveranciernummer]					= CON.[Vendor No_]
		,[Contract - Leveranciernaam]					= LEV.[Name]
		,[Contract - Omschrijving]						= CON.[Description]
		,[Contract - Type]								= iif(CON.[Type] <> '', CON.[Type] + ' - ' + CTY.[Description], 'ONBEKEND/NVT') 
		,[Contract - Status]							= case  when CON.[Status] = 1 then 'Initiatie'
																when CON.[Status] = 2 then 'Lopend'
																when CON.[Status] = 3 then 'Vervallen'
																when CON.[Status] = 4 then 'Afgehandeld'
																else 'ONBEKEND/NVT'
																end
		,[Contract - Startdatum]						= cast(CON.[Start Date] as date)
		,[Contract - Einddatum]							= cast(CON.[End Date] as date)
		,[Contract - Fiatteringstatus]					= case	when CON.[Approval Status] = 0 then 'Geen budgethouders'
																when CON.[Approval Status] = 1 then 'Niet gefiatteerd'
																when CON.[Approval Status] = 2 then 'Gedeeltelijk gefiatteerd'
																when CON.[Approval Status] = 3 then 'Volledig gefiatteerd'
																else 'ONBEKEND/NVT'
																end
		,[Contract - Gereedmelden orders]				= CON.[Order Status ready]
		,[Project - Nummer]								= PRJ.[Nr_]
		,[Project - Naam]								= PRJ.[Naam]
		,[Project - Omschrijving]						= PRJ.[Omschrijving]
		,[Project - Contactpersoon 1]					= (select [Name] from [empire_data].[dbo].[Staedion$Empire_Project_Contact_Person] where [Project No_] = PRJ.[Nr_] and [Priority] = 1 and Hide = 0)
		,[Project - Contactpersoon 2]					= (select [Name] from [empire_data].[dbo].[Staedion$Empire_Project_Contact_Person] where [Project No_] = PRJ.[Nr_] and [Priority] = 2 and Hide = 0)
		,[Project - Startdatum]							= iif(PRJ.[Startdatum] <> '17530101', cast(PRJ.[Startdatum] as date), null)
		,[Project - Opleverdatum]						= iif(PRJ.[Opleverdatum] <> '17530101', cast(PRJ.[Opleverdatum] as date), null)
		,[Project - Status]								= PRJ.[Status]	
		,[Budgetregel - Clusternummer]					= BRE.[Clusternr_] 
		,[Budgetregel - Werksoort]						= BRE.[Werksoort]
		,[Budgetregel - Werksoortomschrijving]			= BRE.[Werksoortomschrijving]
		,[Budgetregel - Budgetregelnummer]				= BRE.[Regelnr_] 
		,[Budgetregel - Stardatum]						= iif(BRE.[Startdatum] <> '17530101', cast(BRE.[Startdatum] as date), null)
		,[Budgetregel - Opleverdatum]					= iif(BRE.[Opleverdatum] <> '17530101', cast(BRE.[Opleverdatum] as date), null)
		,[Eenheidnummer]								= OGE.[Realty Object No_]
		,[Adres]										= OGE.[Realty Object Address]
		,[Postcode]										= NAW.Postcode
		,[Plaats]										= NAW.Plaats
		
FROM [empire_data].[dbo].[Staedion$Maintenance_Contract] as CON						-- Hoofdcontract waarop toestemmingsprocedure van toepassing is
join [empire_data].[dbo].[Vendor] as LEV											-- Leveranciernummer koppelen aan leveranciernaam
	on CON.[Vendor No_] = LEV.[No_]
join [empire_data].[dbo].[Staedion$Contract_budget_holder] as HOL					-- Budgethouder en goedkeurder en moment van goedkeuren van het contract
	on CON.No_ = HOL.No_
left outer join [empire_data].[dbo].[Staedion$Empire_Project] as PRJ				-- Project vallende onder het contract, meerjarige contracten kunnen meerdere projecten bevatten
	on CON.No_ = PRJ.[Contract No_]	
left outer join [empire_data].[dbo].[Staedion$Maintenance_Contract_Type] as CTY		-- Onderhoudscontracttype
	on CON.[Type] = CTY.Code
left outer join [empire_data].[dbo].[Staedion$Empire_Projectbudgetregel] as BRE		-- Budgetregels van project als hoofdregel per cluster zijn op start, einddatum en werksoort na leeg
	on PRJ.[Nr_] = BRE.[Projectnr_]
left outer join [empire_data].[dbo].[Staedion$Mutation_Data_Realty_Object] as OGE	-- Eenheden behorende bij onderhoudscontracten per budgetregel
	on CON.[No_] = OGE.[Maintenance Contract No_]
		and BRE.[Regelnr_] = OGE.[MDB Line No_]
left outer join [empire_data].[dbo].[Staedion$OGE] as NAW
	on OGE.[Realty Object No_] = NAW.Nr_
where	CON.[Status] <> 3															-- Contract status is niet 'vervallen'
		and year(CON.[End Date]) >= year(getdate())	- 1								-- Contracten die ten laatste vorig zijn verlopen of nog niet verlopen zijn

GO
