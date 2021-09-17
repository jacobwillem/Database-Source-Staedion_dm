SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [RekeningCourant].[fn_Derdendossiers] (
       @DatumVanaf DATE = '20190101'
       ,@DatumTotenMet DATE = '20211231'
       )
RETURNS TABLE
AS
/* ########################################################################################################################## 
	Betreft			Ophalen van gegevens derdendossiers in Empire
							Gezien kleine omvang van tabellen kan dit on-the-fly
							Tbv Power BI wordt een snapshot per maand gegenereerd met per peildatum een Rapportagestatus: lopend + nieuw 
	--------------------------------------------------------------------------------------------------------------------------
	TEST
	--------------------------------------------------------------------------------------------------------------------------
	-- performance

	-- Check: beginstand + aangemaakt - Afgerond = Eindstand
	select   Jaar = year(Peildatum)
				  , Maand = month(Peildatum)
					,[Beginstand] = sum([Beginstand])
					,[Aangemaakt] = sum([Aangemaakt])
					,[Afgerond] = sum([Afgerond])				
					,[Eindstand] = sum([Eindstand])
	-- select  Dossiernr, Ingangsdatum, Afgesloten,[Beginstand],[Aangemaakt],[Afgerond],[Eindstand], Startdatum, Peildatum,*
	from		[RekeningCourant].[fn_Derdendossiers] (default,default)
	--where Dossiernr = 'DERD-20001181'
	group by year(Peildatum), month(Peildatum)
	order by   year(Peildatum) desc, month(Peildatum) asc  OPTION (MAXRECURSION 10000)

	--------------------------------------------------------------------------------------------------------------------------
	METADATA
	--------------------------------------------------------------------------------------------------------------------------
	EXEC [empire_staedion_data].[dbo].[dsp_info_object_en_velden] staedion_dm, 'RekeningCourant', 'fn_Derdendossiers'

	--------------------------------------------------------------------------------------------------------------------------
	WIJZIGINGEN
	--------------------------------------------------------------------------------------------------------------------------
	20210916 JvdW aangemaakt tbv vervanging dwex door PBI
	########################################################################################################################## */
RETURN
WITH CTE_Nummers AS (					-- wat gepiel voorlopig omdat er nog geen tijdsdimensie is die je makkelijk kunt bevragen, zou ook met master..sp_value kunnen maar dat levert ook weer reference-issues op
		SELECT 1 AS Getal
		UNION ALL
		SELECT getal + 1 AS Getal
		FROM CTE_Nummers
		WHERE CTE_Nummers.Getal <= 10000
		)
	,CTE_Datums AS (
		SELECT cast(CONVERT(DATETIME, '20180101') + Getal AS DATE) AS [Datum]
		FROM CTE_Nummers
		)
	,CTE_Peildata(Peildatum, Startdatum, Bedrijf_id) AS (
		SELECT DISTINCT eomonth([Datum]) AS Peildatum
			,Startdatum = dateadd(d, 1, eomonth(dateadd(m, - 1, [Datum])))
			,1 AS Bedrijf_id
		FROM CTE_Datums
		WHERE [Datum] BETWEEN coalesce(@DatumVanaf, datefromparts(year(getdate()), 1, 1))
				AND coalesce(@DatumTotenMet, datefromparts(year(getdate()), 12, 31))
		)



SELECT PEIL.[bedrijf_id]
       ,Dossiernr = DRD.No_
       ,Dossiersoort = DRD.[Type]
       ,[Omschrijving dossiersoort] = TYP.[Description] --Lookup("Debt Recovery Type".Description WHERE (Code=FIELD(Type)))
       ,[Kenmerk derden] = DRD.[External Dossier No_]
       ,Huurdernr = DRD.[Customer No_]
       ,Ingangsdatum = cast(DRD.[Start Date] AS DATE)
       ,[Afgesloten] = cast(nullif(DRD.[Closed], '1753-01-01') AS DATE)
       ,[Code reden afsluiting] = DRD.[Reason Closure]
       ,[Reden afsluiting] = REAS.[Description]
			 ,[Dossier status] =  CASE DRD.[Dossier status]
              WHEN 0
                     THEN ''
              WHEN 1
                     THEN 'Bedrag afgeboekt'
              WHEN 2
                     THEN 'Bedrag en betaling afgeboekt'
              WHEN 3
                     THEN 'Betaling teruggeboekt'
              WHEN 3
                     THEN 'Teruggeboekt'
              ELSE cast(DRD.[Dossier status] AS NVARCHAR(2))
              END
       ,[Status derdendossier] = CASE DRD.[Status]
              WHEN 0
                     THEN ''
              WHEN 1
                     THEN 'In beh. WSNP'
              WHEN 2
                     THEN 'In beh. Minnelijk'
              WHEN 3
                     THEN 'In beh. Sanering'
              ELSE cast(DRD.[Status] AS NVARCHAR(2))
              END
       ,[Totaal vordering] = (
              SELECT sum([Rem_ Amt_ when Posted])
              FROM [S-logsh-prod].[Empire].dbo.[Staedion$Debt Recovery Ledger Entry] AS LDG
              WHERE LDG.[Dossier No_] = DRD.[No_]
              )
       ,[Beginstand] = CASE 
              WHEN DRD.[Start Date] < PEIL.Startdatum
                     AND (
                            DRD.[Closed] = '1753-01-01'
                            OR DRD.[Closed] >= PEIL.Startdatum
                            )
                     THEN 1
              ELSE 0
              END
       ,[Aangemaakt] = CASE 
              WHEN DRD.[Start Date] >= PEIL.Startdatum
                     AND DRD.[Start Date] <= PEIL.[Peildatum]
                     THEN 1
              ELSE 0
              END
       ,[Afgerond] = CASE 
              WHEN DRD.[Closed] >= PEIL.Startdatum
                     AND DRD.[Closed] <= PEIL.[Peildatum]
                     THEN 1
              ELSE 0
              END
       ,[Eindstand] = CASE 
              WHEN DRD.[Start Date] <= PEIL.[Peildatum]
                     AND (
                            DRD.[Closed] = '1753-01-01'
                            OR DRD.[Closed] > PEIL.[Peildatum]
                            )
                     THEN 1
              ELSE 0
              END
       ,Rapportagestatus = CASE 
              WHEN DRD.[Start Date] < PEIL.Startdatum
                     AND (
                            DRD.[Closed] = '1753-01-01'
                            OR DRD.[Closed] > PEIL.Startdatum
                            )
                     THEN 'Lopende zaak'
              WHEN DRD.[Start Date] < PEIL.Startdatum
                     AND DRD.[Closed] <> '1753-01-01'
                     AND DRD.[Closed] <= PEIL.[Peildatum]
                     THEN 'Afgesloten'
              WHEN DRD.[Start Date] >= PEIL.Startdatum
                     AND DRD.[Closed] <> '1753-01-01'
                     AND DRD.[Closed] <= PEIL.[Peildatum]
                     THEN 'Nieuw en afgesloten'
              WHEN DRD.[Start Date] >= PEIL.Startdatum
                     AND (
                            DRD.[Closed] = '1753-01-01'
                            OR DRD.[Closed] > PEIL.[Peildatum]
                            )
                     THEN 'Nieuwe zaak'
              END
       ,Rapportagestatus_id = CASE 
              WHEN DRD.[Start Date] < PEIL.Startdatum
                     AND (
                            DRD.[Closed] = '1753-01-01'
                            OR DRD.[Closed] > PEIL.Startdatum
                            )
                     THEN 2 -- 2	Lopende zaak
              WHEN DRD.[Start Date] < PEIL.Startdatum
                     AND DRD.[Closed] <> '1753-01-01'
                     AND DRD.[Closed] <= PEIL.[Peildatum]
                     THEN 3 -- 3	Afgesloten
              WHEN DRD.[Start Date] >= PEIL.Startdatum
                     AND DRD.[Closed] <> '1753-01-01'
                     AND DRD.[Closed] <= PEIL.[Peildatum]
                     THEN 4 -- 4	Nieuw en afgesloten
              WHEN DRD.[Start Date] >= PEIL.Startdatum
                     AND (
                            DRD.[Closed] = '1753-01-01'
                            OR DRD.[Closed] > PEIL.[Peildatum]
                            )
                     THEN 1 -- 1	Nieuwe zaak
              END
			 ,[Sociaal dagvaarden] = DRD.Summoning
			 ,[Datum uitspraak WSNP] = DRD.[Date Decision WSNP]
			 ,[Datum akkoord Saneringskosten] = DRD.[Date Agr_ Restr_ Cost]
			 ,[Datum akkoord Minnelijk] = DRD.[Date Agr_ Settlement]
       ,PEIL.Startdatum
       ,PEIL.Peildatum
FROM [S-logsh-prod].[Empire].dbo.[staedion$Debt Recovery Dossier] AS DRD
LEFT OUTER JOIN [S-logsh-prod].[Empire].dbo.[staedion$Debt Recovery Type] AS TYP
       ON TYP.[Code] = DRD.[Type]
LEFT OUTER JOIN [S-logsh-prod].[Empire].dbo.[staedion$Debt Recovery Reason Closure] AS REAS
       ON REAS.[Code] = DRD.[Reason Closure]
INNER JOIN CTE_Peildata AS PEIL
       ON (
                     DRD.[Start Date] <= PEIL.Startdatum
                     AND coalesce(nullif(DRD.[Closed], '17530101'), '20990101') > PEIL.Startdatum
                     OR (
                            DRD.[Start Date] BETWEEN PEIL.Startdatum
                                   AND PEIL.[Peildatum]
                            )
                     OR (
                            DRD.[Closed] BETWEEN PEIL.Startdatum
                                   AND PEIL.[Peildatum]
                            )
                     ) 

GO
