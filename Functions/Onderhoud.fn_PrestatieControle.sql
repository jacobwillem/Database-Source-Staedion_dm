SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [Onderhoud].[fn_PrestatieControle] ()
RETURNS TABLE 
AS
/* ###################################################################################################
BETREFT: Tijdelijke opzet voor tonen van relevante data voor PBI rapport Prestatiecontrole
=> achterliggende datamart staedion_dm.Onderhoud wordt opgesteld

----------------------------------------------------------------------------------------
WIJZIGINGEN  
------------------------------------------------------------------------------------------------------
20211202 JvdW 
------------------------------------------------------------------------------------------------------
CHECKS                   
------------------------------------------------------------------------------------------------------
select * 
from staedion_dm.Onderhoud.fn_PrestatieControle () 
	WHERE [Taak - sjablooncode] IN ( N'PRESCONTROLE_KOSPEC',
                                            N'PRESCONTROLE_GR_750',
                                            N'PRESCONTROLE_KL_750',
                                            N'PRESCONTROLE_VASTETP'          )
--and Verzoek = 'OND00235055-000'  
order by Verzoek, coalesce(nullif([Order],''),'Z')
;


SELECT	top 10 *  
FROM	empire_dwh.dbo.itvf_npo_regels ('Afgerond','20210101','20211231',DEFAULT,DEFAULT) 
WHERE	[Taak - sjablooncode] LIKE '%CONTR%'

------------------------------------------------------------------------------------------------------
TEMP
------------------------------------------------------------------------------------------------------

################################################################################################### */	
RETURN
WITH cte_basis
AS (SELECT Verzoek,
           ROW_NUMBER() OVER (PARTITION BY Verzoek ORDER BY [Taak]) AS Volgnr,
           -- TIJDELIJK: dit gaat fout bij ConnectIT bonnen
           [Taak - sjablooncode],
           [Verzoek - omschrijving],
           [Verzoek - eenheidnr],
           [Verzoek - status],
           [Verzoek - datum invoer],
           [Order],
           [Order - leverancier],
           [Taak],
		   [Order - aanmaakdatum],
           [Order - urgentiecode],
           [Order - status],
           [Taak - kostencode],
           [Order - kostencode],
           [Order - inkoopwijze],
           [Order - datum technisch gereed],
           [Taak - inkoopwijze],
           [Taak - status],
		   [Taak - geplande resource],
           [Verzoek - Hyperlink],
		   [Order - weigeringsdatum],
		   [Order - acceptatiedatum],
		   [Order - weigeringsreden]
    -- select top 10 *
    FROM empire_dwh.dbo.[ITVF_npo_regels]('Aangemaakt', '20200101', '20211231', 1, DEFAULT)
    WHERE [Verzoek] IN ( 'OND00223918-000','OND00235055-000','OND00246617-000','OND00252350-000','OND00236403-000',
                           'OND00230050-000','OND00248354-000','OND00232708-000','OND00227595-000','OND00229526-000',
                           'OND00211876-000','OND00245574-000','OND00139918-000','OND00251161-000'

                           --'OND00249413-000', 'OND00201686-000', 'OND00258701-000', 'OND00215995-000',
                           --'OND00223481-000', 'OND00235055-000', 'OND00246617-000', 'OND00227595-000',
                           --'OND00248354-000', 'OND00233629-000', 'OND00211568-000', 'OND00246857-000',
                           --'OND00233517-000', 'OND00214042-000', 'OND00236403-000', 'OND00211876-000',
                           --'OND00229526-000', 'OND00217423-000', 'OND00217423-000', 'OND00232708-000',
                           --'OND00253761-000', 'OND00252350-000', 'OND00230050-000', 'OND00230050-000',
                           --'OND00256878-000', 'OND00232778-000', 'OND00232708-000'
                       )
-- AND [Taak - standaard taakcode] LIKE 'PRES%'
),
     cte_bijlagen_taak
AS (SELECT NPO_T.No_ AS Taak,
           COUNT(*) AS [Aantal bijlagen]
    FROM EMPIRE.Empire.dbo.[Staedion$DM - Maintenance Task] AS NPO_T
        JOIN EMPIRE.Empire.dbo.[DM - Attachment Set] AS DM_S
            ON DM_S.[SET ID] = NPO_T.[Attachment Set ID]
    WHERE NPO_T.No_ IN
          (
              SELECT Taak FROM cte_basis
          )
    GROUP BY NPO_T.No_),
     cte_bijlagen_order
AS (SELECT NPO_O.No_ AS [Order],
           COUNT(*) AS [Aantal bijlagen]
    FROM EMPIRE.Empire.dbo.[Staedion$DM - Maintenance Order] AS NPO_O
        JOIN EMPIRE.Empire.dbo.[DM - Attachment Set] AS DM_S
            ON DM_S.[SET ID] = NPO_O.[Attachment Set ID]
    WHERE NPO_O.No_ IN
          (
              SELECT [Order] FROM cte_basis
          )
    GROUP BY NPO_O.No_)
SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS ID,
		BASIS.Verzoek,
       BASIS.[Verzoek - omschrijving],
       BASIS.[Order],
       BASIS.[Taak],
       BASIS.[Order - leverancier],
       [Eerste order] = FIRST_VALUE(BASIS.[Order]) OVER (PARTITION BY BASIS.Verzoek
                                                         ORDER BY COALESCE(NULLIF(BASIS.[Order],''),'Z geen order ?')
                                                         ROWS UNBOUNDED PRECEDING
                                                        ),
       [Leverancier eerste order] = FIRST_VALUE([Order - leverancier]) OVER (PARTITION BY BASIS.Verzoek
                                                                             ORDER BY COALESCE(NULLIF(BASIS.[Order],''),'Z geen order ?')
                                                                             ROWS UNBOUNDED PRECEDING
                                                                            ),
       [Leverancier vorige order] = LAG([Order - leverancier]) OVER (ORDER BY BASIS.[Order] asc),
       [Order - inkoopwijze] = FIRST_VALUE([Order - inkoopwijze]) OVER (PARTITION BY BASIS.Verzoek
                                                                        ORDER BY COALESCE(NULLIF(BASIS.[Order],''),'Z geen order ?')
                                                                        ROWS UNBOUNDED PRECEDING
                                                                       ),
       BASIS.Volgnr,
       BASIS.[Taak - sjablooncode],
       [Omschrijving prestatie-controle] = ST.[Description],
       BASIS.[Taak - status],
       BASIS.[Verzoek - eenheidnr],
       [Adres eenheid] = OGE.Straatnaam + ' ' + CAST(OGE.huisnr_ AS NVARCHAR(10)) + ' ' + OGE.toevoegsel,
       BASIS.[Verzoek - status],
       BASIS.[Verzoek - datum invoer],
       BASIS.[Order - urgentiecode],
       BASIS.[Order - status],
       BASIS.[Order - kostencode],
       '<a href="'+ BASIS.[Verzoek - Hyperlink]+'">'+BASIS.Verzoek+'</a>' AS [Verzoek - Hyperlink] ,
	   BASIS.[Order - aanmaakdatum],
		BASIS.[Order - weigeringsdatum],
		BASIS.[Order - acceptatiedatum],
		BASIS.[Order - weigeringsreden],
       [Order - bijlagen] = COALESCE(BIJL_O.[Aantal bijlagen], 0),
       [Taak - bijlagen] = COALESCE(BIJL_T.[Aantal bijlagen], 0),
       [Garantieorder aangemaakt J/N] = COALESCE((SELECT MAX(1) 
												FROM cte_basis AS KOPIE
												WHERE KOPIE.Verzoek = BASIS.Verzoek 
												AND  KOPIE.[Taak - sjablooncode] IN ( N'PRESCONTROLE_GARANT')),0),
       [Afwijzing kostenspecificatie J/N] = IIF(BASIS.[Order - weigeringsdatum] <> '17530101',
                                                   1,
                                                   0),
       [Prestatie-controle uitgevoerd J/N] = IIF(
                                                   COALESCE(BASIS.[Taak - status], '') IN ('Afgehandeld', 'Technisch gereed')
                                                   AND BASIS.[Taak - sjablooncode] IN ( N'PRESCONTROLE_KOSPEC',
                                                                                        N'PRESCONTROLE_GR_750',
                                                                                        N'PRESCONTROLE_KL_750',
                                                                                        N'PRESCONTROLE_VASTETP'
                                                                                      ),
                                                   1,
                                                   0),
		[Prestatie-controle uitgevoerd door] = IIF(
                                                   COALESCE(BASIS.[Taak - status], '') IN ('Afgehandeld', 'Technisch gereed')
                                                   AND BASIS.[Taak - sjablooncode] IN ( N'PRESCONTROLE_KOSPEC',
                                                                                        N'PRESCONTROLE_GR_750',
                                                                                        N'PRESCONTROLE_KL_750',
                                                                                        N'PRESCONTROLE_VASTETP'
                                                                                      ),
                                                   LEFT(CONNECTIT.Resourcelist, 4) + ' (' + RES.[Name] + ')' + substring(CONNECTIT.Resourcelist, 5, len(CONNECTIT.Resourcelist)),
                                                   null),
       [Datum prestatie-controle] =  IIF(
                                                   COALESCE(BASIS.[Taak - status], '') IN ('Afgehandeld', 'Technisch gereed')
                                                   AND BASIS.[Taak - sjablooncode] IN ( N'PRESCONTROLE_KOSPEC',
                                                                                        N'PRESCONTROLE_GR_750',
                                                                                        N'PRESCONTROLE_KL_750',
                                                                                        N'PRESCONTROLE_VASTETP'
                                                                                      ),
                                                   BASIS.[Order - datum technisch gereed],
                                                   null)
FROM cte_basis AS BASIS
    JOIN empire_data.dbo.staedion$OGE AS OGE
        ON OGE.Nr_ = BASIS.[Verzoek - eenheidnr]
    LEFT OUTER JOIN empire_data.dbo.[Staedion$DM___Repair_Template] AS ST  
        ON ST.[Code] = BASIS.[Taak - sjablooncode]
    LEFT OUTER JOIN cte_bijlagen_taak AS BIJL_T
        ON BIJL_T.Taak = BASIS.[Taak]
    LEFT OUTER JOIN cte_bijlagen_order AS BIJL_O
        ON BIJL_O.[Order] = BASIS.[Order]
	LEFT OUTER JOIN empire_data.dbo.Staedion$Connect_IT_Status AS CONNECTIT
				 ON CONNECTIT.MaintenanceOrderNo = BASIS.[Order]
				 LEFT OUTER JOIN  [empire_data].dbo.staedion$Resource AS RES 
				  ON left(CONNECTIT.Resourcelist, 4) = RES.No_

--WHERE BASIS.Verzoek = 'OND00251161-000'
--WHERE BASIS.Verzoek = 'OND00252350-000';


GO
