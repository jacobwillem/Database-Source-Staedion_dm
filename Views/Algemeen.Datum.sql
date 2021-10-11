SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Algemeen].[Datum]
/* ##############################################################################################################
Van Ruben Stolk tbv div PBI-rapportages voor O&V

20211011	JvdW toegevoegd	tbv PBI Leegstand

############################################################################################################## */

AS
  SELECT
    [Datum]                                         = d.datum,
    [Is laatste laaddatum]                          = CASE
                                                        WHEN d.last_loading_day = 1 THEN 'Ja'
                                                        WHEN d.last_loading_day = 0 THEN 'Nee'
                                                        ELSE NULL
                                                      END,
    [Jaar]                                          = d.jaar,

    [Tertaal code]                                  = d.tertaal,
    [Tertaal]                                       =       CONVERT(VARCHAR(1), d.tertaal_vh_jaar)   + 'e tertaal '   + CONVERT(VARCHAR(4), d.jaar),
    [Tertaal kort]                                  = 'T' + CONVERT(VARCHAR(1), d.tertaal_vh_jaar)   + SPACE(1)       + CONVERT(VARCHAR(4), d.jaar),

    [Tertaal van het jaar]                          =       CONVERT(VARCHAR(1), d.tertaal_vh_jaar)   + 'e tertaal',
    [Tertaal van het jaar kort]                     = 'T' + CONVERT(VARCHAR(1), d.tertaal_vh_jaar),

    [Kwartaal code]                                 = d.kwartaal,
    [Kwartaal]                                      =       CONVERT(VARCHAR(1), d.kwartaal_vh_jaar)  + 'e kwartaal '  + CONVERT(VARCHAR(4), d.jaar),
    [Kwartaal kort]                                 = 'Q' + CONVERT(VARCHAR(1), d.kwartaal_vh_jaar)  + SPACE(1)       + CONVERT(VARCHAR(4), d.jaar),

    [Kwartaal van het jaar]                         =       CONVERT(VARCHAR(1), d.kwartaal_vh_jaar)  + 'e kwartaal',
    [Kwartaal van het jaar kort]                    = 'Q' + CONVERT(VARCHAR(1), d.kwartaal_vh_jaar),

    [Maand code]                                    = d.maand,
    [Maand]                                         = d.maand_vh_jaar_name + SPACE(1) + CONVERT(VARCHAR(4), d.jaar),
    [Maand kort]                                    = d.maand_vh_jaar_name_short + SPACE(1) + CONVERT(VARCHAR(4), d.jaar),

    [Maand van het jaar code]                       = d.maand_vh_jaar,
    [Maand van het jaar]                            = d.maand_vh_jaar_name,
    [Maand van het jaar kort]                       = d.maand_vh_jaar_name_short,

    [Jaar relatief code]                            =      d.jaar_relatief,
    [Jaar relatief sortering aflopend]              = -1 * d.jaar_relatief,
    [Jaar relatief]                                 = CASE
                                                        WHEN d.jaar_relatief        < -1  THEN 'Huidig jaar -/- '       + CONVERT(VARCHAR(4), ABS(d.jaar_relatief))
                                                        WHEN d.jaar_relatief        = -1  THEN 'Vorig jaar'
                                                        WHEN d.jaar_relatief        =  0  THEN 'Huidig jaar'
                                                        WHEN d.jaar_relatief        =  1  THEN 'Volgend jaar'
                                                        WHEN d.jaar_relatief        >  1  THEN 'Huidig jaar + '         + CONVERT(VARCHAR(4), ABS(d.jaar_relatief))
                                                      END,
    [Jaar relatief alternatief]                     = CASE
                                                        WHEN d.jaar_relatief        < -1  THEN CONVERT(VARCHAR(4), d.jaar)
                                                        WHEN d.jaar_relatief        = -1  THEN 'Vorig jaar'
                                                        WHEN d.jaar_relatief        =  0  THEN 'Huidig jaar'
                                                        WHEN d.jaar_relatief        =  1  THEN 'Volgend jaar'
                                                        WHEN d.jaar_relatief        >  1  THEN CONVERT(VARCHAR(4), d.jaar)
                                                      END,

    [Tertaal relatief code]                         =      d.tertaal_relatief,
    [Tertaal relatief sortering aflopend]           = -1 * d.tertaal_relatief,
    [Tertaal relatief]                              = CASE
                                                        WHEN d.tertaal_relatief     < -1  THEN 'Huidig tertaal -/- '    + CONVERT(VARCHAR(6), ABS(d.tertaal_relatief))
                                                        WHEN d.tertaal_relatief     = -1  THEN 'Vorig tertaal'
                                                        WHEN d.tertaal_relatief     =  0  THEN 'Huidig tertaal'
                                                        WHEN d.tertaal_relatief     =  1  THEN 'Volgend tertaal'
                                                        WHEN d.tertaal_relatief     >  1  THEN 'Huidig tertaal + '      + CONVERT(VARCHAR(6), ABS(d.tertaal_relatief))
                                                      END,
    [Tertaal relatief alternatief]                  = CASE
                                                        WHEN d.tertaal_relatief     < -1  THEN CONVERT(VARCHAR(1), d.tertaal_vh_jaar)   + 'e tertaal '   + CONVERT(VARCHAR(4), d.jaar)
                                                        WHEN d.tertaal_relatief     = -1  THEN 'Vorig tertaal'
                                                        WHEN d.tertaal_relatief     =  0  THEN 'Huidig tertaal'
                                                        WHEN d.tertaal_relatief     =  1  THEN 'Volgend tertaal'
                                                        WHEN d.tertaal_relatief     >  1  THEN CONVERT(VARCHAR(1), d.tertaal_vh_jaar)   + 'e tertaal '   + CONVERT(VARCHAR(4), d.jaar)
                                                      END,

    [Kwartaal relatief code]                        =      d.kwartaal_relatief,
    [Kwartaal relatief sortering aflopend]          = -1 * d.kwartaal_relatief,
    [Kwartaal relatief]                             = CASE
                                                        WHEN d.kwartaal_relatief    < -1  THEN 'Huidig kwartaal -/- '   + CONVERT(VARCHAR(11), ABS(d.kwartaal_relatief))
                                                        WHEN d.kwartaal_relatief    = -1  THEN 'Vorig kwartaal'
                                                        WHEN d.kwartaal_relatief    =  0  THEN 'Huidig kwartaal'
                                                        WHEN d.kwartaal_relatief    =  1  THEN 'Volgend kwartaal'
                                                        WHEN d.kwartaal_relatief    >  1  THEN 'Huidig kwartaal + '     + CONVERT(VARCHAR(11), ABS(d.kwartaal_relatief))
                                                      END,
    [Kwartaal relatief alternatief]                 = CASE
                                                        WHEN d.kwartaal_relatief    < -1  THEN CONVERT(VARCHAR(1), d.kwartaal_vh_jaar)  + 'e kwartaal '  + CONVERT(VARCHAR(4), d.jaar)
                                                        WHEN d.kwartaal_relatief    = -1  THEN 'Vorig kwartaal'
                                                        WHEN d.kwartaal_relatief    =  0  THEN 'Huidig kwartaal'
                                                        WHEN d.kwartaal_relatief    =  1  THEN 'Volgend kwartaal'
                                                        WHEN d.kwartaal_relatief    >  1  THEN CONVERT(VARCHAR(1), d.kwartaal_vh_jaar)  + 'e kwartaal '  + CONVERT(VARCHAR(4), d.jaar)
                                                      END,

    [Maand relatief code]                           =      d.maand_relatief,
    [Maand relatief sortering aflopend]             = -1 * d.maand_relatief,
    [Maand relatief]                                = CASE
                                                        WHEN d.maand_relatief       < -1  THEN 'Huidige maand -/- '     + CONVERT(VARCHAR(11), ABS(d.maand_relatief))
                                                        WHEN d.maand_relatief       = -1  THEN 'Vorige maand'
                                                        WHEN d.maand_relatief       =  0  THEN 'Huidige maand'
                                                        WHEN d.maand_relatief       =  1  THEN 'Volgende maand'
                                                        WHEN d.maand_relatief       >  1  THEN 'Huidige maand + '       + CONVERT(VARCHAR(11), ABS(d.maand_relatief))
                                                      END,
    [Maand relatief alternatief]                    = CASE
                                                        WHEN d.maand_relatief       < -1  THEN d.maand_vh_jaar_name + SPACE(1) + CONVERT(VARCHAR(4), d.jaar)
                                                        WHEN d.maand_relatief       = -1  THEN 'Vorige maand'
                                                        WHEN d.maand_relatief       =  0  THEN 'Huidige maand'
                                                        WHEN d.maand_relatief       =  1  THEN 'Volgende maand'
                                                        WHEN d.maand_relatief       >  1  THEN d.maand_vh_jaar_name + SPACE(1) + CONVERT(VARCHAR(4), d.jaar)
                                                      END,

    [Dag relatief code]                             =      d.dag_relatief,
    [Dag relatief sortering aflopend]               = -1 * d.dag_relatief,
    [Dag relatief]                                  = CASE
                                                        WHEN d.dag_relatief         <  0 THEN 'Laaddag -/- '            + CONVERT(VARCHAR(11), ABS(d.dag_relatief))
                                                        WHEN d.dag_relatief         =  0 THEN 'Laaddag'
                                                        WHEN d.dag_relatief         >  0 THEN 'Laaddag + '              + CONVERT(VARCHAR(11), ABS(d.dag_relatief))
                                                      END,
	[Week van het jaar code]													= d.week_value,
	-- JvdW 20200428 toegevoegd 
	[Toegerekende posten bijgewerkt tot]							= (
																											SELECT MAX([Posting Date])
																											FROM empire_data.dbo.[Staedion$Allocated_G_L_Entries]
																											),
	-- 20211011 JvdW toegevoegd	
    FilterHuidigeDagofLaatsteDagMaand = CASE 
              WHEN (
                            d.last_loading_day = 1
                            OR 
							(d.datum = EOMONTH(DATEFROMPARTS(YEAR(d.datum), MONTH(d.datum), 1))
                             AND d.datum <= EOMONTH(DATEADD(MONTH,-1,GETDATE()))
							 -- eomonth(getdate()): om verwarring te voorkomen niet einde huidige maand nemen
							 )
					)
                     THEN 'Ja'
              ELSE 'Nee'
              END,
    [Peildatum rapportage] = CASE WHEN d.last_loading_day = 1 THEN 'Laaddatum'
			  ELSE CASE WHEN d.datum = EOMONTH(DATEFROMPARTS(YEAR(d.datum), MONTH(d.datum), 1))
                             AND d.datum <= EOMONTH(DATEADD(MONTH,-1,GETDATE()))
							THEN CONVERT(NVARCHAR(20),d.datum, 105)
              ELSE 'Nvt' END END																											
  FROM empire_dwh.dbo.tijd AS d
  CROSS JOIN empire_logic.dbo.dlt_parameters AS dp
  WHERE d.datum BETWEEN dp.date_table_range_start AND dp.date_table_range_end


GO
