SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Algemeen].[Datum]
as
  select
    [Datum]                                         = d.datum,
    [Is laatste laaddatum]                          = case
                                                        when d.last_loading_day = 1 then 'Ja'
                                                        when d.last_loading_day = 0 then 'Nee'
                                                        else null
                                                      end,
    [Jaar]                                          = d.jaar,

    [Tertaal code]                                  = d.tertaal,
    [Tertaal]                                       =       convert(varchar(1), d.tertaal_vh_jaar)   + 'e tertaal '   + convert(varchar(4), d.jaar),
    [Tertaal kort]                                  = 'T' + convert(varchar(1), d.tertaal_vh_jaar)   + space(1)       + convert(varchar(4), d.jaar),

    [Tertaal van het jaar]                          =       convert(varchar(1), d.tertaal_vh_jaar)   + 'e tertaal',
    [Tertaal van het jaar kort]                     = 'T' + convert(varchar(1), d.tertaal_vh_jaar),

    [Kwartaal code]                                 = d.kwartaal,
    [Kwartaal]                                      =       convert(varchar(1), d.kwartaal_vh_jaar)  + 'e kwartaal '  + convert(varchar(4), d.jaar),
    [Kwartaal kort]                                 = 'Q' + convert(varchar(1), d.kwartaal_vh_jaar)  + space(1)       + convert(varchar(4), d.jaar),

    [Kwartaal van het jaar]                         =       convert(varchar(1), d.kwartaal_vh_jaar)  + 'e kwartaal',
    [Kwartaal van het jaar kort]                    = 'Q' + convert(varchar(1), d.kwartaal_vh_jaar),

    [Maand code]                                    = d.maand,
    [Maand]                                         = d.maand_vh_jaar_name + space(1) + convert(varchar(4), d.jaar),
    [Maand kort]                                    = d.maand_vh_jaar_name_short + space(1) + convert(varchar(4), d.jaar),

    [Maand van het jaar code]                       = d.maand_vh_jaar,
    [Maand van het jaar]                            = d.maand_vh_jaar_name,
    [Maand van het jaar kort]                       = d.maand_vh_jaar_name_short,

    [Jaar relatief code]                            =      d.jaar_relatief,
    [Jaar relatief sortering aflopend]              = -1 * d.jaar_relatief,
    [Jaar relatief]                                 = case
                                                        when d.jaar_relatief        < -1  then 'Huidig jaar -/- '       + convert(varchar(4), ABS(d.jaar_relatief))
                                                        when d.jaar_relatief        = -1  then 'Vorig jaar'
                                                        when d.jaar_relatief        =  0  then 'Huidig jaar'
                                                        when d.jaar_relatief        =  1  then 'Volgend jaar'
                                                        when d.jaar_relatief        >  1  then 'Huidig jaar + '         + convert(varchar(4), ABS(d.jaar_relatief))
                                                      end,
    [Jaar relatief alternatief]                     = case
                                                        when d.jaar_relatief        < -1  then convert(varchar(4), d.jaar)
                                                        when d.jaar_relatief        = -1  then 'Vorig jaar'
                                                        when d.jaar_relatief        =  0  then 'Huidig jaar'
                                                        when d.jaar_relatief        =  1  then 'Volgend jaar'
                                                        when d.jaar_relatief        >  1  then convert(varchar(4), d.jaar)
                                                      end,

    [Tertaal relatief code]                         =      d.tertaal_relatief,
    [Tertaal relatief sortering aflopend]           = -1 * d.tertaal_relatief,
    [Tertaal relatief]                              = case
                                                        when d.tertaal_relatief     < -1  then 'Huidig tertaal -/- '    + convert(varchar(6), ABS(d.tertaal_relatief))
                                                        when d.tertaal_relatief     = -1  then 'Vorig tertaal'
                                                        when d.tertaal_relatief     =  0  then 'Huidig tertaal'
                                                        when d.tertaal_relatief     =  1  then 'Volgend tertaal'
                                                        when d.tertaal_relatief     >  1  then 'Huidig tertaal + '      + convert(varchar(6), ABS(d.tertaal_relatief))
                                                      end,
    [Tertaal relatief alternatief]                  = case
                                                        when d.tertaal_relatief     < -1  then convert(varchar(1), d.tertaal_vh_jaar)   + 'e tertaal '   + convert(varchar(4), d.jaar)
                                                        when d.tertaal_relatief     = -1  then 'Vorig tertaal'
                                                        when d.tertaal_relatief     =  0  then 'Huidig tertaal'
                                                        when d.tertaal_relatief     =  1  then 'Volgend tertaal'
                                                        when d.tertaal_relatief     >  1  then convert(varchar(1), d.tertaal_vh_jaar)   + 'e tertaal '   + convert(varchar(4), d.jaar)
                                                      end,

    [Kwartaal relatief code]                        =      d.kwartaal_relatief,
    [Kwartaal relatief sortering aflopend]          = -1 * d.kwartaal_relatief,
    [Kwartaal relatief]                             = case
                                                        when d.kwartaal_relatief    < -1  then 'Huidig kwartaal -/- '   + convert(varchar(11), ABS(d.kwartaal_relatief))
                                                        when d.kwartaal_relatief    = -1  then 'Vorig kwartaal'
                                                        when d.kwartaal_relatief    =  0  then 'Huidig kwartaal'
                                                        when d.kwartaal_relatief    =  1  then 'Volgend kwartaal'
                                                        when d.kwartaal_relatief    >  1  then 'Huidig kwartaal + '     + convert(varchar(11), ABS(d.kwartaal_relatief))
                                                      end,
    [Kwartaal relatief alternatief]                 = case
                                                        when d.kwartaal_relatief    < -1  then convert(varchar(1), d.kwartaal_vh_jaar)  + 'e kwartaal '  + convert(varchar(4), d.jaar)
                                                        when d.kwartaal_relatief    = -1  then 'Vorig kwartaal'
                                                        when d.kwartaal_relatief    =  0  then 'Huidig kwartaal'
                                                        when d.kwartaal_relatief    =  1  then 'Volgend kwartaal'
                                                        when d.kwartaal_relatief    >  1  then convert(varchar(1), d.kwartaal_vh_jaar)  + 'e kwartaal '  + convert(varchar(4), d.jaar)
                                                      end,

    [Maand relatief code]                           =      d.maand_relatief,
    [Maand relatief sortering aflopend]             = -1 * d.maand_relatief,
    [Maand relatief]                                = case
                                                        when d.maand_relatief       < -1  then 'Huidige maand -/- '     + convert(varchar(11), ABS(d.maand_relatief))
                                                        when d.maand_relatief       = -1  then 'Vorige maand'
                                                        when d.maand_relatief       =  0  then 'Huidige maand'
                                                        when d.maand_relatief       =  1  then 'Volgende maand'
                                                        when d.maand_relatief       >  1  then 'Huidige maand + '       + convert(varchar(11), ABS(d.maand_relatief))
                                                      end,
    [Maand relatief alternatief]                    = case
                                                        when d.maand_relatief       < -1  then d.maand_vh_jaar_name + space(1) + convert(varchar(4), d.jaar)
                                                        when d.maand_relatief       = -1  then 'Vorige maand'
                                                        when d.maand_relatief       =  0  then 'Huidige maand'
                                                        when d.maand_relatief       =  1  then 'Volgende maand'
                                                        when d.maand_relatief       >  1  then d.maand_vh_jaar_name + space(1) + convert(varchar(4), d.jaar)
                                                      end,

    [Dag relatief code]                             =      d.dag_relatief,
    [Dag relatief sortering aflopend]               = -1 * d.dag_relatief,
    [Dag relatief]                                  = case
                                                        when d.dag_relatief         <  0 then 'Laaddag -/- '            + convert(varchar(11), ABS(d.dag_relatief))
                                                        when d.dag_relatief         =  0 then 'Laaddag'
                                                        when d.dag_relatief         >  0 then 'Laaddag + '              + convert(varchar(11), ABS(d.dag_relatief))
                                                      end,
	[Week van het jaar code]													= d.week_value,
	-- JvdW 20200428 toegevoegd 
	[Toegerekende posten bijgewerkt tot]							= (
																											SELECT max([Posting Date])
																											FROM empire_data.dbo.[Staedion$Allocated_G_L_Entries]
																											) 
  from empire_dwh.dbo.tijd as d
  cross join empire_logic.dbo.dlt_parameters as dp
  where d.datum between dp.date_table_range_start and dp.date_table_range_end


GO
