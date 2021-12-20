SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [Contracten].[vw_Onderhoudscontracten]
AS

with PLV as(
			select Projectnr_
				,Budgetregelnr_
				,[Aangegane Verplichting] = SUM([Verplichting (LV)])
				,[Restant Verplichting] = SUM(iif(PLI.[Completely Received] = 0, [Verplichting (LV)], 0))
				,[Realisatie] = SUM(iif(PLI.[Completely Received] = 1, [Verplichting (LV)], 0))
			from [empire_data].[dbo].[Staedion$Empire_Projectbudg_det_regel] as BDR
			left outer join [empire_data].[dbo].[Staedion$Purchase_Header] as PHE
			on BDR.[Nr_] = PHE.[No_]
			left outer join [empire_data].[dbo].[Staedion$Purchase_Line] as PLI	
			on	PHE.[No_] = PLI.[Document No_]
			and BDR.[Inkoopregelnr_] = PLI.[Line No_]
			group by Projectnr_, Budgetregelnr_
			)
,PLS as(
		select	 [Document No_]
				,[Totaalbedrag excl BTW]				= SUM([Line Amount])
		from [empire_data].[dbo].[Staedion$Purchase_Line]
		group by [Document No_]
		)
,POV as(
			select Projectnr_
				,[Aangegane Verplichting] = SUM([Verplichting (LV)])
				,[Restant Verplichting] = SUM(iif(PLI.[Completely Received] = 0, [Verplichting (LV)], 0))
				,[Realisatie] = SUM(iif(PLI.[Completely Received] = 1, [Verplichting (LV)], 0))
			from [empire_data].[dbo].[Staedion$Empire_Projectbudg_det_regel] as BDR
			left outer join [empire_data].[dbo].[Staedion$Purchase_Header] as PHE
			on BDR.[Nr_] = PHE.[No_]
			left outer join [empire_data].[dbo].[Staedion$Purchase_Line] as PLI	
			on	PHE.[No_] = PLI.[Document No_]
			and BDR.[Inkoopregelnr_] = PLI.[Line No_]
			group by Projectnr_
			)
,POB as(
			select BRE.[Projectnr_]
				,[Budgetpost - Bedrag incl BTW]	= SUM([Bedrag incl_ BTW])
			from [empire_data].[dbo].[Staedion$Empire_Projectbudgetregel] as BRE
			left outer join [empire_data].[dbo].[Staedion$Empire_Projectbudgetpost] as BUP
			on BRE.Projectnr_ = BUP.Projectnr_ and BRE.Regelnr_ = BUP.Budgetregelnr_
			group by BRE.Projectnr_
			)
,COV as(
			select CON.No_
				,[Aangegane Verplichting] = SUM([Verplichting (LV)])
				,[Restant Verplichting] = SUM(iif(PLI.[Completely Received] = 0, [Verplichting (LV)], 0))
				,[Realisatie] = SUM(iif(PLI.[Completely Received] = 1, [Verplichting (LV)], 0))
			from [empire_data].[dbo].[Staedion$Maintenance_Contract] as CON		
			left outer join [empire_data].[dbo].[Staedion$Empire_Project] as PRJ
			on CON.No_ = PRJ.[Contract No_]
			left outer join [empire_data].[dbo].[Staedion$Empire_Projectbudgetregel] as BRE
			on PRJ.[Nr_] = BRE.[Projectnr_]
			left outer join [empire_data].[dbo].[Staedion$Empire_Projectbudg_det_regel] as BDR
			on PRJ.[Nr_] = BDR.[Projectnr_] and BRE.Regelnr_ = BDR.Budgetregelnr_
			left outer join [empire_data].[dbo].[Staedion$Purchase_Header] as PHE
			on BDR.[Nr_] = PHE.[No_]
			left outer join [empire_data].[dbo].[Staedion$Purchase_Line] as PLI	
			on	PHE.[No_] = PLI.[Document No_]
			and BDR.[Inkoopregelnr_] = PLI.[Line No_]
			group by CON.No_
			)
,BGP as(
		select	 Projectnr_
				,Budgetregelnr_
				,[Begrotingpost - Bedrag incl BTW]		= SUM([Bedrag incl_ BTW])
		from [empire_data].[dbo].[Staedion$Empire_projectbegrootpost]
		group by Projectnr_, Budgetregelnr_
		)
,BUP as(
		select	 Projectnr_
				,Budgetregelnr_
				,[Budgetpost - Bedrag incl BTW]			= SUM([Bedrag incl_ BTW])
		from [empire_data].[dbo].[Staedion$Empire_Projectbudgetpost]
		group by Projectnr_, Budgetregelnr_
		)
,PNP as(
		select	 Projectnr_
				,Budgetregelnr_
				,[Prognosepost - Bedrag incl BTW]		= SUM([Bedrag incl_ BTW])
		from [empire_data].[dbo].[Staedion$Prognosepost]
		group by Projectnr_, Budgetregelnr_
		)

select	 [Contract - Nummer]							= HOL.[No_]
		,[Contract - Budgethouder]						= HOL.[Budget Holder User ID]
		,[Contract - Goedkeurder]						= HOL.[Approver User ID]
		,[Contract - Goedgekeurd]						= HOL.[Approved]
		,[Contract - Datum goedgekeurd]					= iif(HOL.[Approval Date] <> '17530101', cast(HOL.[Approval Date] as date), null) 
	    ,[Contract - Mutatie budgethouder]				= MBH.[Budget Holder User ID]
		,[Contract - Mutatie goedkeurder]				= MBH.[Approver User ID]
		,[Contract - Mutatie goedgekeurd]				= MBH.[Approved]
		,[Contract - Mutatie datum goedgekeurd]         = iif(MBH.[Approval Date] <> '17530101', cast(MBH.[Approval Date] as date), null)
		,[Contract - Mutatie fiat status]				= case  when MUC.[Approval Status] = 0 then 'Geen budgethouders'
																when MUC.[Approval Status] = 1 then 'Niet gefiatteerd'
																when MUC.[Approval Status] = 2 then 'Gedeeltelijk gefiatteerd'
																when MUC.[Approval Status] = 3 then 'Volledig gefiatteerd'
																else 'ONBEKEND/NVT'
																end 
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
		,[Contract - Budget]							= CON.[Total Budget]
		,[Contract - Aangegane Verplichting]			= COV.[Aangegane Verplichting]
		,[Contract - Restant Verplichting]				= COV.[Restant Verplichting]
		,[Contract - Realisatie]						= COV.[Realisatie]
		,[Project - Budget]								= POB.[Budgetpost - Bedrag incl BTW]
		,[Project - Aangegane Verplichting]				= POV.[Aangegane Verplichting]
		,[Project - Restant Verplichting]				= POV.[Restant Verplichting]
		,[Project - Realisatie]							= POV.[Realisatie]
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
		,[Budgetregel - Begrotingspost]					= BGP.[Begrotingpost - Bedrag incl BTW]
		,[Budgetregel - Budget]							= BUP.[Budgetpost - Bedrag incl BTW]
		,[Budgetregel - Aangegane Verplichting]			= PLV.[Aangegane Verplichting]
		,[Budgetregel - Restant Verplichting]			= PLV.[Restant Verplichting]
		,[Budgetregel - Vrije Budgetruimte]				= coalesce(BUP.[Budgetpost - Bedrag incl BTW], 0) - coalesce(PLV.[Aangegane Verplichting], 0)
		,[Budgetregel - Prognose]						= PNP.[Prognosepost - Bedrag incl BTW]
		,[Budgetregel - Prognoseruimte]					= coalesce(PNP.[Prognosepost - Bedrag incl BTW], 0) - coalesce(PLV.[Aangegane Verplichting], 0)
		,[Budgetregel - Begroot - Prognose]				= coalesce(BGP.[Begrotingpost - Bedrag incl BTW], 0) - coalesce(PNP.[Prognosepost - Bedrag incl BTW], 0)
		,[Budgetregel - Realisatie]						= PLV.[Realisatie]
		,[Budgetregel - % Budget besteed]				= case  when BUP.[Budgetpost - Bedrag incl BTW] is null then null
																when BUP.[Budgetpost - Bedrag incl BTW] <> 0 and PLV.[Aangegane Verplichting] is not null then PLV.[Aangegane Verplichting] / BUP.[Budgetpost - Bedrag incl BTW]
																else 0
																end
		,[Inkooporder - Nummer]							= BDR.[Nr_]
		,[Inkooporder - Status]							= case	when PHE.[Status] = 0 then 'Open'
																when PHE.[Status] = 1 then 'Vrijgegeven'
																else 'ONBEKEND/NVT'
																end
		,[Inkooporder - Totaalbedrag excl BTW]			= PLS.[Totaalbedrag excl BTW]
		,[Inkoopregel - BTW productboekingsgroep]		= PLI.[VAT Prod_ Posting Group]
		,[Inkoopregel - Omschrijving]					= PLI.[Description]
		,[Inkoopregel - Omschrijving 2]					= PLI.[Description 2]
		,[Inkoopregel - Bedrag]							= PLI.[Line Amount]
		,[Inkoopregel - Verplichting]					= PLI.[Verplichting (LV)]
		,[Budgetdetailregel - Status]					= case	when BDR.[Status] = 0 then 'Open'
																when BDR.[Status] = 6 then 'Gereed'
																when BDR.[Status] = 7 then 'Gegund'
																when BDR.[Status] = 8 then 'Gereed'
																when BDR.[Status] = 9 then 'Afgehandeld'
																else 'ONBEKEND/NVT'
																end
		,[Inkoopregel - Volledig ontvangen] 			= PLI.[Completely Received]

FROM [empire_data].[dbo].[Staedion$Maintenance_Contract] as CON						-- Hoofdcontract waarop toestemmingsprocedure van toepassing is
left outer join [empire_data].[dbo].[staedion$Mutation_Data_Budget_Holder] as MBH   -- Hoofdcontract mutatie budgethouder
	on CON.No_ = MBH.No_
left outer join [empire_data].[dbo].[staedion$Mutation_Data_Contract] as MUC		-- Hoofdcontract mutatie fiat status
	on CON.No_ = MUC.[Maintenance Contract No_]
join [empire_data].[dbo].[Vendor] as LEV											-- Leveranciernummer koppelen aan leveranciernaam
	on CON.[Vendor No_] = LEV.[No_]
join [empire_data].[dbo].[Staedion$Contract_budget_holder] as HOL					-- Budgethouder en goedkeurder en moment van goedkeuren van het contract
	on CON.No_ = HOL.No_
left outer join [empire_data].[dbo].[Staedion$Empire_Project] as PRJ				-- Project vallende onder het contract, meerjarige contracten kunnen meerdere projecten bevatten
	on CON.No_ = PRJ.[Contract No_]	
left outer join [empire_data].[dbo].[Staedion$Maintenance_Contract_Type] as CTY		-- Onderhoudscontracttype
	on CON.[Type] = CTY.Code
left outer join POB																	-- Budgetposten van project met gesommeerd bedrag per project
	on PRJ.[Nr_] = POB.Projectnr_
left outer join [empire_data].[dbo].[Staedion$Empire_Projectbudgetregel] as BRE		-- Budgetregels van project als hoofdregel per cluster zijn op start, einddatum en werksoort na leeg
	on PRJ.[Nr_] = BRE.[Projectnr_]
left outer join  BGP																-- Begrotingposten van project met gesommeerd bedrag per budgetregel
	on PRJ.[Nr_] = BGP.Projectnr_ and BRE.Regelnr_ = BGP.Budgetregelnr_
left outer join  BUP																-- Budgetposten van project met gesommeerd bedrag per budgetregel
	on PRJ.[Nr_] = BUP.Projectnr_ and BRE.Regelnr_ = BUP.Budgetregelnr_
left outer join  PNP																-- Prognoseposten van project met gesommeerd bedrag per budgetregel
	on PRJ.[Nr_] = PNP.Projectnr_ and BRE.Regelnr_ = PNP.Budgetregelnr_
left outer join PLV																	-- Verplichtingen op inkooporder gesommeerd bedrag per budgetregel
	on PRJ.[Nr_] = PLV.[Projectnr_] and BRE.Regelnr_ = PLV.Budgetregelnr_
left outer join POV 																-- Verplichtingen op inkooporder gesommeerd bedrag per project
	on PRJ.[Nr_] = POV.[Projectnr_]
left outer join COV 																-- Verplichtingen op inkooporder gesommeerd bedrag per contract
	on CON.[No_] = COV.[No_]
left outer join [empire_data].[dbo].[Staedion$Empire_Projectbudg_det_regel] as BDR	-- Budgetdetailregels van project met koppeling met inkooporders bijvoorbeeld per klus of kwartaal
	on PRJ.[Nr_] = BDR.[Projectnr_] and BRE.Regelnr_ = BDR.Budgetregelnr_
left outer join [empire_data].[dbo].[Staedion$Purchase_Header] as PHE				-- Inkooporder die aan de budgetdetailregel gekoppeld is.
	on BDR.[Nr_] = PHE.[No_]
--left outer join [empire_data].[dbo].[Vendor] as LEVPHE							-- Leveranciernummer koppelen aan leveranciernaam op inkooporder
--on PHE.[Buy-from Vendor No_] = LEVPHE.[No_]
left outer join PLS																	-- Som van regels per inkooporder gekoppeld op inkoopordernummer
	on	PHE.[No_] = PLS.[Document No_]
left outer join [empire_data].[dbo].[Staedion$Purchase_Line] as PLI					-- Regels inkooporder gekoppeld op inkoopordernummer, clusternummer en budgetdetailregel volgorde
	on	PHE.[No_] = PLI.[Document No_]
		and BDR.[Inkoopregelnr_] = PLI.[Line No_]

where	CON.[Status] <> 3															-- Contract status is niet 'vervallen'
		and year(CON.[End Date]) >= year(getdate())	- 1								-- Contracten die ten laatste vorig zijn verlopen of nog niet verlopen zijn
	--and PHE.[Buy-from Vendor No_] <> CON.[Vendor No_] and BDR.[Nr_] is not null	-- Er zijn geen contracten met orders waarop een andere leverancier staat
	--and PLI.[Line Amount] <> PLI.[Amount]											-- Er zijn geen inkoopregels die een ander bedrag hebben dan het regelbedrag
	--and PLS.[Totaalbedrag excl BTW] is not null and PLI.[Line Amount] is null		-- Er zijn geen inkoopregels die niet gekoppeld worden terwijl de inkooporder wordt herkend
	--and PLI.No_ <> 'A815640'														-- Alle betalingen vallen in grootboekrekening A815640



GO
