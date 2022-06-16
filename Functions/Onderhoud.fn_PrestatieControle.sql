SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [Onderhoud].[fn_PrestatieControle] ()
RETURNS TABLE 
AS

/* #############################################################################################################################
EXEC sys.sp_updateextendedproperty @name = N'MS_Description'
       ,@value = 
N'Tonen van diverse metrics rondom de prestatiecontrole van onderhoudswerkzaamheden geregistreerd in module Dagelijks Onderhoud in Empire
Zie: PBI rapport Prestatiecontrole
Bron gegevens: datamart staedion_dm.Onderhoud
'
       ,@level0type = N'SCHEMA'
       ,@level0name = 'Onderhoud'
       ,@level1type = N'FUNCTION'
       ,@level1name = 'fn_PrestatieControle';
GO

--------------------------------------------------------------------------------------------------------------------------------
WIJZIGINGEN 
--------------------------------------------------------------------------------------------------------------------------------
20211202 JvdW Topdesk 21 10 861
20220422 JvdW Code vervangen door code datamart + gecheckt dat bijv aantal bijlagen  door datamart identiek is aan mijn vorige versie (gebaseerd op brontabellen)
> daarbij oude benaming gehandhaafd omdat er al een Power BI was aangemaakt

--------------------------------------------------------------------------------------------------------------------------------
TESTEN 
--------------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM staedion_dm.Onderhoud.fn_PrestatieControle()
--WHERE [Taak - sjablooncode] IN(N'PRESCONTROLE_KOSPEC', N'PRESCONTROLE_GR_750', N'PRESCONTROLE_KL_750', N'PRESCONTROLE_VASTETP', N'PRESCONTROLE_GARANT')
--and Verzoek = 'OND00291507-000'
ORDER BY Verzoek, COALESCE(NULLIF([Order], ''), 'Z');
;

--------------------------------------------------------------------------------------------------------------------------------
ACHTERGRONDINFORMATIE 
--------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################# */

RETURN
WITH cte_basis
AS (SELECT		 VERZ.Onderhoudsverzoek AS Verzoek
				,ROW_NUMBER() OVER (
						PARTITION BY VERZ.Onderhoudsverzoek ORDER BY TAAK.[Taak nr]
						) AS Volgnr						
						,SJAB.Code AS [Taak - sjablooncode]
						 -- ,SJAB.Reparatiesjabloon AS [Omschrijving reparatiesjabloon]
						,VERZ.Omschrijving AS [Verzoek - omschrijving]
						,coalesce(nullif(VERZ.Eenheidnr,''),VERZ.[Collectiefnr]) AS [Verzoek - eenheidnr]
						,VS.Onderhoudsverzoekstatus AS [Verzoek - status]
						,VERZ.Melddatum  AS [Verzoek - datum invoer]
						,ORD.Onderhoudsorder AS [Order]
						,ORD.Leveranciernr AS [Order - leverancier]
						,ORD.[Aangemaakt door] AS [Order - aangemaakt door]
						,TAAK.Onderhoudstaak AS [Taak]
						,ORD.Aanmaakdatum AS [Order - aanmaakdatum]
						,UR.Urgentiecode AS [Order - urgentiecode]
						,OS.Orderstatus AS [Order - status]
						,KS_T.[Cost Code] AS [Taak - kostencode]
						,KS_O.[Cost Code] AS [Order - kostencode]
						,ORD.Inkoopwijze AS [Order - inkoopwijze]
						,ORD.[Datum technisch gereed] AS [Order - datum technisch gereed]
						,TAAK.Inkoopwijze AS [Taak - inkoopwijze]
						,TS.Onderhoudstaakstatus AS [Taak - status]
						,'???' AS [Taak - geplande resource]
						,staedion_dm.algemeen.fn_EmpireLink('Staedion', 11031240, 'No.=' + '''' + VERZ.Onderhoudsverzoek + '''', 'view') AS [Verzoek - Hyperlink]
						,ORD.Weigeringsdatum AS [Order - weigeringsdatum]
						,ORD.Acceptatiedatum AS [Order - acceptatiedatum]
						,WR.Weigeringsreden as [Order - weigeringsreden]
						,ORD.[Aantal bijlagen] AS [Order - aantal bijlagen]
						,TAAK.[Aantal bijlagen] AS [Taak - aantal bijlagen]
						,[Order met of zonder prestatiecontrole] = iif(SJAB.Code LIKE 'PRES%',1,0)
		  --      ,COALESCE(ORD.Leveranciernr, TAAK.Leveranciernr) AS Leveranciernr
		  --      ,TAAK.Omschrijving
		  --      ,AFR.Afrondcode AS [Afrondcode taak]
		FROM staedion_dm.Onderhoud.Onderhoudsverzoek AS VERZ
		LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudsverzoekstatus AS VS
				ON VS.Onderhoudsverzoekstatus_id = VERZ.Onderhoudsverzoekstatus_id
		LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudstaak AS TAAK
				ON TAAK.Onderhoudsverzoek = VERZ.Onderhoudsverzoek
						AND TAAK.[Geldig tot] IS NULL
		LEFT OUTER JOIN staedion_dm.onderhoud.Kostencode AS KS_T
				ON KS_T.Kostencode_id = TAAK.Kostencode_id
		LEFT OUTER JOIN staedion_dm.onderhoud.Onderhoudstaakstatus AS TS
				ON TS.Onderhoudstaakstatus_id = TAAK.Onderhoudstaakstatus_id
		LEFT OUTER JOIN staedion_dm.Onderhoud.Reparatiesjabloon AS SJAB
				ON SJAB.Reparatiesjabloon_id = TAAK.Reparatiesjabloon_id
		LEFT OUTER JOIN staedion_dm.Onderhoud.Onderhoudsorder AS ORD
				ON ORD.Onderhoudsorder = TAAK.Onderhoudsorder
						AND ORD.[Huidig record] = 1
		LEFT OUTER JOIN staedion_dm.onderhoud.Weigeringsreden AS WR
				ON WR.Weigeringsreden_id = ORD.Weigeringsreden_id
		LEFT OUTER JOIN staedion_dm.onderhoud.Orderstatus AS OS
				ON OS.Orderstatus_id = ORD.Orderstatus_id
		LEFT OUTER JOIN staedion_dm.onderhoud.Urgentie AS UR
				ON UR.Urgentie_id = ORD.Urgentie_id
		LEFT OUTER JOIN staedion_dm.onderhoud.Kostencode AS KS_O
				ON KS_O.Kostencode_id = ORD.Kostencode_id
		LEFT OUTER JOIN staedion_dm.onderhoud.Afrondcode AS AFR
				ON AFR.Afrondcode_id = TAAK.Afrondcode_id
		WHERE VERZ.[Huidig record] = 1
		--and VERZ.Onderhoudsverzoek =  'OND00291507-000'
		--AND SJAB.Code LIKE 'PRES%'
       )
SELECT ROW_NUMBER() OVER (
              ORDER BY (
                            SELECT 1
                            )
              ) AS ID
       ,BASIS.Verzoek
       ,BASIS.[Verzoek - omschrijving]
       ,BASIS.[Order]
       ,BASIS.[Taak]
       --,BASIS.[Order - leverancier]
       ,[Order - leverancier] = LAG([Order - leverancier]) OVER (
              ORDER BY BASIS.[Order] ASC
              )
       ,[Eerste order] = FIRST_VALUE(BASIS.[Order]) OVER (
              PARTITION BY BASIS.Verzoek ORDER BY COALESCE(NULLIF(BASIS.[Order], ''), 'Z geen order ?') ROWS UNBOUNDED PRECEDING
              )
       ,[Leverancier eerste order] = FIRST_VALUE([Order - leverancier]) OVER (
              PARTITION BY BASIS.Verzoek ORDER BY COALESCE(NULLIF(BASIS.[Order], ''), 'Z geen order ?') ROWS UNBOUNDED PRECEDING
              )
       ,[Leverancier vorige order] = LAG([Order - leverancier]) OVER (
              ORDER BY BASIS.[Order] ASC
              )
       ,[Order - inkoopwijze] = FIRST_VALUE([Order - inkoopwijze]) OVER (
              PARTITION BY BASIS.Verzoek ORDER BY COALESCE(NULLIF(BASIS.[Order], ''), 'Z geen order ?') ROWS UNBOUNDED PRECEDING
              )
       ,BASIS.Volgnr
       ,BASIS.[Taak - sjablooncode]
       ,[Omschrijving prestatie-controle] = ST.[Description]
       ,BASIS.[Taak - status]
       ,BASIS.[Verzoek - eenheidnr]
       ,[Adres eenheid] = OGE.Straatnaam + ' ' + CAST(OGE.huisnr_ AS NVARCHAR(10)) + ' ' + OGE.toevoegsel
       ,BASIS.[Verzoek - status]
       ,BASIS.[Verzoek - datum invoer]
       ,BASIS.[Order - urgentiecode]
       ,BASIS.[Order - status]
       ,BASIS.[Order - kostencode]
       ,'<a href="' + BASIS.[Verzoek - Hyperlink] + '">' + BASIS.Verzoek + '</a>' AS [Verzoek - Hyperlink]
       ,BASIS.[Order - aanmaakdatum]
       ,BASIS.[Order - weigeringsdatum]
       ,BASIS.[Order - acceptatiedatum]
       ,BASIS.[Order - weigeringsreden]
	     ,BASIS.[Order - aantal bijlagen] AS [Order - bijlagen]
	     ,BASIS.[Taak - aantal bijlagen] AS [Taak - bijlagen]
       ,[Garantieorder aangemaakt J/N] = COALESCE((
                     SELECT MAX(1)
                     FROM cte_basis AS KOPIE
                     WHERE KOPIE.Verzoek = BASIS.Verzoek
                            AND KOPIE.[Taak - sjablooncode] IN (N'PRESCONTROLE_GARANT')
                     ), 0)
       ,[Afwijzing kostenspecificatie J/N] = IIF(BASIS.[Order - weigeringsdatum] <> '17530101', 1, 0)
       ,[Afwijzing kostenspecificatie J/N - obv weigeringsreden] = IIF(nullif(BASIS.[Order - weigeringsreden], 'Onbekend') is not null, 1, 0)
       ,[Prestatie-controle uitgevoerd J/N] = IIF(COALESCE(BASIS.[Taak - status], '') IN (
                     'Afgehandeld'
                     ,'Technisch gereed'
                     )
              AND BASIS.[Taak - sjablooncode] IN (
                      N'PRESCONTROLE_KOSSPEC'
										 ,N'PRESCONTROLE_KOSPEC'
                     ,N'PRESCONTROLE_GR_750'
                     ,N'PRESCONTROLE_KL_750'
                     ,N'PRESCONTROLE_VASTETP'
										 --,N'PRESCONTROLE_GARANT'
										 ), 1, 0)
       ,[Prestatie-controle uitgevoerd door] = IIF(COALESCE(BASIS.[Taak - status], '') IN (
                     'Afgehandeld'
                     ,'Technisch gereed'
                     )
              AND BASIS.[Taak - sjablooncode] IN (
                     N'PRESCONTROLE_KOSSPEC'
										 ,N'PRESCONTROLE_KOSPEC'
                     ,N'PRESCONTROLE_GR_750'
                     ,N'PRESCONTROLE_KL_750'
                     ,N'PRESCONTROLE_VASTETP'
										 --,N'PRESCONTROLE_GARANT'
                     ), BASIS.[Order - aangemaakt door], NULL)					 -- LEFT(CONNECTIT.Resourcelist, 4) + ' (' + RES.[Name] + ')' + substring(CONNECTIT.Resourcelist, 5, len(CONNECTIT.Resourcelist))
       ,[Datum prestatie-controle] = IIF(COALESCE(BASIS.[Taak - status], '') IN (
                     'Afgehandeld'
                     ,'Technisch gereed'
                     )
              AND BASIS.[Taak - sjablooncode] IN (
                     N'PRESCONTROLE_KOSSPEC'
										 ,N'PRESCONTROLE_KOSPEC'
                     ,N'PRESCONTROLE_GR_750'
                     ,N'PRESCONTROLE_KL_750'
                     ,N'PRESCONTROLE_VASTETP'
										 --,N'PRESCONTROLE_GARANT'
                     ), BASIS.[Order - datum technisch gereed], NULL)
FROM cte_basis AS BASIS
JOIN empire_data.dbo.staedion$OGE AS OGE
       ON OGE.Nr_ = BASIS.[Verzoek - eenheidnr]
LEFT OUTER JOIN empire_data.dbo.[Staedion$DM___Repair_Template] AS ST
       ON ST.[Code] = BASIS.[Taak - sjablooncode]
--LEFT OUTER JOIN cte_bijlagen_taak AS BIJL_T
--       ON BIJL_T.Taak = BASIS.[Taak]
--LEFT OUTER JOIN cte_bijlagen_order AS BIJL_O
--       ON BIJL_O.[Order] = BASIS.[Order]
LEFT OUTER JOIN empire_data.dbo.Staedion$Connect_IT_Status AS CONNECTIT
       ON CONNECTIT.MaintenanceOrderNo = BASIS.[Order]
LEFT OUTER JOIN [empire_data].dbo.staedion$Resource AS RES
       ON left(CONNECTIT.Resourcelist, 4) = RES.No_
              --WHERE BASIS.Verzoek = 'OND00251161-000'
              --WHERE BASIS.Verzoek = 'OND00252350-000';
WHERE BASIS.[Order - aanmaakdatum] >= '20220101'

------------------------------------------------------------------------------------------------------------------------- */
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tonen van diverse metrics rondom de prestatiecontrole van onderhoudswerkzaamheden geregistreerd in module Dagelijks Onderhoud in Empire
Zie: PBI rapport Prestatiecontrole
Bron gegevens: datamart staedion_dm.Onderhoud
', 'SCHEMA', N'Onderhoud', 'FUNCTION', N'fn_PrestatieControle', NULL, NULL
GO
